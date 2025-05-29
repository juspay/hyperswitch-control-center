type authenticationSuccessCol =
  | Authentication_Count
  | Authentication_Success_Count
  | Authentication_Success_Rate
  | Time_Bucket
  | Unknown

type responseKeys = [
  | #authentication_count
  | #authentication_success_count
  | #authentication_success_rate
  | #time_bucket
]

type authenticationSuccessObject = {
  authentication_count: int,
  authentication_success_count: int,
  time_bucket: string,
}
