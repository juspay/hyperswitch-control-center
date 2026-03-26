type transferAmountOverTimeCols =
  | Total_Transfer_Amount
  | Time_Bucket
  | Connector

type transferAmountOverTimeObject = {
  total_transfer_amount: float,
  time_bucket: string,
  connector: string,
}
