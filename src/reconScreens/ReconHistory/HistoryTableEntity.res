open HistoryTypes

type colType =
  | Gateway
  | ReconUuid
  | MerchantId
  | ReconStatus
  | ReconStartedAt
  | FileUuid
  | BatchId
  | SystemAFileId
  | SystemBFileId
  | SystemCFileId
  | ReconEndedAt

let defaultColumns = [
  Gateway,
  ReconUuid,
  MerchantId,
  ReconStatus,
  ReconStartedAt,
  FileUuid,
  BatchId,
  SystemAFileId,
  SystemBFileId,
  SystemCFileId,
  ReconEndedAt,
]

let getHeading = colType => {
  switch colType {
  | Gateway => Table.makeHeaderInfo(~key="gateway", ~title="Gateway")
  | ReconUuid => Table.makeHeaderInfo(~key="recon_uuid", ~title="Recon UUID")
  | MerchantId => Table.makeHeaderInfo(~key="merchant_id", ~title="Merchant Id")
  | ReconStatus => Table.makeHeaderInfo(~key="recon_status", ~title="Recon Status")
  | ReconStartedAt => Table.makeHeaderInfo(~key="recon_started_at", ~title="Recon Started At")
  | FileUuid => Table.makeHeaderInfo(~key="file_uuid", ~title="File UUID")
  | BatchId => Table.makeHeaderInfo(~key="batch_id", ~title="Batch ID")
  | SystemAFileId => Table.makeHeaderInfo(~key="system_a_file_id", ~title="System A File ID")
  | SystemBFileId => Table.makeHeaderInfo(~key="system_b_file_id", ~title="System B File ID")
  | SystemCFileId => Table.makeHeaderInfo(~key="system_c_file_id", ~title="System C File ID")
  | ReconEndedAt => Table.makeHeaderInfo(~key="recon_ended_at", ~title="Recon Ended At")
  }
}

let getCell = (history: historyPayload, colType): Table.cell => {
  switch colType {
  | Gateway =>
    CustomCell(
      <HelperComponents.ConnectorCustomCell
        connectorName=history.gateway connectorType={Processor}
      />,
      "",
    )
  | ReconUuid => EllipsisText(history.recon_uuid, "")
  | MerchantId => Text(history.merchant_id)
  | ReconStatus =>
    Label({
      title: history.recon_status,
      color: switch history.recon_status {
      | "SUCCESS" => LabelGreen
      | "FAILED" => LabelRed
      | _ => LabelOrange
      },
    })
  | ReconStartedAt => Date(history.recon_started_at)
  | FileUuid => EllipsisText(history.file_uuid, "")
  | BatchId => EllipsisText(history.batch_id, "")
  | SystemAFileId => EllipsisText(history.system_a_file_id, "")
  | SystemBFileId => EllipsisText(history.system_b_file_id, "")
  | SystemCFileId => EllipsisText(history.system_c_file_id, "")
  | ReconEndedAt => Date(history.recon_ended_at)
  }
}

let getHistoryList: JSON.t => array<historyPayload> = json => {
  LogicUtils.getArrayDataFromJson(json, HistoryListMapper.getHistoryPayloadType)
}

let historyEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getHistoryList,
    ~defaultColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="history",
    ~getShowLink={
      history =>
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${history.merchant_id}`),
          ~authorization,
        )
    },
  )
}
