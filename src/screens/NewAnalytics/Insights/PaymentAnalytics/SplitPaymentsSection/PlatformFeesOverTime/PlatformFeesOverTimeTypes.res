type platformFeesOverTimeCols =
  | Total_Platform_Fees
  | Time_Bucket
  | Connector

type platformFeesOverTimeObject = {
  total_platform_fees: float,
  time_bucket: string,
  connector: string,
}
