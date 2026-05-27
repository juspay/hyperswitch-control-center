open Typography
open ReconEngineTypes
open ReconEngineOverviewRevampUtils

type stageTone = Neutral | Success | Warning | Danger | Info

let stageStripeBg = (t: stageTone): string =>
  switch t {
  | Neutral => "bg-nd_gray-400"
  | Success => "bg-nd_green-500"
  | Warning => "bg-nd_orange-400"
  | Danger => "bg-nd_red-500"
  | Info => "bg-nd_primary_blue-500"
  }

module Stage = {
  @react.component
  let make = (
    ~index: int,
    ~label: string,
    ~value: string,
    ~hint: string="",
    ~lossText: string="",
    ~tone: stageTone=Neutral,
    ~onClick: option<ReactEvent.Mouse.t => unit>=?,
  ) => {
    let clickable = onClick !== None
    let cardCls = clickable
      ? "flex-1 min-w-[180px] rounded-xl border border-nd_gray-150 bg-white px-4 py-4 flex flex-col gap-2 text-left cursor-pointer hover:border-nd_gray-300 hover:bg-nd_gray-25 transition-colors"
      : "flex-1 min-w-[180px] rounded-xl border border-nd_gray-150 bg-white px-4 py-4 flex flex-col gap-2 text-left"

    <button type_="button" ?onClick className=cardCls>
      <div className="flex flex-row items-center gap-2">
        <span className={`w-1.5 h-4 rounded-full ${tone->stageStripeBg}`} />
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {`Step ${(index + 1)->Int.toString} · ${label}`->React.string}
        </span>
      </div>
      <span className={`${heading.lg.semibold} text-nd_gray-800 tabular-nums tracking-tight`}>
        {value->React.string}
      </span>
      {hint === ""
        ? React.null
        : <span className={`${body.xs.medium} text-nd_gray-500`}> {hint->React.string} </span>}
      {lossText === ""
        ? React.null
        : <span className={`${body.xs.semibold} text-nd_red-600 tabular-nums`}>
            {lossText->React.string}
          </span>}
    </button>
  }
}

module Connector = {
  @react.component
  let make = () =>
    <div className="hidden md:flex items-center justify-center px-1 flex-shrink-0 text-nd_gray-300">
      <Icon name="chevron-right" size=18 customIconColor="#A1A8B8" />
    </div>
}

@react.component
let make = (
  ~ingestions: array<ingestionHistoryType>,
  ~transformations: array<transformationHistoryType>,
  ~transactions: array<transactionType>,
) => {
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let goto = (path: string) => {
    mixpanelEvent(~eventName="recon_engine_overview_pipeline_clicked")
    RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=path))
  }

  /* Files (Step 1) */
  let filesTotal = ingestions->Array.length
  let filesFailed =
    ingestions
    ->Array.filter(i =>
      switch i.status {
      | Failed => true
      | _ => false
      }
    )
    ->Array.length

  /* Rows Transformed (Step 2) */
  let rowsTransformed = transformations->Array.reduce(0, (acc, t) => acc + t.data.transformed_count)
  let rowsIgnored = transformations->Array.reduce(0, (acc, t) => acc + t.data.ignored_count)
  let txErrorCount =
    transformations
    ->Array.filter(t => t.data.errors->Array.length > 0)
    ->Array.length

  /* Transactions (Step 3) — total created during window. */
  let txCreated = transactions->Array.length

  /* Matched / posted (Step 4) — landed in ledger. */
  let counts = bucketCount(transactions)
  let matched = counts.matched

  <div className="flex flex-col gap-3 px-6">
    <div className="flex flex-row items-baseline justify-between">
      <span className={`${body.sm.semibold} text-nd_gray-700 uppercase tracking-wider`}>
        {"Reconciliation pipeline"->React.string}
      </span>
      <span className={`${body.xs.medium} text-nd_gray-500`}>
        {"Click any stage to inspect"->React.string}
      </span>
    </div>
    <div className="flex flex-row flex-wrap items-stretch gap-2">
      <Stage
        index=0
        label="Files received"
        value={filesTotal->compactInt}
        hint={filesTotal === 1 ? "file ingested" : "files ingested"}
        lossText={filesFailed === 0 ? "" : `${filesFailed->Int.toString} failed to ingest`}
        tone=Info
        onClick={_ => goto("/v1/recon-engine/sources")}
      />
      <Connector />
      <Stage
        index=1
        label="Rows transformed"
        value={rowsTransformed->compactInt}
        hint={rowsIgnored === 0 ? "successful conversions" : `${rowsIgnored->compactInt} ignored`}
        lossText={txErrorCount === 0
          ? ""
          : `${txErrorCount->Int.toString} transformation${txErrorCount === 1
                ? ""
                : "s"} had errors`}
        tone=Success
        onClick={_ => goto("/v1/recon-engine/transformed-entries")}
      />
      <Connector />
      <Stage
        index=2
        label="Transactions"
        value={txCreated->compactInt}
        hint="reconciliation candidates"
        lossText={counts.mismatched === 0 ? "" : `${counts.mismatched->Int.toString} mismatched`}
        tone=Warning
        onClick={_ => goto("/v1/recon-engine/transactions")}
      />
      <Connector />
      <Stage
        index=3
        label="Matched & posted"
        value={matched->compactInt}
        hint="landed in ledger"
        lossText={counts.awaiting === 0
          ? ""
          : `${counts.awaiting->Int.toString} still awaiting match`}
        tone=Success
        onClick={_ =>
          goto(
            "/v1/recon-engine/transactions?status=matched_auto,matched_manual,matched_force,posted_manual",
          )}
      />
    </div>
  </div>
}
