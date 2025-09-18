open LogicUtils
open PerformanceMonitorTypes

let getPieChartOptions = series => {
  {
    "chart": {
      "type": "pie",
      "style": {
        "fontFamily": "InterDisplay",
      },
    },
    "tooltip": {
      "valueSuffix": ``,
    },
    "subtitle": {
      "text": "",
    },
    "title": {
      "text": "",
    },
    "colors": [
      "#80A3F8",
      "#7AAF73",
      "#DA6C68",
      "#5398A7",
      "#E18494",
      "#79B8F3",
      "#B6A1D2",
      "#E3945C",
      "#FFAB99",
      "#679FDF",
    ],
    "plotOptions": {
      "pie": {
        "center": ["50%", "50%"],
        "allowPointSelect": true,
        "cursor": `pointer`,
        "dataLabels": {
          "enabled": true,
          "distance": -15, // Set distance for the label inside the slice
          "format": `{point.percentage:.0f}%`,
        },
        "showInLegend": true,
      },
    },
    "legend": {
      "align": "right", // Align the legend to the right
      "verticalAlign": "middle", // Vertically center the legend
      "layout": "vertical", // Use a vertical layout for legend items
      "width": "35%",
      "enabled": true,
      "itemStyle": LineChartUtils.legendItemStyle("12px"),
      "itemHiddenStyle": {
        "color": "rgba(53, 64, 82, 0.2)",
        "cursor": "pointer",
        "fontWeight": "500",
        "fontStyle": "normal",
      },
      "itemHoverStyle": LineChartUtils.legendItemStyle("12px"),
      "symbolRadius": 4,
      "symbolPaddingTop": 5,
      "itemMarginBottom": 10,
    },
    "credits": {
      "enabled": false, // Disable the Highcharts credits
    },
    "series": [
      {
        "name": "Total",
        "colorByPoint": true,
        "innerSize": "60%",
        "data": series,
      },
    ],
  }->Identity.genericTypeToJson
}

let getDonutCharData = (~args) => {
  let {array, config} = args
  let {groupByKeys} = config
  let grouped = PerformanceUtils.getGroupByDataForStatusAndPaymentCount(array, groupByKeys)
  let keys = grouped->Dict.keysToArray
  let series: array<donutPieSeriesRecord> = keys->Array.map(val => {
    let dict = grouped->Dict.get(val)->Option.getOr(Dict.make())
    {
      name: val,
      y: dict->getInt("failure", 0),
    }
  })
  series
}
