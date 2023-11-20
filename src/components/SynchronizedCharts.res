%%raw(`require("./highcharts.css")`)

open LogicUtils
type highcharts
type tooltipPosition = {
  x: int,
  y: int,
}
type tooltipPoint = {
  plotX: int,
  plotY: int,
}

external chartsToDict: highcharts => Js.Dict.t<Js.Json.t> = "%identity"
@send
external setState: (Js.Json.t, string, bool) => unit = "setState"
@send
external drawCrosshair: (Js.Json.t, Js.Json.t, Js.Json.t) => unit = "drawCrosshair"
@send
external hideCrosshair: (Js.Json.t, unit) => unit = "hideCrosshair"
@send
external refresh: (Js.Dict.t<Js.Json.t>, array<Js.Json.t>) => unit = "refresh"
@send
external hide: (Js.Dict.t<Js.Json.t>, unit) => unit = "hide"
@send
external show: (Js.Dict.t<Js.Json.t>, unit) => unit = "show"
@send
external getPosition: (Js.Json.t, int, int, tooltipPoint) => tooltipPosition = "getPosition"
@send
external getChartPosition: Js.Json.t => Js.Json.t = "getChartPosition"

@module("highcharts") external highchartsModule: highcharts = "default"

type animation = {duration?: int}

type style = {
  color?: string,
  fontWeight?: int,
  fontSize?: int,
  fontFamily?: string,
  lineWidth?: int,
  lineHeight?: float,
  zIndex?: int,
  width?: string,
}

type chart = {
  \"type"?: string,
  height?: int,
  zoomType?: string,
  panning?: bool,
  className?: string,
  borderColor?: string,
  backgroundColor?: string,
  borderWidth?: int,
  borderRadius?: int,
  spacingTop?: int,
  spacingBottom?: int,
  spacingLeft?: int,
  spacingRight?: int,
  animation?: animation,
  fontFamily?: string,
  style?: style,
}

type title = {
  text?: string,
  useHTML?: bool,
  align?: string,
  floating?: bool,
  x?: int,
  y?: int,
  style?: style,
}

type crosshair = {color?: string, zIndex?: int}

type xAxis = {
  \"type"?: string,
  lineColor?: string,
  crosshair?: crosshair,
}

type yAxisRecord = {value: float}

type labels = {
  formatter?: Js_OO.Callback.arity1<yAxisRecord => string>,
  enabled?: bool,
  useHTML?: bool,
}
type tickPositionerYaxis = {dataMin: float, dataMax: float}
type yAxis = {
  title?: title,
  tickPositioner?: Js_OO.Callback.arity1<tickPositionerYaxis => array<float>>,
  opposite?: bool,
  gridZIndex?: int,
  gridLineColor?: string,
  gridLineDashStyle?: string,
  lineColor?: string,
  lineWidth?: int,
  visible?: bool,
  labels?: labels,
}

type tooltip = {
  xDateFormat?: string,
  shared?: bool,
  useHTML?: bool,
  hideDelay?: int,
  positioner?: Js_OO.Callback.arity4<(Js.Json.t, int, int, tooltipPoint) => tooltipPosition>,
  formatter?: Js_OO.Callback.arity1<Js.Json.t => string>,
  stickOnContact?: bool,
  borderWidth?: int,
  borderRadius?: int,
  backgroundColor?: string,
  shadow?: bool,
  outside?: bool,
  followPointer?: bool,
  className?: string,
  style?: style,
}

type legend = {enabled?: bool}
type credits = {enabled?: bool}
type halo = {size?: int}
type hover = {
  lineWidth?: int,
  lineWidthPlus?: int,
  enabled?: bool,
  halo?: halo,
}

type inactive = {enabled?: bool}

type states = {hover?: hover, inactive?: inactive}

type area = {
  fillOpacity?: float,
  lineWidth?: int,
  states?: states,
}

type boxplot = {visible?: bool}
type marker = {
  enabled?: bool,
  radius?: float,
  symbol?: string,
}
type events = {
  mouseOver?: Js_OO.Callback.arity1<Js.Json.t => unit>,
  mouseOut?: Js_OO.Callback.arity1<Js.Json.t => unit>,
  click?: Js_OO.Callback.arity1<Js.Json.t => unit>,
}

type point = {events?: events}
type series = {
  marker?: marker,
  states?: states,
  point?: point,
  cursor?: string,
}

type plotOptions = {
  area?: area,
  boxplot?: boxplot,
  series?: series,
}

type seriesLine = {
  name?: string,
  data?: array<(float, float)>,
  dashStyle?: string,
  animation?: animation,
  color?: string,
  legendIndex?: int,
  lineWidth?: float,
  opacity?: float,
  zIndex?: int,
  marker?: marker,
}

