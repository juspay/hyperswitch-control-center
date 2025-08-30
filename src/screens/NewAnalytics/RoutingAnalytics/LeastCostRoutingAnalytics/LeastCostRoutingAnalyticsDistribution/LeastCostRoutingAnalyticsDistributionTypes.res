type savingsTimeConfig = {
  title: string,
  tooltipTitle: string,
  yAxisMaxValue: option<int>,
  statType: LogicUtilsTypes.valueType,
  suffix: string,
}
type getObjects<'a> = {
  data: 'a,
  xKey: string,
  yKey: string,
}
