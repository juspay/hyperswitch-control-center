open LogicUtils
open PerformanceMonitorTypes

let getPieChartOptions = (config: chartOption, data) => {
  {
    "chart": {
      "type": "pie",
    },
    "title": {
      "text": config.title.text,
    },
    "tooltip": {
      "valueSuffix": ``,
    },
    "subtitle": {
      "text": "",
    },
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
      // "y": 35,
    },
    "credits": {
      "enabled": false, // Disable the Highcharts credits
    },
    "series": [
      {
        "name": "Total",
        "colorByPoint": true,
        "innerSize": "75%",
        "data": data,
      },
    ],
  }->Identity.genericTypeToJson
}

let getDonutCharData = (~array: array<JSON.t>, ~config: chartDataConfig) => {
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
