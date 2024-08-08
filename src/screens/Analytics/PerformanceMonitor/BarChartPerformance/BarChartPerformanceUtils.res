open PerformanceMonitorTypes

let getStackedBarData = (~array: array<JSON.t>, ~config: chartDataConfig) => {
  let {groupByKeys} = config
  let grouped = PerformanceUtils.getGroupByDataForStatusAndPaymentCount(array, groupByKeys)
  let keys = grouped->Dict.keysToArray
  let finalResult = Dict.make()
  let categories = []
  let _ = keys->Array.forEach(v => {
    let dict = grouped->Dict.get(v)->Option.getOr(Dict.make())
    let plotChartBy = config.plotChartBy->Option.getOr(dict->Dict.keysToArray)
    let _ = plotChartBy->Array.forEach(ele => {
      switch dict->Dict.get(ele) {
      | None => {
          let val = 0
          let arr = finalResult->Dict.get(ele)->Option.getOr([])
          arr->Array.push(val)
          let _ = finalResult->Dict.set(ele, arr)
        }
      | Some(val) => {
          let val = val
          let arr = finalResult->Dict.get(ele)->Option.getOr([])
          arr->Array.push(val)
          let _ = finalResult->Dict.set(ele, arr)
        }
      }
    })
    categories->Array.push(v)
  })

  let series =
    finalResult
    ->Dict.keysToArray
    ->Array.map(val => {
      {
        name: val,
        data: finalResult->Dict.get(val)->Option.getOr([]),
      }
    })

  {
    categories,
    series,
  }
}

let barOption = (config: chartConfig, data: barChartData) =>
  {
    "chart": {
      "type": `column`,
    },
    "colors": config.colors,
    "title": {
      "text": config.title.text,
      "align": "left",
    },
    "xAxis": {
      "categories": data.categories,
      "title": {
        "text": config.xAxis.text,
      },
    },
    "yAxis": {
      "min": 0,
      "stackLabels": {
        "enabled": true,
      },
    },
    "legend": {
      "align": "right", // Align the legend to the right
      "verticalAlign": "top", // Vertically center the legend
      "layout": "vertical", // Use a vertical layout for legend items
      // "width": "35%",
      "y": 30,
    },
    "tooltip": {
      "headerFormat": "<b>{point.x}</b><br/>",
      "pointFormat": "{series.name}: {point.y}<br/>Total: {point.stackTotal}",
    },
    "plotOptions": {
      "column": {
        "stacking": "normal",
        "dataLabels": {
          "enabled": true,
        },
      },
    },
    "credits": {
      "enabled": false, // Disable the Highcharts credits
    },
    "series": data.series,
  }->Identity.genericObjectOrRecordToJson
