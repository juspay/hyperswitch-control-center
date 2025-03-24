open IntelligentRoutingTypes
open LogicUtils

let defaultColumns = [FileName, TotalAmount, NumberOfTransaction, Processors, PaymentMethodTypes]

let allColumns = [FileName, TotalAmount, NumberOfTransaction, Processors, PaymentMethodTypes]

let getHeading = colType => {
  switch colType {
  | NumberOfTransaction => Table.makeHeaderInfo(~key="total", ~title="Number of Transactions")
  | TotalAmount => Table.makeHeaderInfo(~key="total_amount", ~title="Total Amount")
  | FileName => Table.makeHeaderInfo(~key="file_name", ~title="File Name")
  | Processors => Table.makeHeaderInfo(~key="processors", ~title="Processors")
  | PaymentMethodTypes =>
    Table.makeHeaderInfo(~key="payment_method_types", ~title="Payment Method Types")
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
  | PaymentMethodTypes =>
    Text(concatStringArray(reviewFields.payment_method_types->Array.map(LogicUtils.getTitle)))
  }
}

let itemToObjMapper = dict => {
  {
    total: dict->getInt("total", 0),
    total_amount: dict->getInt("total_amount", 0),
    file_name: dict->getString("file_name", ""),
    processors: dict->getStrArray("processors"),
    payment_method_types: dict->getStrArray("payment_method_types"),
  }
}

let getReviewFields: JSON.t => reviewFields = json => {
  json->getDictFromJsonObject->itemToObjMapper
}
