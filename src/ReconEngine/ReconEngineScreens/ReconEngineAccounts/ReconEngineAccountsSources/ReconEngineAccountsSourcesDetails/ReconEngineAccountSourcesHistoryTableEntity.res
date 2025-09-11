open ReconEngineFileManagementTypes
open ReconEngineFileManagementEntity

let defaultColumns = [IngestionHistoryId, FileName, IngestionType, ReceivedAt, Status, Actions]

let ingestionHistoryTableEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=_ => [],
    ~defaultColumns,
    ~getHeading=getIngestionHistoryHeading,
    ~getCell=getIngestionHistoryCell,
    ~dataKey="",
    ~getShowLink={
      connec => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${connec.ingestion_history_id}`),
          ~authorization,
        )
      }
    },
  )
}
