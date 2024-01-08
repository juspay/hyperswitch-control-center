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

let formattedLabel = (value: float) => {
  value->Js.Float.toFixedWithPrecision(~digits=2) ++ "%"
}

let fromColorIndex = t => {
  if t.from === "Start" {
    "300"
  } else {
    "400"
  }
}

let sumOfNodeLinks: (float, tooltiplink) => float = (accumulator, node) => {
  accumulator +. node.total
}

let title_class = `block font-bold text-lg text-white text-opacity-75 dark:text-black dark:text-opacity-75 pt-6`
let subtitle_class = `inline font-medium text-base text-white text-opacity-75 dark:text-black dark:text-opacity-75 mt-4 -ml-2 `
let sankey_node_class = `font-semibold text-fs-13 not-italic dark:fill-jp-gray-tabset_gray fill-jp-gray-border_gray `

let tooltipFormatter = () => {
  @this
  (t: tooltiplink) => {
    open LogicUtils
    let tFrom =
      t.from->String.includes("( +++ )")
        ? t.from->String.split("( +++ )")->Belt.Array.get(0)->Belt.Option.getWithDefault("")
        : t.from
    let tTo =
      t.to->String.includes("( +++ )")
        ? t.to->String.split("( +++ )")->Belt.Array.get(0)->Belt.Option.getWithDefault("")
        : t.to
    `<div class="w-70 p-4 rounded-lg">
        <div class="block"><div class="align-sub rounded-sm inline-block w-4 h-4  mr-4 bg-red" style="fill: ${t.fromNode.color};background: ${t.fromNode.color};"></div>
        <div class="${subtitle_class}">
          ${tFrom}
        </div>
        <div class="block border-dashed ml-1 h-7 w-0 border-2 border-inherit"></div>
        <div class="block"><div class="align-sub rounded-sm inline-block w-4 h-4 mr-4" style="fill: ${t.toNode.color};background: ${t.toNode.color};"></div>
        <div class="${subtitle_class}">
          ${tTo}
        </div>
        <div class ="${title_class}"><b>
          ${shortNum(
        ~labelValue=t.weight,
        ~numberFormat=getDefaultNumberFormat(),
        (),
      )}  of ${shortNum(~labelValue=t.total, ~numberFormat=getDefaultNumberFormat(), ())}
          (${formattedLabel(t.weight *. 100.00 /. t.total)}) </b>
        </div>
      </div>`
  }
}

let nodeFormatter = (~data: array<(string, string, int, int, int)>) => {
  @this
  (t: tooltipnode) => {
    open LogicUtils
    let filteredDataNonLastindex = data->Array.filter(item => {
      let (_, _, _, _, index) = item
      index === t.level
    })

    let filteredDataLastIndex = data->Array.filter(item => {
      let (_, _, _, _, index) = item
      index === t.level - 1
    })

    let total_weight_to =
      filteredDataNonLastindex
      ->Array.map(item => {
        let (_, _, current_weight, _, _) = item
        current_weight->Belt.Int.toFloat
      })
      ->AnalyticsUtils.sumOfArrFloat

    let total_weight_from =
      filteredDataLastIndex
      ->Array.map(item => {
        let (_, _, current_weight, _, _) = item
        current_weight->Belt.Int.toFloat
      })
      ->AnalyticsUtils.sumOfArrFloat
    // case if less nodes volume are coming and more volume is going
    let total_weight = Js.Math.max_float(total_weight_to, total_weight_from)
    let overallText = if total_weight !== 0. {
      `of ${shortNum(~labelValue=total_weight, ~numberFormat=getDefaultNumberFormat(), ())}
      (${formattedLabel(t.sum->Belt.Int.toFloat *. 100.00 /. total_weight)})</b>`
    } else {
      ""
    }

    `<div class="w-70 p-4 rounded-lg">
      <div class="block">
        <div class="block"><div class="align-sub rounded-sm inline-block w-4 h-4  mr-4 bg-red" style="fill: ${t.color};background: ${t.color};"></div>
        <div class="${subtitle_class}">
          ${t.name}
        </div>
        <div class ="${title_class}"><b>
          ${shortNum(
        ~labelValue=t.sum->Belt.Int.toFloat,
        ~numberFormat=getDefaultNumberFormat(),
        (),
      )}
          ${overallText}
        </div>
      </div>`
  }
}

type highcharts
type highchartsSankey
@module("highcharts") external highchartsModule: highcharts = "default"
@module("highcharts/modules/sankey")
external highchartsSankey: highcharts => unit = "default"
let useInit = (data: array<(string, string, int, int, int)>, nodes) => {
  highchartsSankey(highchartsModule)
  let theme = ThemeProvider.useTheme()
  let options: Js.Json.t = {
    "title": {
      "text": "",
    },
    "series": [
      {
        "keys": ["from", "to", "weight", "total"],
        "data": data,
        "type": "sankey",
        "name": "",
        "nodes": nodes,
        "nodeWidth": 40,
        "minLinkWidth": 10,
        "dataLabels": {
          "align": "left",
          "allowOverlap": true,
          "color": theme === Dark ? "white" : "black",
          "style": {
            "color": theme === Dark ? "#354052" : "#f6f8f9",
            "fontFamily": "IBM Plex Sans",
            "fontStyle": "normal",
            "fontWeight": 600,
          },
        }->Identity.genericObjectOrRecordToJson,
        "connectEnds": false,
      }->Identity.genericObjectOrRecordToJson,
    ],
    "chart": {
      "height": 698,
      "backgroundColor": "transparent",
    },
    "credits": {
      "enabled": false,
    },
    "tooltip": {
      "shared": true,
      "useHTML": true,
      "headerFormat": `<table>`,
      "pointFormatter": tooltipFormatter()->Some,
      "nodeFormatter": nodeFormatter(~data)->Some,
      "valueDecimals": 2,
      "backgroundColor": theme === Dark ? "white" : "black",
    },
  }->Identity.genericObjectOrRecordToJson
  options
}

module SankeyReact = {
  @module("highcharts-react-official") @react.component
  external make: (~highcharts: highcharts, ~options: Js.Json.t=?) => React.element = "default"
}

module SankeyReactJsonOption = {
  @module("highcharts-react-official") @react.component
  external make: (~highcharts: highcharts, ~options: Js.Json.t=?) => React.element = "default"
}
