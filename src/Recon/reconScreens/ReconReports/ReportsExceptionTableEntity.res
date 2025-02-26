open ReportsTypes
open LogicUtils

let defaultColumns: array<exceptionColtype> = [
  TransactionId,
  OrderId,
  PaymentGateway,
  PaymentMethod,
  TxnAmount,
  MismatchAmount,
  ExceptionStatus,
  ExceptionType,
  LastUpdated,
  Actions,
]
let attemptColumns: array<exceptionAttemptsColType> = [
  Source,
  OrderId,
  TxnAmount,
  PaymentGateway,
  SettlmentDate,
  FeeAmount,
]

let getHeading = (colType: exceptionColtype) => {
  switch colType {
  | TransactionId => Table.makeHeaderInfo(~key="transaction_id", ~title="Transaction Id")
  | OrderId => Table.makeHeaderInfo(~key="order_id", ~title="Order Id")
  | ReconStatus => Table.makeHeaderInfo(~key="recon_status", ~title="Recon Status")
  | PaymentGateway => Table.makeHeaderInfo(~key="payment_gateway", ~title="Payment Gateway")
  | PaymentMethod => Table.makeHeaderInfo(~key="payment_method", ~title="Payment Method")
  | TxnAmount => Table.makeHeaderInfo(~key="txn_amount", ~title="Txn Amount")
  | MismatchAmount => Table.makeHeaderInfo(~key="settlement_id", ~title="Mismatch Id")
  | ExceptionStatus => Table.makeHeaderInfo(~key="recon_status", ~title="Exception Status")
  | ExceptionType => Table.makeHeaderInfo(~key="transaction_date", ~title="Exception Type")
  | LastUpdated => Table.makeHeaderInfo(~key="transaction_date", ~title="Last Updated")
  | Actions => Table.makeHeaderInfo(~key="actions", ~title="Actions")
  }
}
let getCell = (report: reportExceptionsPayload, colType: exceptionColtype): Table.cell => {
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
  | ReconStatus => Text(report.recon_status)
  | PaymentMethod => Text(report.payment_method)
  | ExceptionStatus => Text(report.payment_method)
  | ExceptionType => Text(report.payment_method)
  | TxnAmount => Text(Js.Float.toString(report.txn_amount))
  | LastUpdated => Text(Js.Float.toString(report.txn_amount))
  | MismatchAmount => Text(Js.Float.toString(report.mismatch_amount))
  | Actions => CustomCell(<Icon name="external-link-alt" />, "")
  }
}

let getAttemptsCell = (
  report: exceptionAttemptsPayload,
  colType: exceptionAttemptsColType,
): Table.cell => {
  switch colType {
  | Source => Text(report.payment_gateway)
  | OrderId => Text(report.order_id)
  | TxnAmount => Text(Js.Float.toString(report.txn_amount))
  | PaymentGateway =>
    CustomCell(
      <HelperComponents.ConnectorCustomCell
        connectorName=report.payment_gateway connectorType={Processor}
      />,
      "",
    )
  | SettlmentDate => Text(Js.Float.toString(report.txn_amount))
  | FeeAmount => Text(Js.Float.toString(report.txn_amount))
  }
}
let getAttemptsHeading = (colType: exceptionAttemptsColType) => {
  switch colType {
  | Source => Table.makeHeaderInfo(~key="transaction_id", ~title="Transaction Id")
  | OrderId => Table.makeHeaderInfo(~key="order_id", ~title="Order Id")
  | PaymentGateway => Table.makeHeaderInfo(~key="payment_gateway", ~title="Payment Gateway")
  | TxnAmount => Table.makeHeaderInfo(~key="txn_amount", ~title="Txn Amount")
  | SettlmentDate => Table.makeHeaderInfo(~key="txn_amount", ~title="Txn Amount")
  | FeeAmount => Table.makeHeaderInfo(~key="txn_amount", ~title="Txn Amount")
  }
}
type reconStatusForExceptions =
  | Reconciled
  | Unreconciled
  | None

let reconStatusVariantMapperForExceptions: string => reconStatusForExceptions = statusLabel =>
  switch statusLabel->String.toUpperCase {
  | "RECONCILED" => Reconciled
  | "UNRECONCILED" => Unreconciled
  | _ => None
  }
let useGetStatus = (order: reportExceptionsPayload) => {
  let {globalUIConfig: {primaryColor}} = React.useContext(ThemeProvider.themeContext)
  let orderStatusLabel = order.recon_status->capitalizeString
  let fixedStatusCss = "text-sm text-white font-bold px-3 py-2 rounded-md"
  switch order.recon_status->reconStatusVariantMapperForExceptions {
  | Reconciled =>
    <div className={`${fixedStatusCss} bg-hyperswitch_green dark:bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | Unreconciled =>
    <div className={`${fixedStatusCss} bg-nd_red-50 dark:bg-opacity-50 flex gap-2`}>
      <p className="text-nd_red-400"> {orderStatusLabel->React.string} </p>
      <Icon name="info-circle" customIconColor="text-nd_red-400" />
    </div>
  | _ =>
    <div className={`${fixedStatusCss} ${primaryColor} bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  }
}

let getExceptionReportPayloadType = dict => {
  {
    transaction_id: dict->getString("transaction_id", ""),
    order_id: dict->getString("order_id", ""),
    payment_gateway: dict->getString("payment_gateway", ""),
    payment_method: dict->getString("payment_method", ""),
    recon_status: dict->getString("recon_status", ""),
    txn_amount: dict->getFloat("txn_amount", 0.0),
    mismatch_amount: dict->getFloat("mismatch_amount", 0.0),
    exception_status: dict->getString("exception_status", ""),
    exception_type: dict->getString("exception_type", ""),
    last_updated: dict->getString("last_updated", ""),
    actions: dict->getString("actions", ""),
  }
}

let getExceptionAttemptsPayloadType = dict => {
  {
    source: dict->getString("transaction_id", ""),
    order_id: dict->getString("order_id", ""),
    payment_gateway: dict->getString("payment_gateway", ""),
    settlement_date: dict->getString("payment_gateway", ""),
    txn_amount: dict->getFloat("txn_amount", 0.0),
    fee_amount: dict->getFloat("mismatch_amount", 0.0),
  }
}
let getArrayOfReportsListPayloadType = json => {
  json->Array.map(reportJson => {
    reportJson->getDictFromJsonObject->getExceptionReportPayloadType
  })
}
let getArrayOfReportsAttemptsListPayloadType = json => {
  json->Array.map(reportJson => {
    reportJson->getDictFromJsonObject->getExceptionAttemptsPayloadType
  })
}
let getReportsList: JSON.t => array<reportExceptionsPayload> = json => {
  LogicUtils.getArrayDataFromJson(json, getExceptionReportPayloadType)
}

let getAttemptsList: JSON.t => array<exceptionAttemptsPayload> = json => {
  LogicUtils.getArrayDataFromJson(json, getExceptionAttemptsPayloadType)
}

let reportsEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getReportsList,
    ~defaultColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="reports",
    ~getShowLink={
      connec =>
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${connec.transaction_id}`),
          ~authorization,
        )
    },
  )
}

let exceptionAttemptsEntity = () => {
  EntityType.makeEntity(
    ~uri=``,
    ~defaultColumns=attemptColumns,
    ~getObjects=getAttemptsList,
    ~getHeading=getAttemptsHeading,
    ~getCell=getAttemptsCell,
    ~dataKey="reporsdxsdts",
  )
}
