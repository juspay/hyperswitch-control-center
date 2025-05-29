type exemptionRequestRateCol =
  | Authentication_Attempt_Count
  | Authentication_Exemption_Requested
  | Exemption_Request_Rate
  | Time_Bucket
  | Unknown

type responseKeys = [
  | #authentication_attempt_count
  | #authentication_exemption_requested
  | #exemption_request_rate
  | #time_bucket
]

type exemptionRequestRateObject = {
  authentication_attempt_count: int,
  authentication_exemption_requested: int,
  time_bucket: string,
}
