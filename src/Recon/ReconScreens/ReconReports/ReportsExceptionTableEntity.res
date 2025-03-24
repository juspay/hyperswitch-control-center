open ReportsTypes
open ReconExceptionsUtils

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
  | SettlementDate => Text(`Expected: ${report.settlement_date->String.slice(~start=0, ~end=5)}`)
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

let exceptionReportsEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getExceptionReportsList,
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
