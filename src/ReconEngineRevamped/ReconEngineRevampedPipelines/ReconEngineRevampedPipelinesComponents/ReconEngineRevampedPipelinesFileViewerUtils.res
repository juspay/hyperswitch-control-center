open LogicUtils
open ReconEngineTypes

type severity =
  | Transformed
  | ErrorLine
  | Skipped
  | Header
  | Blank

type lineStatus = {
  severity: severity,
  label: string,
  detail: option<string>,
}

type fileStatus = {
  lineMap: Map.t<int, lineStatus>,
  unlinkedErrors: array<string>,
  transformedCount: int,
  errorCount: int,
  skippedCount: int,
}

// Parse a backend error string of the form "Line 42: some message".
// Returns Some(lineNumber, message) when it matches, None otherwise
// (e.g. "Validation error: ..." has no line number).
let parseLineError = (err: string): option<(int, string)> => {
  if err->String.startsWith("Line ") {
    switch err->String.indexOf(":") {
    | -1 => None
    | idx =>
      let numPart = err->String.substring(~start=5, ~end=idx)->String.trim
      let msg = err->String.sliceToEnd(~start=idx + 1)->String.trim
      switch Int.fromString(numPart) {
      | Some(n) if n > 0 => Some((n, msg))
      | _ => None
      }
    }
  } else {
    None
  }
}

// Read explicit row_skip / line_no skip rules from a transformation config.
// Shape: config.skip_configs[].conditions[] where a line skip is
// {skip_type: "row_skip", row_skip_type: "line_no", line_number: N}.
let getSkipLineNumbers = (config: JSON.t): array<int> => {
  let result = []
  let cfgDict = config->getDictFromJsonObject
  let skipConfigs = cfgDict->getArrayFromDict("skip_configs", [])
  skipConfigs->Array.forEach(sc => {
    let conditions = sc->getDictFromJsonObject->getArrayFromDict("conditions", [])
    conditions->Array.forEach(cond => {
      let d = cond->getDictFromJsonObject
      if (
        d->getString("skip_type", "") == "row_skip" &&
          d->getString("row_skip_type", "") == "line_no"
      ) {
        let ln = d->getInt("line_number", -1)
        if ln > 0 {
          result->Array.push(ln)->ignore
        }
      }
    })
  })
  result
}

let operatorSymbol = (op: string): string =>
  switch op {
  | "not_equals" => "≠"
  | "equals" => "="
  | other => other
  }

// Render skip/error reasons as a small markdown bullet list for the hover card.
let formatReasons = (reasons: array<lineSkipReasonType>): string =>
  reasons
  ->Array.map(r => `- \`${r.identifier}\` ${operatorSymbol(r.operator)} \`${r.value}\``)
  ->Array.joinWith("\n")

let severityOfStatus = (status: string): severity =>
  switch status {
  | "transformed" => Transformed
  | "skipped" => Skipped
  | "error" => ErrorLine
  | "header" => Header
  | _ => Transformed
  }

let labelOfStatus = (status: string): string =>
  switch status {
  | "transformed" => "Transformed"
  | "skipped" => "Skipped"
  | "error" => "Error"
  | "header" => "Header"
  | other => other
  }

// Markdown shown on hover for a precise line outcome.
let detailOfOutcome = (o: lineOutcomeType): option<string> => {
  let reasons = formatReasons(o.reasons)
  switch o.status {
  | "skipped" => Some(reasons == "" ? "**Skipped**" : `**Skipped**\n\n${reasons}`)
  | "error" => Some(reasons == "" ? "**Error**" : `**Error**\n\n${reasons}`)
  | "header" => Some("**Header**")
  | "transformed" =>
    switch o.staging_entry_id {
    | Some(id) => Some(`**Transformed**\n\nStaging entry: \`${id}\``)
    | None => Some("**Transformed**")
    }
  | _ => None
  }
}

let buildFileStatus = (
  ~rawLines: array<string>,
  ~transformation: transformationHistoryType,
  ~config: JSON.t,
): fileStatus => {
  let lineMap: Map.t<int, lineStatus> = Map.make()
  let unlinkedErrors = []
  let outcomes = transformation.data.line_outcomes
  let hasOutcomes = outcomes->Array.length > 0

  // 1. Errors from the errors array (parse failures); these win over outcomes.
  transformation.data.errors->Array.forEach(err => {
    switch parseLineError(err) {
    | Some((n, msg)) =>
      lineMap->Map.set(
        n,
        {severity: ErrorLine, label: "Error", detail: Some(`**Error**\n\n${msg}`)},
      )
    | None => unlinkedErrors->Array.push(err)->ignore
    }
  })

  // 2. Precise per-line outcomes when available; else fall back to the
  //    line-number skip rules from the transformation config.
  if hasOutcomes {
    outcomes->Array.forEach(o =>
      switch lineMap->Map.get(o.line_number) {
      | Some({severity: ErrorLine}) => () // an explicit error wins
      | _ =>
        lineMap->Map.set(
          o.line_number,
          {
            severity: severityOfStatus(o.status),
            label: labelOfStatus(o.status),
            detail: detailOfOutcome(o),
          },
        )
      }
    )
  } else {
    getSkipLineNumbers(config)->Array.forEach(n =>
      switch lineMap->Map.get(n) {
      | Some({severity: ErrorLine}) => ()
      | _ =>
        lineMap->Map.set(
          n,
          {severity: Skipped, label: "Skipped", detail: Some("**Skipped** by line-number rule")},
        )
      }
    )
  }

  // 3. Blanks, plus heuristic header/transformed defaults ONLY when there are no
  //    outcomes. With outcomes, header lines come from the outcomes themselves
  //    (status "header") and any uncovered line stays neutral.
  let total = rawLines->Array.length
  for i in 1 to total {
    switch lineMap->Map.get(i) {
    | Some(_) => ()
    | None =>
      let line = rawLines->Array.get(i - 1)->Option.getOr("")
      if line->String.trim == "" {
        lineMap->Map.set(i, {severity: Blank, label: "", detail: None})
      } else if !hasOutcomes && i == 1 {
        lineMap->Map.set(i, {severity: Header, label: "Header", detail: None})
      } else if !hasOutcomes {
        lineMap->Map.set(i, {severity: Transformed, label: "Transformed", detail: None})
      } else {
        lineMap->Map.set(i, {severity: Blank, label: "", detail: None})
      }
    }
  }

  // 4. Counts (by final severity, distinct per line)
  let transformedCount = ref(0)
  let errorCount = ref(0)
  let skippedCount = ref(0)
  for i in 1 to total {
    switch lineMap->Map.get(i) {
    | Some({severity: ErrorLine}) => errorCount := errorCount.contents + 1
    | Some({severity: Skipped}) => skippedCount := skippedCount.contents + 1
    | Some({severity: Transformed}) => transformedCount := transformedCount.contents + 1
    | _ => ()
    }
  }

  {
    lineMap,
    unlinkedErrors,
    transformedCount: transformedCount.contents,
    errorCount: errorCount.contents,
    skippedCount: skippedCount.contents,
  }
}
