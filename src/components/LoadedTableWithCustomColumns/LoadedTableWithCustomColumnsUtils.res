open LogicUtils

let setColumnValueInLocalStorage = (val, title) => {
  let varianType = title->getNonEmptyString->Option.getOr("Unknown")->String.toLowerCase

  let optionalValueFromLocalStorage = HSLocalStorage.getCustomTableColumnsfromLocalStorage()
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
  HSLocalStorage.setCustomTableHeadersInLocalStorage(finalValue)
}

let retrieveColumnValueFromLocalStorage = title => {
  let optionalValueFromLocalStorage = HSLocalStorage.getCustomTableColumnsfromLocalStorage()
  let valueFromLocalStorage = optionalValueFromLocalStorage->Option.getOr("")

  valueFromLocalStorage
  ->safeParse
  ->getDictFromJsonObject
  ->getString(title->String.toLowerCase, "")
  ->String.split(",")
}
