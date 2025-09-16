open ReconEngineTypes
open ReconEngineAccountsSourcesEntity

let defaultColumns: array<ReconEngineAccountsSourcesEntity.transformationHistoryColType> = [
  TransformationHistoryId,
  TotalRecords,
  ProcessedCount,
  IgnoredCount,
  ErrorCount,
  Status,
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
