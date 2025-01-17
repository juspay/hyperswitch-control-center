// constants
let fontFamily = "Arial, sans-serif"
let darkGray = "#666666"
let gridLineColor = "#e6e6e6"

external barGraphOptionsToJson: BarGraphTypes.barGraphOptions => JSON.t = "%identity"

open BarGraphTypes
let getBarGraphOptions = (barGraphOptions: barGraphPayload) => {
  let {categories, data, title, tooltipFormatter} = barGraphOptions

  let style = {
    fontFamily,
    fontSize: "12px",
    color: darkGray,
  }

  {
    chart: {
      \"type": "bar",
      spacingLeft: 20,
      spacingRight: 20,
    },
    title: {
      text: "",
    },
    xAxis: {
      categories,
      labels: {
        align: "center",
        style,
      },
      tickWidth: 1,
      tickmarkPlacement: "on",
      endOnTick: false,
      startOnTick: false,
      gridLineWidth: 1,
      gridLineDashStyle: "Dash",
      gridLineColor,
      min: 0,
    },
    yAxis: {
      title,
      labels: {
        align: "center",
        style,
      },
      gridLineWidth: 1,
      gridLineDashStyle: "Solid",
      gridLineColor,
      tickInterval: 25,
      min: 0,
      max: 100,
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
    plotOptions: {
      bar: {
        marker: {
          enabled: false,
        },
        pointPadding: 0.2,
      },
    },
    series: data,
    credits: {
      enabled: false,
    },
  }
}
