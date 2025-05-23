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
