open ReportsTypes
open LogicUtils

let defaultColumns: array<exceptionColtype> = [
  OrderId,
  TransactionId,
  PaymentGateway,
  PaymentMethod,
  ReconStatus,
  TxnAmount,
  TransactionDate,
  SettlementAmount,
  ExceptionType,
  Actions,
]
let exceptionMatrixColumns: array<exceptionMatrixColType> = [
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
  | TransactionDate => Table.makeHeaderInfo(~key="transaction_date", ~title="Transaction Date")
  | ExceptionType => Table.makeHeaderInfo(~key="exception_type", ~title="Exception Type")
  | Actions => Table.makeHeaderInfo(~key="actions", ~title="Actions")
  | SettlementAmount => Table.makeHeaderInfo(~key="settlement_amount", ~title="Settlement Amount")
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
  | ReconStatus =>
    switch report.recon_status {
    | "Reconciled" =>
      CustomCell(
        <div
          className={`text-sm  font-bold px-2 py-0.5  rounded-lg  bg-nd_green-50 dark:bg-opacity-50 flex items-center h-7 w-fit gap-1`}>
          <p className="text-nd_green-400"> {report.recon_status->React.string} </p>
          <Icon name="nd-check" customIconColor="text-nd_green-400" />
        </div>,
        "",
      )
    | "Unreconciled" =>
      CustomCell(
        <div
          className={`text-sm font-bold px-2 py-0.5 rounded-lg bg-nd_red-50 dark:bg-opacity-50 h-7 flex gap-1 w-fit items-center`}>
          <p className="text-nd_red-400"> {report.recon_status->React.string} </p>
          <Icon name="nd-info-circle" customIconColor="text-nd_red-400" />
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
  | PaymentMethod => Text(report.payment_method)
  | ExceptionType =>
    CustomCell(
      <HelperComponents.EllipsisText showCopy=false displayValue={report.exception_type} />,
      "",
    )
  | TransactionDate => Date(report.transaction_date)
  | TxnAmount => Text(Js.Float.toString(report.txn_amount))
  | Actions => CustomCell(<Icon name="nd-external-link-square" size=16 />, "")
  | SettlementAmount => Text(Js.Float.toString(report.settlement_amount))
  }
}

let getExceptionMatrixCell = (
  report: exceptionMatrixPayload,
  colType: exceptionMatrixColType,
): Table.cell => {
  switch colType {
  | Source => Text(report.source)
  | OrderId => Text(report.order_id)
  | TxnAmount => Text(Js.Float.toString(report.txn_amount))
  | PaymentGateway =>
    CustomCell(
      <HelperComponents.ConnectorCustomCell
        connectorName=report.payment_gateway connectorType={Processor}
      />,
      "",
    )
  | SettlmentDate => Text(Js.Float.toString(report.settlement_date))
  | FeeAmount => Text(Js.Float.toString(report.txn_amount))
  }
}
let getExceptionMatrixHeading = (colType: exceptionMatrixColType) => {
  switch colType {
  | Source => Table.makeHeaderInfo(~key="transaction_id", ~title="Source")
  | OrderId => Table.makeHeaderInfo(~key="order_id", ~title="Order Id")
  | PaymentGateway => Table.makeHeaderInfo(~key="payment_gateway", ~title="Payment Gateway")
  | TxnAmount => Table.makeHeaderInfo(~key="txn_amount", ~title="Txn Amount")
  | SettlmentDate => Table.makeHeaderInfo(~key="settlement_date", ~title="Settlement Date")
  | FeeAmount => Table.makeHeaderInfo(~key="fee_amount", ~title="Fee Amount")
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
  let fixedStatusCss = "text-sm text-white font-bold px-3  py-1 rounded-md"
  switch order.recon_status->reconStatusVariantMapperForExceptions {
  | Reconciled =>
    <div className={`${fixedStatusCss} bg-nd_green-50 dark:bg-opacity-50 flex gap-2`}>
      <p className="text-nd_green-400"> {orderStatusLabel->React.string} </p>
      <Icon name="nd-check" customIconColor="text-nd_green-400" />
    </div>
  | Unreconciled =>
    <div className={`${fixedStatusCss} bg-nd_red-50 dark:bg-opacity-50 flex gap-2 `}>
      <p className="text-nd_red-400"> {orderStatusLabel->React.string} </p>
      <Icon name="nd-info-circle" customIconColor="text-nd_red-400" />
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
    settlement_date: dict->getFloat("settlement_date", 0.0),
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
    actions: dict->getString("actions", ""),
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
