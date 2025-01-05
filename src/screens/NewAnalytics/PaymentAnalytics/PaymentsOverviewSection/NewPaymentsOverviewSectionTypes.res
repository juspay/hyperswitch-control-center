type overviewColumns =
  | Total_Smart_Retried_Amount
  | Total_Success_Rate
  | Total_Payment_Processed_Amount
  | Total_Refund_Processed_Amount
  | Total_Dispute

type dataObj = {
  total_smart_retried_amount: float,
  total_success_rate: float,
  total_payment_processed_amount: float,
  total_payment_processed_count: int,
  total_refund_processed_amount: float,
  total_dispute: int,
}
