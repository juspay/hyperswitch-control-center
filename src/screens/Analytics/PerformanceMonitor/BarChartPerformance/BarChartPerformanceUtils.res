open PerformanceMonitorTypes
let getBarOption = data =>
  {
    "chart": {
      "type": `column`,
    },
    "xAxis": {
      "categories": data.categories,
      "title": {
        "text": "",
      },
    },
    "title": {
      "text": "",
    },
    "yAxis": {
      "min": 0,
      "stackLabels": {
        "enabled": true,
      },
      "title": {
        "text": "",
      },
    },
    "legend": {
      "align": "right", // Align the legend to the right
      "verticalAlign": "middle", // Vertically center the legend
      "layout": "vertical", // Use a vertical layout for legend items
      "width": "20%",
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
    "tooltip": {
      "headerFormat": "<b>{point.x}</b><br/>",
      "pointFormat": "{series.name}: {point.y}<br/>Total: {point.stackTotal}",
    },
    "plotOptions": {
      "column": {
        "stacking": "normal",
        "borderRadius": 3,
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

let getBarchartColor = name => {
  switch name {
  | "failure" => "#f44708"
  | "charged" => "#38b000"
  | "authentication_pending" => "#80E1D9"
  | "authentication_failed" => "#F8BC3B"
  | "pending" => "#B2596E"
  | "payment_method_awaited" => "#72BEF4"
  | "authorized" => "#FFB27A"
  | _ => "#0D7EA0"
  }
}

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
        color: val->getBarchartColor,
      }
    })

  {
    categories,
    series,
  }
}
