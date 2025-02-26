open ReportsTypes
open LogicUtils

let defaultColumns: array<allColtype> = [
  TransactionId,
  OrderId,
  PaymentGateway,
  PaymentMethod,
  TxnAmount,
  SettlementAmount,
  ReconStatus,
  TransactionDate,
  Actions,
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
  Actions,
]
type reconStatus =
  | Reconciled
  | Unreconciled
  | None
let reconStatusVariantMapper: string => reconStatus = statusLabel =>
  switch statusLabel->String.toUpperCase {
  | "Reconciled" => Reconciled
  | "Unreconciled" => Unreconciled
  | _ => None
  }
let useGetAllReportStatus = (order: allReportPayload) => {
  let {globalUIConfig: {primaryColor}} = React.useContext(ThemeProvider.themeContext)
  let orderStatusLabel = order.recon_status->String.toUpperCase
  let fixedStatusCss = "text-sm text-white font-bold px-3 py-2 rounded-md"
  switch order.recon_status->reconStatusVariantMapper {
  | Reconciled =>
    <div className={`${fixedStatusCss} bg-hyperswitch_green dark:bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | Unreconciled =>
    <div className={`${fixedStatusCss} bg-red-960 dark:bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | _ =>
    <div className={`${fixedStatusCss} ${primaryColor} bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  }
}

let getHeading = (colType: allColtype) => {
  switch colType {
  | TransactionId => Table.makeHeaderInfo(~key="transaction_id", ~title="Transaction Id")
  | OrderId => Table.makeHeaderInfo(~key="merchant_id", ~title="Merchant Id")
  | ReconStatus => Table.makeHeaderInfo(~key="recon_status", ~title="Recon Status")
  | PaymentGateway => Table.makeHeaderInfo(~key="payment_gateway", ~title="Payment Gateway")
  | PaymentMethod => Table.makeHeaderInfo(~key="payment_method", ~title="Payment Method")
  | SettlementAmount => Table.makeHeaderInfo(~key="settlement_amount", ~title="Settlement Amount")
  | TxnAmount => Table.makeHeaderInfo(~key="txn_amount", ~title="Txn Amount")
  | TransactionDate => Table.makeHeaderInfo(~key="transaction_date", ~title="Transaction Date")
  | Actions => Table.makeHeaderInfo(~key="actions", ~title="Actions")
  }
}

let getCell = (report: allReportPayload, colType: allColtype): Table.cell => {
  switch colType {
  | TransactionId => Text(report.transaction_id)
  | OrderId => Text(report.order_id)
  | PaymentGateway => Text(report.payment_gateway)
  | PaymentMethod => Text(report.payment_method)
  | ReconStatus =>
    Label({
      title: report.recon_status,
      color: switch report.recon_status {
      | "Reconciled" => LabelGreen
      | "Unreconciled" => LabelRed
      | _ => LabelOrange
      },
    })
  | TransactionDate => Date(report.transaction_date)
  | SettlementAmount => Text(Js.Float.toString(report.settlement_amount))
  | TxnAmount => Text(Js.Float.toString(report.txn_amount))
  | Actions => CustomCell(<Icon name="external-link-alt" />, "")
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
    actions: dict->getString("actions", ""),
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
