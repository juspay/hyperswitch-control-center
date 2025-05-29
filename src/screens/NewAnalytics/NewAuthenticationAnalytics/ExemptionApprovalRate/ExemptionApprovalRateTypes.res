type exemptionApprovalRateCol =
  | Authentication_Exemption_Accepted
  | Authentication_Exemption_Requested
  | Exemption_Approval_Rate
  | Time_Bucket
  | Unknown

type responseKeys = [
  | #authentication_exemption_accepted
  | #authentication_exemption_requested
  | #exemption_approval_rate
  | #time_bucket
]

type exemptionApprovalRateObject = {
  authentication_exemption_accepted: int,
  authentication_exemption_requested: int,
  time_bucket: string,
}