type options = {
  chart?: chart,
  title?: title,
  subtitle?: title,
  xAxis?: xAxis,
  yAxis?: yAxis,
  tooltip?: tooltip,
  legend?: legend,
  credits?: credits,
  plotOptions?: plotOptions,
  series?: array<seriesLine>,
}

module HighchartsReact = {
  @module("highcharts-react-official") @react.component
  external make: (~highcharts: highcharts, ~options: options=?) => React.element = "default"
}

let getMatchedPoint = (points, xAxis) => {
  points->Js.Array2.find(point => {
    point->getDictFromJsonObject->getFloat("x", 0.) === xAxis
  })
}

let setHighlightState = (~hideTitle=false, ()) =>
  @this
  (point: Js.Json.t) => {
    let charts =
      highchartsModule
      ->chartsToDict
      ->getArrayFromDict("charts", [])
      ->Belt.Array.keepMap(Js.Json.decodeObject)
    let currentSeries = point->getDictFromJsonObject->getObj("series", Js.Dict.empty())
    let currentChart = currentSeries->getObj("chart", Js.Dict.empty())
    let xAxisPoint = point->getDictFromJsonObject->getFloat("x", 0.)
    charts->Js.Array2.forEach(chart => {
      let title = chart->getObj("title", Js.Dict.empty())
      if !(title->Js.Json.object_->checkEmptyJson) && hideTitle {
        title->hide()
      }
      if chart !== currentChart {
        let matchedPoints = []
        let series = chart->getArrayFromDict("series", [])
        series->Js.Array2.forEach(s => {
          let pointsArr = s->getDictFromJsonObject->getArrayFromDict("points", [])
          let matchedPoint =
            pointsArr
            ->getMatchedPoint(xAxisPoint)
            ->Belt.Option.getWithDefault(Js.Dict.empty()->Js.Json.object_)

          if !(matchedPoint->checkEmptyJson) {
            matchedPoints->Js.Array2.push(matchedPoint)->ignore
            matchedPoint->setState("hover", false)
          }
        })
        let xAxisArr = chart->getArrayFromDict("xAxis", [])
        let xAxis =
          xAxisArr->Belt.Array.get(0)->Belt.Option.getWithDefault(Js.Dict.empty()->Js.Json.object_)

        let matchedPoint_0 =
          matchedPoints
          ->Belt.Array.get(0)
          ->Belt.Option.getWithDefault(Js.Dict.empty()->Js.Json.object_)
        let tooltip = chart->getObj("tooltip", Js.Dict.empty())
        if !(tooltip->Js.Json.object_->checkEmptyJson) && !(xAxis->checkEmptyJson) {
          tooltip->refresh(matchedPoints)
          xAxis->drawCrosshair(Js.Dict.empty()->Js.Json.object_, matchedPoint_0)
        }
      }
    })
  }

let hideHighlightState = (~showTitle=false, ()) =>
  @this
  (point: Js.Json.t) => {
    let charts =
      highchartsModule
      ->chartsToDict
      ->getArrayFromDict("charts", [])
      ->Js.Array2.map(getDictFromJsonObject)
    let currentSeries = point->getDictFromJsonObject->getObj("series", Js.Dict.empty())
    let currentChart = currentSeries->getObj("chart", Js.Dict.empty())
    let xAxisPoint = point->getDictFromJsonObject->getFloat("x", 0.)
    charts->Js.Array2.forEach(chart => {
      let title = chart->getObj("title", Js.Dict.empty())
      if !(title->Js.Json.object_->checkEmptyJson) && showTitle {
        title->show()
      }
      if chart !== currentChart {
        let series = chart->getArrayFromDict("series", [])
        series->Js.Array2.forEach(s => {
          let pointsArr = s->getDictFromJsonObject->getArrayFromDict("points", [])
          let matchedPoint =
            pointsArr
            ->getMatchedPoint(xAxisPoint)
            ->Belt.Option.getWithDefault(Js.Dict.empty()->Js.Json.object_)
          if !(matchedPoint->checkEmptyJson) {
            matchedPoint->setState("", false)
          }
        })
        let xAxis =
          chart
          ->getArrayFromDict("xAxis", [])
          ->Belt.Array.get(0)
          ->Belt.Option.getWithDefault(Js.Dict.empty()->Js.Json.object_)
        let tooltip = chart->getObj("tooltip", Js.Dict.empty())
        if !(tooltip->Js.Json.object_->checkEmptyJson) {
          tooltip->hide()
          xAxis->hideCrosshair()
        }
      }
    })
  }
