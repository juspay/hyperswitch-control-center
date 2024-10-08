type analyticsPages = Payment
type viewType = Graph | Table
type statisticsDirection = Upward | Downward | No_Change

type analyticsPagesRoutes = | @as("new-analytics-payment") NewAnalyticsPayment

type domain = [#payments | #refunds | #disputes]
type dimension = [
  | #connector
  | #payment_method
  | #payment_method_type
  | #card_network
  | #authentication_type
]
type status = [#charged | #failure]
type metrics = [
  | #payment_processed_amount
  | #payment_count
  | #payment_success_rate
  | #time_bucket
  | #connector
  | #payment_method
  | #payment_method_type
  | #card_network
  | #authentication_type
  | #smart_retried_amount
  | #payments_success_rate
  | #refund_success_count
  | #dispute_status_metric
]
type granularity = [
  | #G_ONEDAY
]
// will change this once we get the api srtcuture
type requestBodyConfig = {
  metrics: array<metrics>,
  delta?: bool,
  groupBy?: array<dimension>,
  filters?: array<dimension>,
  customFilter?: dimension,
  applyFilterFor?: array<status>,
  excludeFilterValue?: array<status>,
}

type moduleEntity = {
  requestBodyConfig: requestBodyConfig,
  title: string,
  domain: domain,
}

type chartEntity<'t, 'chartOption, 'data> = {
  getObjects: (~data: 'data, ~xKey: string, ~yKey: string) => 't,
  getChatOptions: 't => 'chartOption,
}

type optionType = {label: string, value: string}

type valueType =
  | Amount
  | Rate
  | Volume
  | Latency
  | LatencyMs
  | No_Type
