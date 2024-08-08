open PerformanceMonitorTypes

let getGaugeData = (~array: array<JSON.t>, ~config: chartDataConfig) => {
  let key = switch config.name {
  | Some(val) => (val: metrics :> string)
  | _ => ""
  }
  let value = switch array->Array.get(0) {
  | Some(val) => {
      let rate =
        val
        ->JSON.Decode.object
        ->Option.getOr(Dict.make())
        ->Dict.get(key)
        ->Option.getOr(0.0->JSON.Encode.float)
        ->JSON.Decode.float
        ->Option.getOr(0.0)
        ->Float.toFixedWithPrecision(~digits=3)
        ->Float.fromString
        ->Option.getOr(0.0)

      rate
    }
  | None => 0.0
  }

  {
    value: value,
  }
}

let gaugeOption = (config: chartConfig, data: gaugeChartData) =>
  {
    "chart": {
      "type": "gauge",
      "plotBackgroundColor": null,
      "plotBackgroundImage": null,
      "plotBorderWidth": 0,
      "plotShadow": false,
      "height": "80%",
    },
    "pane": {
      "startAngle": -90,
      "endAngle": 89.9,
      "background": null,
      "center": ["50%", "75%"],
      "size": "110%",
    },
    "yAxis": {
      "min": 0,
      "max": 100,
      "tickPixelInterval": 72,
      "tickPosition": "inside",
      "tickColor": "#FFFFFF",
      "tickLength": 20,
      "tickWidth": 2,
      "minorTickInterval": null,
      "labels": {
        "distance": 20,
        "style": {
          "fontSize": "14px",
        },
      },
      "lineWidth": 0,
      "plotBands": [
        {
          "from": 0,
          "to": 60,
          "color": "#DF5353", // red
          "thickness": 20,
          "borderRadius": "50%",
        },
        {
          "from": 60,
          "to": 80,
          "color": "#DDDF0D", // yellow
          "thickness": 20,
          "borderRadius": "50%",
        },
        {
          "from": 80,
          "to": 100,
          "color": "#55BF3B", // green
          "thickness": 20,
          "borderRadius": "50%",
        },
      ],
    },
    "title": {
      "text": config.title.text,
    },
    "series": [
      {
        "name": "Success Rate",
        "data": [data.value],
        "tooltip": {
          "valueSuffix": "%",
        },
        "dial": {
          "radius": "80%",
          "backgroundColor": "gray",
          "baseWidth": 12,
          "baseLength": "0%",
          "rearLength": "0%",
        },
        "pivot": {
          "backgroundColor": "gray",
          "radius": 6,
        },
        "dataLabels": {
          "format": `{y} %`,
          "borderWidth": 0,
          "style": {
            "fontSize": "18px",
          },
        },
      },
    ],
  }->Identity.genericObjectOrRecordToJson
