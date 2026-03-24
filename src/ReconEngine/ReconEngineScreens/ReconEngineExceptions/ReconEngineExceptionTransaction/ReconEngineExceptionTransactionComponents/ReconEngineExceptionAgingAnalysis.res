open Typography
open ReconEngineTypes

type agingBucket = {
  label: string,
  count: int,
  color: string,
  bgColor: string,
}

let getAgeDays = (createdAt: string): float => {
  let now = Date.make()->Date.getTime
  let created = Date.fromString(createdAt)->Date.getTime
  let diffMs = now -. created
  diffMs /. (1000.0 *. 60.0 *. 60.0 *. 24.0)
}

let categorizeByAge = (exceptions: array<transactionType>): array<agingBucket> => {
  let (bucket0to1, bucket1to7, bucket7to30, bucket30plus) = exceptions->Array.reduce(
    (0, 0, 0, 0),
    ((b1, b2, b3, b4), transaction) => {
      let ageDays = getAgeDays(transaction.created_at)
      if ageDays < 1.0 {
        (b1 + 1, b2, b3, b4)
      } else if ageDays < 7.0 {
        (b1, b2 + 1, b3, b4)
      } else if ageDays < 30.0 {
        (b1, b2, b3 + 1, b4)
      } else {
        (b1, b2, b3, b4 + 1)
      }
    },
  )

  [
    {label: "< 1 day", count: bucket0to1, color: "bg-nd_green-400", bgColor: "bg-nd_green-50"},
    {label: "1-7 days", count: bucket1to7, color: "bg-nd_yellow-400", bgColor: "bg-nd_yellow-50"},
    {label: "7-30 days", count: bucket7to30, color: "bg-orange-400", bgColor: "bg-orange-50"},
    {label: "30+ days", count: bucket30plus, color: "bg-nd_red-400", bgColor: "bg-nd_red-50"},
  ]
}

module AgingBar = {
  @react.component
  let make = (~buckets: array<agingBucket>, ~total: int) => {
    <RenderIf condition={total > 0}>
      <div className="flex flex-row h-2 rounded-full overflow-hidden gap-0.5 w-full">
        {buckets
        ->Array.mapWithIndex((bucket, index) => {
          let widthPct = if total > 0 {
            bucket.count->Int.toFloat /. total->Int.toFloat *. 100.0
          } else {
            0.0
          }
          <RenderIf key={index->Int.toString} condition={widthPct > 0.0}>
            <div
              className={`${bucket.color} rounded-full`}
              style={ReactDOM.Style.make(~width=`${widthPct->Float.toFixedWithPrecision(~digits=1)}%`, ())}
            />
          </RenderIf>
        })
        ->React.array}
      </div>
    </RenderIf>
  }
}

@react.component
let make = (~exceptionData: array<transactionType>) => {
  let buckets = React.useMemo(() => {
    categorizeByAge(exceptionData)
  }, [exceptionData])

  let total = exceptionData->Array.length

  <RenderIf condition={total > 0}>
    <div className="border border-nd_gray-150 rounded-xl p-4 bg-white">
      <div className="flex flex-row items-center justify-between mb-3">
        <p className={`text-nd_gray-700 ${body.md.semibold}`}>
          {"Exception Aging"->React.string}
        </p>
      </div>
      <AgingBar buckets total />
      <div className="grid grid-cols-4 gap-3 mt-3">
        {buckets
        ->Array.mapWithIndex((bucket, index) => {
          <div
            key={index->Int.toString}
            className={`flex flex-col items-center gap-1 p-2 rounded-lg ${bucket.bgColor}`}>
            <p className={`text-nd_gray-800 ${body.md.semibold}`}>
              {bucket.count->Int.toString->React.string}
            </p>
            <p className={`text-nd_gray-500 ${body.sm.medium}`}>
              {bucket.label->React.string}
            </p>
          </div>
        })
        ->React.array}
      </div>
    </div>
  </RenderIf>
}
