open RoutingAnalyticsMetricsTypes
open LogicUtils

let metricsArray: array<metrics> = [
  #overall_authorization_rate,
  #first_attempt_authorization_rate,
  #total_successful,
  #total_failure,
]

let getDisplayNameFromMetricType = (metrics: metrics) => {
  switch metrics {
  | #overall_authorization_rate => "Overall Authorization Rate"
  | #first_attempt_authorization_rate => "First Attempt Authorization Rate (FAAR)"
  | #total_successful => "Total Successful"
  | #total_failure => "Total Failure"
  }
}

let getMetricRequestPayloadFromMetricType = (metrics: metrics) => {
  switch metrics {
  | #overall_authorization_rate => ["payment_success_rate"]
  | #first_attempt_authorization_rate => ["sessionized_payments_success_rate"]
  | #total_successful => ["payment_success_count", "payment_count"]
  | #total_failure => ["payment_count"]
  }
}

let metricsQueryDataItemToObjMapper = dict => {
  {
    payment_success_rate: dict->getFloat("payment_success_rate", 0.0),
    payment_count: dict->getInt("payment_count", 0),
    payment_success_count: dict->getInt("payment_success_count", 0),
    payment_failed_count: dict->getInt("payment_failed_count", 0),
  }
}

let metricsMetadataItemToObjMapper = dict => {
  {
    total_success_rate_without_smart_retries: dict->getFloat(
      "total_success_rate_without_smart_retries",
      0.0,
    ),
  }
}

let metricsResponseItemToObjMapper = dict => {
  {
    queryData: dict
    ->getJsonObjectFromDict("queryData")
    ->getArrayDataFromJson(metricsQueryDataItemToObjMapper),
    metaData: dict
    ->getJsonObjectFromDict("metaData")
    ->getArrayDataFromJson(metricsMetadataItemToObjMapper),
  }
}

let getAPIURLFromMetricType = (metric: metrics) => {
  open APIUtilsTypes

  switch metric {
  | #overall_authorization_rate => (V1(ANALYTICS_ROUTING), "routing")
  | #first_attempt_authorization_rate => (V1(ANALYTICS_PAYMENTS_V2), "payments")
  | #total_successful => (V1(ANALYTICS_ROUTING), "routing")
  | #total_failure => (V1(ANALYTICS_PAYMENTS), "payments")
  }
}
