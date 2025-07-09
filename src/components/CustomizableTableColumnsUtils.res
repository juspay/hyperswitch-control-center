open LogicUtils
type operationSection =
  | Refunds
  | Orders
  | Payouts
  | Disputes
  | Customers
  | Unkown

let textToVariantMapper = text => {
  switch text {
  | "Orders" => Orders
  | "Refunds" => Refunds
  | "Disputes" => Disputes
  | "Payouts" => Payouts
  | "Customers" => Customers
  | _ => Unkown
  }
}

let createValForLocalStorage = (val, varianType: operationSection) => {
  let optionalValueFromLocalStorage = LocalStorage.getItem("tableColumnsOrder")->Nullable.toOption
  let valueFromLocalStorage = switch optionalValueFromLocalStorage {
  | Some(str) => str
  | _ => ""
  }

  let valueDict =
    valueFromLocalStorage
    ->safeParse
    ->getDictFromJsonObject

  valueDict->Dict.set((varianType :> string), val->Array.toString->JSON.Encode.string)

  let finalString =
    valueDict
    ->JSON.Encode.object
    ->JSON.stringify
  finalString
}

let parseColumnsFromLocalStorage = title => {
  let optionalValueFromLocalStorage = LocalStorage.getItem("tableColumnsOrder")->Nullable.toOption
  let valueFromLocalStorage = switch optionalValueFromLocalStorage {
  | Some(str) => str
  | _ => ""
  }

  let parsedValue =
    valueFromLocalStorage
    ->safeParse
    ->getDictFromJsonObject
    ->getString(title, "")
    ->String.split(",")

  parsedValue
}
