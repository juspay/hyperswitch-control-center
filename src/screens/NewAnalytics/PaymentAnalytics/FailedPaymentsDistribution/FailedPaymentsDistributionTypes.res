type col =
  | ErrorReason
  | Count
  | Ratio
  | Connector
  | PaymentsFailureRate

type failedPaymentsDistributionObject = {
  reason: string,
  count: int,
  percentage: int,
  connector: string,
}
