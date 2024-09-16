type analyticsPages = Overview | Payment
type viewType = Graph | Table
type statisticsDirection = Upward | Downward

type analyticsPagesRoutes =
  | @as("new-analytics-overview") NewAnalyticsOverview
  | @as("new-analytics-payment") NewAnalyticsPayment

type domain = [#payments]
type dimension = [#no_value]
type status = [#charged | #failure]
type metrics = [#payment_processed_amount | #payment_success_rate]

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

type entity<'t, 'chatOption> = {
  requestBodyConfig: requestBodyConfig,
  title: string,
  domain: domain,
  getObjects: JSON.t => 't,
  getChatOptions: 't => 'chatOption,
}

type dropDownOptionType = {label: string}
