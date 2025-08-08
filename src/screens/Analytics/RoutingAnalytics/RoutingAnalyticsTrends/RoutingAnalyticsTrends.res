@react.component
let make = () => {
  open Typography

  <div className="flex flex-col gap-6 w-full">
    <div className="flex flex-col gap-1 mb-2">
      <p className={`${body.lg.semibold} text-nd_gray-800`}>
        {"Time Series Distribution"->React.string}
      </p>
      <p className={`${body.md.medium} text-nd_gray-400`}>
        {"Track the auth rates and transaction volumes of various processors across time"->React.string}
      </p>
    </div>
    <RoutingAnalyticsTrendsSuccess />
    <RoutingAnalyticsTrendsVolume />
  </div>
}
