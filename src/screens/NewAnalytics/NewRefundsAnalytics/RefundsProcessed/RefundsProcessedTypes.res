type refundsProcessedCols =
  | Refund_Processed_Amount
  | Refund_Success_Count
  | Total_Refund_Processed_Amount
  | Total_Refund_Processed_Count
  | Time_Bucket

type refundsProcessedObject = {
  refund_processed_amount_in_usd: float,
  refund_success_count: int,
  total_refund_processed_amount_in_usd: float,
  total_refund_processed_count: int,
  time_bucket: string,
}
