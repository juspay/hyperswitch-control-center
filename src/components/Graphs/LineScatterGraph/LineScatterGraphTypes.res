type \"type" = string
type spacingLeft = int
type spacingRight = int

type info = {index: int}
type pointSeries = {name: string}
type point = {color: string, x: string, y: float, point: info, series: pointSeries}
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

type style = {
  color: color,
  fontFamily?: string,
  fontSize?: string,
  fontWeight?: string,
}
type title = {text: string, style?: style, align?: align, x?: int, y?: int}
type enabled = {enabled: bool}
type credits = {
  ...enabled,
}
type exporting = {
  ...enabled,
}

type inactive = {...enabled, opacity: float}

type states = {inactive: inactive}

type plotSeries = {states: states}

type marker = {
  ...enabled,
  radius?: float,
  symbol?: string,
}

type scatter = {marker: marker}

type line = {marker: marker}
type plotOptions = {line: line, series: plotSeries, scatter?: scatter}
type labels = {
  formatter: pointFormatter => string,
  align: align,
  style: style,
  y?: y,
  x?: int,
}
type xAxisLabels = {
  align: align,
  style: style,
  y?: y,
  x?: int,
}
type chart = {
  height: int,
  spacingLeft: spacingLeft,
  spacingRight: spacingRight,
  style: style,
}

type dataObj = {
  \"type"?: \"type",
  showInLegend: showInLegend,
  name: name,
  data: array<JSON.t>,
  color: color,
}

type data = array<dataObj>

type yAxis = {
  title: title,
  labels: labels,
  gridLineWidth: gridLineWidth,
  gridLineColor: gridLineColor,
  gridLineDashStyle: gridLineDashStyle,
  min?: option<int>,
  max?: option<int>,
}

type xAxis = {
  categories: categories,
  crosshair: crosshair,
  lineWidth: lineWidth,
  tickWidth: tickWidth,
  labels: xAxisLabels,
  tickInterval: int,
  gridLineWidth: gridLineWidth,
  gridLineColor: gridLineColor,
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
  ...enabled,
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
  fontWeight?: string,
}

type legendPoint = {
  color: string,
  name: string,
}

external asLegendsFormatter: Js_OO.Callback.arity1<'a> => legendPoint => string = "%identity"

type legend = {
  useHTML: bool,
  labelFormatter: legendPoint => string,
  symbolPadding?: int,
  symbolWidth?: int,
  itemStyle?: itemStyle,
  align?: string,
  verticalAlign?: string,
  floating?: bool,
  x?: int,
  y?: int,
  margin?: int,
}

type lineScatterGraphOptions = {
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

type chartHeight = DefaultHeight | Custom(int)
type chartLeftSpacing = DefaultLeftSpacing | Custom(int)

type lineScatterGraphPayload = {
  chartHeight: chartHeight,
  chartLeftSpacing: chartLeftSpacing,
  categories: categories,
  data: data,
  title: title,
  yAxisMaxValue: option<int>,
  yAxisMinValue: option<int>,
  tooltipFormatter: pointFormatter => string,
  yAxisFormatter: pointFormatter => string,
  legend: legend,
  symbol?: string,
}
