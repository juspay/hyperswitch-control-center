type file = Sample | Upload

type dataType = Historical | Realtime
type realtime = StreamLive

type reviewFieldsColsType =
  | FileName
  | NumberOfTransaction
  | NumberOfTerminalTransactions
  | NumberOfProcessors
  | TotalAmount
  | MostUsedProcessor
  | PaymentMethod

type reviewFields = {
  file_name: string,
  number_of_transaction: int,
  number_of_terminal_transactions: int,
  number_of_processors: int,
  most_used_processor: array<string>,
  payment_method: array<string>,
  total_amount: int,
}

type transactionDetails = {
  txn_no: int,
  order_id: string,
  juspay_txn_id: string,
  amount: float,
  payment_gateway: string,
  payment_status: bool,
  payment_method_type: string,
  order_currency: string,
  model_connector: string,
  suggested_uplift: float,
}
