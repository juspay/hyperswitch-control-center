type failureReasonsColsTypes =
  | Error_Reason
  | Failure_Reason_Count
  | Reasons_Count_Ratio
  | Total_Failure_Reasons_Count
  | Connector
  | Payment_Method
  | Payment_Method_Type
  | Authentication_Type

type failureReasonsObjectType = {
  error_reason: string,
  failure_reason_count: int,
  total_failure_reasons_count: int,
  reasons_count_ratio: float,
  connector: string,
  payment_method: string,
  payment_method_type: string,
  authentication_type: string,
}
