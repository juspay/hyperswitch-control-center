external objToJson: {..} => Js.Json.t = "%identity"

type highcharts

@module("highcharts") external highchartsModule: highcharts = "default"

@react.component
let make = (~data, ~height=500, ~width=2600, ~axisVisible=false, ~lineChartOptions=?) => {
  let defaultOptions = switch lineChartOptions {
  | Some(val) => val
  | _ =>
    {
      "chart": {
        "margin": [2, 0, 2, 0],
        "borderWidth": 0,
        "type": "line",
        "width": width,
        "height": height,
        "style": {
          "overflow": "visible",
        },
        "backgroundColor": Js.Json.null,
        "skipClone": false,
      },
      "title": {
        "text": "",
      },
      "credits": {
        "enabled": false,
      },
      "xAxis": {
        "labels": {
          "enabled": false,
        },
        "visible": false,
        "title": {
          "text": "",
        },
        "startOnTick": false,
        "endOnTick": false,
        "tickPositions": [0],
      },
      "yAxis": {
        "labels": {
          "enabled": false,
        },
        "title": {
          "text": "",
        },
        "startOnTick": false,
        "endOnTick": false,
        "tickPositions": [],
      },
      "legend": {
        "enabled": false,
      },
      "plotOptions": {
        "series": {
          "zones": [
            {
              "value": 0,
              "color": "#FF0000",
            },
          ],
          "lineColor": "#00FF00",
          "animation": true,
          "lineWidth": 2,
          "shadow": false,
          "states": {
            "hover": {
              "lineWidth": 3,
            },
          },
          "marker": {
            "radius": 1,
            "states": {
              "hover": {
                "radius": 2,
              },
            },
          },
        },
        "column": {
          "negativeColor": "red",
          "borderColor": "silver",
        },
      },
      "series": [
        {
          "data": data,
          "pointStart": 0,
          "color": Some("#006ae5"),
          "fillColor": {
            "linearGradient": (0, 0, 1, 1),
          },
        },
      ],
      "tooltip": {
        "headerFormat": ``,
        "pointFormat": `<b> Iteration Count {point.x} : Diff {point.y}% </b>`,
        "hideDelay": 0,
        "outside": true,
        "shared": true,
      },
    }->objToJson
  }
  <Highcharts.Chart highcharts={Highcharts.highchartsModule} options=defaultOptions />
}
