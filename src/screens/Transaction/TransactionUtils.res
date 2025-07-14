open LogicUtils
type operationSection =
  | Refunds
  | Orders
  | Payouts
  | Disputes
  | Customers
  | Unknown

let textToVariantMapper = text => {
  switch text {
  | "Orders" => Orders
  | "Refunds" => Refunds
  | "Disputes" => Disputes
  | "Payouts" => Payouts
  | "Customers" => Customers
  | _ => Unknown
  }
}

let setColumnValueInLocalStorage = (val, title) => {
  let varianType = title->textToVariantMapper
  let optionalValueFromLocalStorage = HyperSwitchEntryUtils.getCustomTableColumnsfromStore()
  let valueFromLocalStorage = optionalValueFromLocalStorage->Option.getOr("")

  let valueDict =
    valueFromLocalStorage
    ->safeParse
    ->getDictFromJsonObject

  valueDict->Dict.set((varianType :> string), val->Array.toString->JSON.Encode.string)

  let finalValue =
    valueDict
    ->JSON.Encode.object
    ->JSON.stringify
  HyperSwitchEntryUtils.setCustomTableHeaders(finalValue)
}

let retrieveColumnValueFromLocalStorage = title => {
  let optionalValueFromLocalStorage = HyperSwitchEntryUtils.getCustomTableColumnsfromStore()
  let valueFromLocalStorage = optionalValueFromLocalStorage->Option.getOr("")

  valueFromLocalStorage
  ->safeParse
  ->getDictFromJsonObject
  ->getString(title, "")
  ->String.split(",")
}
