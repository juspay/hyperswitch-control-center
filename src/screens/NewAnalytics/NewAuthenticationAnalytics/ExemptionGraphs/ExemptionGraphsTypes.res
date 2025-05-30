type exemptionGraphsCol =
  | Authentication_Count
  | Authentication_Success_Count
  | Authentication_Success_Rate
  | Authentication_Exemption_Accepted
  | Authentication_Exemption_Requested
  | Exemption_Approval_Rate
  | Authentication_Attempt_Count
  | Exemption_Request_Rate
  | User_Drop_Off_Rate
  | Time_Bucket
  | Unknown

type responseKeys = [
  | #authentication_count
  | #authentication_success_count
  | #authentication_success_rate
  | #time_bucket
  | #authentication_exemption_accepted
  | #authentication_exemption_requested
  | #exemption_approval_rate
  | #authentication_attempt_count
  | #exemption_request_rate
  | #user_drop_off_rate
]

type exemptionGraphsObject = {
  authentication_count: int,
  authentication_success_count: int,
  authentication_success_rate: float,
  time_bucket: string,
  authentication_exemption_accepted: int,
  authentication_exemption_requested: int,
  exemption_approval_rate: float,
  authentication_attempt_count: int,
  exemption_request_rate: float,
  user_drop_off_rate: float,
}
