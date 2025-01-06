type smartRetryPaymentsProcessedCols =
  | Payment_Processed_Amount
  | Payment_Processed_Count
  | Total_Payment_Processed_Amount
  | Total_Payment_Processed_Count
  | Time_Bucket

type smartRetryPaymentsProcessedObject = {
  smart_retry_payment_processed_amount: float,
  smart_retry_payment_processed_count: int,
  total_payment_smart_retry_processed_amount: float,
  total_payment_smart_retry_processed_count: int,
  time_bucket: string,
}
