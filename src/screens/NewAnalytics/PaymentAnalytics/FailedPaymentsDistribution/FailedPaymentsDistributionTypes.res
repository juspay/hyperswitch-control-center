type failedPaymentsDistributionCols =
  | Payments_Failure_Rate_Distribution
  | Payments_Failure_Rate_Distribution_Without_Smart_Retries
  | Connector
  | Payment_Method
  | Payment_Method_Type
  | Authentication_Type

type failedPaymentsDistributionObject = {
  payments_failure_rate_distribution: float,
  payments_failure_rate_distribution_without_smart_retries: float,
  connector: string,
  payment_method: string,
  payment_method_type: string,
  authentication_type: string,
}
