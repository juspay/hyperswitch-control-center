open LogicUtils
open PerformanceMonitorTypes

let getDontchartOptions = (config: chartConfig, series) => {
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
    "series": [
      {
        "name": "failure",
        "colorByPoint": true,
        "innerSize": "75%",
        "data": series,
      },
    ],
  }->Identity.genericTypeToJson
}

let getPieCharData = (~array: array<JSON.t>, ~config: chartDataConfig) => {
  let {groupByKeys} = config
  let grouped = PerformanceUtils.getGroupByDataForStatusAndPaymentCount(array, groupByKeys)
  let keys = grouped->Dict.keysToArray
  let series = keys->Array.map(val => {
    let dict = grouped->Dict.get(val)->Option.getOr(Dict.make())
    {
      "name": val,
      "y": dict->getInt("failure", 0),
    }
  })
  series
}
