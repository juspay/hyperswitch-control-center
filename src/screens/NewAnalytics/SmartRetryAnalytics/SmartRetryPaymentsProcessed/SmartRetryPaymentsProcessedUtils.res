open SmartRetryPaymentsProcessedTypes
open NewAnalyticsUtils
open LogicUtils

let getStringFromVariant = value => {
  switch value {
  | Payment_Processed_Amount => "payment_processed_amount_in_usd"
  | Payment_Processed_Count => "payment_processed_count"
  | Total_Payment_Processed_Amount => "total_payment_processed_amount_in_usd"
  | Total_Payment_Processed_Count => "total_payment_processed_count"
  | Time_Bucket => "time_bucket"
  }
}

let getVariantValueFromString = value => {
  switch value {
  | "payment_processed_amount_in_usd" => Payment_Processed_Amount
  | "payment_processed_count" => Payment_Processed_Count
  | "total_payment_processed_amount_in_usd" => Total_Payment_Processed_Amount
  | "total_payment_processed_count" => Total_Payment_Processed_Count
  | "time_bucket" | _ => Time_Bucket
  }
}

let isAmountMetric = key => {
  switch key->getVariantValueFromString {
  | Payment_Processed_Amount
  | Total_Payment_Processed_Amount => true
  | _ => false
  }
}

let smartRetryPaymentsProcessedMapper = (
  ~params: NewAnalyticsTypes.getObjects<JSON.t>,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  open NewPaymentAnalyticsUtils
  let {data, xKey, yKey} = params
  let comparison = switch params.comparison {
  | Some(val) => Some(val)
  | None => None
  }
  let primaryCategories = data->getCategories(0, yKey)
  let secondaryCategories = data->getCategories(1, yKey)

  let lineGraphData =
    data
    ->getArrayFromJson([])
    ->Array.mapWithIndex((item, index) => {
      let name = NewAnalyticsUtils.getLabelName(~key=yKey, ~index, ~points=item)
      let color = index->getColor
      getLineGraphObj(
        ~array=item->getArrayFromJson([]),
        ~key=xKey,
        ~name,
        ~color,
        ~isAmount=xKey->isAmountMetric,
      )
    })
  let title = {
    text: "Smart Retry Payments Processed",
  }

  open NewAnalyticsTypes
  let metricType = switch xKey->getVariantValueFromString {
  | Payment_Processed_Amount => Amount
  | _ => Volume
  }

  {
    categories: primaryCategories,
    data: lineGraphData,
    title,
    yAxisMaxValue: None,
    tooltipFormatter: tooltipFormatter(
      ~secondaryCategories,
      ~title="Smart Retry Payments Processed",
      ~metricType,
      ~comparison,
    ),
  }
}

let visibleColumns = [Time_Bucket]

let tableItemToObjMapper: Dict.t<JSON.t> => smartRetryPaymentsProcessedObject = dict => {
  open NewPaymentAnalyticsUtils
  {
    smart_retry_payment_processed_amount_in_usd: dict->getAmountValue(
      ~id=Payment_Processed_Amount->getStringFromVariant,
    ),
    smart_retry_payment_processed_count: dict->getInt(
      Payment_Processed_Count->getStringFromVariant,
      0,
    ),
    total_payment_smart_retry_processed_amount_in_usd: dict->getAmountValue(
      ~id=Total_Payment_Processed_Amount->getStringFromVariant,
    ),
    total_payment_smart_retry_processed_count: dict->getInt(
      Total_Payment_Processed_Count->getStringFromVariant,
      0,
    ),
    time_bucket: dict->getString(Time_Bucket->getStringFromVariant, "NA"),
  }
}

