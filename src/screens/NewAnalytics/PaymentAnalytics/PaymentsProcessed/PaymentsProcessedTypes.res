type paymentsProcessedObject = {
  count: int,
  amount: float,
  time_bucket: string,
}

type paymentsProcessedCols =
  | Count
  | Amount
  | TimeBucket

type categories = [#time_bucket]
