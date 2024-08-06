open LogicUtils
open PerformanceMonitorTypes

let getStackedBarData = (~array: array<JSON.t>, ~key: string, ~chatSeries: array<string>) => {
  let grouped = PerformanceUtils.getGroupedData(array, key, chatSeries)
  let keys = grouped->Dict.keysToArray
  let finalResult = Dict.make()
  let categories = []
  let _ = keys->Array.forEach(v => {
    let dict = grouped->Dict.get(v)->Option.getOr(Dict.make())
    let _ =
      dict
      ->Dict.keysToArray
      ->Array.forEach(ele => {
        switch dict->Dict.get(ele) {
        | None => {
            let val = dict->getInt(ele, 0)
            let _ = finalResult->Dict.set(ele, [val])
          }
        | Some(_) => {
            let val = dict->getInt(ele, 0)
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
      "align": "right",
      "x": 10,
      "verticalAlign": "top",
      "y": 10,
      "floating": true,
      "backgroundColor": "white",
      "borderColor": "#CCC",
      "borderWidth": 1,
      "shadow": false,
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
    "series": data.series,
  }->Identity.genericObjectOrRecordToJson
