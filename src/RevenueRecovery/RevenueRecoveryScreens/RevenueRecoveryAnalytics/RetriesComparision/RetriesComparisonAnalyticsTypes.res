// Column names for UI/table use
type retryAttemptsTrendCols =
  | TimeBucket
  | SuccessRate
  | HadRetryAttempt
  | StaticRetries
  | SmartRetries

// Keys as polymorphic variants for JSON parsing or field access
type retryAttemptsTrendKeys = [
  | #retry_attempts_trend
  | #static_retries
  | #smart_retries
  | #time_bucket
  | #success_rate
  | #had_retry_attempt
]

// Structure for each trend entry in the arrays
type retryAttemptEntry = {
  time_bucket: string,
  success_rate: float,
  had_retry_attempt: bool,
}

// Main trend object holding both static and smart retries
type retryAttemptsTrend = {
  static_retries: array<retryAttemptEntry>,
  smart_retries: array<retryAttemptEntry>,
}
