open ReportsTypes
open LogicUtils

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
  | None
let reconStatusVariantMapper: string => reconStatus = statusLabel =>
  switch statusLabel->String.toUpperCase {
  | "RECONCILED" => Reconciled
  | "UNRECONCILED" => Unreconciled
  | _ => None
  }
let useGetAllReportStatus = (order: allReportPayload) => {
  let {globalUIConfig: {primaryColor}} = React.useContext(ThemeProvider.themeContext)
  let orderStatusLabel = order.recon_status->capitalizeString
  let fixedStatusCss = "text-xs text-white font-semibold px-2 py-1 rounded flex items-center gap-2"
  switch order.recon_status->reconStatusVariantMapper {
  | Reconciled =>
    <div className={`${fixedStatusCss}  bg-nd_green-50 dark:bg-opacity-50`}>
      <p className="text-nd_green-400"> {orderStatusLabel->React.string} </p>
      <Icon name="nd-tick" size=12 customIconColor="text-nd_green-400" />
    </div>
  | Unreconciled =>
    <div className={`${fixedStatusCss} bg-nd_red-50 dark:bg-opacity-50`}>
      <p className="text-nd_red-400"> {orderStatusLabel->React.string} </p>
      <Icon name="nd-alert-circle" size=12 customIconColor="text-nd_red-400" />
    </div>
  | _ =>
    <div className={`${fixedStatusCss} ${primaryColor} bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  }
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
    switch report.recon_status {
    | "Reconciled" =>
      CustomCell(
        <div
          className={`text-sm  font-bold px-2 py-1 rounded-lg  bg-nd_green-50 dark:bg-opacity-50 flex items-center gap-1 w-fit`}>
          <p className="text-nd_green-400"> {report.recon_status->React.string} </p>
          <Icon name="nd-tick" size=12 customIconColor="text-nd_green-400" />
        </div>,
        "",
      )
    | "Unreconciled" =>
      CustomCell(
        <div
          className={`text-sm font-bold px-2 py-1 rounded-lg bg-nd_red-50 dark:bg-opacity-50 flex gap-1 items-center w-fit`}>
          <p className="text-nd_red-400"> {report.recon_status->React.string} </p>
          <Icon name="nd-alert-circle" size=12 customIconColor="text-nd_red-400" />
        </div>,
        "",
      )
    | _ =>
      CustomCell(
        <div className={`text-sm text-white font-bold px-3 py-2 border rounded-lg bg-opacity-50`}>
          {report.recon_status->React.string}
        </div>,
        "",
      )
    }

  | TransactionDate => EllipsisText(report.transaction_date, "")
  | SettlementAmount => Text(Float.toString(report.settlement_amount))
  | TxnAmount => Text(Float.toString(report.txn_amount))
  }
}

let getAllReportPayloadType = dict => {
  {
    transaction_id: dict->getString("transaction_id", ""),
    order_id: dict->getString("order_id", ""),
    payment_gateway: dict->getString("payment_gateway", ""),
    payment_method: dict->getString("payment_method", ""),
    txn_amount: dict->getFloat("txn_amount", 0.0),
    settlement_amount: dict->getFloat("settlement_amount", 0.0),
    recon_status: dict->getString("recon_status", ""),
    transaction_date: dict->getString("transaction_date", ""),
  }
}

let getArrayOfReportsListPayloadType = json => {
  json->Array.map(reportJson => {
    reportJson->getDictFromJsonObject->getAllReportPayloadType
  })
}

let getReportsList: JSON.t => array<allReportPayload> = json => {
  LogicUtils.getArrayDataFromJson(json, getAllReportPayloadType)
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
