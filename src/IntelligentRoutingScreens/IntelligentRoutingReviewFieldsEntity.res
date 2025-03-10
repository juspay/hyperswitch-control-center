open IntelligentRoutingTypes
open LogicUtils

let defaultColumns = [
  FileName,
  NumberOfTransaction,
  NumberOfTerminalTransactions,
  NumberOfProcessors,
]

let allColumns = [FileName, NumberOfTransaction, NumberOfTerminalTransactions, NumberOfProcessors]

let getHeading = colType => {
  switch colType {
  | FileName => Table.makeHeaderInfo(~key="file_name", ~title="File Name")
  | NumberOfTransaction =>
    Table.makeHeaderInfo(~key="number_of_transaction", ~title="Number of Transaction")
  | NumberOfTerminalTransactions =>
    Table.makeHeaderInfo(
      ~key="number_of_terminal_transactions",
      ~title="Number of Terminal Transactions",
    )
  | NumberOfProcessors =>
    Table.makeHeaderInfo(~key="number_of_processors", ~title="Number of Processors")
  }
}

let getCell = (reviewFields, colType): Table.cell => {
  switch colType {
  | FileName => Text(reviewFields.file_name)
  | NumberOfTransaction => Text(reviewFields.number_of_transaction->Int.toString)
  | NumberOfTerminalTransactions => Text(reviewFields.number_of_terminal_transactions->Int.toString)
  | NumberOfProcessors => Text(reviewFields.number_of_processors->Int.toString)
  }
}

let itemToObjMapper = dict => {
  {
    file_name: dict->getString("fileName", ""),
    number_of_transaction: dict->getInt("number_of_transaction", 0),
    number_of_terminal_transactions: dict->getInt("number_of_terminal_transactions", 0),
    number_of_processors: dict->getInt("number_of_processors", 0),
  }
}

let getReviewFields: JSON.t => reviewFields = json => {
  json->getDictFromJsonObject->itemToObjMapper
}
