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
  | FirstAttemptSuccess
  | RetrySuccess
  | Refunded
  | Disputed
  | None

type clickhouseAggregateMetric = {
  urlPrefix: string,
  domain: string,
  metric: string,
  groupByField: string,
  statusField: string,
  countField: string,
}

type sankeyAggregateData = {
  statusWithCount: Dict.t<JSON.t>,
  refundsStatusWithCount: Dict.t<JSON.t>,
  disputeStatusWithCount: Dict.t<JSON.t>,
  firstAttemptSuccessCount: float,
  retrySuccessCount: float,
}
