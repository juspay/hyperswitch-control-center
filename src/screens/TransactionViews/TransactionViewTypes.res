type operationsTypes = Orders | Refunds | Disputes | Payouts

type viewTypes =
  | All
  | Succeeded
  | Failed
  | Dropoffs
  | Cancelled
  | Pending
  | Expired
  | Reversed
  | RequiresCapture
  | None

type clickhouseAggregateMetric = {
  urlPrefix: string,
  domain: string,
  metric: string,
  groupByField: string,
  statusField: string,
  countField: string,
}
