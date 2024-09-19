type paymentsProcessedObject = {
  count: int,
  amount: float,
  currency: string,
  time_bucket: string,
}

type paymentsProcessedCols =
  | Count
  | Amount
  | Currency
  | TimeBucket
