type reportCommonPayload = {
  transaction_id: string,
  order_id: string,
  payment_gateway: string,
  payment_method: string,
  txn_amount: float,
  actions: string,
  recon_status: string,
}
type allReportPayload = {
  ...reportCommonPayload,
  settlement_amount: float,
  transaction_date: string,
}

type reportExceptionsPayload = {
  ...reportCommonPayload,
  mismatch_amount: float,
  exception_status: string,
  exception_type: string,
  last_updated: string,
}
type exceptionAttemptsPayload = {
  source: string,
  order_id: string,
  txn_amount: float,
  payment_gateway: string,
  settlement_date: string,
  fee_amount: float,
}

type commonColType =
  | TransactionId
  | OrderId
  | PaymentGateway
  | PaymentMethod
  | TxnAmount
  | Actions
  | ReconStatus

type allColtype =
  | ...commonColType
  | SettlementAmount
  | TransactionDate

type exceptionColtype =
  | ...commonColType
  | MismatchAmount
  | ExceptionStatus
  | ExceptionType
  | LastUpdated

type exceptionAttemptsColType =
  | Source
  | OrderId
  | TxnAmount
  | PaymentGateway
  | SettlmentDate
  | FeeAmount
