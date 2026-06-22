open Typography
open LogicUtils
open ReconEngineTypes

let getRelativeTime = (isoString: string) => {
  let now = Js.Date.now()
  let then_ = Js.Date.fromString(isoString)->Js.Date.getTime
  let diffMs = now -. then_
  let diffMins = (diffMs /. 60000.0)->Float.toInt
  let diffHours = diffMins / 60
  let diffDays = diffHours / 24
  if diffDays > 0 {
    `${diffDays->Int.toString} day${diffDays == 1 ? "" : "s"} ago`
  } else if diffHours > 0 {
    `${diffHours->Int.toString} hour${diffHours == 1 ? "" : "s"} ago`
  } else if diffMins > 0 {
    `${diffMins->Int.toString} min${diffMins == 1 ? "" : "s"} ago`
  } else {
    "just now"
  }
}

let getDurationStr = (createdAt: string, processedAt: string): string => {
  if !(processedAt->isNonEmptyString) {
    ""
  } else {
    let t1 = Js.Date.fromString(createdAt)->Js.Date.getTime
    let t2 = Js.Date.fromString(processedAt)->Js.Date.getTime
    let secs = ((t2 -. t1) /. 1000.0)->Float.toInt
    secs > 0 ? `${secs->Int.toString}s` : ""
  }
}

let formatDateTime = (isoStr: string): string => {
  let d = Js.Date.fromString(isoStr)
  let month = switch d->Js.Date.getMonth->Float.toInt {
  | 0 => "Jan"
  | 1 => "Feb"
  | 2 => "Mar"
  | 3 => "Apr"
  | 4 => "May"
  | 5 => "Jun"
  | 6 => "Jul"
  | 7 => "Aug"
  | 8 => "Sep"
  | 9 => "Oct"
  | 10 => "Nov"
  | _ => "Dec"
  }
  let day = d->Js.Date.getDate->Float.toInt->Int.toString
  let year = d->Js.Date.getFullYear->Float.toInt->Int.toString
  let hours = d->Js.Date.getHours->Float.toInt->Int.toString
  let mins = d->Js.Date.getMinutes->Float.toInt
  let minsStr = mins < 10 ? `0${mins->Int.toString}` : mins->Int.toString
  `${month} ${day}, ${year} · ${hours}:${minsStr}`
}

type stgColType =
  | StgType
  | StgId
  | StgMode
  | StgStatus
  | StgReview
  | StgAmount
  | StgEffective

let defaultStgCols: array<stgColType> = [
  StgType,
  StgId,
  StgMode,
  StgStatus,
  StgReview,
  StgAmount,
  StgEffective,
]

let getStgHeading = (colType: stgColType) => {
  switch colType {
  | StgType => Table.makeHeaderInfo(~key="entry_type", ~title="Type")
  | StgId => Table.makeHeaderInfo(~key="staging_entry_id", ~title="Staging ID")
  | StgMode => Table.makeHeaderInfo(~key="processing_mode", ~title="Mode")
  | StgStatus => Table.makeHeaderInfo(~key="status", ~title="Status")
  | StgReview => Table.makeHeaderInfo(~key="review", ~title="Review")
  | StgAmount => Table.makeHeaderInfo(~key="amount", ~title="Amount")
  | StgEffective => Table.makeHeaderInfo(~key="effective_at", ~title="Effective")
  }
}

let getStgCell = (entry: processingEntryType, colType: stgColType): Table.cell => {
  switch colType {
  | StgType =>
    Table.Label({
      title: entry.entry_type->String.toUpperCase,
      color: switch entry.entry_type->String.toLowerCase {
      | "credit" => LabelGreen
      | "debit" => LabelBlue
      | _ => LabelGray
      },
    })
  | StgId =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customParentClass="flex flex-row items-center gap-1.5"
        customTextCss="truncate whitespace-nowrap max-w-[160px] font-mono text-xs text-nd_gray-700"
        displayValue=Some(entry.staging_entry_id)
      />,
      entry.staging_entry_id,
    )
  | StgMode =>
    CustomCell(
      <span
        className={`${body.xs.semibold} px-2 py-0.5 border border-nd_blue-300 text-nd_blue-600 rounded-full bg-nd_blue-50 whitespace-nowrap`}>
        {entry.processing_mode->React.string}
      </span>,
      entry.processing_mode,
    )
  | StgStatus =>
    Table.Label({
      title: switch entry.status {
      | Processed => "Processed"
      | NeedsManualReview => "Needs review"
      | Pending => "Pending"
      | Archived => "Archived"
      | Void => "Void"
      | UnknownProcessingEntryStatus => "Unknown"
      },
      color: switch entry.status {
      | Processed => LabelGreen
      | NeedsManualReview => LabelOrange
      | Pending => LabelBlue
      | _ => LabelGray
      },
    })
  | StgReview =>
    switch entry.status {
    | NeedsManualReview => Text((entry.data.needs_manual_review_type :> string)->snakeToTitle)
    | _ => Text("—")
    }
  | StgAmount =>
    CustomCell(
      <span className={`${body.sm.medium} text-nd_gray-700 whitespace-nowrap`}>
        {`${entry.currency} ${entry.amount->Float.toFixedWithPrecision(~digits=2)}`->React.string}
      </span>,
      entry.amount->Float.toString,
    )
  | StgEffective =>
    CustomCell(
      <span className={`${body.sm.regular} text-nd_gray-500 whitespace-nowrap`}>
        {getRelativeTime(entry.effective_at)->React.string}
      </span>,
      entry.effective_at,
    )
  }
}

let stagingTableEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=_ => [],
  ~defaultColumns=defaultStgCols,
  ~getHeading=getStgHeading,
  ~getCell=getStgCell,
  ~dataKey="",
)

