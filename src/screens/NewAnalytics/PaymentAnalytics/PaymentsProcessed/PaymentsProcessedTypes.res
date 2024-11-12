type paymentsProcessedCols =
  | Payment_Processed_Amount
  | Payment_Processed_Count
  | Payment_Processed_Amount_Without_Smart_Retries
  | Payment_Processed_Count_Without_Smart_Retries
  | Total_Payment_Processed_Amount
  | Total_Payment_Processed_Count
  | Total_Payment_Processed_Amount_Without_Smart_Retries
  | Total_Payment_Processed_Count_Without_Smart_Retriess
  | Time_Bucket

type paymentsProcessedObject = {
  payment_processed_amount_in_usd: float,
  payment_processed_count: int,
  payment_processed_amount_without_smart_retries_in_usd: float,
  payment_processed_count_without_smart_retries: int,
  total_payment_processed_amount_in_usd: float,
  total_payment_processed_count: int,
  total_payment_processed_amount_without_smart_retries_in_usd: float,
  total_payment_processed_count_without_smart_retries: int,
  time_bucket: string,
}
