type declineTypes = [
  | #soft_declines
  | #hard_declines
]

type response_keys = [
  | #static_retries
  | #smart_retries
  | #smart_retries_booster
  | #auth_rate_percent
  | #delta_percent
  | #soft_declines_percent
  | #hard_declines_percent
]

type recoveredType = {
  declineType: declineTypes,
  value: float,
}

type retrySummaryCols =
  | StaticRetries
  | SmartRetries
  | SmartRetriesBooster
  | AuthRatePercent
  | DeltaPercent
  | SoftDeclinesRecoveredPercent
  | HardDeclinesRecoveredPercent

type retrySummaryKeys = [
  | #static_retries
  | #smart_retries
  | #smart_retries_booster
]

type recoveredOrders = {
  soft_declines_percent: float,
  hard_declines_percent: float,
}

type retryStrategyData = {
  auth_rate_percent: float,
  delta_percent: float,
  recovered_orders: recoveredOrders,
}

type retrySummaryObject = {
  static_retries: retryStrategyData,
  smart_retries: retryStrategyData,
  smart_retries_booster: retryStrategyData,
}
