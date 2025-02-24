// constants
let fontFamily = "Arial, sans-serif"
let darkGray = "#666666"
let gridLineColor = "#e6e6e6"
open ColumnGraphTypes
let getColumnGraphOptions = (barGraphOptions: columnGraphPayload) => {
  let {data, title, tooltipFormatter} = barGraphOptions

  {
    chart: {
      \"type": "column",
      height: 270,
    },
    title,
    xAxis: {
      \"type": "category",
    },
    yAxis: {
      title: {
        text: "",
      },
    },
    tooltip: {
      style: {
        padding: "0px",
        fontFamily,
        fontSize: "14px",
      },
      shape: "square",
      shadow: false,
      backgroundColor: "transparent",
      borderColor: "transparent",
      borderWidth: 0.0,
      formatter: tooltipFormatter,
      useHTML: true,
      shared: true,
    },
    legend: {
      enabled: false,
    },
    plotOptions: {
      series: {
        borderWidth: 0,
        borderRadius: 10,
        stacking: "normal",
      },
    },
    series: data,
    credits: {
      enabled: false,
    },
  }
}