module StatCard = {
  @react.component
  let make = (
    ~label: string,
    ~value: int,
    ~desc: string,
    ~descColor: string="text-nd_gray-400",
  ) => {
    <div className="flex flex-col p-4 flex-1 min-w-0">
      <p className={`${body.xs.semibold} uppercase tracking-wide text-nd_gray-400 mb-1`}>
        {label->React.string}
      </p>
      <div className={`${heading.lg.semibold} text-nd_gray-800 mb-0.5`}>
        <ReconEngineRevampedHelper.NumberCell value />
      </div>
      <RenderIf condition={desc->isNonEmptyString}>
        <p className={`${body.xs.regular} ${descColor}`}> {desc->React.string} </p>
      </RenderIf>
    </div>
  }
}

module TransformationCard = {
  @react.component
  let make = (~tx: transformationHistoryType, ~onOpen: unit => unit) => {
    let cleaned = tx.data.transformed_count
    let total = tx.data.total_count
    let ignored = tx.data.ignored_count
    let dur = getDurationStr(tx.created_at, tx.processed_at)
    let errorCount = tx.data.errors->Array.length

    <div className="border border-nd_gray-150 rounded-xl overflow-hidden">
      <div
        className="flex items-center justify-between px-5 py-4 bg-white cursor-pointer hover:bg-nd_gray-50 transition-colors"
        onClick={_ => onOpen()}>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 flex-wrap mb-1">
            <TableUtils.NewLabelCell
              labelColor={switch tx.status {
              | Processed => LabelGreen
              | Failed => LabelRed
              | Processing => LabelOrange
              | Pending => LabelYellow
              | _ => LabelGray
              }}
              text={(tx.status :> string)->capitalizeString}
            />
            <p className={`${body.sm.semibold} text-nd_gray-800`}>
              {tx.transformation_name->React.string}
            </p>
            <span className={`${body.xs.regular} text-nd_gray-400`}>
              {`→ ${tx.account_id}`->React.string}
            </span>
          </div>
          <div className="flex items-center gap-2">
            <p className={`${body.xs.regular} text-nd_gray-500`}>
              {`${cleaned->Int.toString} / ${total->Int.toString} rows`->React.string}
            </p>
            <RenderIf condition={ignored > 0}>
              <span className={`${body.xs.regular} text-nd_gray-300`}> {"·"->React.string} </span>
              <p className={`${body.xs.regular} text-nd_orange-500`}>
                {`${ignored->Int.toString} ignored`->React.string}
              </p>
            </RenderIf>
            <RenderIf condition={dur->isNonEmptyString}>
              <span className={`${body.xs.regular} text-nd_gray-300`}> {"·"->React.string} </span>
              <p className={`${body.xs.regular} text-nd_gray-400`}> {dur->React.string} </p>
            </RenderIf>
            <RenderIf condition={errorCount > 0}>
              <span className={`${body.xs.regular} text-nd_gray-300`}> {"·"->React.string} </span>
              <p className={`${body.xs.regular} text-nd_red-500`}>
                {`${errorCount->Int.toString} error${errorCount == 1 ? "" : "s"}`->React.string}
              </p>
            </RenderIf>
          </div>
        </div>
        <Icon name="nd-arrow-right" size=14 className="text-nd_gray-400 flex-shrink-0 ml-4" />
      </div>
    </div>
  }
}

module FilterSelect = {
  @react.component
  let make = (~value: string, ~options: array<(string, string)>, ~onChange: string => unit) => {
    let selectOptions = options->Array.map(((v, l)) => {SelectBox.label: l, value: v})
    let input = ReactFinalForm.makeInputRecord(value->JSON.Encode.string, ev => {
      let v = ev->Identity.genericTypeToJson->getStringFromJson(value)
      onChange(v)
    })
    <SelectBoxAdapter
      input options=selectOptions allowMultiSelect=false isDropDown=true deselectDisable=true
    />
  }
}

