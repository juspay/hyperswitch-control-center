type userDropOffRateCol =
  | Authentication_Attempt_Count
  | Authentication_Success_Count
  | User_Drop_Off_Rate
  | Time_Bucket
  | Unknown

type responseKeys = [
  | #authentication_attempt_count
  | #authentication_success_count
  | #user_drop_off_rate
  | #time_bucket
]

type userDropOffRateObject = {
  authentication_attempt_count: int,
  authentication_success_count: int,
  time_bucket: string,
}
