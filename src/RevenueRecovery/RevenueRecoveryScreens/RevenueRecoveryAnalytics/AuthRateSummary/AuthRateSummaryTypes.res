type authRateSummaryCols =
  | SuccessRatePercent
  | SuccessOrdersPercentage
  | SoftDeclinesPercentage
  | HardDeclinesPercentage

type responseKeys = [
  | #success_rate_percent
  | #success_orders_percentage
  | #soft_declines_percentage
  | #hard_declines_percentage
]

type authRateSummaryObject = {
  success_rate_percent: float,
  success_orders_percentage: float,
  soft_declines_percentage: float,
  hard_declines_percentag: float,
}
