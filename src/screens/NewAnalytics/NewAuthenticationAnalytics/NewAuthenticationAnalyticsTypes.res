type timeRange = {
  start_time: string,
  end_time: string,
}

type queryDataType = {
  authentication_count: int,
  authentication_attempt_count: int,
  authentication_success_count: int,
  authentication_exemption_accepted: option<int>,
  authentication_exemption_requested: option<int>,
  challenge_flow_count: int,
  challenge_attempt_count: int,
  challenge_success_count: int,
  frictionless_flow_count: int,
  frictionless_success_count: int,
  error_message_count: int,
  authentication_funnel: int,
  authentication_status: option<string>,
  trans_status: option<string>,
  error_message: string,
  authentication_connector: option<string>,
  message_version: option<string>,
  time_range: timeRange,
  time_bucket: string,
}
type timeRangeType = {
  startTime: string,
  endTime: string,
}

type secondFunnelDataType = {
  authentication_count: int,
  authentication_attempt_count: int,
  authentication_success_count: int,
  challenge_flow_count: int,
  challenge_attempt_count: int,
  challenge_success_count: int,
  frictionless_flow_count: int,
  frictionless_success_count: int,
  error_message_count: option<int>,
  authentication_funnel: int,
  authentication_status: option<string>,
  trans_status: option<string>,
  error_message: option<string>,
  authentication_connector: option<string>,
  message_version: option<string>,
  time_range: timeRange,
  time_bucket: string,
}

type funnelDataType = {
  mutable payments_requiring_3ds_2_authentication: int,
  mutable authentication_initiated: int,
  mutable authentication_attemped: int,
  mutable authentication_successful: int,
}

type metaDataType = {total_error_message_count: int}

type insightsDataType = {
  queryData: array<queryDataType>,
  metaData: array<metaDataType>,
}

type metricsData = {
  title: string,
  value: float,
  valueType: LogicUtilsTypes.valueType,
  tooltip_description: string,
}

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
  | #authentication_exemption_accepted
  | #authentication_exemption_requested
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
  description?: string,
  domain: domain,
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
