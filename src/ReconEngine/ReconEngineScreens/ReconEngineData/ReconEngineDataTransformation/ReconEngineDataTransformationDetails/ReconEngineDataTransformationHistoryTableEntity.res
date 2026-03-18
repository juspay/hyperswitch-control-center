open ReconEngineTypes
open ReconEngineDataSourcesEntity

let defaultColumns: array<transformationHistoryColType> = [
  TransformationHistoryId,
  IngestionHistoryId,
  Status,
  TotalRecords,
  ProcessedCount,
  IgnoredCount,
  ErrorCount,
  TransformedAt,
  Actions,
]

let transformationHistoryTableEntity = (
  path: string,
  ~authorization: CommonAuthTypes.authorization,
) => {
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=_ => [],
    ~defaultColumns,
    ~getHeading=getTransformationHistoryHeading,
    ~getCell=getTransformationHistoryCell,
    ~dataKey="",
    ~getShowLink={
      connectorObj => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(
            ~url=`/${path}/${connectorObj.ingestion_history_id}?transformationHistoryId=${connectorObj.transformation_history_id}`,
          ),
          ~authorization,
        )
      }
    },
  )
}
