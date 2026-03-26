type platformFeeRateByConnectorCols =
  | Avg_Platform_Fee_Rate
  | Connector

type platformFeeRateByConnectorObject = {
  avg_platform_fee_rate: float,
  connector: string,
}
