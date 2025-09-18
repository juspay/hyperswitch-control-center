type failedRefundsDistributionTypes =
  | Refunds_Failure_Rate
  | Refund_Count
  | Connector

type failedRefundsDistributionObject = {
  refund_count: int,
  refunds_failure_rate: float,
  connector: string,
}
