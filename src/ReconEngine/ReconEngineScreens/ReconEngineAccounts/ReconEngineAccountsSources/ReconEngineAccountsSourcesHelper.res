open Typography
open ReconEngineAccountsSourcesTypes
open ReconEngineAccountsSourcesUtils
open ReconEngineAccountsTypes
open ReconEngineAccountsUtils

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

module SourceConfigItem = {
  @react.component
  let make = (~data: sourceConfigDataType) => {
    <div className="flex flex-col space-y-1">
      <span className={`${body.md.medium} text-nd_gray-500`}>
        {data.label->sourceConfigLabelToString->React.string}
      </span>
      {switch data.valueType {
      | #text =>
        <span className={`${body.md.medium} text-nd_gray-600`}> {data.value->React.string} </span>
      | #date =>
        <span className={`${body.md.medium} text-nd_gray-600`}>
          <TableUtils.DateCell timestamp={data.value} textAlign={Left} />
        </span>
      | #status =>
        <StatusIndicator status={data.value->getStatusVariantFromString} value={data.value} />
      }}
    </div>
  }
}
