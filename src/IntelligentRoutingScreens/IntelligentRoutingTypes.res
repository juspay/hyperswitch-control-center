type file = Sample | Upload

type reviewFieldsColsType =
  | FileName
  | NumberOfTransaction
  | NumberOfTerminalTransactions
  | NumberOfProcessors

type reviewFields = {
  file_name: string,
  number_of_transaction: int,
  number_of_terminal_transactions: int,
  number_of_processors: int,
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
