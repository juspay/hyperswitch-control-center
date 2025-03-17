open IntelligentRoutingTypes
open LogicUtils

let defaultColumns = [FileName, TotalAmount, NumberOfTransaction, Processors, PaymentMethod]

let allColumns = [FileName, TotalAmount, NumberOfTransaction, Processors, PaymentMethod]

let getHeading = colType => {
  switch colType {
  | NumberOfTransaction => Table.makeHeaderInfo(~key="total", ~title="Number of Transactions")
  | TotalAmount => Table.makeHeaderInfo(~key="total_amount", ~title="Total Amount")
  | FileName => Table.makeHeaderInfo(~key="file_name", ~title="File Name")
  | Processors => Table.makeHeaderInfo(~key="processors", ~title="Processors")
  | PaymentMethod => Table.makeHeaderInfo(~key="payment_methods", ~title="Payment Methods")
  }
}

let concatStringArray = arr => {
  arr->Array.map(s => s->String.trim)->Array.joinWith(", ")
}

let getCell = (reviewFields, colType): Table.cell => {
  switch colType {
  | NumberOfTransaction => Text(reviewFields.total->Int.toString)
  | TotalAmount => Text(formatAmount(reviewFields.total_amount, "USD"))
  | FileName => Text(reviewFields.file_name)
  | Processors => Text(concatStringArray(reviewFields.processors))
  | PaymentMethod => Text(concatStringArray(reviewFields.payment_methods))
  }
}

let itemToObjMapper = dict => {
  {
    total: dict->getInt("total", 0),
    total_amount: dict->getInt("total_amount", 0),
    file_name: dict->getString("file_name", ""),
    processors: dict->getStrArray("processors"),
    payment_methods: dict->getStrArray("payment_methods"),
  }
}

let getReviewFields: JSON.t => reviewFields = json => {
  json->getDictFromJsonObject->itemToObjMapper
}
