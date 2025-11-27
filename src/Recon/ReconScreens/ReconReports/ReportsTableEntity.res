open ReportsTypes
open ReconReportUtils

let defaultColumns: array<allColtype> = [
  OrderId,
  TransactionId,
  PaymentGateway,
  PaymentMethod,
  TxnAmount,
  SettlementAmount,
  ReconStatus,
  TransactionDate,
]
let allColumns: array<allColtype> = [
  TransactionId,
  OrderId,
  PaymentGateway,
  PaymentMethod,
  TxnAmount,
  SettlementAmount,
  ReconStatus,
  TransactionDate,
]
type reconStatus =
  | Reconciled
  | Unreconciled
  | Missing
  | None

let getHeading = (colType: allColtype) => {
  switch colType {
  | TransactionId => Table.makeHeaderInfo(~key="transaction_id", ~title="Transaction ID")
  | OrderId => Table.makeHeaderInfo(~key="order_id", ~title="Order ID")
  | ReconStatus => Table.makeHeaderInfo(~key="recon_status", ~title="Recon Status")
  | PaymentGateway => Table.makeHeaderInfo(~key="payment_gateway", ~title="Payment Gateway")
  | PaymentMethod => Table.makeHeaderInfo(~key="payment_method", ~title="Payment Method")
  | SettlementAmount =>
    Table.makeHeaderInfo(~key="settlement_amount", ~title="Settlement Amount ($)")
  | TxnAmount => Table.makeHeaderInfo(~key="txn_amount", ~title="Transaction Amount ($)")
  | TransactionDate => Table.makeHeaderInfo(~key="transaction_date", ~title="Transaction Date")
  }
}

let getCell = (report: allReportPayload, colType: allColtype): Table.cell => {
  switch colType {
  | TransactionId => Text(report.transaction_id)
  | OrderId => Text(report.order_id)
  | PaymentGateway =>
    CustomCell(
      <HelperComponents.ConnectorCustomCell
        connectorName=report.payment_gateway connectorType={Processor}
      />,
      "",
    )
  | PaymentMethod => Text(report.payment_method)
  | ReconStatus =>
    Label({
      title: {report.recon_status->String.toUpperCase},
      color: switch report.recon_status->getReconStatusTypeFromString {
      | Reconciled => LabelGreen
      | Unreconciled => LabelRed
      | Missing => LabelOrange
      },
    })
  | TransactionDate => EllipsisText(report.transaction_date, "")
  | SettlementAmount => Text(Float.toString(report.settlement_amount))
  | TxnAmount => Text(Float.toString(report.txn_amount))
  }
}

let reportsEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getReportsList,
    ~defaultColumns,
    ~allColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="reports",
    ~getShowLink={
      connector => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${connector.transaction_id}`),
          ~authorization,
        )
      }
    },
  )
}
