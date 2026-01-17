open InsightsPaymentsOverviewSectionTypes
open LogicUtils

let getStringFromVariant = value => {
  switch value {
  | Total_Smart_Retried_Amount => "total_smart_retried_amount"
  | Total_Success_Rate => "total_success_rate"
  | Total_Payment_Processed_Amount => "total_payment_processed_amount"
  | Total_Refund_Processed_Amount => "total_refund_processed_amount"
  | Total_Dispute => "total_dispute"
  | Total_Authorised_Uncaptured_Count => "payment_intent_count"
  }
}

let defaultValue =
  {
    total_smart_retried_amount: 0.0,
    total_success_rate: 0.0,
    total_payment_processed_amount: 0.0,
    total_refund_processed_amount: 0.0,
    total_dispute: 0,
    total_authorised_uncaptured_count: 0,
  }
  ->Identity.genericTypeToJson
  ->getDictFromJsonObject

let getPayload = (~entity, ~metrics, ~startTime, ~endTime, ~filter=None, ~groupByNames=None) => {
  open InsightsTypes
  InsightsUtils.requestBody(
    ~startTime,
    ~endTime,
    ~delta=entity.requestBodyConfig.delta,
    ~metrics,
    ~groupByNames,
    ~filter,
  )
}

let parseResponse = (response, key) => {
  response
  ->getDictFromJsonObject
  ->getArrayFromDict(key, [])
  ->getValueFromArray(0, Dict.make()->JSON.Encode.object)
  ->getDictFromJsonObject
}

let parseResponseAuthorisedUncapturedPayments = (response, key) => {
  let responseArray =
    response
    ->getDictFromJsonObject
    ->getArrayFromDict(key, [])

  let manualCapture = responseArray->Array.find(data => {
    let status = data->getDictFromJsonObject->getString("status", "")
    status == "requires_capture"
  })

  manualCapture->Option.getOr(Dict.make()->JSON.Encode.object)->getDictFromJsonObject
}

open InsightsTypes
let getKey = (id, ~isSmartRetryEnabled=Smart_Retry, ~currency="") => {
  open CurrencyFormatUtils
  let key = switch id {
  | Total_Dispute => #total_dispute
  | Total_Refund_Processed_Amount =>
    switch currency->getTypeValue {
    | #all_currencies => #total_refund_processed_amount_in_usd
    | _ => #total_refund_processed_amount
    }
  | Total_Success_Rate =>
    switch isSmartRetryEnabled {
    | Smart_Retry => #total_success_rate
    | Default => #total_success_rate_without_smart_retries
    }
  | Total_Authorised_Uncaptured_Count => #total_authorised_uncaptured_count
  | Total_Smart_Retried_Amount =>
    switch (isSmartRetryEnabled, currency->getTypeValue) {
    | (Smart_Retry, #all_currencies) => #total_smart_retried_amount_in_usd
    | (Smart_Retry, _) => #total_smart_retried_amount
    | (Default, #all_currencies) => #total_smart_retried_amount_without_smart_retries_in_usd
    | (Default, _) => #total_smart_retried_amount_without_smart_retries
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

let setValue = (dict, ~data, ~ids: array<overviewColumns>, ~metricType, ~currency) => {
  open NewAnalyticsUtils
  ids->Array.forEach(id => {
    let key = id->getStringFromVariant

    let value = switch id {
    | Total_Smart_Retried_Amount
    | Total_Payment_Processed_Amount =>
      data
      ->getAmountValue(~id=id->getKey(~isSmartRetryEnabled=metricType, ~currency), ~currency)
      ->JSON.Encode.float
    | Total_Refund_Processed_Amount =>
      data
      ->getAmountValue(~id={id->getKey(~currency)}, ~currency)
      ->JSON.Encode.float
    | Total_Dispute =>
      data
      ->getFloat(key, 0.0)
      ->JSON.Encode.float
    | Total_Authorised_Uncaptured_Count =>
      data
      ->getFloat(key, 0.0)
      ->JSON.Encode.float
    | _ => {
        let id = id->getKey(~isSmartRetryEnabled=metricType)
        data
        ->getFloat(id, 0.0)
        ->JSON.Encode.float
      }
    }

    dict->Dict.set(key, value)
  })
}

let getInfo = (~responseKey: overviewColumns) => {
  open InsightsTypes
  switch responseKey {
  | Total_Smart_Retried_Amount => {
      titleText: "Total Payment Savings",
      description: "Amount saved via payment retries",
      valueType: Amount,
    }
  | Total_Success_Rate => {
      titleText: "Total Authorization Rate",
      description: "Overall successful payment intents divided by total payment intents excluding dropoffs",
      valueType: Rate,
    }
  | Total_Payment_Processed_Amount => {
      titleText: "Total Payments Processed",
      description: "The total amount of payments processed in the selected time range",
      valueType: Amount,
    }
  | Total_Refund_Processed_Amount => {
      titleText: "Total Refunds Processed",
      description: "The total amount of refund payments processed in the selected time range",
      valueType: Amount,
    }
  | Total_Dispute => {
      titleText: "All Disputes",
      description: "Total number of disputes irrespective of status in the selected time range",
      valueType: Volume,
    }
  | Total_Authorised_Uncaptured_Count => {
      titleText: "Authorised Uncaptured Payments Count",
      description: "Total amount of authorised but uncaptured payments in the selected time range",
      valueType: Volume,
    }
  }
}

let getValueFromObj = (data, index, responseKey) => {
  data
  ->getArrayFromJson([])
  ->getValueFromArray(index, Dict.make()->JSON.Encode.object)
  ->getDictFromJsonObject
  ->getFloat(responseKey, 0.0)
}
