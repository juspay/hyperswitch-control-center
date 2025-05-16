open InsightsTypes

let defaultCurrency = {
  label: "All Currencies (Converted to USD*)",
  value: (#all_currencies: defaultFilters :> string),
}

let getOptions = json => {
  open LogicUtils
  let currencies = []

  json
  ->getDictFromJsonObject
  ->getArrayFromDict("queryData", [])
  ->Array.forEach(value => {
    let valueDict = value->getDictFromJsonObject
    let key = valueDict->getString("dimension", "")

    if key == (#currency: filters :> string) {
      let values =
        valueDict
        ->getArrayFromDict("values", [])
        ->Array.map(item => {
          item->JSON.Decode.string->Option.getOr("")
        })
        ->Array.filter(isNonEmptyString)
        ->Array.map(item => {label: item->snakeToTitle, value: item})

      let values = [defaultCurrency]->Array.concat(values)

      currencies->Array.pushMany(values)
    }
  })

  currencies
}
