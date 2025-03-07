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
