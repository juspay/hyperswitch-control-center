open ReportsTypes
open LogicUtils

let defaultColumns: array<exceptionColtype> = [
  OrderId,
  TransactionId,
  PaymentGateway,
  PaymentMethod,
  TxnAmount,
  SettlementAmount,
  ExceptionType,
  TransactionDate,
]
let exceptionMatrixColumns: array<exceptionMatrixColType> = [
  Source,
  OrderId,
  TxnAmount,
  PaymentGateway,
  SettlementDate,
  FeeAmount,
]

let getHeading = (colType: exceptionColtype) => {
  switch colType {
  | TransactionId => Table.makeHeaderInfo(~key="transaction_id", ~title="Transaction ID")
  | OrderId => Table.makeHeaderInfo(~key="order_id", ~title="Order ID")
  | PaymentGateway => Table.makeHeaderInfo(~key="payment_gateway", ~title="Payment Gateway")
  | PaymentMethod => Table.makeHeaderInfo(~key="payment_method", ~title="Payment Method")
  | TxnAmount => Table.makeHeaderInfo(~key="txn_amount", ~title="Transaction Amount ($)")
  | SettlementAmount =>
    Table.makeHeaderInfo(~key="settlement_amount", ~title="Settlement Amount ($)")
  | TransactionDate => Table.makeHeaderInfo(~key="transaction_date", ~title="Transaction Date")
  | ExceptionType => Table.makeHeaderInfo(~key="exception_type", ~title="Exception Type")
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
  | PaymentMethod => Text(report.payment_method)
  | ExceptionType =>
    CustomCell(
      <HelperComponents.EllipsisText showCopy=false displayValue={report.exception_type} />,
      "",
    )
  | TransactionDate => EllipsisText(report.transaction_date, "")
  | TxnAmount => Text(Float.toString(report.txn_amount))
  | SettlementAmount => Text(Float.toString(report.settlement_amount))
  }
}

let getExceptionMatrixCell = (
  report: exceptionMatrixPayload,
  colType: exceptionMatrixColType,
): Table.cell => {
  switch colType {
  | Source => Text(report.source)
  | OrderId => Text(report.order_id)
  | TxnAmount => Text(Float.toString(report.txn_amount))
  | PaymentGateway =>
    CustomCell(
      <HelperComponents.ConnectorCustomCell
        connectorName=report.payment_gateway connectorType={Processor}
      />,
      "",
    )
  | SettlementDate => Text(`Expected: ${report.settlement_date->String.slice(~start=0, ~end=6)}`)
  | FeeAmount => Text(Float.toString(report.txn_amount))
  }
}
let getExceptionMatrixHeading = (colType: exceptionMatrixColType) => {
  switch colType {
  | Source => Table.makeHeaderInfo(~key="transaction_id", ~title="Source")
  | OrderId => Table.makeHeaderInfo(~key="order_id", ~title="Order ID")
  | PaymentGateway => Table.makeHeaderInfo(~key="payment_gateway", ~title="Payment Gateway")
  | TxnAmount => Table.makeHeaderInfo(~key="txn_amount", ~title="Transaction Amount ($)")
  | SettlementDate => Table.makeHeaderInfo(~key="settlement_date", ~title="Settlement Date")
  | FeeAmount => Table.makeHeaderInfo(~key="fee_amount", ~title="Fee Amount ($)")
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
  let fixedStatusCss = "text-sm text-white font-semibold px-3  py-1 rounded-md"
  switch order.recon_status->reconStatusVariantMapperForExceptions {
  | Reconciled =>
    <div className={`${fixedStatusCss} bg-nd_green-50 dark:bg-opacity-50 flex gap-2`}>
      <p className="text-nd_green-400"> {orderStatusLabel->React.string} </p>
      <Icon name="nd-tick" customIconColor="text-nd_green-400" />
    </div>
  | Unreconciled =>
    <div className={`${fixedStatusCss} bg-nd_red-50 dark:bg-opacity-50 flex gap-2 `}>
      <p className="text-nd_red-400"> {orderStatusLabel->React.string} </p>
      <Icon name="nd-alert-circle" customIconColor="text-nd_red-400" />
    </div>
  | _ =>
    <div className={`${fixedStatusCss} ${primaryColor} bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  }
}
let getExceptionMatrixPayloadType = dict => {
  {
    source: dict->getString("source", ""),
    order_id: dict->getString("order_id", ""),
    payment_gateway: dict->getString("payment_gateway", ""),
    settlement_date: dict->getString("settlement_date", ""),
    txn_amount: dict->getFloat("txn_amount", 0.0),
    fee_amount: dict->getFloat("fee_amount", 0.0),
  }
}
let getExceptionMatrixList: JSON.t => array<exceptionMatrixPayload> = json => {
  LogicUtils.getArrayDataFromJson(json, getExceptionMatrixPayloadType)
}

let getExceptionReportPayloadType = dict => {
  {
    transaction_id: dict->getString("transaction_id", ""),
    order_id: dict->getString("order_id", ""),
    payment_gateway: dict->getString("payment_gateway", ""),
    payment_method: dict->getString("payment_method", ""),
    recon_status: dict->getString("recon_status", ""),
    txn_amount: dict->getFloat("txn_amount", 0.0),
    exception_type: dict->getString("exception_type", ""),
    transaction_date: dict->getString("transaction_date", ""),
    settlement_amount: dict->getFloat("settlement_amount", 0.0),
    exception_matrix: dict
    ->getArrayFromDict("exception_matrix", [])
    ->JSON.Encode.array
    ->getExceptionMatrixList,
  }
}

let getArrayOfReportsListPayloadType = json => {
  json->Array.map(reportJson => {
    reportJson->getDictFromJsonObject->getExceptionReportPayloadType
  })
}
let getArrayOfReportsAttemptsListPayloadType = json => {
  json->Array.map(reportJson => {
    reportJson->getDictFromJsonObject->getExceptionMatrixPayloadType
  })
}
let getReportsList: JSON.t => array<reportExceptionsPayload> = json => {
  LogicUtils.getArrayDataFromJson(json, getExceptionReportPayloadType)
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
    ~defaultColumns=exceptionMatrixColumns,
    ~getObjects=getExceptionMatrixList,
    ~getHeading=getExceptionMatrixHeading,
    ~getCell=getExceptionMatrixCell,
    ~dataKey="exception_matrix",
  )
}
