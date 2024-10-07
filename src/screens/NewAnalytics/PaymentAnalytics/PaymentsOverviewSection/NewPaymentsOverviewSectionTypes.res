type dataObj = {
  smart_retried_amount: float,
  payments_success_rate: float,
  payment_processed_amount: float,
  refund_success_count: float,
  dispute_status_metric: float,
}

type singleStatConfig = {
  titleText: string,
  description: string,
  valueType: NewAnalyticsTypes.valueType,
}
