type url = All | Exceptions
type reconStatus = Reconciled | Unreconciled | Missing
type exceptionType = AmountMismatch | StatusMismatch | Both | Resolved

type reportCommonPayload = {
  transaction_id: string,
  order_id: string,
  payment_gateway: string,
  payment_method: string,
  txn_amount: float,
  recon_status: string,
  transaction_date: string,
  settlement_amount: float,
}
type allReportPayload = {
  ...reportCommonPayload,
}
type exceptionMatrixPayload = {
  source: string,
  order_id: string,
  txn_amount: float,
  payment_gateway: string,
  settlement_date: string,
  fee_amount: float,
}

type reportExceptionsPayload = {
  ...reportCommonPayload,
  exception_type: string,
  exception_matrix: array<exceptionMatrixPayload>,
}

type commonColType =
  | TransactionId
  | OrderId
  | PaymentGateway
  | PaymentMethod
  | TxnAmount
  | SettlementAmount
  | TransactionDate

type allColtype = ReconStatus | ...commonColType

type exceptionColtype =
  | ...commonColType
  | ExceptionType

type exceptionMatrixColType =
  | Source
  | OrderId
  | TxnAmount
  | PaymentGateway
  | SettlementDate
  | FeeAmount
