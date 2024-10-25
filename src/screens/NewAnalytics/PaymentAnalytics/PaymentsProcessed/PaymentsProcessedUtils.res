open PaymentsProcessedTypes
open NewPaymentAnalyticsUtils
open LogicUtils

let getStringFromVariant = value => {
  switch value {
  | Payment_Processed_Amount => "payment_processed_amount"
  | Payment_Processed_Count => "payment_processed_count"
  | Payment_Processed_Amount_Without_Smart_Retries => "payment_processed_amount_without_smart_retries"
  | Payment_Processed_Count_Without_Smart_Retries => "payment_processed_count_without_smart_retries"
  | Total_Payment_Processed_Amount => "total_payment_processed_amount"
  | Total_Payment_Processed_Count => "total_payment_processed_count"
  | Total_Payment_Processed_Amount_Without_Smart_Retries => "total_payment_processed_amount_without_smart_retries"
  | Total_Payment_Processed_Count_Without_Smart_Retriess => "total_payment_processed_count_without_smart_retries"
  | Time_Bucket => "time_bucket"
  }
}

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

let visibleColumns = [Payment_Processed_Amount, Payment_Processed_Count, Time_Bucket]

let tableItemToObjMapper: Dict.t<JSON.t> => paymentsProcessedObject = dict => {
  {
    payment_processed_amount: dict->getFloat(Payment_Processed_Amount->getStringFromVariant, 0.0),
    payment_processed_count: dict->getInt(Payment_Processed_Count->getStringFromVariant, 0),
    payment_processed_amount_without_smart_retries: dict->getFloat(
      Payment_Processed_Amount_Without_Smart_Retries->getStringFromVariant,
      0.0,
    ),
    payment_processed_count_without_smart_retries: dict->getInt(
      Payment_Processed_Count_Without_Smart_Retries->getStringFromVariant,
      0,
    ),
    total_payment_processed_amount: dict->getFloat(
      Total_Payment_Processed_Amount->getStringFromVariant,
      0.0,
    ),
    total_payment_processed_count: dict->getInt(
      Total_Payment_Processed_Count->getStringFromVariant,
      0,
    ),
    total_payment_processed_amount_without_smart_retries: dict->getFloat(
      Total_Payment_Processed_Amount_Without_Smart_Retries->getStringFromVariant,
      0.0,
    ),
    total_payment_processed_count_without_smart_retries: dict->getInt(
      Total_Payment_Processed_Count_Without_Smart_Retriess->getStringFromVariant,
      0,
    ),
    time_bucket: dict->getString(Time_Bucket->getStringFromVariant, "NA"),
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
  switch colType {
  | Payment_Processed_Amount =>
    Table.makeHeaderInfo(
      ~key=Payment_Processed_Amount->getStringFromVariant,
      ~title="Amount",
      ~dataType=TextType,
    )
  | Payment_Processed_Amount_Without_Smart_Retries =>
    Table.makeHeaderInfo(
      ~key=Payment_Processed_Amount_Without_Smart_Retries->getStringFromVariant,
      ~title="Amount",
      ~dataType=TextType,
    )
  | Payment_Processed_Count =>
    Table.makeHeaderInfo(
      ~key=Payment_Processed_Count->getStringFromVariant,
      ~title="Count",
      ~dataType=TextType,
    )
  | Payment_Processed_Count_Without_Smart_Retries =>
    Table.makeHeaderInfo(
      ~key=Payment_Processed_Count_Without_Smart_Retries->getStringFromVariant,
      ~title="Count",
      ~dataType=TextType,
    )
  | Time_Bucket =>
    Table.makeHeaderInfo(~key=Time_Bucket->getStringFromVariant, ~title="Date", ~dataType=TextType)

  | Total_Payment_Processed_Amount
  | Total_Payment_Processed_Count
  | Total_Payment_Processed_Amount_Without_Smart_Retries
  | Total_Payment_Processed_Count_Without_Smart_Retriess =>
    Table.makeHeaderInfo(~key="", ~title="", ~dataType=TextType)
  }
}

let getCell = (obj, colType): Table.cell => {
  open NewAnalyticsUtils
  switch colType {
  | Payment_Processed_Amount => Text(obj.payment_processed_amount->valueFormatter(Amount))
  | Payment_Processed_Amount_Without_Smart_Retries =>
    Text(obj.payment_processed_amount_without_smart_retries->valueFormatter(Amount))
  | Payment_Processed_Count => Text(obj.payment_processed_count->Int.toString)
  | Payment_Processed_Count_Without_Smart_Retries =>
    Text(obj.payment_processed_count_without_smart_retries->Int.toString)
  | Time_Bucket => Text(obj.time_bucket->formatDateValue(~includeYear=true))
  | Total_Payment_Processed_Amount
  | Total_Payment_Processed_Count
  | Total_Payment_Processed_Amount_Without_Smart_Retries
  | Total_Payment_Processed_Count_Without_Smart_Retriess =>
    Text("")
  }
}

open NewAnalyticsTypes
let dropDownOptions = [
  {label: "By Amount", value: Payment_Processed_Amount->getStringFromVariant},
  {label: "By Count", value: Payment_Processed_Count->getStringFromVariant},
]

let tabs = [{label: "Daily", value: (#G_ONEDAY: granularity :> string)}]

let defaultMetric = {
  label: "By Amount",
  value: Payment_Processed_Amount->getStringFromVariant,
}

let defaulGranularity = {
  label: "Daily",
  value: (#G_ONEDAY: granularity :> string),
}

let getMetaDataMapper = key => {
  switch key {
  | "payment_processed_amount" => "total_payment_processed_amount"
  | "payment_processed_count" => "total_payment_processed_count"
  | "payment_processed_amount_without_smart_retries" => "total_payment_processed_amount_without_smart_retries"
  | "payment_processed_count_without_smart_retries" => "total_payment_processed_count_without_smart_retries"
  | _ => ""
  }
}
