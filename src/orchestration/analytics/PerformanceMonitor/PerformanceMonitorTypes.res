type performance = [#ConnectorPerformance | #PaymentMethodPerormance]
type dimension = [#connector | #payment_method | #payment_method_type | #status | #no_value]

type status = [#charged | #failure | #payment_method_awaited]
type metrics = [#payment_count | #connector_success_rate]
type distribution = [#payment_error_message | #TOP_5]

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

type stackBarSeriesRecord = {
  name: string,
  data: array<int>,
  color: string,
}

type categories = array<string>
type series = array<stackBarSeriesRecord>
type yAxis = {text: string}
type xAxis = {text: string}

type title = {text: string}
type colors = array<string>

type donutPieSeriesRecord = {
  name: string,
  y: int,
}
type stackBarChartData = {
  categories: categories,
  series: series,
}

type gaugeData = {value: float}

type donutChatData = {series: series}

type chartDataConfig = {
  groupByKeys: array<dimension>,
  plotChartBy?: array<status>,
  yLabels?: array<string>,
  name?: metrics,
}

type distributionType = {
  distributionFor: string,
  distributionCardinality: string,
}

type requestBodyConfig = {
  metrics: array<metrics>,
  delta?: bool,
  groupBy?: array<dimension>,
  filters?: array<dimension>,
  customFilter?: dimension,
  applyFilterFor?: array<status>,
  excludeFilterValue?: array<status>,
  distribution?: distributionType,
}
type args<'t1> = {
  array: array<JSON.t>,
  config: chartDataConfig,
  optionalArgs?: 't1,
}
type entity<'t, 't1> = {
  requestBodyConfig: requestBodyConfig,
  configRequiredForChartData: chartDataConfig,
  getChartData: (~args: args<'t1>) => 't,
  title: string,
  getChartOption: 't => JSON.t,
}
