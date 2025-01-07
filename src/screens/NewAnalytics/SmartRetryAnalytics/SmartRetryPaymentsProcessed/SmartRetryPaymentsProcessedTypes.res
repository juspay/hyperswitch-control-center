type smartRetryPaymentsProcessedCols =
  | Payment_Processed_Amount
  | Payment_Processed_Count
  | Total_Payment_Processed_Amount
  | Total_Payment_Processed_Count
  | Time_Bucket

type responseKeys = [
  | #payment_processed_amount
  | #payment_processed_amount_in_usd
  | #payment_processed_amount_without_smart_retrie
  | #payment_processed_amount_without_smart_retries_in_usd
  | #payment_processed_count
  | #payment_processed_count_without_smart_retries
  | #total_payment_processed_amount
  | #total_payment_processed_amount_in_usd
  | #total_payment_processed_amount_without_smart_retries
  | #total_payment_processed_amount_without_smart_retries_in_usd
  | #total_payment_processed_count
  | #total_payment_processed_count_without_smart_retries
  | #time_bucket
]

type smartRetryPaymentsProcessedObject = {
  smart_retry_payment_processed_amount: float,
  smart_retry_payment_processed_count: int,
  total_payment_smart_retry_processed_amount: float,
  total_payment_smart_retry_processed_count: int,
  time_bucket: string,
}
