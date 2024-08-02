let barOption = (categories, series) =>
  {
    "chart": {
      "type": `column`,
    },
    "colors": ["#c74050", "#619f5b"],
    "title": {
      "text": `Major trophies for some English teams`,
      "align": "left",
    },
    "xAxis": {
      "categories": categories,
    },
    "yAxis": {
      "min": 0,
      "title": {
        "text": "Count trophies",
      },
      "stackLabels": {
        "enabled": true,
      },
    },
    "legend": {
      "align": "left",
      "x": 70,
      "verticalAlign": "top",
      "y": 70,
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
    "series": series,
  }->Identity.genericObjectOrRecordToJson

open PerformanceMonitorTypes
open LogicUtils

let getDimensionNameFromString = dimension => {
  switch dimension {
  | "connector" => #connector
  | "payment_method" => #payment_method
  | "payment_method_type" => #payment_method_type
  | "status" => #status
  | _ => #no_value
  }
}
let dimensionMapper = dict => {
  dimension: dict->getString("dimension", "")->getDimensionNameFromString,
  values: dict->getStrArray("values"),
}
let dimensionObjMapper = (dimensions: array<JSON.t>) => {
  dimensions->JSON.Encode.array->getArrayDataFromJson(dimensionMapper)
}

let defaultDimesions = {
  dimension: #no_value,
  values: [],
}

let getPerformanceMonitorBody = (performanceType: performance, dimensions: dimensions) => {
  switch performanceType {
  | #ConnectorPerformance => PerformanceUtils.connectorPerformanceBody("", "", dimensions)
  | _ => JSON.Encode.null
  }
}
