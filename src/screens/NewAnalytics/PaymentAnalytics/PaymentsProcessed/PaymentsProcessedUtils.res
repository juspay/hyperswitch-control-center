open PaymentsProcessedTypes
open NewPaymentAnalyticsUtils
open LogicUtils

let paymentsProcessedMapper = (
  ~data: JSON.t,
  ~xKey: string,
  ~yKey: string,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  let primaryCategories = data->getCategories(0, yKey)
  let secondaryCategories = data->getCategories(1, yKey)

  let lineGraphData =
    data
    ->getArrayFromJson([])
    ->Array.mapWithIndex((item, index) => {
      let name = `Series ${(index + 1)->Int.toString}`
      let color = index->getColor
      getLineGraphObj(~array=item->getArrayFromJson([]), ~key=xKey, ~name, ~color)
    })
  let title = {
    text: "Payments Processed",
  }
  {
    categories: primaryCategories,
    data: lineGraphData,
    title,
    tooltipFormatter: tooltipFormatter(
      ~secondaryCategories,
      ~title="Payments Processed",
      ~metricType=Amount,
    ),
  }
}
// Need to modify
let getMetaData = json =>
  json
  ->getArrayFromJson([])
  ->getValueFromArray(0, JSON.Encode.array([]))
  ->getDictFromJsonObject
  ->getArrayFromDict("metaData", [])
  ->getValueFromArray(0, JSON.Encode.array([]))
  ->getDictFromJsonObject

open NewAnalyticsTypes
let visibleColumns: array<metrics> = [#payment_processed_amount, #payment_count, #time_bucket]

let tableItemToObjMapper: Dict.t<JSON.t> => paymentsProcessedObject = dict => {
  {
    payment_count: dict->getInt((#payment_count: metrics :> string), 0),
    payment_processed_amount: dict->getFloat((#payment_processed_amount: metrics :> string), 0.0),
    time_bucket: dict->getString((#time_bucket: metrics :> string), "NA"),
  }
}

let getObjects: JSON.t => array<paymentsProcessedObject> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = (colType: metrics) => {
  switch colType {
  | #payment_count =>
    Table.makeHeaderInfo(
      ~key=(#payment_count: metrics :> string),
      ~title="Count",
      ~dataType=TextType,
    )
  | #payment_processed_amount =>
    Table.makeHeaderInfo(
      ~key=(#payment_processed_amount: metrics :> string),
      ~title="Amount",
      ~dataType=TextType,
    )
  | #time_bucket | _ =>
    Table.makeHeaderInfo(~key=(#time_bucket: metrics :> string), ~title="Date", ~dataType=TextType)
  }
}

let getCell = (obj, colType: metrics): Table.cell => {
  switch colType {
  | #payment_count => Text(obj.payment_count->Int.toString)
  | #payment_processed_amount => Text(obj.payment_processed_amount->Float.toString)
  | #time_bucket | _ => Text(obj.time_bucket)
  }
}

let dropDownOptions = [
  {label: "By Amount", value: (#payment_processed_amount: metrics :> string)},
  {label: "By Count", value: (#payment_count: metrics :> string)},
]

let tabs = [{label: "Daily", value: (#G_ONEDAY: granularity :> string)}]

let defaultMetric = {
  label: "By Amount",
  value: (#payment_processed_amount: metrics :> string),
}

let defaulGranularity = {
  label: "Daily",
  value: (#G_ONEDAY: granularity :> string),
}

let getMetaDataKey = key => {
  switch key {
  | "payment_processed_amount" => "total_payment_processed_amount"
  | "payment_count" => "total_payment_processed_count"
  | _ => ""
  }
}
