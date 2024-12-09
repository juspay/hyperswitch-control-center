type analyticsPages = Payment
type viewType = Graph | Table
type statisticsDirection = Upward | Downward | No_Change

type analyticsPagesRoutes =
  | @as("new-analytics-payment") NewAnalyticsPayment
  | @as("new-analytics-smart-retry") NewAnalyticsSmartRetry
  | @as("new-analytics-refund") NewAnalyticsRefund

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
  | #sessionized_smart_retried_amount
  | #sessionized_payments_success_rate
  | #sessionized_payment_processed_amount
  | #refund_processed_amount
  | #dispute_status_metric
  | #payments_distribution
  | #failure_reasons
  | #payments_distribution
  | #payment_success_rate
]
type granularity = [
  | #G_ONEDAY
]

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

type getObjects<'data> = {
  data: 'data,
  xKey: string,
  yKey: string,
  comparison?: DateRangeUtils.comparison,
}

type chartEntity<'t, 'chartOption, 'data> = {
  getObjects: (~params: getObjects<'data>) => 't,
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

type metricType =
  | Smart_Retry
  | Default
