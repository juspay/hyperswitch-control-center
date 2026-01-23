open ReconEngineTypes
open ReconEngineDataSourcesEntity

let defaultColumns: array<ReconEngineDataSourcesEntity.transformationHistoryColType> = [
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
      connec => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(
            ~url=`/${path}/${connec.ingestion_history_id}?transformationHistoryId=${connec.transformation_history_id}`,
          ),
          ~authorization,
        )
      }
    },
  )
}
