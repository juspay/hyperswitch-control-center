open Typography
open ReconEngineTypes
open ReconEngineExceptionsStatusUtils
open ReconEngineExceptionTransactionTypes

module EmptyState = {
  @react.component
  let make = () =>
    <div className="flex flex-1 flex-col items-center justify-center text-center px-8 gap-3">
      <div className="w-12 h-12 rounded-full bg-nd_gray-50 flex items-center justify-center">
        <Icon name="nd-alert-circle" size=24 customIconColor="#A1A8B8" />
      </div>
      <p className={`${body.lg.semibold} text-nd_gray-600`}>
        {"Select an exception"->React.string}
      </p>
      <p className={`${body.sm.medium} text-nd_gray-400 max-w-xs`}>
        {"Pick a row on the left to see why it's flagged and how to resolve it."->React.string}
      </p>
    </div>
}

module Header = {
  @react.component
  let make = (~onOpenFull: unit => unit, ~onClose: unit => unit) =>
    <div
      className="flex flex-row items-center gap-2 px-5 h-12 border-b border-nd_gray-150 bg-white flex-shrink-0">
      <span className={`${body.sm.medium} text-nd_gray-500 flex-1`}>
        {"Exception details"->React.string}
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
  let make = (~txn: transactionType, ~onResolve: unit => unit) => {
    let status = txn.transaction_status
    let kind = status->getStatusKind
    let varianceRaw = txn.credit_amount.value -. txn.debit_amount.value
    let variance = varianceRaw < 0.0 ? -.varianceRaw : varianceRaw
    let currency = txn.credit_amount.currency
    let amount = txn.credit_amount.value > 0.0 ? txn.credit_amount.value : txn.debit_amount.value

    <div className="flex flex-col gap-4">
      <div className="flex flex-row items-center gap-2.5 flex-wrap">
        <TagBinding
          text={status->getStatusLabel} color={status->getTagColor} variant=Subtle size=Sm
        />
        <span className={`${body.sm.medium} text-nd_gray-500`}>
          {`Flagged ${txn.created_at->formatRelativeTime} ago`->React.string}
        </span>
      </div>
      <div className="flex flex-col gap-1">
        <div className="flex flex-row items-baseline gap-2 flex-wrap">
          <span className={`${heading.xl.semibold} text-nd_gray-800 tabular-nums tracking-tight`}>
            {`${currency} ${amount->Float.toString}`->React.string}
          </span>
          {switch kind {
          | ReconEngineTransactionsStatusUtils.MismatchKind =>
            <span
              className={`${body.sm.semibold} text-nd_red-600 bg-nd_red-50 px-2 py-0.5 rounded-md tabular-nums`}>
              {`±${currency} ${variance->Float.toString}`->React.string}
            </span>
          | _ => React.null
          }}
        </div>
        <p className={`${body.sm.medium} text-nd_gray-500`}>
          {status->getStatusDescription->React.string}
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
  let make = (~txn: transactionType) =>
    <div className="grid grid-cols-2 gap-x-6 gap-y-5">
      <div className="flex flex-col gap-1 min-w-0">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {"Transaction ID"->React.string}
        </span>
        <HelperComponents.CopyTextCustomComp
          customTextCss={`${body.sm.medium} text-nd_gray-700 font-mono truncate`}
          displayValue=Some(txn.transaction_id)
        />
      </div>
      <div className="flex flex-col gap-1 min-w-0">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {"Rule"->React.string}
        </span>
        <span className={`${body.sm.medium} text-nd_gray-700 truncate`}>
          {txn.rule.rule_name->React.string}
        </span>
      </div>
      <div className="flex flex-col gap-1 min-w-0">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {"Created"->React.string}
        </span>
        <span className={`${body.sm.medium} text-nd_gray-700 tabular-nums truncate`}>
          {txn.created_at
          ->DateTimeUtils.getFormattedDate("DD MMM YYYY, hh:mm A")
          ->React.string}
        </span>
      </div>
      <div className="flex flex-col gap-1 min-w-0">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {"Version"->React.string}
        </span>
        <span className={`${body.sm.medium} text-nd_gray-700 tabular-nums`}>
          {`v${txn.version->Int.toString}`->React.string}
        </span>
      </div>
    </div>
}

module RecommendedAction = {
  @react.component
  let make = (~status: domainTransactionStatus, ~onResolve: unit => unit) => {
    let recommended = status->getRecommendedResolution
    switch recommended {
    | NoResolutionActionNeeded => React.null
    | _ =>
      <div
        className="rounded-xl border border-nd_primary_blue-200 bg-nd_primary_blue-50/40 px-4 py-3.5 flex flex-col gap-2.5">
        <div className="flex flex-row items-center gap-2">
          <span className={`${body.xs.semibold} text-nd_primary_blue-600 uppercase tracking-wider`}>
            {"Recommended"->React.string}
          </span>
          <span
            className={`${body.xs.semibold} text-nd_primary_blue-600 bg-white px-1.5 py-0.5 rounded`}>
            {"Suggested by status"->React.string}
          </span>
        </div>
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

module EntriesPreview = {
  @react.component
  let make = (~txn: transactionType) => {
    let grouped = React.useMemo(() => {
      let dict = Dict.make()
      txn.entries->Array.forEach(entry => {
        let key = entry.account.account_id
        let bucket = dict->Dict.get(key)->Option.getOr([])
        dict->Dict.set(key, Array.concat(bucket, [entry]))
      })
      dict->Dict.toArray
    }, [txn])

    <div className="flex flex-col gap-2.5">
      <div className="flex flex-row items-baseline justify-between">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {"Entries"->React.string}
        </span>
        <span className={`${body.xs.medium} text-nd_gray-400`}>
          {`${txn.entries->Array.length->Int.toString} total`->React.string}
        </span>
      </div>
      <div className="flex flex-col gap-2.5">
        {grouped
        ->Array.map(((accountId, entries)) => {
          let accountName =
            entries->Array.get(0)->Option.map(e => e.account.account_name)->Option.getOr(accountId)
          <div
            key={accountId} className="rounded-xl border border-nd_gray-150 bg-white px-4 py-3.5">
            <div className="flex flex-row items-baseline justify-between mb-2.5">
              <span
                className={`${body.sm.semibold} text-nd_gray-600 uppercase tracking-wider truncate`}>
                {accountName->React.string}
              </span>
            </div>
            {entries
            ->Array.mapWithIndex((entry, idx) => {
              let isDebit = entry.entry_type === Debit
              let stripe = isDebit ? "border-nd_red-500" : "border-nd_green-400"
              let label = isDebit ? "DEBIT" : "CREDIT"
              let textColor = isDebit ? "text-nd_red-600" : "text-nd_green-600"
              <div
                key={entry.entry_id ++ idx->Int.toString}
                className="flex flex-row items-center gap-3 pt-3 border-t border-dashed border-nd_gray-150 first:border-t-0 first:pt-0">
                <span
                  className={`${body.xs.semibold} ${textColor} pl-2 border-l-[3px] ${stripe} tracking-wider flex-shrink-0`}>
                  {label->React.string}
                </span>
                <span
                  className={`${body.sm.medium} text-nd_gray-700 font-mono truncate flex-1 min-w-0`}>
                  {entry.order_id->React.string}
                </span>
                <span className={`${body.sm.medium} text-nd_gray-700 tabular-nums flex-shrink-0`}>
                  {`${entry.amount.currency} ${entry.amount.value->Float.toString}`->React.string}
                </span>
              </div>
            })
            ->React.array}
          </div>
        })
        ->React.array}
      </div>
    </div>
  }
}

@react.component
let make = (
  ~activeException: option<transactionType>,
  ~onClearSelection: ReactEvent.Mouse.t => unit,
) => {
  let openFull = (txn: transactionType) =>
    RescriptReactRouter.push(
      GlobalVars.appendDashboardPath(
        ~url=`/v1/recon-engine/exceptions/recon/${txn.transaction_id}`,
      ),
    )

  switch activeException {
  | None =>
    <aside
      className="hidden lg:flex flex-shrink-0 w-[440px] flex-col bg-white border-l border-nd_gray-150">
      <Header
        onOpenFull={() => ()}
        onClose={() => onClearSelection(ReactEvent.Mouse.preventDefault->Obj.magic)}
      />
      <EmptyState />
    </aside>
  | Some(txn) =>
    <aside
      className="hidden lg:flex flex-shrink-0 w-[440px] flex-col bg-white border-l border-nd_gray-150 overflow-hidden">
      <Header
        onOpenFull={() => openFull(txn)}
        onClose={() => onClearSelection(ReactEvent.Mouse.preventDefault->Obj.magic)}
      />
      <div className="flex-1 overflow-y-auto px-6 py-5 flex flex-col gap-5">
        <HeroBlock txn onResolve={() => openFull(txn)} />
        <RecommendedAction status={txn.transaction_status} onResolve={() => openFull(txn)} />
        <div className="h-px bg-nd_gray-150" />
        <MetaGrid txn />
        <EntriesPreview txn />
      </div>
    </aside>
  }
}
