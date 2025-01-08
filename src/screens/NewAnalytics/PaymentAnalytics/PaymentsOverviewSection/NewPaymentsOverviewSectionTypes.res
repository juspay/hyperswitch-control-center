type overviewColumns =
  | Total_Smart_Retried_Amount
  | Total_Success_Rate
  | Total_Payment_Processed_Amount
  | Total_Refund_Processed_Amount
  | Total_Dispute

type responseKeys = [
  | #total_smart_retried_amount
  | #total_smart_retried_amount_in_usd
  | #total_smart_retried_amount_without_smart_retries
  | #total_smart_retried_amount_without_smart_retries_in_usd
  | #total_success_rate
  | #total_success_rate_without_smart_retries
  | #total_payment_processed_amount
  | #total_payment_processed_amount_in_usd
  | #total_payment_processed_amount_without_smart_retries
  | #total_payment_processed_amount_without_smart_retries_in_usd
  | #total_refund_processed_amount
  | #total_refund_processed_amount_in_usd
  | #total_dispute
]

type dataObj = {
  total_smart_retried_amount: float,
  total_success_rate: float,
  total_payment_processed_amount: float,
  total_refund_processed_amount: float,
  total_dispute: int,
}
