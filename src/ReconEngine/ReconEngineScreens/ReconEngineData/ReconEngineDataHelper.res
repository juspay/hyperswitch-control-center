open Typography
open ReconEngineDataTypes

module StatusIndicator = {
  @react.component
  let make = (~status: status, ~value: string) => {
    let (bgColor, textColor) = switch status {
    | Active => ("bg-nd_green-300", "text-nd_gray-600")
    | Inactive => ("bg-nd_red-400", "text-nd_gray-600")
    | UnknownStatus => ("bg-nd_gray-400", "text-nd_gray-600")
    }

    <div className="flex items-center space-x-2">
      <span className="relative flex h-2 w-2">
        <span className={`absolute inline-flex h-full w-full rounded-full ${bgColor} opacity-75`} />
        <span className={`relative inline-flex rounded-full h-2 w-2 ${bgColor}`} />
      </span>
      <span className={`${body.md.medium} ${textColor} ml-2`}> {value->React.string} </span>
    </div>
  }
}
