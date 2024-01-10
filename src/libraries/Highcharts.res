type title = {"text": string, "style": Js.Json.t}
type subtitle = {"text": string}
type data_obj = {"name": string, "value": int, "color": string, "id": string}
type new_series = {"type": string, "layoutAlgorithm": string, "data": array<data_obj>}
type series = {"type": string, "name": string, "data": array<(float, float)>}

type fillColorSeries = {
  linearGradient?: (int, int, int, int),
  color?: string,
  stops: ((int, string), (int, string)),
}
type tooltipPointer = {followPointer: bool}
type dataLableStyle = {
  color: option<string>,
  fontSize: option<string>,
}
type yAxisRecord = {value: float, name: string}
type dataLabels = {
  enabled: bool,
  formatter: option<Js_OO.Callback.arity1<Js.Json.t => string>>,
  useHTML: bool,
}

type seriesLine<'a> = {
  name: string,
  data: array<('a, Js.Nullable.t<float>)>,
  color: option<string>,
  pointPlacement?: string,
  legendIndex: int,
  fillColor?: fillColorSeries,
  fillOpacity?: float,
  lineWidth?: int,
  opacity?: float,
  stroke?: string,
  tooltip?: tooltipPointer,
  fill?: string,
  connectNulls?: bool,
  dataLabels?: dataLabels,
  showInLegend?: bool,
}

type series2<'t> = {"type": string, "name": string, "data": array<'t>}

type series5

@obj external makeAreaSeries: (~\"type": string, ~something: bool) => series5 = ""
@obj
external makeSomethingSeries: (~\"type": string, ~something: (float, int, string)) => series5 = ""

let x = makeAreaSeries(~\"type"="hello", ~something=false)
let y = makeSomethingSeries(~\"type"="hello", ~something=(2., 1, "heloo"))

type gridLine = {attr: (. Js.Json.t) => unit}
type pos
type tick = {
  gridLine: gridLine,
  pos: float,
}
type eventYaxis = {ticks: Dict.t<gridLine>}
type chartEventOnload = {yAxis: array<eventYaxis>}
type chartEvent = {render: option<Js_OO.Callback.arity1<chartEventOnload => unit>>}
type chart = {
  "type": string,
  "zoomType": string,
  "margin": option<array<int>>,
  "backgroundColor": Js.Nullable.t<string>,
  "height": option<int>,
  "width": option<int>,
  "events": option<chartEvent>,
}
type linearGradient = {"x1": int, "y1": int, "x2": int, "y2": int}
type stop = (int, string)
type fillColor = {"linearGradient": linearGradient, "stops": array<stop>}
type hover = {"lineWidth": float}
type states = {"hover": hover}

type area = {
  "fillColor": option<fillColor>,
  "threshold": Js.Nullable.t<string>,
  "lineWidth": float,
  "states": states,
  "pointStart": option<int>,
  "fillOpacity": float,
}

type boxplot = {"visible": bool}
type marker = {"enabled": option<bool>, "radius": option<int>, "symbol": option<string>}

type markerseries = {"marker": marker}

type plotOptionshalo = {"size": option<int>}
type plotOptionsHover = {"enabled": option<bool>, "halo": option<plotOptionshalo>}
type plotOptionsStates = {"hover": option<plotOptionsHover>}
type plotOptionsStateConfig = {"states": plotOptionsStates}

type element = {visible: bool}
type chartLegend = {series: array<element>}
type legendItem = {chart: chartLegend}
@send
external show: element => unit = "show"
@send
external hide: element => unit = "hide"
type eventClick = {
  "legendItemClick": option<Js_OO.Callback.arity2<(legendItem, ReactEvent.Keyboard.t) => unit>>,
  "mouseOver": option<string>,
}

// type plotOptionPoint = {
//   "mouseOver": option<Js_OO.Callback.arity1<Js.Json.t => unit>>,
//   "mouseOut": option<Js_OO.Callback.arity1<Js.Json.t => unit>>,
// }

// type pointEvents = {"events": option<plotOptionPoint>}

type plotOptionSeries = {
  "marker": marker,
  "states": option<plotOptionsStates>,
  "events": option<eventClick>,
  // "point": option<pointEvents>,
}

// can be uncommented if require but pls check x asis does not breaks
type xAxis = {
  // "visible": bool,
  // "labels": option<{
  //   "formatter": option<unit => string>,
  //   "enabled": bool,
  // }>,
  "type": string,
  // "crosshair": option<Js.Json.t>,
}
type plotLinesLablesStyle = {
  color: option<string>,
  fontWeight: option<string>,
  background: option<string>,
}
type plotLineLable = {align: option<string>, style: option<plotLinesLablesStyle>}
type plotLines = {
  label: option<plotLineLable>,
  dashStyle: option<string>,
  value: option<float>,
  width: option<int>,
  color: option<string>,
}
type chartCssObject = {
  color: string,
  backgroundColor: string,
}
// type yTickPostion

type tickPositionerYaxis = {dataMin: float, dataMax: float}
type yAxis = {
  "tickPositioner": option<Js_OO.Callback.arity1<tickPositionerYaxis => array<float>>>,
  "visible": bool,
  "title": Js.Json.t,
  "labels": option<{
    "formatter": option<Js_OO.Callback.arity1<yAxisRecord => string>>,
    "enabled": bool,
    "useHTML": bool,
  }>,
  "plotLines": option<array<plotLines>>,
  // "opposite": option<bool>,
  // "gridLineColor": option<string>,
  // "gridLineDashStyle": option<string>,
  // "lineWidth": option<int>,
}
type seriesTooltip = {
  color: string,
  name: string,
}
type tooltipchart = {
  series: seriesTooltip,
  x: string,
  y: float,
}
type legendchart = {name: string}
type credits = {"enabled": bool}
type legendStyle = {"color": string, "cursor": string, "fontSize": string, "fontWeight": string}

