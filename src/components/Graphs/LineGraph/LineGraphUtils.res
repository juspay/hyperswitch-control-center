open LineGraphTypes

// colors
let darkGray = "#666666"
let lightGray = "#999999"
let gridLineColor = "#e6e6e6"
let fontFamily = "Arial, sans-serif"

let valueFormatter = (
  @this
  this => {
    `<div style="display: flex; align-items: center;">
        <div style="width: 13px; height: 13px; background-color:${this.color}; border-radius:3px;"></div>
        <div style="margin-left: 5px;">${this.name}</div>
    </div>`
  }
)->asLegendsFormatter

let getLineGraphOptions = (lineGraphOptions: lineGraphPayload) => {
  let {categories, data, title, tooltipFormatter, yAxisMaxValue} = lineGraphOptions

  let stepInterval = Js.Math.max_int(
    Js.Math.ceil_int(categories->Array.length->Int.toFloat /. 10.0),
    1,
  )

  let yAxis: LineGraphTypes.yAxis = {
    title: {
      ...title,
      style: {
        color: darkGray,
        fontFamily, // Set the desired font family
      },
    },
    gridLineWidth: 1,
    gridLineColor,
    gridLineDashStyle: "Dash",
    labels: {
      align: "center",
      style: {
        color: lightGray,
        fontFamily, // Set the desired font family
      },
      x: 5,
    },
    min: 0,
  }

  {
    chart: {
      \"type": "line",
      spacingLeft: 20,
      spacingRight: 20,
      style: {
        color: darkGray,
        fontFamily,
      },
    },
    title,
    xAxis: {
      categories,
      crosshair: true,
      lineWidth: 1,
      tickWidth: 1,
      labels: {
        align: "center",
        style: {
          color: lightGray,
          fontFamily, // Set the desired font family
        },
        y: 35,
      },
      tickInterval: stepInterval,
      gridLineWidth: 1,
      gridLineColor,
      tickmarkPlacement: "on",
      endOnTick: false,
      startOnTick: false,
    },
    tooltip: {
      style: {
        padding: "0px",
        fontFamily, // Set the desired font family
        fontSize: "14px", // Optional: Set the font size
      },
      shape: "square",
      shadow: false,
      backgroundColor: "transparent",
      borderColor: "transparent",
      borderWidth: 0.0,
      formatter: tooltipFormatter,
      useHTML: true,
      shared: true, // Allows multiple series' data to be shown in a single tooltip
    },
    yAxis: {
      switch yAxisMaxValue {
      | Some(val) => {
          ...yAxis,
          max: val->Some,
        }
      | _ => yAxis
      }
    },
    legend: {
      useHTML: true,
      labelFormatter: valueFormatter,
      symbolPadding: 0,
      symbolWidth: 0,
      itemStyle: {
        fontFamily,
        fontSize: "12px",
        color: darkGray,
      },
      align: "right",
      verticalAlign: "top",
      x: 0,
      y: 0,
    },
    plotOptions: {
      line: {
        marker: {
          enabled: false,
        },
      },
    },
    series: data,
    credits: {
      enabled: false,
    },
  }
}
