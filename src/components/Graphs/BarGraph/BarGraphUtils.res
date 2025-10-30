// constants
let fontFamily = "Arial, sans-serif"
let darkGray = "#666666"
let gridLineColor = "#e6e6e6"
open BarGraphTypes
let getBarGraphOptions = (
  barGraphOptions: barGraphPayload,
  ~yMax=100,
  ~pointWidth=20,
  ~borderRadius=0,
  ~borderWidth=1.0,
  ~gridLineWidthXAxis=1,
  ~gridLineWidthYAxis=1,
  ~tickInterval=25.0,
  ~tickWidth=1,
  ~height: option<float>=None,
  ~xAxisLineWidth: option<int>=None,
  ~yAxisLineWidth: option<int>=None,
  ~yAxisLabelFormatter=None,
) => {
  let {categories, data, title, tooltipFormatter} = barGraphOptions

  let style = {
    fontFamily,
    fontSize: "12px",
    color: darkGray,
  }

  let chartConfigBase = {
    \"type": "bar",
    spacingLeft: 20,
    spacingRight: 20,
  }

  let chartConfig = switch height {
  | Some(heightValue) => {...chartConfigBase, height: heightValue}
  | None => chartConfigBase
  }

  let xAxisLabelBaseConfig = {
    align: "center",
    style,
  }

  let yAxisLabelBaseConfig = {
    align: "center",
    style,
  }

  let yAxisLabel = switch yAxisLabelFormatter {
  | Some(formatter) => {...yAxisLabelBaseConfig, formatter}
  | None => yAxisLabelBaseConfig
  }

  let xAxisBaseConfig = {
    categories,
    labels: xAxisLabelBaseConfig,
    tickWidth,
    tickmarkPlacement: "on",
    endOnTick: false,
    startOnTick: false,
    gridLineWidth: gridLineWidthXAxis,
    gridLineDashStyle: "Dash",
    gridLineColor,
    min: 0,
  }

  let xAxisConfig = switch xAxisLineWidth {
  | Some(lineWidth) => {...xAxisBaseConfig, lineWidth}
  | None => xAxisBaseConfig
  }

  let yAxisBaseConfig = {
    title,
    labels: yAxisLabel,
    gridLineWidth: gridLineWidthYAxis,
    gridLineDashStyle: "Solid",
    gridLineColor,
    tickInterval,
    min: 0,
    max: yMax,
  }

  let yAxisConfig = switch yAxisLineWidth {
  | Some(lineWidth) => {...yAxisBaseConfig, lineWidth}
  | None => yAxisBaseConfig
  }

  {
    chart: {
      chartConfig
    },
    title: {
      text: "",
    },
    xAxis: xAxisConfig,
    yAxis: yAxisConfig,
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
    plotOptions: {
      bar: {
        marker: {
          enabled: false,
        },
        pointPadding: 0.2,
        pointWidth,
        borderRadius,
        borderWidth,
      },
    },
    series: data,
    credits: {
      enabled: false,
    },
  }
}
