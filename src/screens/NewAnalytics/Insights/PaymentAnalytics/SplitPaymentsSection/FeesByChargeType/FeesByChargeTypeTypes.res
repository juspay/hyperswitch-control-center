type feesByChargeTypeCols =
  | Total_Platform_Fees
  | Charge_Type

type feesByChargeTypeObject = {
  total_platform_fees: float,
  charge_type: string,
}
