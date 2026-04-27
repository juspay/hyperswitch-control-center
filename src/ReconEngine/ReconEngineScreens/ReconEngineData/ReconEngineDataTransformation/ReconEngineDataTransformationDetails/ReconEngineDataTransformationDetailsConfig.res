open Typography

@react.component
let make = (~config: ReconEngineTypes.transformationConfigType) => {
  open ReconEngineDataSourcesHelper
  open ReconEngineDataSourcesEntity

  let detailsFields: array<transformationConfigColType> = [
    TransformationId,
    IngestionId,
    Status,
    LastModifiedAt,
  ]

  <div
    className="relative border rounded-xl px-6 py-1 mt-8 grid xl:grid-cols-4 lg:grid-cols-3 md:grid-cols-2 grid-cols-1 items-start gap-y-8 gap-x-20">
    <div
      className={`${body.sm.medium} text-nd_gray-400 flex flex-row items-center cursor-not-allowed gap-2 absolute right-3 top-3`}>
      <Icon name="nd-edit-pencil" size=16 className="text-nd_primary_blue-500 opacity-60" />
      <span className={`text-nd_primary_blue-500 opacity-60 ${body.md.medium}`}>
        {"Edit"->React.string}
      </span>
    </div>
    {detailsFields
    ->Array.map(colType => {
      <DisplayKeyValueParams
        key={LogicUtils.randomString(~length=10)}
        heading={getTransformationConfigHeading(colType)}
        value={getTransformationConfigCell(config, colType)}
      />
    })
    ->React.array}
  </div>
}
