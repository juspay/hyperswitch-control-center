type successRateCols =
  | Refund_Success_Rate
  | Total_Refund_Success_Rate
  | Time_Bucket

type payments_success_rate = {
  refund_success_rate: float,
  total_refund_success_rate: float,
  time_bucket: string,
}