module StagingEntryDrawer = {
  @react.component
  let make = (~entry: processingEntryType, ~onClose: unit => unit) => {
    let amountStr = `${entry.currency} ${entry.amount->Float.toFixedWithPrecision(~digits=2)}`

    let (entryTypeClasses, entryTypeDot) = switch entry.entry_type->String.toLowerCase {
    | "credit" => ("bg-nd_green-50 text-nd_green-600 border-nd_green-200", "bg-nd_green-500")
    | "debit" => ("bg-nd_blue-50 text-nd_blue-600 border-nd_blue-200", "bg-nd_blue-500")
    | _ => ("bg-nd_gray-50 text-nd_gray-600 border-nd_gray-200", "bg-nd_gray-400")
    }

    let (statusClasses, statusDot) = switch entry.status {
    | Processed => ("bg-nd_green-50 text-nd_green-600", "bg-nd_green-500")
    | NeedsManualReview => ("bg-nd_orange-50 text-nd_orange-600", "bg-nd_orange-500")
    | Pending => ("bg-nd_blue-50 text-nd_blue-600", "bg-nd_blue-500")
    | _ => ("bg-nd_gray-50 text-nd_gray-500", "bg-nd_gray-400")
    }

    let statusLabel = switch entry.status {
    | Processed => "Processed"
    | NeedsManualReview => "Needs review"
    | Pending => "Pending"
    | Archived => "Archived"
    | Void => "Void"
    | UnknownProcessingEntryStatus => "Unknown"
    }

    let d: Dict.t<JSON.t> = Dict.make()
    d->Dict.set("staging_entry_id", entry.staging_entry_id->JSON.Encode.string)
    let accd: Dict.t<JSON.t> = Dict.make()
    accd->Dict.set("account_id", entry.account.account_id->JSON.Encode.string)
    accd->Dict.set("account_name", entry.account.account_name->JSON.Encode.string)
    d->Dict.set("account", accd->JSON.Encode.object)
    d->Dict.set("entry_type", entry.entry_type->JSON.Encode.string)
    let amtd: Dict.t<JSON.t> = Dict.make()
    amtd->Dict.set("value", entry.amount->JSON.Encode.float)
    amtd->Dict.set("currency", entry.currency->JSON.Encode.string)
    d->Dict.set("amount", amtd->JSON.Encode.object)
    d->Dict.set("processing_mode", entry.processing_mode->JSON.Encode.string)
    d->Dict.set("status", (entry.status :> string)->JSON.Encode.string)
    d->Dict.set("effective_at", entry.effective_at->JSON.Encode.string)
    d->Dict.set("order_id", entry.order_id->JSON.Encode.string)
    d->Dict.set("transformation_history_id", entry.transformation_history_id->JSON.Encode.string)
    let jsonStr = d->JSON.Encode.object->JSON.stringifyWithIndent(2)

    <>
      <div className="fixed inset-0 bg-black/20 z-40" onClick={_ => onClose()} />
      <div
        className="fixed right-0 top-0 h-full w-[480px] bg-white shadow-2xl rounded-l-2xl z-50 flex flex-col overflow-hidden">
        <div
          className="flex items-center justify-between px-6 py-4 border-b border-nd_gray-150 flex-shrink-0">
          <p className={`${heading.sm.semibold} text-nd_gray-800`}>
            {"Staging entry"->React.string}
          </p>
          <button
            className="w-8 h-8 flex items-center justify-center rounded-lg hover:bg-nd_gray-100 text-nd_gray-500 transition-colors"
            onClick={_ => onClose()}>
            <Icon name="nd-cross" size=14 />
          </button>
        </div>
        <div className="flex-1 flex flex-col overflow-hidden">
          <div className="px-6 py-5 flex flex-col gap-5 flex-shrink-0">
            <div className="flex items-center gap-2 flex-wrap">
              <span
                className={`${body.xs.semibold} flex items-center gap-1.5 px-2.5 py-1 rounded-full border ${entryTypeClasses}`}>
                <span className={`w-1.5 h-1.5 rounded-full flex-shrink-0 ${entryTypeDot}`} />
                {entry.entry_type->String.toUpperCase->React.string}
              </span>
              <span
                className={`${body.xs.semibold} px-2.5 py-1 border border-nd_blue-300 text-nd_blue-600 rounded-full bg-nd_blue-50`}>
                {entry.processing_mode->React.string}
              </span>
              <span
                className={`${body.xs.semibold} flex items-center gap-1.5 px-2.5 py-1 rounded-full ${statusClasses}`}>
                <span className={`w-1.5 h-1.5 rounded-full flex-shrink-0 ${statusDot}`} />
                {statusLabel->React.string}
              </span>
            </div>
            <div>
              <p className={`${heading.xl.semibold} text-nd_gray-900 mb-1`}>
                {amountStr->React.string}
              </p>
              <p className={`${body.sm.regular} font-mono text-nd_gray-400`}>
                {entry.staging_entry_id->React.string}
              </p>
            </div>
          </div>
          <div className="flex-1 flex flex-col overflow-hidden px-6 pb-5">
            <p className={`${body.xs.semibold} uppercase tracking-widest text-nd_gray-400 mb-2`}>
              {"Metadata"->React.string}
            </p>
            <div
              className="flex-1 border border-nd_gray-150 rounded-xl bg-nd_gray-25 overflow-auto p-3">
              <pre className="text-xs font-mono text-nd_gray-900 whitespace-pre-wrap break-all">
                {jsonStr->React.string}
              </pre>
            </div>
          </div>
        </div>
      </div>
    </>
  }
}

