type overviewColumns =
  | Total_Refund_Processed_Amount
  | Total_Refund_Success_Rate
  | Successful_Refund_Count
  | Failed_Refund_Count
  | Pending_Refund_Count

type dataObj = {
  total_refund_processed_amount_in_usd: float,
  total_refund_success_rate: float,
  successful_refund_count: int,
  failed_refund_count: int,
  pending_refund_count: int,
}
