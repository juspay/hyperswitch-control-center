type overviewColumns =
  | Total_Smart_Retried_Amount
  | Total_Smart_Retried_Amount_Without_Smart_Retries
  | Total_Success_Rate
  | Total_Success_Rate_Without_Smart_Retries
  | Total_Payment_Processed_Amount
  | Total_Payment_Processed_Amount_Without_Smart_Retries
  | Refund_Processed_Amount
  | Total_Dispute

type dataObj = {
  total_smart_retried_amount_in_usd: float,
  total_smart_retried_amount_without_smart_retries_in_usd: float,
  total_success_rate: float,
  total_success_rate_without_smart_retries: float,
  total_payment_processed_amount_in_usd: float,
  total_payment_processed_count: int,
  total_payment_processed_amount_without_smart_retries_in_usd: float,
  total_payment_processed_count_without_smart_retries: int,
  refund_processed_amount: float,
  total_dispute: int,
}

type singleStatConfig = {
  titleText: string,
  description: string,
  valueType: NewAnalyticsTypes.valueType,
}
