type performance = [#ConnectorPerformance | #PaymentMethodPerormance]
type dimension = [
  | #connector
  | #payment_method
  | #payment_method_type
  | #status
  | #no_value
  | #refund_status
]

type status = [#charged | #failure]
type metrics = [
  | #payment_count
  | #payment_success_rate
  | #refund_success_rate
  | #payment_count
  | #refund_count
]

type paymentStatus = [#failure | #charged]
type paymentDistribution = {
  payment_count: int,
  status: string,
  connector?: string,
  payment_method?: string,
}
type dimensionRecord = {
  dimension: dimension,
  values: array<string>,
}
type dimensions = array<dimensionRecord>

type seriesRecord = {
  name: string,
  data: array<int>,
}

type categories = array<string>
type series = array<seriesRecord>
type yAxis = {text: string}
type xAxis = {text: string}

type title = {text: string}
type colors = array<string>

type barChartData = {
  categories: categories,
  series: series,
}

type gaugeChartData = {value: float}

type chartConfig = {
  yAxis: yAxis,
  xAxis: xAxis,
  title: title,
  colors: array<string>,
}
type chartDataConfig = {groupByKeys: array<dimension>, name?: metrics, plotChartBy?: array<string>}

type requestBodyConfig = {
  metrics: array<metrics>,
  groupBy: array<dimension>,
  filters: array<dimension>,
  delta?: bool,
  customFilter: option<dimension>,
  applyFilterFor: option<array<string>>,
}

type entity<'t> = {
  requestBodyConfig: requestBodyConfig,
  getChartData: (~array: array<JSON.t>, ~config: chartDataConfig) => 't,
  configRequiredForChartData: chartDataConfig,
  chartConfig: chartConfig,
}
