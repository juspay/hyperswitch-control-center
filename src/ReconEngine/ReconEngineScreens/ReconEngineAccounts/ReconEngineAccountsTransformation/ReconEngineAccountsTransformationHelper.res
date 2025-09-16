open Typography
open ReconEngineAccountsTransformationTypes
open ReconEngineAccountsHelper
open ReconEngineAccountsUtils

module TransformationConfigItem = {
  @react.component
  let make = (~data: transformationConfigDataType) => {
    <div className="flex flex-col space-y-1">
      <span className={`${body.md.medium} text-nd_gray-500`}>
        {(data.label :> string)->React.string}
      </span>
      {switch data.valueType {
      | #text =>
        <span className={`${body.md.medium} text-nd_gray-600 whitespace-nowrap`}>
          {data.value->React.string}
        </span>
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
