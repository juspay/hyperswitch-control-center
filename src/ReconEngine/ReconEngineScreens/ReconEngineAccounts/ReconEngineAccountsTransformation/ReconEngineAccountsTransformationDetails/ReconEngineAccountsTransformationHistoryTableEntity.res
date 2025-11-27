open ReconEngineTypes
open ReconEngineAccountsSourcesEntity

let defaultColumns: array<ReconEngineAccountsSourcesEntity.transformationHistoryColType> = [
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
      transformationHistory => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(
            ~url=`/${path}/${transformationHistory.ingestion_history_id}?transformationHistoryId=${transformationHistory.transformation_history_id}`,
          ),
          ~authorization,
        )
      }
    },
  )
}
