type successRateCols =
  | Successful_Payments
  | Successful_Payments_Without_Smart_Retries
  | Total_Payments
  | Payments_Success_Rate
  | Payments_Success_Rate_Without_Smart_Retries
  | Total_Success_Rate
  | Total_Success_Rate_Without_Smart_Retries
  | Time_Bucket

type payments_success_rate = {
  successful_payments: int,
  successful_payments_without_smart_retries: int,
  total_payments: int,
  payments_success_rate: float,
  payments_success_rate_without_smart_retries: float,
  total_success_rate: float,
  total_success_rate_without_smart_retries: float,
  time_bucket: string,
}