let getObjects: JSON.t => array<smartRetryPaymentsProcessedObject> = json => {
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
  | Payment_Processed_Count =>
    Table.makeHeaderInfo(
      ~key=Payment_Processed_Count->getStringFromVariant,
      ~title="Count",
      ~dataType=TextType,
    )
  | Time_Bucket =>
    Table.makeHeaderInfo(~key=Time_Bucket->getStringFromVariant, ~title="Date", ~dataType=TextType)

  | Total_Payment_Processed_Amount
  | Total_Payment_Processed_Count =>
    Table.makeHeaderInfo(~key="", ~title="", ~dataType=TextType)
  }
}

let getCell = (obj, colType): Table.cell => {
  switch colType {
  | Payment_Processed_Amount =>
    Text(obj.smart_retry_payment_processed_amount_in_usd->valueFormatter(Amount))
  | Payment_Processed_Count => Text(obj.smart_retry_payment_processed_count->Int.toString)
  | Time_Bucket => Text(obj.time_bucket->formatDateValue(~includeYear=true))
  | Total_Payment_Processed_Amount
  | Total_Payment_Processed_Count =>
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

let modifySmartRetryQueryData = data => {
  data->Array.map(item => {
    let valueDict = item->getDictFromJsonObject

    let key = Payment_Processed_Count->getStringFromVariant
    let paymentProcessedCount = valueDict->getInt(key, 0)

    let key = Payment_Processed_Amount->getStringFromVariant
    let paymentProcessedAmount = valueDict->getFloat(key, 0.0)

    let key =
      PaymentsProcessedTypes.Payment_Processed_Amount_Without_Smart_Retries->PaymentsProcessedUtils.getStringFromVariant
    let paymentProcessedAmountWithoutSmartRetries = valueDict->getFloat(key, 0.0)

    let key =
      PaymentsProcessedTypes.Payment_Processed_Count_Without_Smart_Retries->PaymentsProcessedUtils.getStringFromVariant
    let paymentProcessedCountWithoutSmartRetries = valueDict->getInt(key, 0)

    let totalPaymentProcessedCount =
      paymentProcessedCount - paymentProcessedCountWithoutSmartRetries

    let totalPaymentProcessedAmount =
      paymentProcessedAmount -. paymentProcessedAmountWithoutSmartRetries

    valueDict->Dict.set(
      Payment_Processed_Count->getStringFromVariant,
      totalPaymentProcessedCount->JSON.Encode.int,
    )
    valueDict->Dict.set(
      Payment_Processed_Amount->getStringFromVariant,
      totalPaymentProcessedAmount->JSON.Encode.float,
    )

    valueDict->JSON.Encode.object
  })
}

let modifySmartRetryMetaData = data => {
  data->Array.map(item => {
    let valueDict = item->getDictFromJsonObject

    let key = Total_Payment_Processed_Count->getStringFromVariant
    let paymentProcessedCount = valueDict->getInt(key, 0)

    let key = Total_Payment_Processed_Amount->getStringFromVariant
    let paymentProcessedAmount = valueDict->getFloat(key, 0.0)

    let key =
      PaymentsProcessedTypes.Total_Payment_Processed_Amount_Without_Smart_Retries->PaymentsProcessedUtils.getStringFromVariant
    let paymentProcessedAmountWithoutSmartRetries = valueDict->getFloat(key, 0.0)

    let key =
      PaymentsProcessedTypes.Total_Payment_Processed_Count_Without_Smart_Retriess->PaymentsProcessedUtils.getStringFromVariant
    let paymentProcessedCountWithoutSmartRetries = valueDict->getInt(key, 0)

    let totalPaymentProcessedCount =
      paymentProcessedCount - paymentProcessedCountWithoutSmartRetries

    let totalPaymentProcessedAmount =
      paymentProcessedAmount -. paymentProcessedAmountWithoutSmartRetries

    valueDict->Dict.set(
      Total_Payment_Processed_Count->getStringFromVariant,
      totalPaymentProcessedCount->JSON.Encode.int,
    )
    valueDict->Dict.set(
      Total_Payment_Processed_Amount->getStringFromVariant,
      totalPaymentProcessedAmount->JSON.Encode.float,
    )

    valueDict->JSON.Encode.object
  })
}
