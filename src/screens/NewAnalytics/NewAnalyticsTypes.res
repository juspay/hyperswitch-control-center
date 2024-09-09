type analyticsPages = Overview | Payment

type analyticsPagesRoutes =
  | @as("new-analytics-overview") NewAnalyticsOverview
  | @as("new-analytics-payment") NewAnalyticsPayment

type dimension = [#connector | #payment_method | #payment_method_type | #status | #no_value]
type status = [#charged | #failure | #payment_method_awaited]
type metrics = [#payment_count | #connector_success_rate]

type dimensionRecord = {
  dimension: dimension,
  values: array<string>,
}

type dimensions = array<dimensionRecord>

type requestBodyConfig = {
  metrics: array<metrics>,
  delta?: bool,
  groupBy?: array<dimension>,
  filters?: array<dimension>,
  customFilter?: dimension,
  applyFilterFor?: array<status>,
  excludeFilterValue?: array<status>,
}

type entity<'t, 't1> = {
  requestBodyConfig: requestBodyConfig,
  title: string,
  getChartOption: 't => JSON.t,
}
