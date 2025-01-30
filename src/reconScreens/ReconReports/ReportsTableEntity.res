open ReportsTypes

type colType =
  | Gateway
  | MerchantId
  | PaymentEntityTxnId
  | ReconId
  | ReconStatus
  | ReconSubStatus
  | ReconciledAt
  | SettlementAmount
  | SettlementId
  | TxnAmount
  | TxnCurrency
  | TxnType

let defaultColumns = [
  Gateway,
  MerchantId,
  PaymentEntityTxnId,
  ReconId,
  ReconStatus,
  ReconSubStatus,
  ReconciledAt,
  SettlementAmount,
  SettlementId,
  TxnAmount,
  TxnCurrency,
  TxnType,
]

let getHeading = colType => {
  switch colType {
  | Gateway => Table.makeHeaderInfo(~key="gateway", ~title="Gateway")
  | MerchantId => Table.makeHeaderInfo(~key="merchant_id", ~title="Merchant Id")
  | PaymentEntityTxnId =>
    Table.makeHeaderInfo(~key="payment_entity_txn_id", ~title="Payment Entity Txn Id")
  | ReconId => Table.makeHeaderInfo(~key="recon_id", ~title="Recon Id")
  | ReconStatus => Table.makeHeaderInfo(~key="recon_status", ~title="Recon Status")
  | ReconSubStatus => Table.makeHeaderInfo(~key="recon_sub_status", ~title="Recon Sub Status")
  | ReconciledAt => Table.makeHeaderInfo(~key="reconciled_at", ~title="Reconciled At")
  | SettlementAmount => Table.makeHeaderInfo(~key="settlement_amount", ~title="Settlement Amount")
  | SettlementId => Table.makeHeaderInfo(~key="settlement_id", ~title="Settlement Id")
  | TxnAmount => Table.makeHeaderInfo(~key="txn_amount", ~title="Txn Amount")
  | TxnCurrency => Table.makeHeaderInfo(~key="txn_currency", ~title="Txn Currency")
  | TxnType => Table.makeHeaderInfo(~key="txn_type", ~title="Txn Type")
  }
}

let getCell = (report: reportPayload, colType): Table.cell => {
  switch colType {
  | Gateway =>
    CustomCell(
      <HelperComponents.ConnectorCustomCell
        connectorName=report.gateway connectorType={Processor}
      />,
      "",
    )
  | MerchantId => Text(report.merchant_id)
  | PaymentEntityTxnId => Text(report.payment_entity_txn_id)
  | ReconId => EllipsisText(report.recon_id, "")
  | ReconStatus =>
    Label({
      title: report.recon_status,
      color: switch report.recon_status {
      | "MATCHED" => LabelGreen
      | "MISMATCH" => LabelRed
      | _ => LabelOrange
      },
    })
  | ReconSubStatus => Text(report.recon_sub_status)
  | ReconciledAt => Date(report.reconciled_at)
  | SettlementAmount => Text(Js.Float.toString(report.settlement_amount))
  | SettlementId => EllipsisText(report.settlement_id, "")
  | TxnAmount => Text(Js.Float.toString(report.txn_amount))
  | TxnCurrency => Text(report.txn_currency)
  | TxnType =>
    ColoredText({
      title: report.txn_type,
      color: switch report.txn_type {
      | "ORDER" => LabelGreen
      | "REFUND" => LabelRed
      | _ => LabelOrange
      },
    })
  }
}

let getPreviouslyConnectedList: JSON.t => array<reportPayload> = json => {
  LogicUtils.getArrayDataFromJson(json, ReportsListMapper.getReportPayloadType)
}

let reportsEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getPreviouslyConnectedList,
    ~defaultColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="",
    ~getShowLink={
      connec =>
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${connec.merchant_id}`),
          ~authorization,
        )
    },
  )
}
