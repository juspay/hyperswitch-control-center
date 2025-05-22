type retryTrendCols =
  | TimeBucket
  | Transactions
  | StaticRetrySuccessRate
  | SmartRetrySuccessRate
  | SmartRetryBoosterSuccessRate

type retryTrendKeys = [
  | #time_bucket
  | #transactions
  | #static_retry_success_rate
  | #smart_retry_success_rate
  | #smart_retry_booster_success_rate
]

type retryTrendEntry = {
  time_bucket: string,
  transactions: int,
  static_retry_success_rate: float,
  smart_retry_success_rate: float,
  smart_retry_booster_success_rate: float,
}
