open Typography
open ReconEngineTypes
open ReconEngineDataStatusUtils

module EmptyState = {
  @react.component
  let make = () =>
    <div className="flex flex-1 flex-col items-center justify-center text-center px-8 gap-3">
      <div className="w-12 h-12 rounded-full bg-nd_gray-50 flex items-center justify-center">
        <Icon name="nd-reports" size=24 customIconColor="#A1A8B8" />
      </div>
      <p className={`${body.lg.semibold} text-nd_gray-600`}> {"Select an entry"->React.string} </p>
      <p className={`${body.sm.medium} text-nd_gray-400 max-w-xs`}>
        {"Pick a row to see its metadata, validation status and lineage."->React.string}
      </p>
    </div>
}

module Header = {
  @react.component
  let make = (~onClose: unit => unit) =>
    <div
      className="flex flex-row items-center gap-2 px-5 h-12 border-b border-nd_gray-150 bg-white flex-shrink-0">
      <span className={`${body.sm.medium} text-nd_gray-500 flex-1`}>
        {"Entry details"->React.string}
      </span>
      <button
        type_="button"
        onClick={_ => onClose()}
        className="w-8 h-8 rounded-md border border-nd_gray-150 bg-white text-nd_gray-500 hover:bg-nd_gray-50 grid place-items-center">
        <Icon name="modal-close-icon" size=14 customIconColor="#606B85" />
      </button>
    </div>
}

module Hero = {
  @react.component
  let make = (~entry: processingEntryType) => {
    let kind = entry.status->getEntryKind
    let isCredit = entry.entry_type === "credit"
    let dirLabel = isCredit ? "Credit" : "Debit"
    let dirColor = isCredit ? "text-nd_green-600" : "text-nd_red-600"

    <div className="flex flex-col gap-4">
      <div className="flex flex-row items-center gap-2.5 flex-wrap">
        <TagBinding
          text={entry.status->getEntryLabel}
          color={entry.status->getEntryTagColor}
          variant={kind === EntryNeedsReview ? Attentive : Subtle}
          size=Sm
        />
        <span className={`${body.sm.medium} text-nd_gray-500`}>
          {`${dirLabel} · ${entry.effective_at->formatRelativeTime} ago`->React.string}
        </span>
      </div>
      <div className="flex flex-col gap-1">
        <span className={`${heading.xl.semibold} ${dirColor} tabular-nums tracking-tight`}>
          {`${entry.currency} ${entry.amount->Float.toString}`->React.string}
        </span>
        {switch entry.status {
        | NeedsManualReview =>
          <p
            className={`${body.sm.medium} text-nd_orange-600 bg-nd_orange-50 border border-nd_orange-100 rounded-md px-2.5 py-1.5`}>
            {entry.data.needs_manual_review_type->getNeedsReviewExplanation->React.string}
          </p>
        | _ => React.null
        }}
      </div>
    </div>
  }
}

module SectionLabel = {
  @react.component
  let make = (~text: string) =>
    <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
      {text->React.string}
    </span>
}

module MetaGrid = {
  @react.component
  let make = (~entry: processingEntryType) =>
    <div className="grid grid-cols-2 gap-x-6 gap-y-5">
      <div className="flex flex-col gap-1 min-w-0">
        <SectionLabel text="Staging entry ID" />
        <HelperComponents.CopyTextCustomComp
          customTextCss={`${body.sm.medium} text-nd_gray-700 font-mono truncate`}
          displayValue=Some(entry.staging_entry_id)
        />
      </div>
      <div className="flex flex-col gap-1 min-w-0">
        <SectionLabel text="Order ID" />
        <HelperComponents.CopyTextCustomComp
          customTextCss={`${body.sm.medium} text-nd_gray-700 font-mono truncate`}
          displayValue=Some(entry.order_id === "" ? "—" : entry.order_id)
        />
      </div>
      <div className="flex flex-col gap-1 min-w-0">
        <SectionLabel text="Account" />
        <span className={`${body.sm.medium} text-nd_gray-700 truncate`}>
          {entry.account.account_name->React.string}
        </span>
      </div>
      <div className="flex flex-col gap-1 min-w-0">
        <SectionLabel text="Effective at" />
        <span className={`${body.sm.medium} text-nd_gray-700 tabular-nums truncate`}>
          {entry.effective_at->React.string}
        </span>
      </div>
    </div>
}

