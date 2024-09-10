let options = {
  "chart": {
    "type": "line",
    "spacingLeft": 20,
    "spacingRight": 20,
  },
  "title": {
    "text": "",
  },
  "xAxis": {
    "categories": [
      "01 Aug",
      "02 Aug",
      "03 Aug",
      "04 Aug",
      "05 Aug",
      "06 Aug",
      "07 Aug",
      "08 Aug",
      "09 Aug",
      "10 Aug",
      "11 Aug",
    ],
    "crosshair": true,
    "lineWidth": 1,
    "tickWidth": 1,
    "labels": {
      "align": "center",
      "style": {
        "color": "#666",
      },
      "y": 35,
    },
    "gridLineWidth": 1,
    "gridLineColor": "#e6e6e6",
    "tickmarkPlacement": "on",
    "endOnTick": false,
    "startOnTick": false,
  },
  "yAxis": {
    "title": {
      "text": "USD",
    },
    "gridLineWidth": 1,
    "gridLineColor": "#e6e6e6",
    "gridLineDashStyle": "Dash",
    "min": 0,
  },
  "plotOptions": {
    "line": {
      "marker": {
        "enabled": false,
      },
    },
  },
  "series": [
    {
      "showInLegend": false,
      "name": "Series 1",
      "data": [3000, 5000, 7000, 5360, 4500, 6800, 5400, 3000, 0, 0],
      "color": "#2f7ed8",
    },
    {
      "showInLegend": false,
      "name": "Series 2",
      "data": [3200, 4800, 6800, 5100, 4300, 6500, 5200, 2800, 0, 0],
      "color": "#8bbc21",
    },
  ],
  "credits": {
    "enabled": false,
  },
}->Identity.genericObjectOrRecordToJson
