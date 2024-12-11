open BarGraphTypes
let getBarGraphOptions = (barGraphOptions: barGraphPayload) => {
  let {categories, data, title, tooltipFormatter} = barGraphOptions
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
        style: {
          fontFamily: "Arial, sans-serif",
          fontSize: "12px",
          color: "#666666",
        },
      },
      tickWidth: 1,
      tickmarkPlacement: "on",
      endOnTick: false,
      startOnTick: false,
      gridLineWidth: 1,
      gridLineDashStyle: "Dash",
      gridLineColor: "#e6e6e6",
      min: 0,
    },
    yAxis: {
      title,
      labels: {
        align: "center",
        style: {
          fontFamily: "Arial, sans-serif",
          fontSize: "12px",
          color: "#666666",
        },
      },
      gridLineWidth: 1,
      gridLineDashStyle: "Solid",
      gridLineColor: "#e6e6e6",
      tickInterval: 25,
      min: 0,
      max: 100,
    },
    tooltip: {
      style: {
        padding: "0px",
        fontFamily: "Arial, sans-serif", // Set the desired font family
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
