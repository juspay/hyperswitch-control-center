type title = {text: string, align: string, useHTML: bool}
type point = {name: string, percentage: float}
type yAxisRecord = {point: point}
type tooltipRecord = {name: string, y: int}
type style = {color: string, opacity: string}
external asTooltipPointFormatter: Js_OO.Callback.arity1<'a> => tooltipRecord => string = "%identity"
type tooltip = {
  pointFormatter: tooltipRecord => string,
  useHTML: bool,
  backgroundColor: string,
  borderColor: string,
  headerFormat: string,
}
external asDataLabelFormatter: Js_OO.Callback.arity1<'a> => yAxisRecord => string = "%identity"
type dataLabels = {
  enabled: bool,
  connectorShape: string,
  formatter: yAxisRecord => string,
  style: style,
  useHTML: bool,
}

type pie = {
  dataLabels: dataLabels,
  startAngle: int,
  endAngle: int,
  center: array<string>,
  size: string,
  colors: array<string>,
  borderColor?: string,
}
type series = {
  name: string,
  \"type": string,
  innerSize: string,
  data: array<(string, float)>,
}

type plotOptions = {pie: pie}
type chart = {backgroundColor: string}

type credits = {enabled: bool}
type options = {
  title: title,
  subtitle: title,
  series: array<series>,
  plotOptions: option<plotOptions>,
  credits: credits,
  tooltip: tooltip,
  chart?: chart,
}

type highcharts

@module("highcharts") @val external highcharts: highcharts = "default"
@module("highcharts") external highchartsModule: highcharts = "default"

module PieChart = {
  @module("highcharts-react-official") @react.component
  external make: (~highcharts: highcharts, ~options: JSON.t=?) => React.element = "default"
}

module Chart = {
  @module("highcharts-react-official") @react.component
  external make: (~highcharts: highcharts, ~options: JSON.t=?) => React.element = "default"
}
