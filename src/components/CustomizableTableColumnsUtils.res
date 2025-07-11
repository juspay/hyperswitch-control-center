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

let createValForLocalStorage = (val, varianType: operationSection) => {

  let optionalValueFromLocalStorage = HyperSwitchEntryUtils.getCustomTableColumnsfromStore()
  let valueFromLocalStorage = optionalValueFromLocalStorage->Option.getOr("")

  let valueDict =
    valueFromLocalStorage
    ->safeParse
    ->getDictFromJsonObject

  valueDict->Dict.set((varianType :> string), val->Array.toString->JSON.Encode.string)

  valueDict
  ->JSON.Encode.object
  ->JSON.stringify
}

let parseColumnsFromLocalStorage = title => {
  let optionalValueFromLocalStorage = HyperSwitchEntryUtils.getCustomTableColumnsfromStore()
  let valueFromLocalStorage = optionalValueFromLocalStorage->Option.getOr("")

  valueFromLocalStorage
  ->safeParse
  ->getDictFromJsonObject
  ->getString(title, "")
  ->String.split(",")
}
