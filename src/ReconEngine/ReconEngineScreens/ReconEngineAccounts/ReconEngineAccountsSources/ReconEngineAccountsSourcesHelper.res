open Typography
open ReconEngineAccountsSourcesTypes
open ReconEngineAccountsSourcesUtils

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
        <div className="flex items-center space-x-2">
          {switch data.value->getStatusVariantFromString {
          | Active =>
            <div className="flex items-center space-x-2">
              <span className="relative flex h-2 w-2">
                <span
                  className="absolute inline-flex h-full w-full rounded-full bg-nd_green-300 opacity-75"
                />
                <span className="relative inline-flex rounded-full h-2 w-2 bg-nd_green-300" />
              </span>
              <span className={`${body.md.medium} text-nd_gray-600 ml-2`}>
                {data.value->React.string}
              </span>
            </div>
          | Inactive =>
            <div className="flex items-center space-x-2">
              <span className="relative flex h-2 w-2">
                <span
                  className="absolute inline-flex h-full w-full rounded-full bg-nd_red-400 opacity-75"
                />
                <span className="relative inline-flex rounded-full h-2 w-2 bg-nd_red-400" />
              </span>
              <span className={`${body.md.medium} text-nd_gray-600 ml-2`}>
                {data.value->React.string}
              </span>
            </div>
          | UnknownStatus =>
            <div className="flex items-center space-x-2">
              <span className="relative flex h-2 w-2">
                <span
                  className="absolute inline-flex h-full w-full rounded-full bg-nd_gray-400 opacity-75"
                />
                <span className="relative inline-flex rounded-full h-2 w-2 bg-nd_gray-400" />
              </span>
              <span className={`${body.md.medium} text-nd_gray-600 ml-2`}>
                {data.value->React.string}
              </span>
            </div>
          }}
        </div>
      }}
    </div>
  }
}
