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
type chartConfig = {
  yAxis: yAxis,
  xAxis: xAxis,
  title: title,
  colors: array<string>,
}
type chartDataConfig = {key: string}

type requestBodyConfig = {
  metrics: array<metrics>,
  groupBy: array<dimension>,
  filters: array<dimension>,
  customFilter: option<dimension>,
  applyFilterFor: option<array<string>>,
}

type entity<'t> = {
  getBody: (
    ~dimensions: dimensions,
    ~startTime: string,
    ~endTime: string,
    ~metrics: array<metrics>,
    ~groupBy: array<dimension>,
    ~filters: array<dimension>,
    ~customFilter: option<dimension>,
    ~applyFilterFor: option<array<string>>,
  ) => RescriptCore.JSON.t,
  requestBodyConfig: requestBodyConfig,
  getChartData: (~array: array<JSON.t>, ~key: string) => 't,
  dataConfig: chartDataConfig,
  chartConfig: chartConfig,
}
