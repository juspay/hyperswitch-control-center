open PaymentsProcessedTypes
open LogicUtils

let getStringFromVariant = value => {
  switch value {
  | Payment_Processed_Amount => "payment_processed_amount"
  | Payment_Processed_Count => "payment_processed_count"
  | Total_Payment_Processed_Amount => "total_payment_processed_amount"
  | Total_Payment_Processed_Count => "total_payment_processed_count"
  | Time_Bucket => "time_bucket"
  }
}

let getVariantValueFromString = value => {
  switch value {
  | "payment_processed_amount" => Payment_Processed_Amount
  | "payment_processed_count" => Payment_Processed_Count
  | "total_payment_processed_amount" => Total_Payment_Processed_Amount
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

let paymentsProcessedMapper = (
  ~params: NewAnalyticsTypes.getObjects<JSON.t>,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  open NewAnalyticsUtils
  let {data, xKey, yKey} = params
  let comparison = switch params.comparison {
  | Some(val) => Some(val)
  | None => None
  }
  let currency = params.currency->Option.getOr("")
  let primaryCategories = data->getCategories(0, yKey)
  let secondaryCategories = data->getCategories(1, yKey)

  let lineGraphData = data->getLineGraphData(~xKey, ~yKey, ~isAmount=xKey->isAmountMetric)
  let title = {
    text: "Payments Processed",
  }

  open NewAnalyticsTypes
  let metricType = switch xKey->getVariantValueFromString {
  | Payment_Processed_Amount => Amount
  | _ => Volume
  }

  let tooltipFormatter = tooltipFormatter(
    ~secondaryCategories,
    ~title="Payments Processed",
    ~metricType,
    ~comparison,
    ~currency,
  )

  {
    categories: primaryCategories,
    data: lineGraphData,
    title,
    yAxisMaxValue: None,
    tooltipFormatter,
  }
}

let visibleColumns = [Time_Bucket]

let tableItemToObjMapper: Dict.t<JSON.t> => paymentsProcessedObject = dict => {
  open NewAnalyticsUtils
  {
    payment_processed_amount: dict->getAmountValue(
      ~id=Payment_Processed_Amount->getStringFromVariant,
    ),
    payment_processed_count: dict->getInt(Payment_Processed_Count->getStringFromVariant, 0),
    total_payment_processed_amount: dict->getAmountValue(
      ~id=Total_Payment_Processed_Amount->getStringFromVariant,
    ),
    total_payment_processed_count: dict->getInt(
      Total_Payment_Processed_Count->getStringFromVariant,
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
  open NewAnalyticsUtils
  switch colType {
  | Payment_Processed_Amount => Text(obj.payment_processed_amount->valueFormatter(Amount))
  | Payment_Processed_Count => Text(obj.payment_processed_count->Int.toString)
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

let getMetaDataMapper = (key, ~currency) => {
  let field = key->getVariantValueFromString
  switch field {
  | Payment_Processed_Amount => {
      let key = Total_Payment_Processed_Amount->getStringFromVariant
      key->NewAnalyticsUtils.modifyKey(~currency)
    }
  | Payment_Processed_Count | _ => Total_Payment_Processed_Count->getStringFromVariant
  }
}

let modifyQueryData = (data, ~isSmartRetryEnabled=Smart_Retry, ~currency) => {
  open NewAnalyticsUtils
  let dataDict = Dict.make()

  data->Array.forEach(item => {
    let valueDict = item->getDictFromJsonObject
    let time = valueDict->getString(Time_Bucket->getStringFromVariant, "")

    switch dataDict->Dict.get(time) {
    | Some(prevVal) => {
        let key = Payment_Processed_Count->getStringFromVariant
        let paymentProcessedCount = valueDict->getInt(key->modifyKey(~isSmartRetryEnabled), 0)
        let prevProcessedCount = prevVal->getInt(key, 0)
        let key = Payment_Processed_Amount->getStringFromVariant
        let paymentProcessedAmount =
          valueDict->getFloat(key->modifyKey(~isSmartRetryEnabled, ~currency), 0.0)
        let prevProcessedAmount = prevVal->getFloat(key, 0.0)

        let totalPaymentProcessedCount = paymentProcessedCount + prevProcessedCount
        let totalPaymentProcessedAmount = paymentProcessedAmount +. prevProcessedAmount

        prevVal->Dict.set(
          Payment_Processed_Count->getStringFromVariant,
          totalPaymentProcessedCount->JSON.Encode.int,
        )
        prevVal->Dict.set(
          Payment_Processed_Amount->getStringFromVariant,
          totalPaymentProcessedAmount->JSON.Encode.float,
        )

        dataDict->Dict.set(time, prevVal)
      }
    | None => dataDict->Dict.set(time, valueDict)
    }
  })

  dataDict->Dict.valuesToArray->Array.map(JSON.Encode.object)
}
