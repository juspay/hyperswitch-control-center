type smartRetryStatergyCols =
  | TimeBucket
  | SuccessRate
  | HadRetryAttempt
  | GroupId
  | GroupName
  | SuccessRateSeries
  | Category
  | OverallSuccessRate
  | GroupwiseData
  | ErrorCategoryAnalysis

type responseKeys = [
  | #time_bucket
  | #success_rate
  | #had_retry_attempt
  | #group_id
  | #group_name
  | #success_rate_series
  | #category
  | #overall_success_rate
  | #groupwise_data
  | #error_category_analysis
  | #billing_state
  | #card_funding
  | #card_network
  | #card_issuer
]

type successRateSeries = {
  time_bucket: string,
  success_rate: float,
  had_retry_attempt: bool,
}

type groupwiseData = {
  group_id: string,
  group_name: string,
  success_rate_series: array<successRateSeries>,
}

type errorCategoryAnalysis = {
  category: string,
  overall_success_rate: array<successRateSeries>,
  groupwise_data: array<groupwiseData>,
}
