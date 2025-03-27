type info = {index: int}
type toolTipSeris = {name: string}
type point = {name: string}
type pointFormatter = {
  color: string,
  x: string,
  y: float,
  series: toolTipSeris,
  point: point,
}
type legendLabelFormatter = {name: string, y: int}
external asTooltipPointFormatter: Js_OO.Callback.arity1<'a> => pointFormatter => string =
  "%identity"
external asLegendPointFormatter: Js_OO.Callback.arity1<'a> => legendLabelFormatter => string =
  "%identity"

type categories = array<string>
type crosshair = bool
type lineWidth = int
type tickWidth = int
type align = string
type color = string
type y = int
type gridLineWidth = int
type gridLineColor = string
type gridLineDashStyle = string
type tickmarkPlacement = string
type endOnTick = bool
type startOnTick = bool
type min = int
type showInLegend = bool
type name = string

type enabled = {enabled: bool}
type credits = {
  ...enabled,
}

type style = {
  color: color,
  fontWeight?: string,
  fontSize?: string,
  fontStyle?: string,
  width?: string,
  dashStyle?: string,
}
type title = {
  text: string,
  align?: string,
  verticalAlign?: string,
  x?: int,
  y?: int,
  style?: style,
  useHTML?: bool,
}

type legend = {
  verticalAlign?: string,
  symbolRadius?: int,
  enabled: bool,
  layout?: string,
  align?: string,
  x?: int, // Adjust for fine-tuning the position
  y?: int,
  itemMarginBottom?: int,
  floating?: bool,
  labelFormatter?: legendLabelFormatter => string,
}
type dataLabels = {
  enabled: bool,
  distance?: int,
  style?: style,
}
type pie = {
  innerSize?: string,
  showInLegend: bool,
  startAngle: int,
  endAngle: int,
  center?: array<string>,
  size?: string,
  dataLabels: dataLabels,
  borderRadius?: int,
}

type cssStyle = {
  fontFamily: string,
  fontSize: string,
  padding: string,
}

type tooltip = {
  shape?: string,
  backgroundColor?: string,
  borderColor?: string,
  useHTML: bool,
  formatter: pointFormatter => string,
  shared?: bool,
  style?: cssStyle,
  borderWidth?: float,
  shadow?: bool,
}

type plotOptions = {pie: pie}
type pieGraphDataType = {
  name: string,
  y: float,
  color?: string,
}
type dataObj<'t> = {
  \"type": string,
  innerSize: string,
  showInLegend: showInLegend,
  name: name,
  data: array<pieGraphDataType>,
  pointWidth?: int,
  pointPadding?: float,
}

type chart = {
  \"type": string,
  height: int,
  width: int,
  spacing: array<int>,
  margin: array<int>,
}

type pieCartData<'t> = array<dataObj<'t>>
type pieGraphOptions<'t> = {
  chart: chart,
  accessibility: enabled,
  title?: title,
  plotOptions: plotOptions,
  series: pieCartData<'t>,
  legend?: legend,
  credits?: credits,
  tooltip?: tooltip,
}

type pieGraphPayload<'t> = {
  data: pieCartData<'t>,
  title: title,
  tooltipFormatter: pointFormatter => string,
  legendFormatter: legendLabelFormatter => string,
  chartSize: string,
  startAngle: int,
  endAngle: int,
  legend: legend,
}

type categoryWiseBreakDown = {
  name: string,
  total: float,
  color?: string,
}

type toolTipStyle = {
  title: string,
  valueFormatterType: LogicUtilsTypes.valueType,
}