module LineageSection = {
  type lineageState = {
    fileName: option<string>,
    ingestionHistoryId: option<string>,
    transformationName: option<string>,
  }

  @react.component
  let make = (~entry: processingEntryType) => {
    let getTransformationHistory = ReconEngineHooks.useGetTransformationHistory()
    let getIngestionHistory = ReconEngineHooks.useGetIngestionHistory()

    let (state, setState) = React.useState(_ => {
      fileName: None,
      ingestionHistoryId: None,
      transformationName: None,
    })

    React.useEffect(() => {
      if entry.transformation_history_id !== "" {
        let load = async () => {
          try {
            let res = await getTransformationHistory(
              ~queryParameters=Some(`id=${entry.transformation_history_id}`),
            )
            let tx = res->Array.get(0)
            switch tx {
            | Some(t) => {
                let ingRes = await getIngestionHistory(
                  ~queryParameters=Some(`ingestion_history_id=${t.ingestion_history_id}`),
                )
                let ing = ingRes->Array.get(0)
                setState(_ => {
                  fileName: ing->Option.map(i => i.file_name),
                  ingestionHistoryId: Some(t.ingestion_history_id),
                  transformationName: Some(t.transformation_name),
                })
              }
            | None => ()
            }
          } catch {
          | _ => ()
          }
        }
        load()->ignore
      }
      None
    }, [entry.id])

    let card = (label, value, action) =>
      <div
        className="rounded-xl border border-nd_gray-150 bg-white px-3.5 py-3 flex flex-row items-center gap-3">
        <div className="flex flex-col gap-0.5 min-w-0 flex-1">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
            {label->React.string}
          </span>
          <span className={`${body.sm.medium} text-nd_gray-700 font-mono truncate`}>
            {value->React.string}
          </span>
        </div>
        {action}
      </div>

    <div className="flex flex-col gap-3">
      <SectionLabel text="Lineage" />
      <div className="flex flex-col gap-1.5">
        {card(
          "Source file",
          state.fileName->Option.getOr("—"),
          switch state.ingestionHistoryId {
          | Some(hid) =>
            <button
              type_="button"
              onClick={_ =>
                RescriptReactRouter.push(
                  GlobalVars.appendDashboardPath(~url=`/v1/recon-engine/sources?file=${hid}`),
                )}
              className="w-8 h-8 rounded-md border border-nd_gray-150 bg-white text-nd_gray-500 hover:bg-nd_gray-50 grid place-items-center flex-shrink-0">
              <Icon name="nd-external-link-square" size=14 customIconColor="#606B85" />
            </button>
          | None => React.null
          },
        )}
        <div className="pl-2">
          <Icon name="nd-arrow-down" size=12 customIconColor="#A1A8B8" />
        </div>
        {card("Transformation", state.transformationName->Option.getOr("—"), React.null)}
        <div className="pl-2">
          <Icon name="nd-arrow-down" size=12 customIconColor="#A1A8B8" />
        </div>
        {card("Transformed entry", entry.staging_entry_id, React.null)}
      </div>
    </div>
  }
}

module MetadataSection = {
  @react.component
  let make = (~entry: processingEntryType) => {
    let json = entry.metadata->JSON.stringifyWithIndent(2)
    <div className="flex flex-col gap-3">
      <SectionLabel text="Metadata" />
      <pre
        className={`${body.xs.medium} text-nd_gray-700 font-mono bg-nd_gray-50 border border-nd_gray-150 rounded-xl px-3 py-3 overflow-x-auto whitespace-pre-wrap break-all max-h-72 overflow-y-auto`}>
        {json->React.string}
      </pre>
    </div>
  }
}

@react.component
let make = (~activeEntry: option<processingEntryType>, ~onClose: unit => unit) =>
  switch activeEntry {
  | None =>
    <aside
      className="hidden lg:flex flex-shrink-0 w-[440px] flex-col bg-white border-l border-nd_gray-150">
      <Header onClose />
      <EmptyState />
    </aside>
  | Some(entry) =>
    <aside
      className="hidden lg:flex flex-shrink-0 w-[440px] flex-col bg-white border-l border-nd_gray-150 overflow-hidden">
      <Header onClose />
      <div className="flex-1 overflow-y-auto px-6 py-5 flex flex-col gap-5">
        <Hero entry />
        <div className="h-px bg-nd_gray-150" />
        <MetaGrid entry />
        <LineageSection entry />
        <MetadataSection entry />
      </div>
    </aside>
  }
