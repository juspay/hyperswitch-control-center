open SmartRetryPaymentsProcessedTypes
open NewAnalyticsUtils
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

let smartRetryPaymentsProcessedMapper = (
  ~params: NewAnalyticsTypes.getObjects<JSON.t>,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  let {data, xKey, yKey} = params
  let comparison = switch params.comparison {
  | Some(val) => Some(val)
  | None => None
  }
  let primaryCategories = data->getCategories(0, yKey)
  let secondaryCategories = data->getCategories(1, yKey)

  let lineGraphData = data->getLineGraphData(~xKey, ~yKey, ~isAmount=xKey->isAmountMetric)

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
    yAxisMaxValue: data->isEmptyGraph(xKey) ? Some(1) : None,
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
  {
    smart_retry_payment_processed_amount: dict->getAmountValue(
      ~id=Payment_Processed_Amount->getStringFromVariant,
    ),
    smart_retry_payment_processed_count: dict->getInt(
      Payment_Processed_Count->getStringFromVariant,
      0,
    ),
    total_payment_smart_retry_processed_amount: dict->getAmountValue(
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
    Text(obj.smart_retry_payment_processed_amount->valueFormatter(Amount))
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

let getKey = (id, ~isSmartRetryEnabled=Smart_Retry, ~currency="") => {
  open NewAnalyticsFiltersUtils
  let key = switch id {
  | Time_Bucket => #time_bucket
  | Payment_Processed_Count =>
    switch isSmartRetryEnabled {
    | Smart_Retry => #payment_processed_count
    | Default => #payment_processed_count_without_smart_retries
    }
  | Total_Payment_Processed_Count =>
    switch isSmartRetryEnabled {
    | Smart_Retry => #total_payment_processed_count
    | Default => #total_payment_processed_count_without_smart_retries
    }

  | Payment_Processed_Amount =>
    switch (isSmartRetryEnabled, currency->getTypeValue) {
    | (Smart_Retry, #all_currencies) => #payment_processed_amount_in_usd
    | (Smart_Retry, _) => #payment_processed_amount
    | (Default, #all_currencies) => #payment_processed_amount_without_smart_retries_in_usd
    | (Default, _) => #payment_processed_amount_without_smart_retrie
    }
  | Total_Payment_Processed_Amount =>
    switch (isSmartRetryEnabled, currency->getTypeValue) {
    | (Smart_Retry, #all_currencies) => #total_payment_processed_amount_in_usd
    | (Smart_Retry, _) => #total_payment_processed_amount
    | (Default, #all_currencies) => #total_payment_processed_amount_without_smart_retries_in_usd
    | (Default, _) => #total_payment_processed_amount_without_smart_retries
    }
  }
  (key: responseKeys :> string)
}

let modifyQueryData = data => {
  let dataDict = Dict.make()
  let currency = (#all_currencies: defaultFilters :> string)
  let isSmartRetryEnabled = Smart_Retry

  data->Array.forEach(item => {
    let valueDict = item->getDictFromJsonObject
    let time = valueDict->getString(Time_Bucket->getStringFromVariant, "")

    switch dataDict->Dict.get(time) {
    | Some(prevVal) => {
        // with smart retry
        let key = Payment_Processed_Count->getStringFromVariant
        let paymentProcessedCount = valueDict->getInt(key, 0)
        let prevProcessedCount = prevVal->getInt(key, 0)
        // without smart retry
        let key = Payment_Processed_Count->getKey(~isSmartRetryEnabled)
        let paymentProcessedCountWithoutSmartRetries = valueDict->getInt(key, 0)
        let prevProcessedCountWithoutSmartRetries = prevVal->getInt(key, 0)

        // with smart retry
        let key = Payment_Processed_Amount->getKey(~currency)
        let paymentProcessedAmount = valueDict->getFloat(key, 0.0)
        let prevProcessedAmount = prevVal->getFloat(key, 0.0)
        // without smart retry
        let key = Payment_Processed_Amount->getKey(~isSmartRetryEnabled, ~currency)
        let paymentProcessedAmountWithoutSmartRetries = valueDict->getFloat(key, 0.0)
        let prevProcessedAmountWithoutSmartRetries = prevVal->getFloat(key, 0.0)

        let totalPaymentProcessedCount = paymentProcessedCount + prevProcessedCount
        let totalPaymentProcessedAmount = paymentProcessedAmount +. prevProcessedAmount
        let totalPaymentProcessedAmountWithoutSmartRetries =
          paymentProcessedAmountWithoutSmartRetries +. prevProcessedAmountWithoutSmartRetries
        let totalPaymentProcessedCountWithoutSmartRetries =
          paymentProcessedCountWithoutSmartRetries + prevProcessedCountWithoutSmartRetries

        // with smart retry
        prevVal->Dict.set(
          Payment_Processed_Count->getStringFromVariant,
          totalPaymentProcessedCount->JSON.Encode.int,
        )
        prevVal->Dict.set(
          Payment_Processed_Amount->getKey(~currency),
          totalPaymentProcessedAmount->JSON.Encode.float,
        )
        // without smart retry
        prevVal->Dict.set(
          Payment_Processed_Count->getKey(~isSmartRetryEnabled=Smart_Retry),
          totalPaymentProcessedCountWithoutSmartRetries->JSON.Encode.int,
        )
        prevVal->Dict.set(
          Payment_Processed_Amount->getKey(~isSmartRetryEnabled=Smart_Retry, ~currency),
          totalPaymentProcessedAmountWithoutSmartRetries->JSON.Encode.float,
        )

        dataDict->Dict.set(time, prevVal)
      }
    | None => dataDict->Dict.set(time, valueDict)
    }
  })

  dataDict->Dict.valuesToArray->Array.map(JSON.Encode.object)
}

let modifySmartRetryQueryData = data => {
  let data = data->modifyQueryData
  let currency = (#all_currencies: defaultFilters :> string)
  let isSmartRetryEnabled = Smart_Retry

  data->Array.map(item => {
    let valueDict = item->getDictFromJsonObject

    // with smart retry
    let key = Payment_Processed_Count->getStringFromVariant
    let paymentProcessedCount = valueDict->getInt(key, 0)
    // without smart retry
    let paymentProcessedCountWithoutSmartRetries =
      valueDict->getInt(Payment_Processed_Count->getKey(~isSmartRetryEnabled), 0)

    // with smart retry
    let paymentProcessedAmount =
      valueDict->getFloat(Payment_Processed_Amount->getKey(~currency), 0.0)
    // without smart retry
    let paymentProcessedAmountWithoutSmartRetries =
      valueDict->getFloat(Payment_Processed_Amount->getKey(~isSmartRetryEnabled, ~currency), 0.0)

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
  let currency = (#all_currencies: defaultFilters :> string)
  let isSmartRetryEnabled = Smart_Retry

  data->Array.map(item => {
    let valueDict = item->getDictFromJsonObject

    // with smart retry
    let key = Total_Payment_Processed_Count->getStringFromVariant
    let paymentProcessedCount = valueDict->getInt(key, 0)
    // without smart retry
    let paymentProcessedCountWithoutSmartRetries =
      valueDict->getInt(Total_Payment_Processed_Count->getKey(~isSmartRetryEnabled), 0)

    // with smart retry
    let paymentProcessedAmount =
      valueDict->getFloat(Total_Payment_Processed_Amount->getKey(~currency), 0.0)
    // without smart retry
    let paymentProcessedAmountWithoutSmartRetries =
      valueDict->getFloat(
        Total_Payment_Processed_Amount->getKey(~isSmartRetryEnabled, ~currency),
        0.0,
      )

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

let getMetaDataMapper = key => {
  let field = key->getVariantValueFromString
  switch field {
  | Payment_Processed_Amount => Total_Payment_Processed_Amount
  | Payment_Processed_Count | _ => Total_Payment_Processed_Count
  }->getStringFromVariant
}
