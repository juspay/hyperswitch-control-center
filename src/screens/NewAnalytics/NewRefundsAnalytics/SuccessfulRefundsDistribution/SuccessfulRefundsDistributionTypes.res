type successfulRefundsDistributionTypes =
  | Refunds_Success_Rate
  | Refund_Count
  | Refund_Success_Count
  | Connector

type successfulRefundsDistributionObject = {
  refund_count: int,
  refund_success_count: int,
  refunds_success_rate: float,
  connector: string,
}
