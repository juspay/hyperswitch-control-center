open LogicUtils
let groupByField = (data, fieldName) => {
  data->Array.reduce(Dict.make(), (acc, item) => {
    let fieldValue = item->getDictFromJsonObject->getString(fieldName, "Unknown")
    acc->Dict.set(fieldValue, [...acc->getArrayFromDict(fieldValue, []), item]->JSON.Encode.array)
    acc
  })
}

let sumIntField = (records: array<JSON.t>, fieldName: string) => {
  records->Array.reduce(0, (acc, record) => {
    acc + record->getDictFromJsonObject->getInt(fieldName, 0)
  })
}

let sumFloatField = (records: array<JSON.t>, fieldName: string) => {
  records->Array.reduce(0.0, (acc, record) => {
    acc +. record->getDictFromJsonObject->getFloat(fieldName, 0.0)
  })
}

let calculateTrafficPercentage = (part: int, total: int) => {
  total > 0 ? Int.toFloat(part) /. Int.toFloat(total) *. 100.0 : 0.0
}

let customLegendFormatter = () => {
  (
    @this
    (this: PieGraphTypes.legendLabelFormatter) => {
      this.name->snakeToTitle
    }
  )->PieGraphTypes.asLegendPointFormatter
}
let defaultGranularityOptionsObject: NewAnalyticsTypes.optionType = {
  label: "",
  value: "",
}
