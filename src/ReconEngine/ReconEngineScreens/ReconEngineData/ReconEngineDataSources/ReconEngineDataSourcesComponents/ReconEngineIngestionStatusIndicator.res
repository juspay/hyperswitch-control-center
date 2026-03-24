open Typography
open ReconEngineTypes

let getStatusConfig = (status: ingestionTransformationStatusType): (string, string, string, bool) => {
  switch status {
  | Processed => ("Processed", "bg-nd_green-400", "text-nd_green-700 bg-nd_green-50", false)
  | Processing => ("Processing", "bg-blue-400", "text-blue-700 bg-blue-50", true)
  | Pending => ("Pending", "bg-nd_yellow-400", "text-nd_yellow-700 bg-nd_yellow-50", false)
  | Failed => ("Failed", "bg-nd_red-400", "text-nd_red-700 bg-nd_red-50", false)
  | Discarded => ("Discarded", "bg-nd_gray-400", "text-nd_gray-700 bg-nd_gray-50", false)
  | UnknownIngestionTransformationStatus => ("Unknown", "bg-nd_gray-300", "text-nd_gray-600 bg-nd_gray-50", false)
  }
}

@react.component
let make = (~status: ingestionTransformationStatusType, ~showLabel: bool=true) => {
  let (label, dotColor, badgeStyle, isAnimated) = getStatusConfig(status)

  <div className={`inline-flex flex-row items-center gap-1.5 px-2 py-1 rounded-full ${badgeStyle}`}>
    <div className="relative flex h-2 w-2">
      <RenderIf condition={isAnimated}>
        <span
          className={`animate-ping absolute inline-flex h-full w-full rounded-full ${dotColor} opacity-75`}
        />
      </RenderIf>
      <span className={`relative inline-flex rounded-full h-2 w-2 ${dotColor}`} />
    </div>
    <RenderIf condition={showLabel}>
      <span className={`${body.sm.semibold}`}> {label->React.string} </span>
    </RenderIf>
  </div>
}
