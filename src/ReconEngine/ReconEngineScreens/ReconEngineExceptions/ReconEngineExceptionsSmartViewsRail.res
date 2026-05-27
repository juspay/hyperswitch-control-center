open Typography
open ReconEngineExceptionsStatusUtils

module Tab = {
  @react.component
  let make = (~view: smartView, ~active: bool, ~count: int, ~onSelect: smartView => unit) => {
    let labelColor = active ? "text-nd_gray-800" : "text-nd_gray-500 hover:text-nd_gray-700"
    let underline = active ? "border-nd_primary_blue-500" : "border-transparent"
    let countPill = active
      ? "bg-nd_primary_blue-50 text-nd_primary_blue-600"
      : "bg-nd_gray-100 text-nd_gray-500"

    <button
      type_="button"
      onClick={_ => onSelect(view)}
      className={`flex flex-row items-center gap-2 px-3.5 py-3 -mb-px border-b-2 ${underline} ${labelColor} transition-colors`}>
      <span className={`${body.sm.medium} whitespace-nowrap`}>
        {view->smartViewLabel->React.string}
      </span>
      <span
        className={`${body.xs.medium} px-1.5 h-[18px] min-w-[22px] inline-flex items-center justify-center rounded-full tabular-nums ${countPill}`}>
        {count->Int.toString->React.string}
      </span>
    </button>
  }
}

@react.component
let make = (
  ~activeView: smartView,
  ~onChange: smartView => unit,
  ~counts: (int, int, int, int, int),
) => {
  let (mismatch, awaiting, missing, stale, all) = counts

  let countFor = (view: smartView) =>
    switch view {
    | AllOpen => all
    | NeedsAttention => mismatch
    | AwaitingConfirmation => awaiting
    | Missing => missing
    | StaleOpen => stale
    }

  <div
    className="flex flex-row items-end gap-1 px-6 border-b border-nd_gray-150 bg-white flex-shrink-0 overflow-x-auto">
    {allSmartViews
    ->Array.map(view =>
      <Tab
        key={view->smartViewLabel}
        view
        active={view === activeView}
        count={view->countFor}
        onSelect=onChange
      />
    )
    ->React.array}
  </div>
}
