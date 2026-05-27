@@warning("-45")
/* See ReconEngineOverviewRulePerformance.res for the same suppression rationale —
   field labels like account_id are unambiguous via pattern-matched variants,
   even though both ReconEngineTypes and ReconEngineRulesTypes expose them. */

open ReconEngineRulesTypes

/* ============================== Plain-English strategy ==============================
   Backend variant names ("OneToOne(SingleSingle)") mean nothing to a merchant.
   The summary is a single sentence; the caption keeps the raw discriminator visible
   for the support / debugging case. */

let plainStrategySummary = (strategy: reconStrategyType): string =>
  switch strategy {
  | OneToOne(SingleSingle(_)) => "Match one source row to one target row"
  | OneToOne(SingleMany(_)) => "Match one source row to many target rows"
  | OneToOne(ManySingle(_)) => "Group source rows, then match to one target row"
  | OneToOne(ManyMany(_)) => "Group source rows, then match to many target rows"
  | OneToMany(SingleSingle(_)) => "Split one source row across multiple target accounts"
  | OneToOne(UnknownOneToOneStrategy)
  | OneToMany(UnknownOneToManyStrategy)
  | UnknownReconStrategy => "Strategy not recognised"
  }

/* Short summary tuned for table-cell width. */
let plainStrategyShortSummary = (strategy: reconStrategyType): string =>
  switch strategy {
  | OneToOne(SingleSingle(_)) => "One-to-one"
  | OneToOne(SingleMany(_)) => "One source → many targets"
  | OneToOne(ManySingle(_)) => "Grouped → one target"
  | OneToOne(ManyMany(_)) => "Grouped → many targets"
  | OneToMany(SingleSingle(_)) => "Split across targets"
  | OneToOne(UnknownOneToOneStrategy)
  | OneToMany(UnknownOneToManyStrategy)
  | UnknownReconStrategy => "Unknown"
  }

let strategyBackendCaption = (strategy: reconStrategyType): string =>
  switch strategy {
  | OneToOne(SingleSingle(_)) => "one_to_one · single_single"
  | OneToOne(SingleMany(_)) => "one_to_one · single_many"
  | OneToOne(ManySingle(_)) => "one_to_one · many_single"
  | OneToOne(ManyMany(_)) => "one_to_one · many_many"
  | OneToMany(SingleSingle(_)) => "one_to_many · single_single"
  | OneToOne(UnknownOneToOneStrategy)
  | OneToMany(UnknownOneToManyStrategy)
  | UnknownReconStrategy => "unknown"
  }

let strategyHigherKind = (strategy: reconStrategyType): string =>
  switch strategy {
  | OneToOne(_) => "one_to_one"
  | OneToMany(_) => "one_to_many"
  | UnknownReconStrategy => "unknown"
  }

let strategySubKind = (strategy: reconStrategyType): string =>
  switch strategy {
  | OneToOne(SingleSingle(_)) | OneToMany(SingleSingle(_)) => "single_single"
  | OneToOne(SingleMany(_)) => "single_many"
  | OneToOne(ManySingle(_)) => "many_single"
  | OneToOne(ManyMany(_)) => "many_many"
  | OneToOne(UnknownOneToOneStrategy)
  | OneToMany(UnknownOneToManyStrategy)
  | UnknownReconStrategy => "unknown"
  }

/* ============================== Source / Target helpers ============================== */

let getSourceAccountId = (strategy: reconStrategyType): string =>
  switch strategy {
  | OneToOne(SingleSingle(d)) => d.source_account.account_id
  | OneToOne(SingleMany(d)) => d.source_account.account_id
  | OneToOne(ManySingle(d)) => d.source_account.account_id
  | OneToOne(ManyMany(d)) => d.source_account.account_id
  | OneToMany(SingleSingle(d)) => d.source_account.account_id
  | _ => ""
  }

/* Returns target account IDs with split info if present (OneToMany only). */
type targetSpec = {
  account_id: string,
  split_type: option<string> /* "percentage" | "fixed" */,
  split_value: option<float>,
}

