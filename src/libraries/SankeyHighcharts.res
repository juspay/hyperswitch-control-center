type title = {"text": string}
type node = {
  id: string,
  color: string,
  name: string,
  dataLabels: {"x": int},
}
type nodeColor = {color: string}
type tooltiplink = {
  from: string,
  to: string,
  weight: float,
  total: float,
  fromColorIndex: string,
  toColorIndex: string,
  name: string,
  fromNode: nodeColor,
  toNode: nodeColor,
}
type tooltipNodeSeriesData = {total: float}

type tooltipNodeSeries = {data: array<tooltipNodeSeriesData>}

type tooltipnode = {
  id: string,
  name: string,
  sum: int,
  linksTo: array<tooltiplink>,
  linksFrom: array<tooltiplink>,
  key: string,
  fromNode: nodeColor,
  toNode: nodeColor,
  series: tooltipNodeSeries,
  color: string,
  level: int,
}
type series = {
  "keys": array<string>,
  "type": string,
  "name": string,
  "data": array<(string, string, int, int)>,
  "nodes": array<node>,
  "nodeWidth": int,
  "minLinkWidth": int,
  "dataLabels": Js.Json.t,
  "connectEnds": bool,
}

type credits = {"enabled": bool}
type chart = {"height": int, "backgroundColor": string}
type options = {
  title: title,
  series: array<Js.Json.t>,
  chart: chart,
  credits: credits,
  tooltip: {
    "shared": bool,
    "useHTML": bool,
    "headerFormat": string,
    "pointFormatter": option<Js_OO.Callback.arity1<tooltiplink => string>>,
    "nodeFormatter": option<Js_OO.Callback.arity1<tooltipnode => string>>,
    "valueDecimals": int,
    "backgroundColor": string,
  },
}

type highcharts
type highchartsSankey
@module("highcharts") external highchartsModule: highcharts = "default"
@module("highcharts/modules/sankey")
external highchartsSankey: highcharts => unit = "default"

module SankeyReact = {
  @module("highcharts-react-official") @react.component
  external make: (~highcharts: highcharts, ~options: Js.Json.t=?) => React.element = "default"
}

module SankeyReactJsonOption = {
  @module("highcharts-react-official") @react.component
  external make: (~highcharts: highcharts, ~options: Js.Json.t=?) => React.element = "default"
}
