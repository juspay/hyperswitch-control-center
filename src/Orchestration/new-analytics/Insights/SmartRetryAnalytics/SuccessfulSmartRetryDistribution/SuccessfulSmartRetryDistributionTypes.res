type successfulSmartRetryDistributionCols =
  | Payments_Success_Rate_Distribution_With_Only_Retries
  | Connector
  | Payment_Method
  | Payment_Method_Type
  | Authentication_Type

type successfulSmartRetryDistributionObject = {
  payments_success_rate_distribution_with_only_retries: float,
  connector: string,
  payment_method: string,
  payment_method_type: string,
  authentication_type: string,
}