let getTargetSpecs = (strategy: reconStrategyType): array<targetSpec> =>
  switch strategy {
  | OneToOne(SingleSingle(d)) => [
      {account_id: d.target_account.account_id, split_type: None, split_value: None},
    ]
  | OneToOne(SingleMany(d)) => [
      {account_id: d.target_account.account_id, split_type: None, split_value: None},
    ]
  | OneToOne(ManySingle(d)) => [
      {account_id: d.target_account.account_id, split_type: None, split_value: None},
    ]
  | OneToOne(ManyMany(d)) => [
      {account_id: d.target_account.account_id, split_type: None, split_value: None},
    ]
  | OneToMany(SingleSingle(d)) =>
    switch d.target_accounts {
    | Percentage({targets}) =>
      targets->Array.map(((t, sv)) => {
        account_id: t.account_id,
        split_type: Some("percentage"),
        split_value: Some(sv.value),
      })
    | Fixed({targets}) =>
      targets->Array.map(((t, sv)) => {
        account_id: t.account_id,
        split_type: Some("fixed"),
        split_value: Some(sv.value),
      })
    | UnknownTargetsType => []
    }
  | _ => []
  }

let splitChipLabel = (spec: targetSpec): string =>
  switch (spec.split_type, spec.split_value) {
  | (Some("percentage"), Some(v)) => `${v->Float.toString}%`
  | (Some("fixed"), Some(v)) => `${v->Float.toString} (fixed)`
  | _ => ""
  }

/* Pull the search_identifier and match_rules per target. For 1:1 strategies
 the search/match are shared; for 1:many they sit on each target. */
type searchSpec = {
  source_field: string,
  target_field: string,
  version: string,
}

type matchSpec = {
  source_field: string,
  target_field: string,
  operator: string,
}

type targetExpansion = {
  spec: targetSpec,
  search_identifier: option<searchSpec>,
  match_version: string,
  match_rules: array<matchSpec>,
}

let getTargetExpansions = (strategy: reconStrategyType): array<targetExpansion> => {
  let liftMatch = (rules: array<matchRuleType>): array<matchSpec> =>
    rules->Array.map(r => {
      source_field: r.source_field,
      target_field: r.target_field,
      operator: r.operator,
    })

  switch strategy {
  | OneToOne(SingleSingle(d)) => [
      {
        spec: {account_id: d.target_account.account_id, split_type: None, split_value: None},
        search_identifier: Some({
          source_field: d.search_identifier.source_field,
          target_field: d.search_identifier.target_field,
          version: d.search_identifier.search_version,
        }),
        match_version: d.match_rules.match_version,
        match_rules: liftMatch(d.match_rules.rules),
      },
    ]
  | OneToOne(SingleMany(d)) => [
      {
        spec: {account_id: d.target_account.account_id, split_type: None, split_value: None},
        search_identifier: Some({
          source_field: d.search_identifier.source_field,
          target_field: d.search_identifier.target_field,
          version: d.search_identifier.search_version,
        }),
        match_version: d.match_rules.match_version,
        match_rules: liftMatch(d.match_rules.rules),
      },
    ]
  | OneToOne(ManySingle(d)) => [
      {
        spec: {account_id: d.target_account.account_id, split_type: None, split_value: None},
        search_identifier: Some({
          source_field: d.search_identifier.source_field,
          target_field: d.search_identifier.target_field,
          version: d.search_identifier.search_version,
        }),
        match_version: d.match_rules.match_version,
        match_rules: liftMatch(d.match_rules.rules),
      },
    ]
  | OneToOne(ManyMany(d)) => [
      {
        spec: {account_id: d.target_account.account_id, split_type: None, split_value: None},
        search_identifier: Some({
          source_field: d.search_identifier.source_field,
          target_field: d.search_identifier.target_field,
          version: d.search_identifier.search_version,
        }),
        match_version: d.match_rules.match_version,
        match_rules: liftMatch(d.match_rules.rules),
      },
    ]
  | OneToMany(SingleSingle(d)) => {
      let mkExpansion = (
        t: oneToManySingleSingleTargetType,
        sv: option<splitValueType>,
        split_type,
      ) => {
        spec: {
          account_id: t.account_id,
          split_type,
          split_value: sv->Option.map(s => s.value),
        },
        search_identifier: Some({
          source_field: t.search_identifier.source_field,
          target_field: t.search_identifier.target_field,
          version: t.search_identifier.search_version,
        }),
        match_version: t.match_rules.match_version,
        match_rules: liftMatch(t.match_rules.rules),
      }
      switch d.target_accounts {
      | Percentage({targets}) =>
        targets->Array.map(((t, sv)) => mkExpansion(t, Some(sv), Some("percentage")))
      | Fixed({targets}) => targets->Array.map(((t, sv)) => mkExpansion(t, Some(sv), Some("fixed")))
      | UnknownTargetsType => []
      }
    }
  | _ => []
  }
}

