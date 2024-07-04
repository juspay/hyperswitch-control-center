type title = {text: string, align?: string, useHTML?: bool}
type tooltipRecord = {category: string, y: int}
external asTooltipPointFormatter: Js_OO.Callback.arity1<'a> => tooltipRecord => string = "%identity"
type tooltip = {
  pointFormatter: tooltipRecord => string,
  useHTML: bool,
  backgroundColor: string,
  borderColor: string,
  headerFormat: string,
}
type seriesOptions = {data: array<int>}
type series = {
  name: string,
  data: array<float>,
  yData?: array<int>,
  options?: seriesOptions,
  \"type": string,
}
type yAxisRecord = {series: series, x: string, y: int}
external asDataLabelFormatter: Js_OO.Callback.arity1<'a> => yAxisRecord => string = "%identity"

type dataLabels = {
  enabled: bool,
  formatter?: yAxisRecord => string,
  useHTML: bool,
}

type bar = {
  dataLabels: dataLabels,
  colors: array<string>,
  colorByPoint: bool,
  borderColor: string,
}

type plotOptions = {bar: bar}

type credits = {enabled: bool}
type chart = {\"type": string, backgroundColor: string}
type axis = {series: array<series>, categories: array<string>}
type xAxisRecord = {axis: axis, value: string}
external asXLabelFormatter: Js_OO.Callback.arity1<'a> => xAxisRecord => string = "%identity"
type labels = {
  enabled: bool,
  formatter?: xAxisRecord => string,
  useHTML?: bool,
}
type xAxis = {categories: array<string>, lineWidth: int, opposite: bool, labels: labels}
type yAxis = {min: int, title: title, labels: labels, gridLineWidth: int, visible: bool}
type legend = {enabled: bool}
type options = {
  chart: chart,
  title: title,
  subtitle: title,
  xAxis: xAxis,
  yAxis: yAxis,
  legend: legend,
  series: array<series>,
  plotOptions: option<plotOptions>,
  credits: credits,
  tooltip: tooltip,
}

type highcharts

@module("highcharts") @val external highcharts: highcharts = "default"
@module("highcharts") external highchartsModule: highcharts = "default"

module HBarChart = {
  @module("highcharts-react-official") @react.component
  external make: (~highcharts: highcharts, ~options: JSON.t=?) => React.element = "default"
}

module Chart = {
  @module("highcharts-react-official") @react.component
  external make: (~highcharts: highcharts, ~options: JSON.t=?) => React.element = "default"
}
