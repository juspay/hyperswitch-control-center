type \"type" = string
type zoomType = string
type spacingLeft = int
type spacingRight = int

type info = {index: int}
type point = {color: string, x: string, y: float, point: info, key: string}
type pointFormatter = {points: array<point>}
type yAxisFormatter = {value: int}

external asTooltipPointFormatter: Js_OO.Callback.arity1<'a> => pointFormatter => string =
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
type pointWidth = int
type borderRadius = int

type style = {
  color: color,
  fontFamily?: string,
  fontSize?: string,
}
type title = {text: string, style?: style, align?: align, x?: int, y?: int}
type enabled = {enabled: bool}
type credits = {
  ...enabled,
}
type exporting = {
  ...enabled,
}
type marker = {
  ...enabled,
}
type line = {marker: marker}
type column = {pointWidth: pointWidth, borderRadius: borderRadius}
type plotOptions = {line: line, column: column}
type labels = {
  align: align,
  style: style,
  y?: y,
  x?: int,
}
type chart = {
  zoomType: zoomType,
  spacingLeft: spacingLeft,
  spacingRight: spacingRight,
}

type dataObj = {
  showInLegend: showInLegend,
  \"type": \"type",
  name: name,
  data: array<int>,
  color: color,
  yAxis: int,
}

type data = array<dataObj>

type yAxisObj = {
  title: title,
  opposite: bool,
  labels: labels,
  gridLineWidth: gridLineWidth,
  gridLineColor: gridLineColor,
  gridLineDashStyle: gridLineDashStyle,
  min: min,
  max?: option<int>,
}

type yAxis = array<yAxisObj>

type xAxis = {
  title: title,
  categories: categories,
  crosshair: crosshair,
  lineWidth: lineWidth,
  tickWidth: tickWidth,
  labels: labels,
  tickInterval: int,
  gridLineWidth: gridLineWidth,
  gridLineColor: gridLineColor,
  gridLineDashStyle: gridLineDashStyle,
  tickmarkPlacement: tickmarkPlacement,
  endOnTick: endOnTick,
  startOnTick: startOnTick,
}

type cssStyle = {
  fontFamily: string,
  fontSize: string,
  padding: string,
}

type tooltip = {
  shape: string,
  backgroundColor: string,
  borderColor: string,
  useHTML: bool,
  formatter: pointFormatter => string,
  shared: bool,
  style: cssStyle,
  borderWidth: float,
  shadow: bool,
}

type itemStyle = {
  fontFamily: string,
  fontSize: string,
  color: string,
}

type legendPoint = {
  color: string,
  name: string,
}

external asLegendsFormatter: Js_OO.Callback.arity1<'a> => legendPoint => string = "%identity"

type legend = {
  itemStyle: itemStyle,
  useHTML: bool,
  labelFormatter: legendPoint => string,
  symbolPadding: int,
  symbolWidth: int,
  symbolHeight: int,
  symbolRadius: int,
  align: string,
  verticalAlign: string,
  x: int,
  y: int,
}

type lineColumnGraphOptions = {
  chart: chart,
  legend: legend,
  title: title,
  xAxis: xAxis,
  yAxis: yAxis,
  plotOptions: plotOptions,
  series: data,
  credits: credits,
  tooltip: tooltip,
}

type lineColumnGraphPayload = {
  categories: categories,
  data: data,
  title: title,
  tooltipFormatter: pointFormatter => string,
}
