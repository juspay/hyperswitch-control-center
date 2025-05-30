type \"type" = string
type spacingLeft = int
type spacingRight = int

type categories = array<string>
type align = string
type color = string
type gridLineWidth = int
type gridLineColor = string
type gridLineDashStyle = string
type tickmarkPlacement = string
type endOnTick = bool
type startOnTick = bool
type tickInterval = int
type tickWidth = int
type min = int
type max = int
type showInLegend = bool
type name = string

type title = {text: string}
type style = {
  color: color,
  fontFamily: string,
  fontSize: string,
}
type enabled = {enabled: bool}
type credits = {
  ...enabled,
}
type marker = {
  ...enabled,
}
type pointPadding = float
type bar = {
  marker: marker,
  pointPadding: pointPadding,
  stacking?: string,
  borderWidth?: float,
  borderColor?: string,
}
type plotOptions = {bar: bar}
type labels = {
  align: align,
  style: style,
}
type chart = {
  \"type": \"type",
  spacingLeft: spacingLeft,
  spacingRight: spacingRight,
  height?: float,
  spacing?: array<int>,
}

type dataObj = {
  showInLegend: showInLegend,
  name: name,
  data: array<float>,
  color: color,
}

type data = array<dataObj>

type yAxis = {
  title?: title,
  gridLineWidth?: gridLineWidth,
  gridLineColor?: gridLineColor,
  gridLineDashStyle?: gridLineDashStyle,
  tickInterval?: tickInterval,
  min?: min,
  max?: max,
  labels?: labels,
  visible?: bool,
}

type xAxis = {
  categories?: categories,
  labels?: labels,
  tickWidth?: tickWidth,
  tickmarkPlacement?: tickmarkPlacement,
  endOnTick?: endOnTick,
  startOnTick?: startOnTick,
  gridLineDashStyle?: gridLineDashStyle,
  gridLineWidth?: gridLineWidth,
  gridLineColor?: gridLineColor,
  min?: min,
  visible?: bool,
}

type info = {index: int}
type point = {color: string, x: string, y: float, point: info}
type pointFormatter = {points: array<point>}

external asTooltipPointFormatter: Js_OO.Callback.arity1<'a> => pointFormatter => string =
  "%identity"

type cssStyle = {
  fontFamily: string,
  fontSize: string,
  padding: string,
}

type tooltip = {
  shape?: string,
  backgroundColor?: string,
  borderColor?: string,
  useHTML?: bool,
  formatter?: pointFormatter => string,
  shared?: bool,
  style?: cssStyle,
  borderWidth?: float,
  shadow?: bool,
  enabled?: bool,
}

type barGraphOptions = {
  chart: chart,
  title: title,
  xAxis: xAxis,
  yAxis: yAxis,
  plotOptions: plotOptions,
  series: data,
  credits: credits,
  tooltip: tooltip,
}

type barGraphPayload = {
  categories: categories,
  data: data,
  title: title,
  tooltipFormatter: pointFormatter => string,
}
