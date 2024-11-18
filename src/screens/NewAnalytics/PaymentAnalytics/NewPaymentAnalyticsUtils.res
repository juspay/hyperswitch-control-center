let getSmartRetryMetricType = isSmartRetryEnabled => {
  open NewAnalyticsTypes
  switch isSmartRetryEnabled {
  | true => Smart_Retry
  | false => Default
  }
}

let getEntityForSmartRetry = isEnabled => {
  open NewAnalyticsTypes
  open APIUtilsTypes
  switch isEnabled {
  | Smart_Retry => ANALYTICS_PAYMENTS
  | Default => ANALYTICS_PAYMENTS_V2
  }
}
