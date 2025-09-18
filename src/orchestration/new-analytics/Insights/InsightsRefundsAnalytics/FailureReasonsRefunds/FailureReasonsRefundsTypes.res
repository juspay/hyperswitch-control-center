type failreResonsColsTypes =
  | Refund_Error_Message
  | Refund_Error_Message_Count
  | Total_Refund_Error_Message_Count
  | Refund_Error_Message_Count_Ratio
  | Connector

type failreResonsObjectType = {
  connector: string,
  refund_error_message: string,
  refund_error_message_count: int,
  total_refund_error_message_count: int,
  refund_error_message_count_ratio: float,
}
