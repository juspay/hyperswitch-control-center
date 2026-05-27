open Typography
open ReconEngineTypes
open ReconEngineTransformedEntryExceptionsStatusUtils
open ReconEngineTransformedEntryExceptionsTypes

module EmptyState = {
  @react.component
  let make = () =>
    <div className="flex flex-1 flex-col items-center justify-center text-center px-8 gap-3">
      <div className="w-12 h-12 rounded-full bg-nd_gray-50 flex items-center justify-center">
        <Icon name="nd-alert-circle" size=24 customIconColor="#A1A8B8" />
      </div>
      <p className={`${body.lg.semibold} text-nd_gray-600`}> {"Select an entry"->React.string} </p>
      <p className={`${body.sm.medium} text-nd_gray-400 max-w-xs`}>
        {"Pick a row on the left to see why it needs review and how to resolve it."->React.string}
      </p>
    </div>
}

module Header = {
  @react.component
  let make = (~onOpenFull: unit => unit, ~onClose: unit => unit) =>
    <div
      className="flex flex-row items-center gap-2 px-5 h-12 border-b border-nd_gray-150 bg-white flex-shrink-0">
      <span className={`${body.sm.medium} text-nd_gray-500 flex-1`}>
        {"Entry details"->React.string}
      </span>
      <button
        type_="button"
        onClick={_ => onOpenFull()}
        className="w-8 h-8 rounded-md border border-nd_gray-150 bg-white text-nd_gray-500 hover:bg-nd_gray-50 grid place-items-center">
        <Icon name="nd-external-link-square" size=14 customIconColor="#606B85" />
      </button>
      <button
        type_="button"
        onClick={_ => onClose()}
        className="w-8 h-8 rounded-md border border-nd_gray-150 bg-white text-nd_gray-500 hover:bg-nd_gray-50 grid place-items-center">
        <Icon name="modal-close-icon" size=14 customIconColor="#606B85" />
      </button>
    </div>
}

module HeroBlock = {
  @react.component
  let make = (~entry: processingEntryType, ~onResolve: unit => unit) => {
    let status = entry.status
    let entryTypeLower = entry.entry_type->String.toLowerCase
    let isDebit = entryTypeLower === "debit"
    let typeColor = isDebit ? "text-nd_red-600" : "text-nd_green-600"
    let typeStripe = isDebit ? "border-nd_red-500" : "border-nd_green-400"
    let typeLabel = isDebit ? "DEBIT" : "CREDIT"

    <div className="flex flex-col gap-4">
      <div className="flex flex-row items-center gap-2.5 flex-wrap">
        <TagBinding
          text={status->getEntryLabel} color={status->getEntryTagColor} variant=Subtle size=Sm
        />
        <span className={`${body.sm.medium} text-nd_gray-500`}>
          {`Effective ${entry.effective_at->formatRelativeTime} ago`->React.string}
        </span>
      </div>
      <div className="flex flex-col gap-1">
        <div className="flex flex-row items-baseline gap-2 flex-wrap">
          <span
            className={`${body.xs.semibold} ${typeColor} pl-2 border-l-[3px] ${typeStripe} tracking-wider flex-shrink-0`}>
            {typeLabel->React.string}
          </span>
          <span className={`${heading.xl.semibold} text-nd_gray-800 tabular-nums tracking-tight`}>
            {`${entry.currency} ${entry.amount->Float.toString}`->React.string}
          </span>
        </div>
        <p className={`${body.sm.medium} text-nd_gray-500`}>
          {switch status {
          | NeedsManualReview => entry.data.needs_manual_review_type->getNeedsReviewExplanation
          | Pending => "Awaiting reconciliation."
          | _ => ""
          }->React.string}
        </p>
      </div>
      <Button
        text="Open & resolve"
        buttonType=Primary
        buttonSize=Small
        leftIcon={CustomIcon(
          <Icon name="nd-external-link-square" size=14 className="text-white" />,
        )}
        onClick={_ => onResolve()}
      />
    </div>
  }
}

