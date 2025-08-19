open LineGraphTypes

// colors
let darkGray = "#525866"
let lightGray = "#999999"
let gridLineColor = "#e6e6e6"
let fontFamily = "InterDisplay"

let valueFormatter = (
  @this
  this => {
    `<div style="display: flex; align-items: center;">
        <div style="width: 13px; height: 13px; background-color:${this.color}; border-radius:3px;"></div>
        <div style="margin-left: 5px;">${this.name}</div>
    </div>`
  }
)->asLegendsFormatter

let lineGraphYAxisFormatter = (
  ~statType: LogicUtilsTypes.valueType,
  ~currency="",
  ~suffix="",
  ~scaleFactor=1.0,
) => {
  (
    @this
    (this: yAxisFormatter) => {
      let value = this.value->Int.toFloat /. scaleFactor
      let formattedValue = LogicUtils.valueFormatter(value, statType, ~currency, ~suffix)
      formattedValue
    }
  )->asTooltipPointFormatter
}

let getLineGraphOptions = (lineGraphOptions: lineGraphPayload) => {
  let {
    chartHeight,
    chartLeftSpacing,
    categories,
    data,
    title,
    tooltipFormatter,
    yAxisMaxValue,
    yAxisMinValue,
    yAxisFormatter,
    legend,
  } = lineGraphOptions

  let legendFormatter = switch lineGraphOptions.legendFormatter {
  | Some(legendFormatter) => legendFormatter
  | None => valueFormatter
  }

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
        fontSize: "12px", // Set the font size
      },
    },
    gridLineWidth: 1,
    gridLineColor,
    gridLineDashStyle: "Dash",
    labels: {
      formatter: yAxisFormatter,
      align: "center",
      style: {
        color: lightGray,
        fontFamily, // Set the desired font family
      },
      x: 5,
    },
  }

  {
    chart: {
      \"type": "line",
      height: switch chartHeight {
      | Custom(chartHeight) => chartHeight
      | DefaultHeight => 400
      },
      spacingLeft: switch chartLeftSpacing {
      | Custom(chartLeftSpacing) => chartLeftSpacing
      | DefaultLeftSpacing => 20
      },
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
      enabled: true,
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
      switch (yAxisMaxValue, yAxisMinValue) {
      | (Some(maxVal), Some(minVal)) => {
          ...yAxis,
          max: Some(maxVal),
          min: Some(minVal),
        }
      | (Some(maxVal), None) => {
          ...yAxis,
          max: Some(maxVal),
        }
      | (None, Some(minVal)) => {
          ...yAxis,
          min: Some(minVal),
        }
      | (None, None) => yAxis
      }
    },
    legend: {
      ...legend,
      useHTML: true,
      symbolPadding: 0,
      symbolWidth: 0,
      labelFormatter: legendFormatter,
      itemStyle: {
        fontFamily,
        fontSize: "12px",
        color: darkGray,
        fontWeight: "400",
      },
    },
    plotOptions: {
      line: {
        marker: {
          enabled: false,
        },
      },
      series: {
        states: {
          inactive: {
            enabled: false,
            opacity: 0.2,
          },
        },
      },
    },
    series: data,
    credits: {
      enabled: false,
    },
  }
}
