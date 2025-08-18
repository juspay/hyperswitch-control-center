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