module TransformationRunModal = {
  @react.component
  let make = (
    ~tx: transformationHistoryType,
    ~configJson: JSON.t,
    ~schema: metadataSchemaType,
    ~onClose: unit => unit,
  ) => {
    let dur = getDurationStr(tx.created_at, tx.processed_at)
    let errors = tx.data.errors

    let errorGroups: Dict.t<int> = Dict.make()
    errors->Array.forEach(e => {
      let count = errorGroups->Dict.get(e)->Option.getOr(0)
      errorGroups->Dict.set(e, count + 1)
    })
    let errorEntries = errorGroups->Dict.toArray

    let (statusDot, statusTextColor, statusLabel) = switch tx.status {
    | Processed => ("bg-nd_green-500", "text-nd_green-600", "Processed")
    | Failed => ("bg-nd_red-500", "text-nd_red-500", "Failed")
    | Processing => ("bg-nd_orange-400", "text-nd_orange-500", "Processing")
    | Pending => ("bg-nd_yellow-400", "text-nd_yellow-600", "Pending")
    | _ => ("bg-nd_gray-400", "text-nd_gray-500", "Unknown")
    }

    // Parse transformation config
    let cfgDict = configJson->getDictFromJsonObject
    let parseCfgDict = cfgDict->getDictfromDict("parsing_config")
    let fileFormat = parseCfgDict->getString("file_format", "")->String.toUpperCase
    let skipConfigs = cfgDict->getArrayFromDict("skip_configs", [])

    // Schema-derived values from useFetchMetadataSchema
    let sd = schema.schema_data
    let schemaType = sd.schema_type->String.toUpperCase
    let uniqueKeyStr = switch sd.unique_constraint.unique_constraint_type {
    | ReconEngineTypes.SingleField(name) => name
    | ReconEngineTypes.UnknownConstraint => ""
    }
    let mainFields = sd.fields.main_fields
    let metadataFields = sd.fields.metadata_fields

    let getFieldTypeLabel = (ft: ReconEngineTypes.fieldTypeVariant) =>
      switch ft {
      | StringField(_) => "string"
      | NumberField(_) => "number"
      | CurrencyField => "currency"
      | MinorUnitField(_) => "amount · major unit"
      | DateTimeField => "date / time"
      | BalanceDirectionField(_) => "balance direction"
      | UnknownFieldType => "unknown"
      }

    let getEntryFieldStr = (ef: ReconEngineTypes.entryField) =>
      switch ef {
      | String => ""
      | Metadata(key) => `metadata.${key}`
      }

    let formatOperator = (op: string) =>
      switch op->String.toLowerCase {
      | "not_equals" | "neq" => "≠"
      | "equals" | "eq" => "="
      | "contains" => "contains"
      | "not_contains" => "doesn't contain"
      | "starts_with" => "starts with"
      | "ends_with" => "ends with"
      | s => s
      }

    <>
      <div className="fixed inset-0 bg-black/20 z-40" onClick={_ => onClose()} />
      <div
        className="fixed right-0 top-0 h-full w-[560px] bg-white shadow-2xl rounded-l-2xl z-50 flex flex-col overflow-hidden">
        <div
          className="flex items-center justify-between px-6 py-4 border-b border-nd_gray-150 flex-shrink-0">
          <p className={`${heading.sm.semibold} text-nd_gray-800`}>
            {"Transformation run"->React.string}
          </p>
          <button
            className="w-8 h-8 flex items-center justify-center rounded-lg hover:bg-nd_gray-100 text-nd_gray-500 transition-colors"
            onClick={_ => onClose()}>
            <Icon name="nd-cross" size=14 />
          </button>
        </div>
        <div className="flex-1 overflow-y-auto">
          <div className="px-6 py-5 flex flex-col gap-5">
            // Name + status
            <div>
              <div className="flex items-center gap-2 flex-wrap mb-1">
                <p className={`${heading.sm.semibold} text-nd_gray-900`}>
                  {tx.transformation_name->React.string}
                </p>
                <span className={`flex items-center gap-1 ${statusTextColor}`}>
                  <span className={`w-1.5 h-1.5 rounded-full flex-shrink-0 ${statusDot}`} />
                  <span className={body.xs.semibold}> {statusLabel->React.string} </span>
                </span>
              </div>
              <p className={`${body.sm.regular} text-nd_gray-400`}>
                {`writes into → ${tx.account_id}`->React.string}
              </p>
            </div>
            // Connected stat cards
            <div className="border border-nd_gray-200 rounded-xl overflow-hidden flex">
              <div className="flex-1 px-4 py-3 text-center border-r border-nd_gray-150">
                <p className="text-xs font-semibold uppercase tracking-wide text-nd_gray-400 mb-1">
                  {"TOTAL"->React.string}
                </p>
                <p className="text-xl font-semibold text-nd_gray-800">
                  {tx.data.total_count->Int.toString->React.string}
                </p>
              </div>
              <div className="flex-1 px-4 py-3 text-center border-r border-nd_gray-150">
                <p className="text-xs font-semibold uppercase tracking-wide text-nd_gray-400 mb-1">
                  {"TRANSFORMED"->React.string}
                </p>
                <p className="text-xl font-semibold text-nd_green-600">
                  {tx.data.transformed_count->Int.toString->React.string}
                </p>
              </div>
              <div className="flex-1 px-4 py-3 text-center">
                <p className="text-xs font-semibold uppercase tracking-wide text-nd_gray-400 mb-1">
                  {"IGNORED"->React.string}
                </p>
                <p
                  className={`text-xl font-semibold ${tx.data.ignored_count > 0
                      ? "text-nd_orange-500"
                      : "text-nd_gray-800"}`}>
                  {tx.data.ignored_count->Int.toString->React.string}
                </p>
              </div>
            </div>
            // ROW ERRORS
            <RenderIf condition={errors->Array.length > 0}>
              <div>
                <p className={`${body.xs.semibold} uppercase tracking-wide text-nd_red-500 mb-2`}>
                  {`ROW ERRORS ${errors->Array.length->Int.toString}`->React.string}
                </p>
                <div className="border border-nd_gray-150 rounded-xl overflow-hidden">
                  {errorEntries
                  ->Array.mapWithIndex(((msg, cnt), i) =>
                    <div
                      key={i->Int.toString}
                      className={`flex items-center justify-between px-4 py-2.5 ${i > 0
                          ? "border-t border-nd_gray-100"
                          : ""}`}>
                      <span className={`${body.sm.regular} text-nd_gray-700`}>
                        {msg->React.string}
                      </span>
                      <span className={`${body.sm.semibold} text-nd_red-500 ml-4 flex-shrink-0`}>
                        {cnt->Int.toString->React.string}
                      </span>
                    </div>
                  )
                  ->React.array}
                </div>
              </div>
            </RenderIf>
            // Timing
            <div className="border border-nd_gray-150 rounded-xl overflow-hidden">
              <div className="flex items-center justify-between px-4 py-2.5">
                <span className={`${body.sm.regular} text-nd_gray-500`}>
                  {"Started"->React.string}
                </span>
                <span className={`${body.sm.medium} text-nd_gray-800`}>
                  {formatDateTime(tx.created_at)->React.string}
                </span>
              </div>
              <div
                className="flex items-center justify-between px-4 py-2.5 border-t border-nd_gray-100">
                <span className={`${body.sm.regular} text-nd_gray-500`}>
                  {"Finished"->React.string}
                </span>
                <span className={`${body.sm.medium} text-nd_gray-800`}>
                  {(
                    tx.processed_at->isNonEmptyString ? formatDateTime(tx.processed_at) : "—"
                  )->React.string}
                </span>
              </div>
              <div
                className="flex items-center justify-between px-4 py-2.5 border-t border-nd_gray-100">
                <span className={`${body.sm.regular} text-nd_gray-500`}>
                  {"Duration"->React.string}
                </span>
                <span className={`${body.sm.medium} text-nd_gray-800`}>
                  {(dur->isNonEmptyString ? dur : "—")->React.string}
                </span>
              </div>
              <div
                className="flex items-center justify-between px-4 py-2.5 border-t border-nd_gray-100">
                <span className={`${body.sm.regular} text-nd_gray-500`}>
                  {"Run ID"->React.string}
                </span>
                <span className={`${body.xs.regular} font-mono text-nd_gray-600`}>
                  {tx.transformation_history_id->React.string}
                </span>
              </div>
            </div>
            // SKIP CONFIGS
            <RenderIf condition={skipConfigs->Array.length > 0}>
              <div>
                <div className="flex items-center gap-2 mb-2">
                  <Icon name="nd-filter-horizontal" size=12 className="text-nd_gray-400" />
                  <p className={`${body.xs.semibold} uppercase tracking-wide text-nd_gray-500`}>
                    {`Skip Configs ${skipConfigs->Array.length->Int.toString}`->React.string}
                  </p>
                </div>
                <div className="flex flex-col gap-2">
                  {skipConfigs
                  ->Array.mapWithIndex((skipCfg, gi) => {
                    let conditions =
                      skipCfg->getDictFromJsonObject->getArrayFromDict("conditions", [])
                    <div
                      key={gi->Int.toString}
                      className="border border-nd_gray-150 rounded-xl overflow-hidden">
                      <div className="px-4 py-2 bg-nd_gray-50 border-b border-nd_gray-100">
                        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase`}>
                          {`Group ${(gi + 1)->Int.toString}`->React.string}
                        </span>
                      </div>
                      {conditions
                      ->Array.mapWithIndex((cond, ci) => {
                        let d = cond->getDictFromJsonObject
                        let identifier = d->getString("identifier", "")
                        let operator = d->getString("operator", "")
                        let value = d->getString("value", "")
                        <div
                          key={ci->Int.toString}
                          className={`flex items-center gap-2 px-4 py-2.5 flex-wrap ${ci > 0
                              ? "border-t border-nd_gray-100"
                              : ""}`}>
                          <span
                            className={`${body.sm.medium} font-mono text-nd_gray-800 bg-nd_gray-100 px-1.5 py-0.5 rounded`}>
                            {identifier->React.string}
                          </span>
                          <span className={`${body.xs.semibold} text-nd_gray-400`}>
                            {formatOperator(operator)->React.string}
                          </span>
                          <span
                            className={`${body.sm.medium} font-mono text-nd_orange-600 bg-nd_orange-50 px-1.5 py-0.5 rounded border border-nd_orange-100`}>
                            {value->React.string}
                          </span>
                        </div>
                      })
                      ->React.array}
                    </div>
                  })
                  ->React.array}
                </div>
              </div>
            </RenderIf>
            // PARSING
            <RenderIf
              condition={fileFormat->isNonEmptyString ||
              schemaType->isNonEmptyString ||
              uniqueKeyStr->isNonEmptyString}>
              <div>
                <div className="flex items-center gap-2 mb-2">
                  <Icon name="nd-filter-horizontal" size=12 className="text-nd_gray-400" />
                  <p className={`${body.xs.semibold} uppercase tracking-wide text-nd_gray-500`}>
                    {"Parsing"->React.string}
                  </p>
                </div>
                <div className="border border-nd_gray-150 rounded-xl overflow-hidden">
                  {[
                    ("File format", fileFormat),
                    ("Schema type", schemaType),
                    ("Unique key", uniqueKeyStr),
                  ]
                  ->Array.filter(((_, v)) => v->isNonEmptyString)
                  ->Array.mapWithIndex(((label, value), i) =>
                    <div
                      key={i->Int.toString}
                      className={`flex items-center justify-between px-4 py-2.5 ${i > 0
                          ? "border-t border-nd_gray-100"
                          : ""}`}>
                      <span className={`${body.sm.regular} text-nd_gray-500`}>
                        {label->React.string}
                      </span>
                      <span
                        className={`${body.xs.medium} px-2 py-0.5 bg-nd_gray-100 text-nd_gray-700 rounded font-mono`}>
                        {value->React.string}
                      </span>
                    </div>
                  )
                  ->React.array}
                </div>
              </div>
            </RenderIf>
            // FIELDS & RULES
            <RenderIf condition={mainFields->Array.length > 0 || metadataFields->Array.length > 0}>
              <div>
                <div className="flex items-center gap-2 mb-2">
                  <Icon name="nd-connectors" size=12 className="text-nd_gray-400" />
                  <p className={`${body.xs.semibold} uppercase tracking-wide text-nd_gray-500`}>
                    {`Fields & Rules ${(mainFields->Array.length + metadataFields->Array.length)
                        ->Int.toString}`->React.string}
                  </p>
                </div>
                <div className="flex flex-col gap-2">
                  {mainFields
                  ->Array.mapWithIndex((field, i) =>
                    <div
                      key={`m${i->Int.toString}`}
                      className="border border-nd_gray-150 rounded-xl px-4 py-3 flex items-center gap-2 flex-wrap">
                      <span className={`${body.sm.semibold} text-nd_gray-800`}>
                        {field.field_name->snakeToTitle->React.string}
                      </span>
                      <RenderIf condition={field.identifier->isNonEmptyString}>
                        <Icon name="nd-arrow-right" size=12 className="text-nd_gray-400" />
                        <span className={`${body.xs.regular} font-mono text-nd_gray-600`}>
                          {field.identifier->React.string}
                        </span>
                      </RenderIf>
                    </div>
                  )
                  ->React.array}
                  {metadataFields
                  ->Array.mapWithIndex((field, i) => {
                    let typeLabel = getFieldTypeLabel(field.field_type)
                    let fieldMapsTo = getEntryFieldStr(field.field_name)
                    <div
                      key={`md${i->Int.toString}`}
                      className="border border-nd_gray-150 rounded-xl overflow-hidden">
                      <div className="px-4 py-3 flex items-center gap-2 flex-wrap">
                        <span className={`${body.sm.semibold} text-nd_gray-800`}>
                          {field.identifier->React.string}
                        </span>
                        <RenderIf condition={field.required}>
                          <span className={`${body.xs.semibold} text-nd_red-400`}>
                            {"required"->React.string}
                          </span>
                        </RenderIf>
                        <RenderIf condition={typeLabel->isNonEmptyString}>
                          <span
                            className={`${body.xs.medium} px-1.5 py-0.5 rounded bg-nd_gray-100 text-nd_gray-600`}>
                            {typeLabel->React.string}
                          </span>
                        </RenderIf>
                        <RenderIf condition={fieldMapsTo->isNonEmptyString}>
                          <Icon name="nd-arrow-right" size=12 className="text-nd_gray-400" />
                          <span className={`${body.xs.medium} font-mono text-nd_gray-600`}>
                            {fieldMapsTo->React.string}
                          </span>
                        </RenderIf>
                      </div>
                      <RenderIf condition={field.description->isNonEmptyString}>
                        <div className="border-t border-nd_gray-100 px-4 py-2">
                          <span className={`${body.xs.regular} text-nd_gray-500`}>
                            {field.description->React.string}
                          </span>
                        </div>
                      </RenderIf>
                    </div>
                  })
                  ->React.array}
                </div>
              </div>
            </RenderIf>
          </div>
        </div>
      </div>
    </>
  }
}

@react.component
let make = (~ingestionHistoryId: string) => {
  open APIUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let getIngestionHistory = ReconEngineHooks.useGetIngestionHistory()
  let getProcessingEntries = ReconEngineHooks.useGetProcessingEntries()
  let fetchMetadataSchema = ReconEngineHooks.useFetchMetadataSchema()
  let fetchApi = AuthHooks.useApiFetcher()
  let {xFeatureRoute, forceCookies} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastState.useShowToast()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (historyItem, setHistoryItem) = React.useState((_): option<ingestionHistoryType> => None)
  let (accountName, setAccountName) = React.useState(_ => "")
  let (transformations, setTransformations) = React.useState((_): array<
    transformationHistoryType,
  > => [])
  let (txConfigs, setTxConfigs) = React.useState((_): Dict.t<JSON.t> => Dict.make())
  let (txSchemas, setTxSchemas) = React.useState((_): Dict.t<metadataSchemaType> => Dict.make())
  let (allEntries, setAllEntries) = React.useState((_): array<processingEntryType> => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (txFilter, setTxFilter) = React.useState(_ => "all")
  let (modeFilter, setModeFilter) = React.useState(_ => "all")
  let (statusFilter, setStatusFilter) = React.useState(_ => "all")
  let (sortOrder, setSortOrder) = React.useState(_ => "recent")
  let (selectedEntry, setSelectedEntry) = React.useState((_): option<processingEntryType> => None)
  let (selectedTx, setSelectedTx) = React.useState((_): option<transformationHistoryType> => None)
  let (showViewer, setShowViewer) = React.useState(_ => false)

  let onDownloadFile = async () => {
    try {
      let fileId = switch historyItem {
      | Some(h) => h.id
      | None => ingestionHistoryId
      }
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#DOWNLOAD_INGESTION_HISTORY_FILE,
        ~methodType=Get,
        ~id=Some(fileId),
      )
      let res = await fetchApi(url, ~method_=Get, ~xFeatureRoute, ~forceCookies)
      let fileName = switch historyItem {
      | Some(h) => h.file_name
      | None => `${ingestionHistoryId}.csv`
      }
      // Download the raw response bytes as a blob so binary files (xlsx/xls)
      // aren't corrupted by text decoding. octet-stream works for every type —
      // the browser saves it under the original file name/extension.
      let blobContent = await res->Fetch.Response.blob
      DownloadUtils.download(~fileName, ~content=blobContent, ~fileType="application/octet-stream")
      showToast(~message="File downloaded successfully", ~toastType=ToastSuccess)
    } catch {
    | _ => showToast(~message="Failed to download file. Please try again.", ~toastType=ToastError)
    }
  }

  let fetchData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)

      let histList = await getIngestionHistory(
        ~queryParameters=Some(`ingestion_history_id=${ingestionHistoryId}`),
      )
      // sort descending by version → index 0 = latest version
      histList->Array.sort((a, b) => compareLogic(a.version, b.version))
      let latest = histList->Array.get(0)
      setHistoryItem(_ => latest)

      // fetch account name
      switch latest {
      | Some(h) =>
        try {
          let accountUrl = getURL(
            ~entityName=V1(HYPERSWITCH_RECON),
            ~methodType=Get,
            ~hyperswitchReconType=#ACCOUNTS_LIST,
            ~id=Some(h.account_id),
          )
          let accountRes = await fetchDetails(accountUrl)
          let name = accountRes->getDictFromJsonObject->getString("account_name", h.account_id)
          setAccountName(_ => name)
        } catch {
        | _ => setAccountName(_ => h.account_id)
        }
      | None => ()
      }

      let txUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
        ~queryParameters=Some(`ingestion_history_id=${ingestionHistoryId}`),
      )
      let txRes = await fetchDetails(txUrl)
      let txItems =
        txRes->getArrayDataFromJson(ReconEngineUtils.transformationHistoryItemToObjMapper)
      setTransformations(_ => txItems)

      // Fetch config + metadata schema for each transformation upfront
      let configMap: Dict.t<JSON.t> = Dict.make()
      let schemaMap: Dict.t<metadataSchemaType> = Dict.make()
      for i in 0 to txItems->Array.length - 1 {
        let tx = txItems->Array.getUnsafe(i)
        try {
          let cfgUrl = getURL(
            ~entityName=V1(HYPERSWITCH_RECON),
            ~methodType=Get,
            ~hyperswitchReconType=#TRANSFORMATION_CONFIG,
            ~id=Some(tx.transformation_id),
          )
          let cfgRes = await fetchDetails(cfgUrl)
          let cfg = cfgRes->getDictFromJsonObject->getJsonObjectFromDict("config")
          configMap->Dict.set(tx.transformation_id, cfg)
        } catch {
        | _ => ()
        }
        try {
          let metaJson = await fetchMetadataSchema(~transformationId=tx.transformation_id)
          let parsed =
            metaJson->getDictFromJsonObject->ReconEngineUtils.metadataSchemaItemToObjMapper
          schemaMap->Dict.set(tx.transformation_id, parsed)
        } catch {
        | _ => ()
        }
      }
      setTxConfigs(_ => configMap)
      setTxSchemas(_ => schemaMap)

      let entriesRef: ref<array<processingEntryType>> = ref([])
      for i in 0 to txItems->Array.length - 1 {
        let txId = (txItems->Array.getUnsafe(i)).transformation_history_id
        let entries = await getProcessingEntries(
          ~queryParameters=Some(`transformation_history_id=${txId}`),
        )
        entriesRef := entriesRef.contents->Array.concat(entries)
      }
      setAllEntries(_ => entriesRef.contents)

      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    fetchData()->ignore
    None
  }, [ingestionHistoryId])

  let totalStaging =
    allEntries->Array.filter(e => e.status != Archived && e.status != Void)->Array.length
  let totalTransformed =
    transformations->Array.reduce(0, (acc, t) => acc + t.data.transformed_count)
  let totalIgnored = transformations->Array.reduce(0, (acc, t) => acc + t.data.ignored_count)
  let allTxProcessed =
    transformations->Array.length > 0 && transformations->Array.every(t => t.status == Processed)
  let txFailedCount = transformations->Array.filter(t => t.status == Failed)->Array.length

  let txOptions: array<(string, string)> = React.useMemo(() => {
    let opts = [("all", "All transformations")]
    transformations->Array.forEach(t =>
      opts->Array.push((t.transformation_history_id, t.transformation_name))->ignore
    )
    opts
  }, [transformations])

  let modeOptions: array<(string, string)> = React.useMemo(() => {
    let seen: Dict.t<bool> = Dict.make()
    let opts = [("all", "All modes")]
    allEntries->Array.forEach(e => {
      let m = e.processing_mode->String.toLowerCase
      if !(seen->Dict.get(m)->Option.isSome) {
        seen->Dict.set(m, true)
        opts->Array.push((m, e.processing_mode))->ignore
      }
    })
    opts
  }, [allEntries])

  let statusOptions: array<(string, string)> = [
    ("all", "All statuses"),
    ("processed", "Processed"),
    ("needs_manual_review", "Needs review"),
    ("pending", "Pending"),
  ]

  let sortOptions: array<(string, string)> = [("recent", "Most recent"), ("oldest", "Oldest first")]

  let filtered: array<processingEntryType> = React.useMemo(() => {
    let base = allEntries->Array.filter(e => {
      let notArchived = e.status != Archived && e.status != Void
      let matchesTx = txFilter == "all" || e.transformation_history_id == txFilter
      let matchesMode = modeFilter == "all" || e.processing_mode->String.toLowerCase == modeFilter
      let matchesStatus = switch statusFilter {
      | "processed" => e.status == Processed
      | "needs_manual_review" => e.status == NeedsManualReview
      | "pending" => e.status == Pending
      | _ => true
      }
      let matchesSearch =
        !(searchText->isNonEmptyString) ||
        isContainingStringLowercase(e.staging_entry_id, searchText) ||
        isContainingStringLowercase(e.order_id, searchText)
      notArchived && matchesTx && matchesMode && matchesStatus && matchesSearch
    })
    switch sortOrder {
    | "oldest" => base->Array.toSorted((a, b) => String.compare(a.effective_at, b.effective_at))
    | _ => base->Array.toSorted((a, b) => String.compare(b.effective_at, a.effective_at))
    }
  }, (allEntries, txFilter, modeFilter, statusFilter, searchText, sortOrder))

  let processedCount = filtered->Array.filter(e => e.status == Processed)->Array.length
  let needsReviewCount = filtered->Array.filter(e => e.status == NeedsManualReview)->Array.length

  let nullableEntries = filtered->Array.map(Nullable.make)

  <div className="w-full">
    <div className="flex items-center justify-between mb-6">
      <button
        className={`${body.sm.medium} text-nd_gray-500 hover:text-nd_gray-800 flex items-center gap-1.5 transition-colors`}
        onClick={_ =>
          RescriptReactRouter.push(
            GlobalVars.appendDashboardPath(~url="/v1/recon-engine/pipelines"),
          )}>
        <Icon name="nd-arrow-left" size=13 />
        {"Pipelines"->React.string}
      </button>
      <div className="flex items-center gap-2">
        <Button
          text="View file"
          leftIcon={CustomIcon(<Icon name="nd-eye-on" size=12 />)}
          buttonType=Secondary
          buttonSize=Small
          onClick={_ => setShowViewer(_ => true)}
          maxButtonWidth="!w-fit"
        />
        <Button
          text="Download file"
          leftIcon={CustomIcon(<Icon name="nd-download-down" size=12 />)}
          buttonType=Secondary
          buttonSize=Small
          onClick={_ => onDownloadFile()->ignore}
          maxButtonWidth="!w-fit"
        />
      </div>
    </div>
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData
        height="h-96" message="Could not load ingestion details."
      />}>
      {switch historyItem {
      | None => React.null
      | Some(h) =>
        <div className="flex flex-col gap-6">
          <div className="border border-nd_gray-200 rounded-xl bg-white overflow-hidden">
            <div className="p-5">
              <div className="flex items-start justify-between gap-4">
                <div className="flex items-start gap-3 min-w-0">
                  <div
                    className="w-9 h-9 rounded-lg border border-nd_gray-200 bg-nd_gray-50 flex items-center justify-center flex-shrink-0">
                    <Icon name="nd-file" size=16 className="text-nd_gray-500" />
                  </div>
                  <div className="min-w-0">
                    <div className="flex items-center gap-2 flex-wrap mb-1">
                      <p className={`${heading.sm.semibold} text-nd_gray-800 truncate`}>
                        {h.file_name->React.string}
                      </p>
                      <TableUtils.NewLabelCell
                        labelColor={switch h.status {
                        | Processed => LabelGreen
                        | Failed => LabelRed
                        | Processing => LabelOrange
                        | Pending => LabelYellow
                        | _ => LabelGray
                        }}
                        text={(h.status :> string)->capitalizeString}
                      />
                      <RenderIf condition={h.version > 0}>
                        <span
                          className={`${body.xs.medium} px-2 py-0.5 rounded-full bg-nd_gray-100 text-nd_gray-500 border border-nd_gray-200`}>
                          {`v${h.version->Int.toString}`->React.string}
                        </span>
                      </RenderIf>
                    </div>
                    <p className={`${body.sm.regular} text-nd_gray-400`}>
                      {`${ReconEngineRevampedPipelinesUtils.getUploadTypeLabel(
                          h.upload_type,
                        )}${accountName->isNonEmptyString
                          ? " · " ++ accountName
                          : ""}`->React.string}
                    </p>
                  </div>
                </div>
                <div className="text-right flex-shrink-0">
                  <p className={`${body.sm.semibold} text-nd_gray-700`}>
                    {formatDateTime(h.created_at)->React.string}
                  </p>
                  <p className={`${body.xs.regular} text-nd_gray-400`}>
                    {`created ${getRelativeTime(h.created_at)}`->React.string}
                  </p>
                </div>
              </div>
            </div>
            <div className="border-t border-nd_gray-150 flex divide-x divide-nd_gray-150">
              <StatCard label="STAGING ENTRIES" value=totalStaging desc="" />
              <StatCard
                label="TRANSFORMATION RUNS"
                value={transformations->Array.length}
                desc={allTxProcessed
                  ? "all processed"
                  : txFailedCount > 0
                  ? `${txFailedCount->Int.toString} failed`
                  : ""}
                descColor={txFailedCount > 0 ? "text-nd_red-500" : "text-nd_gray-400"}
              />
              <StatCard label="ROWS TRANSFORMED" value=totalTransformed desc="" />
              <StatCard
                label="ROWS IGNORED"
                value=totalIgnored
                desc={totalIgnored > 0 ? "dropped on parse" : ""}
                descColor="text-nd_orange-500"
              />
            </div>
          </div>
          <RenderIf condition={transformations->Array.length > 0}>
            <div>
              <p className={`${body.md.semibold} text-nd_gray-700 mb-3`}>
                {`Transformations applied ${transformations
                  ->Array.length
                  ->Int.toString}`->React.string}
              </p>
              <div className="flex flex-col gap-3">
                {transformations
                ->Array.map(tx =>
                  <TransformationCard
                    key={tx.transformation_history_id}
                    tx
                    onOpen={() => setSelectedTx(_ => Some(tx))}
                  />
                )
                ->React.array}
              </div>
            </div>
          </RenderIf>
          <div>
            <div className="flex items-center gap-3 flex-wrap mb-3">
              <p className={`${body.md.semibold} text-nd_gray-800`}>
                {"Staging entries"->React.string}
              </p>
              <span className={`${body.sm.regular} text-nd_gray-400`}>
                {`${filtered
                  ->Array.length
                  ->Int.toString} total · ${processedCount->Int.toString} processed · ${needsReviewCount->Int.toString} needs review`->React.string}
              </span>
            </div>
            <div className="flex flex-row items-center gap-3 flex-wrap mb-3">
              <div
                className="flex items-center gap-2 border border-nd_gray-200 rounded-lg px-3 py-2 w-72 bg-white">
                <Icon name="nd-search" size=13 className="text-nd_gray-400 flex-shrink-0" />
                <input
                  className={`${body.sm.regular} w-full outline-none text-nd_gray-700 placeholder:text-nd_gray-400 bg-transparent`}
                  placeholder={`Search ${totalStaging->Int.toString} entries — id, reason`}
                  value=searchText
                  onChange={e => {
                    let v = ReactEvent.Form.target(e)["value"]
                    setSearchText(_ => v)
                    setOffset(_ => 0)
                  }}
                />
              </div>
              <FilterSelect
                value=txFilter
                options=txOptions
                onChange={v => {
                  setTxFilter(_ => v)
                  setOffset(_ => 0)
                }}
              />
              <FilterSelect
                value=modeFilter
                options=modeOptions
                onChange={v => {
                  setModeFilter(_ => v)
                  setOffset(_ => 0)
                }}
              />
              <FilterSelect
                value=statusFilter
                options=statusOptions
                onChange={v => {
                  setStatusFilter(_ => v)
                  setOffset(_ => 0)
                }}
              />
              <FilterSelect
                value=sortOrder options=sortOptions onChange={v => setSortOrder(_ => v)}
              />
            </div>
            <div className="border border-nd_gray-200 rounded-xl overflow-hidden">
              <LoadedTable
                title="Staging Entries"
                hideTitle=true
                actualData=nullableEntries
                entity=stagingTableEntity
                resultsPerPage=50
                totalResults={filtered->Array.length}
                offset
                setOffset
                currentFetchCount={filtered->Array.length}
                tableheadingClass="h-11"
                tableHeadingTextClass="!font-normal"
                nonFrozenTableParentClass="!rounded-none !border-0 !shadow-none"
                loadedTableParentClass="flex flex-col"
                enableEqualWidthCol=false
                showAutoScroll=true
                onEntityClick={entry => setSelectedEntry(_ => Some(entry))}
              />
            </div>
          </div>
        </div>
      }}
    </PageLoaderWrapper>
    {switch selectedEntry {
    | Some(entry) => <StagingEntryDrawer entry onClose={() => setSelectedEntry(_ => None)} />
    | None => React.null
    }}
    {switch selectedTx {
    | Some(tx) =>
      let configJson = txConfigs->Dict.get(tx.transformation_id)->Option.getOr(JSON.Encode.null)
      let schema =
        txSchemas
        ->Dict.get(tx.transformation_id)
        ->Option.getOr(Dict.make()->ReconEngineUtils.metadataSchemaItemToObjMapper)
      <TransformationRunModal tx configJson schema onClose={() => setSelectedTx(_ => None)} />
    | None => React.null
    }}
    <RenderIf condition=showViewer>
      <ReconEngineRevampedPipelinesFileViewer
        historyItem
        transformations
        txConfigs
        onClose={() => setShowViewer(_ => false)}
        onDownload={() => onDownloadFile()->ignore}
      />
    </RenderIf>
  </div>
}
