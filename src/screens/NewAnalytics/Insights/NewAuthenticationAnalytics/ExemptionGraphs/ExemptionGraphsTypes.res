type exemptionGraphsCol =
  | Authentication_Connector
  | Authentication_Count
  | Authentication_Success_Count
  | Authentication_Success_Rate
  | Authentication_Exemption_Approved_Count
  | Authentication_Exemption_Requested_Count
  | Exemption_Approval_Rate
  | Authentication_Attempt_Count
  | Exemption_Request_Rate
  | User_Drop_Off_Rate
  | Time_Bucket
  | Unknown

type responseKeys = [
  | #authentication_connector
  | #authentication_count
  | #authentication_success_count
  | #authentication_success_rate
  | #time_bucket
  | #authentication_exemption_approved_count
  | #authentication_exemption_requested_count
  | #exemption_approval_rate
  | #authentication_attempt_count
  | #exemption_request_rate
  | #user_drop_off_rate
]

type exemptionGraphsObject = {
  authentication_connector: string,
  authentication_count: int,
  authentication_success_count: int,
  authentication_success_rate: float,
  time_bucket: string,
  authentication_exemption_approved_count: int,
  authentication_exemption_requested_count: int,
  exemption_approval_rate: float,
  authentication_attempt_count: int,
  exemption_request_rate: float,
  user_drop_off_rate: float,
}
