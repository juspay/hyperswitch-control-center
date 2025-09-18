type failreResonsColsTypes =
  | Refund_Reason
  | Refund_Reason_Count
  | Total_Refund_Reason_Count
  | Refund_Reason_Count_Ratio
  | Connector

type failreResonsObjectType = {
  connector: string,
  refund_reason: string,
  refund_reason_count: int,
  total_refund_reason_count: int,
  refund_reason_count_ratio: float,
}
