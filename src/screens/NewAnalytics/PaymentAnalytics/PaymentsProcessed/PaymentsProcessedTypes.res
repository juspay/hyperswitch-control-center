type paymentsProcessedCols =
  | Payment_Processed_Amount
  | Payment_Processed_Count
  | Total_Payment_Processed_Amount
  | Total_Payment_Processed_Count
  | Time_Bucket

type paymentsProcessedObject = {
  payment_processed_amount: float,
  payment_processed_count: int,
  total_payment_processed_amount: float,
  total_payment_processed_count: int,
  time_bucket: string,
}
