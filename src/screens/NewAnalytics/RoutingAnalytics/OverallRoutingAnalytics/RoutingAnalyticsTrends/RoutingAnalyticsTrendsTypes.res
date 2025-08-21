open OverallRoutingAnalyticsTypes
type routingTrendsMetrics = [
  | #payment_success_rate
  | #payment_count
  | #time_bucket
  | #time_range
  | #connector
]

type routingTrendsObject = {
  payment_success_rate: float,
  payment_count: int,
  time_bucket: string,
}

type routingMapperConfig = {
  title: string,
  tooltipTitle: string,
  yAxisMaxValue: option<int>,
  statType: LogicUtilsTypes.valueType,
  suffix: string,
}
type status = [#charged | #failure | #success | #pending]

type requestBodyConfig = {
  metrics: array<routingTrendsMetrics>,
  delta?: bool,
  groupBy?: array<filters>,
  filters?: array<filters>,
  customFilter?: filters,
  applyFilterFor?: array<status>,
  excludeFilterValue?: array<status>,
}
type moduleEntity = {
  requestBodyConfig: requestBodyConfig,
  title: string,
  description?: string,
}
type getObjects<'data> = {
  data: 'data,
  xKey: string,
  yKey: string,
  comparison?: DateRangeUtils.comparison,
  groupByKey?: string,
}

type chartEntity<'t, 'chartOption, 'data> = {
  getObjects: (~params: getObjects<'data>) => 't,
  getChatOptions: 't => 'chartOption,
}
