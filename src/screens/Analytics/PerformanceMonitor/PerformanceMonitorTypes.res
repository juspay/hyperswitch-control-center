type performance = [#ConnectorPerformance | #PaymentMethodPerormance]
type dimension = [#connector | #payment_method | #payment_method_type | #status | #no_value]

type status = [#charged | #failure]
type metrics = [#payment_count]

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

type stackBarSeriesRecord = {
  name: string,
  data: array<int>,
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

type donutChatData = {series: series}
type chartOption = {
  yAxis: yAxis,
  xAxis: xAxis,
  title: title,
  colors: array<string>,
}
type chartDataConfig = {groupByKeys: array<dimension>, plotChartBy?: array<string>}

type requestBodyConfig = {
  metrics: array<metrics>,
  groupBy: array<dimension>,
  filters: array<dimension>,
  customFilter: option<dimension>,
  applyFilterFor: option<array<string>>,
}

type entity<'t> = {
  requestBodyConfig: requestBodyConfig,
  getRequestBody: (
    ~dimensions: dimensions,
    ~startTime: string,
    ~endTime: string,
    ~metrics: array<metrics>,
    ~groupBy: array<dimension>,
    ~filters: array<dimension>,
    ~customFilter: option<dimension>,
    ~applyFilterFor: option<array<string>>,
  ) => JSON.t,
  configRequiredForChartData: chartDataConfig,
  getChartData: (~array: array<JSON.t>, ~config: chartDataConfig) => 't,
  chartOption: chartOption,
  getChartOption: (chartOption, 't) => JSON.t,
}
