open ReconEngineAccountsSourcesEntity

let defaultColumns: array<ingestionHistoryColType> = [
  IngestionHistoryId,
  FileName,
  IngestionType,
  ReceivedAt,
  Status,
  Actions,
]

let ingestionHistoryTableEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=_ => [],
    ~defaultColumns,
    ~getHeading=getIngestionHistoryHeading,
    ~getCell=getIngestionHistoryCell,
    ~dataKey="",
    ~getShowLink={
      connector => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${connector.ingestion_history_id}`),
          ~authorization,
        )
      }
    },
  )
}
