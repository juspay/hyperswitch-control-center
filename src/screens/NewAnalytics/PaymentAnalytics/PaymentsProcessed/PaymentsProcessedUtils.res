open PaymentsProcessedTypes
open NewPaymentAnalyticsUtils
open LogicUtils

let colMapper = (col: paymentsProcessedCols) => {
  switch col {
  | Count => "count"
  | Amount => "amount"
  | TimeBucket => "time_bucket"
  }
}

let paymentsProcessedMapper = (
  ~data: JSON.t,
  ~xKey: string,
  ~yKey: string,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  let categories = getCategories(data, yKey)
  let data = getLineGraphData(data, xKey)
  let title = {
    text: "USD",
  }
  {categories, data, title}
}

let getMetaData = json =>
  json
  ->getArrayFromJson([])
  ->getValueFromArray(0, JSON.Encode.array([]))
  ->getDictFromJsonObject
  ->getArrayFromDict("metaData", [])
  ->getValueFromArray(0, JSON.Encode.array([]))
  ->getDictFromJsonObject

let graphTitle = json => {
  let totalAmount = getMetaData(json)->getInt("amount", 0)
  let currency = getMetaData(json)->getString("currency", "")

  totalAmount->Int.toString ++ " " ++ currency
}

let visibleColumns = [Count, Amount, TimeBucket]

let tableItemToObjMapper: Dict.t<JSON.t> => paymentsProcessedObject = dict => {
  {
    count: dict->getInt(Count->colMapper, 0),
    amount: dict->getFloat(Amount->colMapper, 0.0),
    time_bucket: dict->getString(TimeBucket->colMapper, "NA"),
  }
}

let getObjects: JSON.t => array<paymentsProcessedObject> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  let key = colType->colMapper
  switch colType {
  | Count => Table.makeHeaderInfo(~key, ~title="Count", ~dataType=TextType)
  | Amount => Table.makeHeaderInfo(~key, ~title="Amount", ~dataType=TextType)
  | TimeBucket => Table.makeHeaderInfo(~key, ~title="Date", ~dataType=TextType)
  }
}

let getCell = (obj, colType): Table.cell => {
  switch colType {
  | Count => Text(obj.count->Int.toString)
  | Amount => Text(obj.amount->Float.toString)
  | TimeBucket => Text(obj.time_bucket)
  }
}

open NewAnalyticsTypes
let dropDownOptions = [
  {label: "By Amount", value: Amount->colMapper},
  {label: "By Count", value: Count->colMapper},
]

let tabs = [
  {label: "Hourly", value: (#hour_wise: granularity :> string)},
  {label: "Daily", value: (#day_wise: granularity :> string)},
  {label: "Weekly", value: (#week_wise: granularity :> string)},
]

let defaultMetric = {
  label: "By Amount",
  value: Amount->colMapper,
}

let defaulGranularity = {
  label: "Daily",
  value: (#day_wise: granularity :> string),
}
