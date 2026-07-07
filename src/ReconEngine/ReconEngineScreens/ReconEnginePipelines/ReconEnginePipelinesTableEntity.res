open ReconEngineTypes
open ReconEngineDataUtils

type pipelineIngestionColType =
  | Account
  | FileName
  | IngestionName
  | Connector
  | Status
  | ReceivedAt
  | Actions

let defaultColumns: array<pipelineIngestionColType> = [
  Account,
  FileName,
  IngestionName,
  Connector,
  Status,
  ReceivedAt,
  Actions,
]

let getPipelineIngestionHeading = colType => {
  switch colType {
  | Account => Table.makeHeaderInfo(~key="account_id", ~title="Account")
  | FileName => Table.makeHeaderInfo(~key="file_name", ~title="File Name")
  | IngestionName => Table.makeHeaderInfo(~key="ingestion_name", ~title="Ingestion Name")
  | Connector => Table.makeHeaderInfo(~key="upload_type", ~title="Connector")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | ReceivedAt => Table.makeHeaderInfo(~key="received_at", ~title="Received At")
  | Actions => Table.makeHeaderInfo(~key="actions", ~title="Actions")
  }
}

let getAccountName = (~accountData: array<accountType>, accountId: string) => {
  accountData
  ->Array.find(account => account.account_id === accountId)
  ->Option.mapOr(accountId, account => account.account_name)
}

let getPipelineIngestionCell = (
  ~accountData: array<accountType>,
  data: ingestionHistoryType,
  colType,
): Table.cell => {
  switch colType {
  | Account => EllipsisText(getAccountName(~accountData, data.account_id), "")
  | FileName => EllipsisText(data.file_name, "")
  | IngestionName => EllipsisText(data.ingestion_name, "")
  | Connector => EllipsisText(data.upload_type, "")
  | Status => getStatusLabel(data.status)
  | ReceivedAt => Date(data.created_at)
  | Actions =>
    CustomCell(
      <ReconEngineDataSourcesHelper.IngestionHistoryActionsComponent ingestionHistory={data} />,
      "",
    )
  }
}

let pipelineIngestionHistoryTableEntity = (
  path: string,
  ~authorization: CommonAuthTypes.authorization,
  ~accountData: array<accountType>,
) => {
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=_ => [],
    ~defaultColumns,
    ~getHeading=getPipelineIngestionHeading,
    ~getCell=(data, colType) => getPipelineIngestionCell(~accountData, data, colType),
    ~dataKey="",
    ~getShowLink={
      connectorObj => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${connectorObj.ingestion_history_id}`),
          ~authorization,
        )
      }
    },
  )
}