type tooltipPosition = {
  x: int,
  y: int,
}

type tooltipPoint = {
  plotX: int,
  plotY: int,
}
type a
type b

type plotPostion = {plotLeft: int, plotSizeX: int, plotSizeY: int, plotWidth: int, plotTop: int}
type toltipPositioner = {chart: plotPostion}

type tooltip = {
  "shared": bool,
  "enabled": bool,
  "useHTML": bool,
  "pointFormat": option<string>,
  "pointFormatter": option<Js_OO.Callback.arity1<tooltipchart => string>>,
  "headerFormat": option<string>,
  "hideDelay": int,
  "outside": bool,
  "positioner": option<
    Js_OO.Callback.arity4<(toltipPositioner, int, int, tooltipPoint) => tooltipPoint>,
  >,
}
type optionsJson<'a> = {
  chart: option<Js.Json.t>,
  title: Js.Json.t,
  series: array<'a>,
  plotOptions: option<Js.Json.t>,
  xAxis: Js.Json.t,
  yAxis: Js.Json.t,
  credits: credits,
  legend: Js.Json.t,
  tooltip?: Js.Json.t,
}

type options<'a> = {
  chart: option<Js.Json.t>,
  title: Js.Json.t,
  series: array<seriesLine<'a>>,
  plotOptions: option<Js.Json.t>,
  xAxis: Js.Json.t,
  yAxis: Js.Json.t,
  credits: credits,
  legend: Js.Json.t,
  tooltip?: Js.Json.t,
}

type chartType = {
  chartType: string,
  backgroundColor: Js.Nullable.t<string>,
}

let makebarChart = (
  ~chartType: string="",
  ~backgroundColor: Js.Nullable.t<string>=Js.Nullable.null,
  (),
) => {
  {
    "type": chartType,
    "backgroundColor": backgroundColor,
  }
}
type barChart = {"type": string, "backgroundColor": Js.Nullable.t<string>}
type barSeries = {data: array<Js.Json.t>}
type xAxis1 = {"type": string}

type barChartSeries = {
  color?: string,
  data: array<float>,
  name?: string,
}
type barChartTitle = {text: string}
type barChartLabels = {formatter: option<Js_OO.Callback.arity1<yAxisRecord => string>>}
type barLegend = {enabled: bool}
type barChartXAxis = {categories: array<string>}
type barChartYaxis = {
  gridLineColor: string,
  labels: option<barChartLabels>,
  title: barChartTitle,
}
//NOTE this can be removed
type barOptions = {
  chart: barChart,
  title: Js.Json.t,
  series: array<barSeries>,
  xAxis: barChartXAxis,
  yAxis: barChartYaxis,
  credits: credits,
  legend: barLegend,
}

type highcharts

@module("highcharts") @val external highcharts: highcharts = "default"
@module("highcharts") external highchartsModule: highcharts = "default"

@module("highcharts") @scope("default")
external objectEach: (Dict.t<gridLine>, tick => unit) => unit = "objectEach"

@module("highcharts/modules/treemap") external treeMapModule: highcharts => unit = "default"
@module("highcharts/modules/sankey") external sankeyChartModule: highcharts => unit = "default"
@module("highcharts/highcharts-more") external bubbleChartModule: highcharts => unit = "default"
@module("highcharts/modules/sunburst") external sunburstChartModule: highcharts => unit = "default"
// @module("highcharts-react-official")
// external make: (~highcharts: highcharts, ~options: options=?) => React.element = "HighchartsReact"
type afterChartCreated
// type chartCallback = {afterChartCreated: afterChartCreated}
type ticks
type callBackYaxis // = {ticks: ticks}
type chartCallback = {yAxis: array<Js.Json.t>}

module HighchartsReact = {
  @module("highcharts-react-official") @react.component
  external make: (
    ~highcharts: highcharts,
    ~options: options<'a>=?,
    ~callback: Js_OO.Callback.arity2<('a, chartCallback) => unit>=?,
  ) => React.element = "default"
}

module HighchartsReactDataJson = {
  @module("highcharts-react-official") @react.component
  external make: (
    ~highcharts: highcharts,
    ~options: optionsJson<'a>=?,
    ~callback: Js_OO.Callback.arity2<('a, chartCallback) => unit>=?,
  ) => React.element = "default"
}

module BarChart = {
  @module("highcharts-react-official") @react.component
  external make: (~highcharts: highcharts, ~options: Js.Json.t=?) => React.element = "default"
}

module PieChart = {
  @module("highcharts-react-official") @react.component
  external make: (~highcharts: highcharts, ~options: Js.Json.t=?) => React.element = "default"
}

module Chart = {
  @module("highcharts-react-official") @react.component
  external make: (~highcharts: highcharts, ~options: Js.Json.t=?) => React.element = "default"
}

module DonutChart = {
  @module("highcharts-react-official") @react.component
  external make: (~highcharts: highcharts, ~options: Js.Json.t=?) => React.element = "default"
}
