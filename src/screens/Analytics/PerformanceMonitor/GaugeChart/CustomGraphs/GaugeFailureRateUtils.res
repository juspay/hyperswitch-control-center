open PerformanceMonitorTypes

let getFailureRateData = (~args) => {
  let count = args.optionalArgs->Option.getOr(0.0)
  let failureCount = GaugeChartPerformanceUtils.getGaugeData(~args).value

  let rate = failureCount /. count *. 100.0
  let value: PerformanceMonitorTypes.gaugeData = {value: rate}
  value
}
let falureGaugeOption = (data: gaugeData) =>
  {
    "chart": {
      "type": "gauge",
      "plotBackgroundColor": null,
      "plotBackgroundImage": null,
      "plotBorderWidth": 0,
      "plotShadow": false,
      "height": "75%",
      "style": {
        "fontFamily": "InterDisplay",
      },
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
          "to": 25,
          "color": "#7AAF73", // red
          "thickness": 20,
          "borderRadius": "50%",
        },
        {
          "from": 25,
          "to": 50,
          "color": "#E3945C", // yellow
          "thickness": 20,
          "borderRadius": "50%",
        },
        {
          "from": 50,
          "to": 100,
          "color": "#DA6C68", // green
          "thickness": 20,
          "borderRadius": "50%",
        },
      ],
    },
    "title": {
      "text": "",
    },
    "credits": {
      "enabled": false,
    },
    "series": [
      {
        "name": "",
        "data": [
          data.value
          ->Float.toFixedWithPrecision(~digits=2)
          ->Float.fromString
          ->Option.getOr(0.0),
        ],
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
