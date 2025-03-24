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

type title = {text: string, visible: bool}
type yAxisTitle = {text: string}
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

type bar = {
  stacking: string,
  dataLabels: enabled,
  borderWidth: int,
  pointWidth: int,
  borderRadius: int,
}
type plotOptions = {bar: bar}
type labels = {
  align: align,
  style: style,
}
type chart = {
  \"type": \"type",
  height: int,
  spacingRight: spacingRight,
  spacingLeft: spacingLeft,
  spacingTop: int,
  style: style,
}

type dataObj = {
  name: name,
  data: array<float>,
  color: color,
}

type data = array<dataObj>

type yAxis = {
  title: yAxisTitle,
  visible: bool,
  stackLabels: enabled,
  max: int,
}

type xAxis = {
  categories: categories,
  visible: bool,
}

type point = {index: int}
type pointFormatter = {point: point}

type labelFormatter = {name: string, yData: array<int>}

external asTooltipPointFormatter: Js_OO.Callback.arity1<'a> => pointFormatter => string =
  "%identity"

external asLabelFormatter: Js_OO.Callback.arity1<'a> => labelFormatter => string = "%identity"

type cssStyle = {
  fontFamily: string,
  fontSize: string,
  padding: string,
}

type tooltip = {enabled: bool}

type legend = {
  align: string,
  verticalAlign: string,
  floating: bool,
  x: int,
  y: int,
  symbolHeight: int,
  symbolWidth: int,
  symbolRadius: int,
  itemDistance: int,
  reversed: bool,
  labelFormatter: labelFormatter => string,
}

type stackedBarGraphOptions = {
  chart: chart,
  title: title,
  xAxis: xAxis,
  yAxis: yAxis,
  plotOptions: plotOptions,
  series: data,
  credits: credits,
  tooltip: tooltip,
  legend: legend,
}

type payloadTitle = {text: string}

type stackedBarGraphPayload = {
  categories: categories,
  data: data,
  labelFormatter: labelFormatter => string,
}
