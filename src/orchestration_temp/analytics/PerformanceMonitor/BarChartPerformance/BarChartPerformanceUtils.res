open PerformanceMonitorTypes
let getBarOption = data =>
  {
    "chart": {
      "type": `column`,
      "style": {
        "fontFamily": "InterDisplay",
      },
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
  | "failure" => "#DA6C68"
  | "charged" => "#7AAF73"
  | "authentication_pending" => "#E3945C"
  | "authentication_failed" => "#E18494"
  | "pending" => "#B6A1D2"
  | "payment_method_awaited" => "#80A3F8"
  | "authorized" => "#5398A7"
  | _ => "#79B8F3"
  }
}

let getStackedBarData = (~args) => {
  let {array, config} = args
  let {groupByKeys} = config
  let grouped = PerformanceUtils.getGroupByDataForStatusAndPaymentCount(array, groupByKeys)
  let keys = grouped->Dict.keysToArray
  let finalResult = Dict.make()
  let categories = []
  let _ = keys->Array.forEach(v => {
    let dict = grouped->Dict.get(v)->Option.getOr(Dict.make())
    let plotChartBy = switch config.plotChartBy {
    | Some(val) => val->Array.map(item => (item: status :> string))
    | None => dict->Dict.keysToArray
    }
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

  let updatedCategories = switch config.yLabels {
  | Some(labels) => labels
  | None => categories
  }

  {
    categories: updatedCategories,
    series,
  }
}
