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
let reconStatusVariantMapper: string => reconStatus = statusLabel =>
  switch statusLabel->String.toUpperCase {
  | "RECONCILED" => Reconciled
  | "UNRECONCILED" => Unreconciled
  | "MISSING" => Missing
  | _ => None
  }

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
    switch report.recon_status->getReconStatusTypeFromString {
    | Reconciled =>
      CustomCell(
        <div
          className={`text-sm  font-bold px-2 py-1 rounded-lg  bg-nd_green-50 dark:bg-opacity-50 flex items-center gap-1 w-fit`}>
          <p className="text-nd_green-400"> {report.recon_status->React.string} </p>
          <Icon name="nd-tick" size=12 customIconColor="text-nd_green-400" />
        </div>,
        "",
      )
    | Unreconciled =>
      CustomCell(
        <div
          className={`text-sm font-bold px-2 py-1 rounded-lg bg-nd_red-50 dark:bg-opacity-50 flex gap-1 items-center w-fit`}>
          <p className="text-nd_red-400"> {report.recon_status->React.string} </p>
          <Icon name="nd-alert-circle" size=12 customIconColor="text-nd_red-400" />
        </div>,
        "",
      )
    | Missing =>
      CustomCell(
        <div
          className={`text-sm font-bold px-2 py-1 rounded-lg bg-orange-50 dark:bg-opacity-50 flex gap-1 items-center w-fit`}>
          <p className="text-orange-400"> {report.recon_status->React.string} </p>
          <Icon name="nd-alert-circle" size=12 customIconColor="text-orange-400" />
        </div>,
        "",
      )
    }

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
      connec => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${connec.transaction_id}`),
          ~authorization,
        )
      }
    },
  )
}
