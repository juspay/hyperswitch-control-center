type analyticsPages = Payment
type viewType = Graph | Table
type statisticsDirection = Upward | Downward | No_Change

type analyticsPagesRoutes =
  | @as("new-analytics/payment") NewAnalyticsPayment
  | @as("new-analytics/smart-retry") NewAnalyticsSmartRetry
  | @as("new-analytics/refund") NewAnalyticsRefund

type domain = [#payments | #refunds | #disputes]
type dimension = [
  | #connector
  | #payment_method
  | #payment_method_type
  | #card_network
  | #authentication_type
  | #error_reason
  | #refund_error_message
  | #refund_reason
]
type status = [#charged | #failure | #success | #pending]
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
  | #failure_reasons
  | // Refunds
  #sessionized_refund_processed_amount
  | #sessionized_refund_success_count
  | #sessionized_refund_success_rate
  | #sessionized_refund_count
  | #sessionized_refund_error_message
  | #sessionized_refund_reason
  | // Authentication Analytics
  #authentication_count
  | #authentication_attempt_count
  | #authentication_success_count
  | #challenge_flow_count
  | #frictionless_flow_count
  | #frictionless_success_count
  | #challenge_attempt_count
  | #challenge_success_count
  | #authentication_funnel
  | #authentication_error_message
  | #authentication_exemption_approved_count
  | #authentication_exemption_requested_count
]
type granularity = [
  | #G_ONEDAY
  | #G_ONEHOUR
  | #G_THIRTYMIN
  | #G_FIFTEENMIN
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
  description?: string,
}

type getObjects<'data> = {
  data: 'data,
  xKey: string,
  yKey: string,
  comparison?: DateRangeUtils.comparison,
  currency?: string,
  title?: string,
}

type chartEntity<'t, 'chartOption, 'data> = {
  getObjects: (~params: getObjects<'data>) => 't,
  getChatOptions: 't => 'chartOption,
}

type optionType = {label: string, value: string}

type metricType =
  | Smart_Retry
  | Default

type singleStatConfig = {
  titleText: string,
  description: string,
  valueType: LogicUtilsTypes.valueType,
}

type filters = [#currency]

type defaultFilters = [#all_currencies | #none]