/* ============================== Trigger helpers ============================== */

let getTrigger = (strategy: reconStrategyType): option<triggerType> =>
  switch strategy {
  | OneToOne(SingleSingle(d)) => Some(d.source_account.trigger)
  | OneToOne(SingleMany(d)) => Some(d.source_account.trigger)
  | OneToOne(ManySingle(d)) => Some(d.source_account.trigger)
  | OneToOne(ManyMany(d)) => Some(d.source_account.trigger)
  | OneToMany(SingleSingle(d)) => Some(d.source_account.trigger)
  | _ => None
  }

let triggerVersionLabel = (trigger: triggerType): string =>
  switch trigger {
  | V1(_) => "v1"
  | V2(_) => "v2"
  | UnknownTrigger => "unknown"
  }

let triggerLogicLabel = (trigger: triggerType): string =>
  switch trigger {
  | V1(_) => "All"
  | V2({logic: All}) => "All"
  | V2({logic: Any}) => "Any"
  | V2({logic: UnknownTriggerLogic}) | UnknownTrigger => "Unknown"
  }

let triggerLogicSentence = (trigger: triggerType, conditionCount: int): string =>
  switch (trigger, conditionCount) {
  | (V1(_), _) => "Match a row only when this condition holds"
  | (V2({logic: All}), 0) => "No filter — every row qualifies"
  | (V2({logic: All}), 1) => "Match only when this condition holds"
  | (V2({logic: All}), _) => "Match only when ALL conditions hold"
  | (V2({logic: Any}), _) => "Match when ANY condition holds"
  | _ => ""
  }

let triggerConditions = (trigger: triggerType): array<triggerConditionType> =>
  switch trigger {
  | V1(c) => [c]
  | V2({conditions}) => conditions
  | UnknownTrigger => []
  }

let getGroupingField = (strategy: reconStrategyType): option<string> =>
  switch strategy {
  | OneToOne(ManySingle(d)) =>
    d.source_account.grouping_field === "" ? None : Some(d.source_account.grouping_field)
  | OneToOne(ManyMany(d)) =>
    d.source_account.grouping_field === "" ? None : Some(d.source_account.grouping_field)
  | _ => None
  }

/* ============================== Operator symbol ============================== */

let operatorSymbol = (op: string): string =>
  switch op->String.toLowerCase {
  | "equals" | "=" | "eq" => "="
  | "not_equals" | "!=" | "ne" => "≠"
  | "greater_than" | ">" | "gt" => ">"
  | "less_than" | "<" | "lt" => "<"
  | "greater_than_or_equal" | ">=" | "gte" => "≥"
  | "less_than_or_equal" | "<=" | "lte" => "≤"
  | s => s
  }

let operatorPlainName = (op: string): string =>
  switch op->String.toLowerCase {
  | "equals" => "equals"
  | "not_equals" => "does not equal"
  | s => s
  }

/* ============================== Aging ============================== */

let agingShort = (cfg: agingConfigType): string =>
  switch cfg {
  | NoAging => "No aging"
  | WithThreshold(t) => {
      let unit = t.threshold_type->LogicUtils.snakeToTitle->String.toLowerCase
      `${t.value->Int.toString} ${unit}`
    }
  | UnknownAgingConfigType => "Unknown"
  }

