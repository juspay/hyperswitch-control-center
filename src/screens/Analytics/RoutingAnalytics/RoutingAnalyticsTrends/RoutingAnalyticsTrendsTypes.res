type routingTrendsMetrics =
  | Payment_Success_Rate
  | Payment_Count
  | Time_Bucket

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
