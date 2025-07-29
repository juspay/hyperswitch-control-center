type metrics = [
  | #overall_authorization_rate
  | #first_attempt_authorization_rate
  | #total_successful
  | #total_failure
]

type metricsQueryDataResponse = {
  payment_success_rate: float,
  payment_count: int,
  payment_success_count: int,
  payments_success_rate_without_smart_retries: float,
  payment_failed_count: int,
}

type metricsMetadataResponse = {total_success_rate_without_smart_retries: float}

type metricsDataResponse = {
  queryData: array<metricsQueryDataResponse>,
  metaData: array<metricsMetadataResponse>,
}
