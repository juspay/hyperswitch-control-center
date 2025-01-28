type refundsProcessedCols =
  | Refund_Processed_Amount
  | Refund_Processed_Count
  | Total_Refund_Processed_Amount
  | Total_Refund_Processed_Count
  | Time_Bucket

type responseKeys = [
  | #refund_processed_amount
  | #refund_processed_amount_in_usd
  | #refund_processed_count
  | #total_refund_processed_amount
  | #total_refund_processed_amount_in_usd
  | #total_refund_processed_count
  | #time_bucket
]

type refundsProcessedObject = {
  refund_processed_amount: float,
  refund_processed_count: int,
  total_refund_processed_amount: float,
  total_refund_processed_count: int,
  time_bucket: string,
}
