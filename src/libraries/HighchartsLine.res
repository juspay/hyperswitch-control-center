type title = {"text": string}
type subtitle = {"text": string}
type series = {"type": string, "name": string, "data": array<(float, float)>}
type chart = {
  "type": string,
  "zoomType": string,
  "margin": option<array<int>>,
  "backgroundColor": Js.Nullable.t<string>,
  "height": option<int>,
}
type linearGradient = {"x1": int, "y1": int, "x2": int, "y2": int}
type stop = (int, string)
type fillColor = {"linearGradient": linearGradient, "stops": array<stop>}
type hover = {"lineWidth": int}
type states = {"hover": hover}

type area = {
  "fillColor": option<fillColor>,
  "threshold": Js.Nullable.t<string>,
  "lineWidth": int,
  "states": states,
  "pointStart": option<int>,
}

type boxplot = {"visible": bool}
type marker = {"enabled": bool}

type markerseries = {"marker": marker}

type plotOptions = {"area": area, "boxplot": boxplot, "series": markerseries}

type xAxis = {
  "visible": bool,
  "labels": option<{
    "formatter": option<unit => string>,
    "enabled": bool,
  }>,
}
type yAxis = {"visible": bool}
type credits = {"enabled": bool}
type legend = {"enabled": bool}
type tooltip = {
  "enabled": bool,
  "pointFormat": option<string>,
  "pointFormatter": option<unit => string>,
  "headerFormat": option<string>,
}

type options = {
  chart: option<chart>,
  title: title,
  series: array<series>,
  plotOptions: option<plotOptions>,
  xAxis: xAxis,
  yAxis: yAxis,
  credits: credits,
  legend: legend,
  tooltip: tooltip,
}
type highcharts
@module("highcharts") external highchartsModule: highcharts = "default"
// @module("highcharts-react-official")
// external make: (~highcharts: highcharts, ~options: options=?) => React.element = "HighchartsReact"
module HighchartsReact = {
  @module("highcharts-react-official") @react.component
  external make: (~highcharts: highcharts, ~options: options=?) => React.element = "default"
}
