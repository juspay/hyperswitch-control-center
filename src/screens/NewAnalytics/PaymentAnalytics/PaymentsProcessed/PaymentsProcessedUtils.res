open PaymentsProcessedTypes
open NewPaymentAnalyticsUtils
open LogicUtils

let getPaymentQueryDataString = queryData =>
  switch queryData {
  | Amount => "amount"
  | Count => "count"
  | TimeBucket => "time_bucket"
  }

let paymentsProcessedMapper = (json: JSON.t): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  let categories = getCategories(json, (#time_bucket: PaymentsProcessedTypes.categories :> string))
  let data = getLineGraphData(json, getPaymentQueryDataString(Amount))
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

let colMapper = (col: paymentsProcessedCols) => {
  switch col {
  | Count => "count"
  | Amount => "amount"
  | TimeBucket => "time_bucket"
  }
}

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