let agingTypeBackend = (cfg: agingConfigType): string =>
  switch cfg {
  | NoAging => "no_aging"
  | WithThreshold(_) => "with_threshold"
  | UnknownAgingConfigType => "unknown"
  }

let agingThresholdTypeBackend = (cfg: agingConfigType): string =>
  switch cfg {
  | WithThreshold(t) => t.threshold_type
  | _ => ""
  }

/* ============================== Field display name ============================== */

let displayField = (raw: string): string => {
  let label = if raw->String.startsWith("metadata.") {
    raw->String.sliceToEnd(~start=9)
  } else {
    raw
  }
  label->LogicUtils.getTitle
}

let isMetadataField = (raw: string): bool => raw->String.startsWith("metadata.")

/* ============================== Account name lookup ============================== */

let accountName = (accounts: array<ReconEngineTypes.accountType>, accountId: string): string =>
  accounts
  ->Array.find(a => a.account_id === accountId)
  ->Option.map(a => a.account_name)
  ->Option.getOr("—")

let accountCurrency = (accounts: array<ReconEngineTypes.accountType>, accountId: string): string =>
  accounts
  ->Array.find(a => a.account_id === accountId)
  ->Option.map(a => a.currency)
  ->Option.getOr("")

/* ============================== Date formatting ============================== */

let absoluteDate = (timestamp: string): string => {
  if timestamp === "" {
    "—"
  } else {
    let date = Js.Date.fromString(timestamp)
    let months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ]
    let m = months->Array.get(date->Js.Date.getMonth->Float.toInt)->Option.getOr("")
    let d = date->Js.Date.getDate->Float.toInt->Int.toString
    let y = date->Js.Date.getFullYear->Float.toInt->Int.toString
    `${m} ${d}, ${y}`
  }
}

let relativeDate = (timestamp: string): string => {
  if timestamp === "" {
    "—"
  } else {
    let date = Js.Date.fromString(timestamp)
    let now = Js.Date.now()
    let diffMs = now -. date->Js.Date.getTime
    let diffDay = diffMs /. (1000.0 *. 60.0 *. 60.0 *. 24.0)
    if diffDay < 1.0 {
      "today"
    } else if diffDay < 2.0 {
      "yesterday"
    } else if diffDay < 30.0 {
      `${diffDay->Float.toInt->Int.toString} days ago`
    } else if diffDay < 365.0 {
      `${(diffDay /. 30.0)->Float.toInt->Int.toString} months ago`
    } else {
      `${(diffDay /. 365.0)->Float.toInt->Int.toString} years ago`
    }
  }
}

/* ============================== Live performance (per-rule) ============================== */

type rulePerformance = {
  matched: int,
  mismatched: int,
  awaiting: int,
  rate: option<float>,
}

let computePerformance = (
  transactions: array<ReconEngineTypes.transactionType>,
  ruleId: string,
): rulePerformance => {
  open ReconEngineTypes
  let ruleTxns = transactions->Array.filter(t => t.rule.rule_id === ruleId)
  let (m, ms, aw) = ruleTxns->Array.reduce((0, 0, 0), ((m, ms, aw), t) =>
    switch t.transaction_status {
    | Posted(_) | Matched(_) => (m + 1, ms, aw)
    | OverAmount(Mismatch) | UnderAmount(Mismatch) | DataMismatch => (m, ms + 1, aw)
    | Expected
    | OverAmount(Expected)
    | UnderAmount(Expected)
    | Missing
    | PartiallyReconciled => (m, ms, aw + 1)
    | _ => (m, ms, aw)
    }
  )
  let total = m + ms + aw
  {
    matched: m,
    mismatched: ms,
    awaiting: aw,
    rate: total === 0 ? None : Some(m->Int.toFloat *. 100.0 /. total->Int.toFloat),
  }
}

let formatPct = (p: float): string => {
  let rounded = (p *. 10.0)->Float.toInt->Int.toFloat /. 10.0
  rounded >= 100.0 ? "100%" : `${rounded->Float.toString}%`
}