module MetaGrid = {
  @react.component
  let make = (~entry: processingEntryType) =>
    <div className="grid grid-cols-2 gap-x-6 gap-y-5">
      <div className="flex flex-col gap-1 min-w-0">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {"Staging Entry ID"->React.string}
        </span>
        <HelperComponents.CopyTextCustomComp
          customTextCss={`${body.sm.medium} text-nd_gray-700 font-mono truncate`}
          displayValue=Some(entry.staging_entry_id)
        />
      </div>
      <div className="flex flex-col gap-1 min-w-0">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {"Account"->React.string}
        </span>
        <span className={`${body.sm.medium} text-nd_gray-700 truncate`}>
          {entry.account.account_name->React.string}
        </span>
      </div>
      <div className="flex flex-col gap-1 min-w-0">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {"Order ID"->React.string}
        </span>
        <span className={`${body.sm.medium} text-nd_gray-700 font-mono truncate`}>
          {entry.order_id->React.string}
        </span>
      </div>
      <div className="flex flex-col gap-1 min-w-0">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {"Effective"->React.string}
        </span>
        <span className={`${body.sm.medium} text-nd_gray-700 tabular-nums truncate`}>
          {entry.effective_at
          ->DateTimeUtils.getFormattedDate("DD MMM YYYY, hh:mm A")
          ->React.string}
        </span>
      </div>
    </div>
}

module RecommendedAction = {
  @react.component
  let make = (~status: processingEntryStatus, ~onResolve: unit => unit) => {
    let recommended = status->getRecommendedResolution
    switch recommended {
    | NoTransformedEntryResolutionNeeded => React.null
    | _ =>
      <div
        className="rounded-xl border border-nd_primary_blue-200 bg-nd_primary_blue-50/40 px-4 py-3.5 flex flex-col gap-2.5">
        <span className={`${body.xs.semibold} text-nd_primary_blue-600 uppercase tracking-wider`}>
          {"Recommended"->React.string}
        </span>
        <div className="flex flex-row items-center gap-3">
          <div
            className="w-9 h-9 rounded-lg bg-white border border-nd_primary_blue-200 grid place-items-center flex-shrink-0">
            <Icon name={recommended->resolutionIcon} size=18 customIconColor="#1F6BD9" />
          </div>
          <div className="flex flex-col gap-0.5 flex-1 min-w-0">
            <span className={`${body.sm.semibold} text-nd_gray-800`}>
              {recommended->resolutionLabel->React.string}
            </span>
            <span className={`${body.xs.medium} text-nd_gray-500`}>
              {recommended->resolutionHint->React.string}
            </span>
          </div>
        </div>
        <Button
          text="Resolve this way"
          buttonType=Secondary
          buttonSize=Small
          customButtonStyle="!w-full !justify-center"
          onClick={_ => onResolve()}
        />
      </div>
    }
  }
}

@react.component
let make = (
  ~activeEntry: option<processingEntryType>,
  ~onClearSelection: ReactEvent.Mouse.t => unit,
) => {
  let openFull = (entry: processingEntryType) =>
    RescriptReactRouter.push(
      GlobalVars.appendDashboardPath(
        ~url=`/v1/recon-engine/exceptions/transformed-entries/${entry.staging_entry_id}`,
      ),
    )

  switch activeEntry {
  | None =>
    <aside
      className="hidden lg:flex flex-shrink-0 w-[440px] flex-col bg-white border-l border-nd_gray-150">
      <Header
        onOpenFull={() => ()}
        onClose={() => onClearSelection(ReactEvent.Mouse.preventDefault->Obj.magic)}
      />
      <EmptyState />
    </aside>
  | Some(entry) =>
    <aside
      className="hidden lg:flex flex-shrink-0 w-[440px] flex-col bg-white border-l border-nd_gray-150 overflow-hidden">
      <Header
        onOpenFull={() => openFull(entry)}
        onClose={() => onClearSelection(ReactEvent.Mouse.preventDefault->Obj.magic)}
      />
      <div className="flex-1 overflow-y-auto px-6 py-5 flex flex-col gap-5">
        <HeroBlock entry onResolve={() => openFull(entry)} />
        <RecommendedAction status={entry.status} onResolve={() => openFull(entry)} />
        <div className="h-px bg-nd_gray-150" />
        <MetaGrid entry />
      </div>
    </aside>
  }
}
