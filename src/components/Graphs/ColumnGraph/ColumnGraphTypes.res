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
  fill: string,
}
type enabled = {enabled: bool}
type credits = {
  ...enabled,
}

type legend = {
  ...enabled,
}

type marker = {
  ...enabled,
}

type pointPadding = float
type column = {
  borderWidth: int,
  borderRadius: int,
  stacking: string,
  pointWidth: int,
}
type plotOptions = {series: column}

type chart = {
  \"type": string,
  height: int,
  style: style,
  spacingRight: spacingRight,
  spacingLeft: spacingLeft,
}

type dataObj = {
  name: string,
  y: float,
  color: string,
}

type seriesObj = {
  name: name,
  colorByPoint: bool,
  data: array<dataObj>,
}

type series = array<seriesObj>

type info = {index: int}
type point = {color: string, x: string, y: float, point: info, key: string}
type pointFormatter = {points: array<point>}
type yAxisFormatter = {value: int}

type labels = {formatter: pointFormatter => string}

type yAxis = {title: title, labels: labels}

type xAxis = {\"type": string}

external asTooltipPointFormatter: Js_OO.Callback.arity1<'a> => pointFormatter => string =
  "%identity"

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

type columnGraphOptions = {
  chart: chart,
  title: title,
  xAxis: xAxis,
  yAxis: yAxis,
  legend: legend,
  plotOptions: plotOptions,
  series: series,
  credits: credits,
  tooltip: tooltip,
}

type columnGraphPayload = {
  data: series,
  title: title,
  tooltipFormatter: pointFormatter => string,
  yAxisFormatter: pointFormatter => string,
}
