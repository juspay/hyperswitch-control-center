type platformFeesByConnectorCols =
  | Total_Platform_Fees
  | Connector

type platformFeesByConnectorObject = {
  total_platform_fees: float,
  connector: string,
}
