open Typography

type progressSegment = {
  label: string,
  count: int,
  color: string,
  textColor: string,
}

module SegmentedBar = {
  @react.component
  let make = (~segments: array<progressSegment>, ~total: int) => {
    <div className="flex flex-row h-7 rounded-lg overflow-hidden w-full">
      {segments
      ->Array.mapWithIndex((segment, index) => {
        let widthPct = if total > 0 {
          segment.count->Int.toFloat /. total->Int.toFloat *. 100.0
        } else {
          0.0
        }
        <RenderIf key={index->Int.toString} condition={widthPct > 0.0}>
          <div
            className={`${segment.color} flex items-center justify-center transition-all duration-500`}
            style={ReactDOM.Style.make(
              ~width=`${widthPct->Float.toFixedWithPrecision(~digits=1)}%`,
              ~minWidth=widthPct > 5.0 ? "auto" : "0px",
              (),
            )}>
            <RenderIf condition={widthPct > 8.0}>
              <span className={`text-white ${body.sm.semibold} whitespace-nowrap`}>
                {`${widthPct->Float.toFixedWithPrecision(~digits=0)}%`->React.string}
              </span>
            </RenderIf>
          </div>
        </RenderIf>
      })
      ->React.array}
    </div>
  }
}

@react.component
let make = (~postedCount: int, ~mismatchedCount: int, ~expectedCount: int) => {
  let totalTransactions = postedCount + mismatchedCount + expectedCount

  let segments = [
    {label: "Reconciled", count: postedCount, color: "bg-nd_green-400", textColor: "text-nd_green-700"},
    {label: "Pending", count: expectedCount, color: "bg-nd_yellow-400", textColor: "text-nd_yellow-700"},
    {
      label: "Mismatched",
      count: mismatchedCount,
      color: "bg-nd_red-400",
      textColor: "text-nd_red-700",
    },
  ]

  <RenderIf condition={totalTransactions > 0}>
    <div className="border border-nd_gray-150 rounded-xl p-4 bg-white">
      <div className="flex flex-row items-center justify-between mb-3">
        <p className={`text-nd_gray-700 ${body.md.semibold}`}>
          {"Reconciliation Progress"->React.string}
        </p>
        <p className={`text-nd_gray-500 ${body.sm.medium}`}>
          {`${totalTransactions->Int.toString} total transactions`->React.string}
        </p>
      </div>
      <SegmentedBar segments total={totalTransactions} />
      <div className="flex flex-row items-center gap-6 mt-3">
        {segments
        ->Array.mapWithIndex((segment, index) => {
          <div key={index->Int.toString} className="flex flex-row items-center gap-2">
            <div className={`w-2.5 h-2.5 rounded-full ${segment.color}`} />
            <span className={`${body.sm.medium} text-nd_gray-500`}>
              {segment.label->React.string}
            </span>
            <span className={`${body.sm.semibold} ${segment.textColor}`}>
              {segment.count->Int.toString->React.string}
            </span>
          </div>
        })
        ->React.array}
      </div>
    </div>
  </RenderIf>
}
