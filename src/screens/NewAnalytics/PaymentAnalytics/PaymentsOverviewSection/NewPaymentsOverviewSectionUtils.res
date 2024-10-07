open NewPaymentsOverviewSectionTypes
let defaultValue =
  {
    smart_retried_amount: 0.0,
    payments_success_rate: 0.0,
    payment_processed_amount: 0.0,
    refund_success_count: 0.0,
    dispute_status_metric: 0.0,
  }
  ->Identity.genericTypeToJson
  ->LogicUtils.getDictFromJsonObject

let getPayload = (~entity, ~metrics, ~startTime, ~endTime) => {
  open NewAnalyticsTypes
  NewAnalyticsUtils.requestBody(
    ~dimensions=[],
    ~startTime,
    ~endTime,
    ~delta=entity.requestBodyConfig.delta,
    ~filters=entity.requestBodyConfig.filters,
    ~metrics,
    ~customFilter=entity.requestBodyConfig.customFilter,
    ~applyFilterFor=entity.requestBodyConfig.applyFilterFor,
  )
}

let parseResponse = response => {
  open LogicUtils
  response
  ->getDictFromJsonObject
  ->getArrayFromDict("queryData", [])
  ->getValueFromArray(0, Dict.make()->JSON.Encode.object)
  ->getDictFromJsonObject
}

open NewAnalyticsTypes
let setValue = (dict, ~data, ~ids: array<metrics>) => {
  open LogicUtils

  ids->Array.forEach(id => {
    dict->Dict.set(
      (id: metrics :> string),
      data
      ->getFloat((id: metrics :> string), 0.0)
      ->JSON.Encode.float,
    )
  })
}

let getInfo = (~metric) => {
  switch metric {
  | #smart_retried_amount => {
      titleText: "Total Payment Savings",
      description: "Amount saved via payment retries",
      valueType: Amount,
    }
  | #payments_success_rate => {
      titleText: "Total Authorization Rate",
      description: "Overall successful payment intents divided by total payment intents excluding dropoffs",
      valueType: Rate,
    }
  | #payment_processed_amount => {
      titleText: "Total Payments Processed",
      description: "The total amount of payments processed in the selected time range",
      valueType: Amount,
    }
  | #refund_success_count => {
      titleText: "Total Refunds Processed",
      description: "The total amount of refund payments processed in the selected time range",
      valueType: Amount,
    }
  | #dispute_status_metric => {
      titleText: "All Disputes",
      description: "Total number of disputes irrespective of status in the selected time range",
      valueType: Volume,
    }
  | _ => {
      titleText: "",
      description: "",
      valueType: No_Type,
    }
  }
}

let getValueFromObj = (data, index, metric) => {
  open LogicUtils
  data
  ->getArrayFromJson([])
  ->getValueFromArray(index, Dict.make()->JSON.Encode.object)
  ->getDictFromJsonObject
  ->getFloat((metric: metrics :> string), 0.0)
}
