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
      let name = NewAnalyticsUtils.getLabelName(~key=yKey, ~index, ~points=item)
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
let visibleColumns: array<metrics> = [
  #sessionized_payment_processed_amount,
  #sessionized_payment_processed_count,
  #time_bucket,
]

let tableItemToObjMapper: Dict.t<JSON.t> => paymentsProcessedObject = dict => {
  {
    payment_count: dict->getInt((#sessionized_payment_processed_count: metrics :> string), 0),
    payment_processed_amount: dict->getFloat(
      (#sessionized_payment_processed_amount: metrics :> string),
      0.0,
    ),
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
  | #sessionized_payment_processed_count =>
    Table.makeHeaderInfo(
      ~key=(#sessionized_payment_processed_count: metrics :> string),
      ~title="Count",
      ~dataType=TextType,
    )
  | #sessionized_payment_processed_amount =>
    Table.makeHeaderInfo(
      ~key=(#sessionized_payment_processed_amount: metrics :> string),
      ~title="Amount",
      ~dataType=TextType,
    )
  | #time_bucket | _ =>
    Table.makeHeaderInfo(~key=(#time_bucket: metrics :> string), ~title="Date", ~dataType=TextType)
  }
}

let getCell = (obj, colType: metrics): Table.cell => {
  switch colType {
  | #sessionized_payment_processed_count => Text(obj.payment_count->Int.toString)
  | #sessionized_payment_processed_amount => Text(obj.payment_processed_amount->Float.toString)
  | #time_bucket | _ => Text(obj.time_bucket)
  }
}

let dropDownOptions = [
  {label: "By Amount", value: (#sessionized_payment_processed_amount: metrics :> string)},
  {label: "By Count", value: (#sessionized_payment_processed_count: metrics :> string)},
]

let tabs = [{label: "Daily", value: (#G_ONEDAY: granularity :> string)}]

let defaultMetric = {
  label: "By Amount",
  value: (#sessionized_payment_processed_amount: metrics :> string),
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
