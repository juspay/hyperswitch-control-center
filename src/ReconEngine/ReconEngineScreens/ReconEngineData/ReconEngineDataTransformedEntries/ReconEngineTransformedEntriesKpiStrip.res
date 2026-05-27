open Typography
open ReconEngineTypes

module Card = {
  @react.component
  let make = (
    ~label: string,
    ~value: string,
    ~tone: string="text-nd_gray-800",
    ~trailing: React.element=React.null,
  ) =>
    <div
      className="flex-1 min-w-0 rounded-xl border border-nd_gray-150 bg-white px-4 py-3.5 flex flex-row items-center gap-3">
      <div className="flex flex-col gap-0.5 min-w-0 flex-1">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {label->React.string}
        </span>
        <span className={`${heading.md.semibold} ${tone} tabular-nums`}>
          {value->React.string}
        </span>
      </div>
      {trailing}
    </div>
}

@react.component
let make = (~entries: array<processingEntryType>) => {
  let totalActive =
    entries
    ->Array.filter(e =>
      switch e.status {
      | Archived | Void => false
      | _ => true
      }
    )
    ->Array.length
  let processed =
    entries
    ->Array.filter(e =>
      switch e.status {
      | Processed => true
      | _ => false
      }
    )
    ->Array.length
  let needsReview =
    entries
    ->Array.filter(e =>
      switch e.status {
      | NeedsManualReview => true
      | _ => false
      }
    )
    ->Array.length
  let validPct = totalActive === 0 ? "—" : `${(processed * 100 / totalActive)->Int.toString}%`

  <div className="flex flex-row gap-3 px-6 pt-4 pb-2 flex-shrink-0">
    <Card label="Active entries" value={totalActive->Int.toString} />
    <Card label="Processed" value={processed->Int.toString} tone="text-nd_green-600" />
    <Card
      label="Needs manual review"
      value={needsReview->Int.toString}
      tone={needsReview > 0 ? "text-nd_orange-600" : "text-nd_gray-800"}
    />
    <Card label="Pass rate" value={validPct} tone="text-nd_primary_blue-600" />
  </div>
}
