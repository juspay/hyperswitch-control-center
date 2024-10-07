open LineGraphTypes

let getLineGraphOptions = (lineGraphOptions: lineGraphPayload) => {
  let {categories, data, title, tooltipFormatter} = lineGraphOptions

  let stepInterval = Js.Math.max_int(
    Js.Math.ceil_int(categories->Array.length->Int.toFloat /. 20.0),
    1,
  )

  {
    chart: {
      \"type": "line",
      spacingLeft: 20,
      spacingRight: 20,
    },
    title: {
      text: "",
    },
    xAxis: {
      categories,
      crosshair: true,
      lineWidth: 1,
      tickWidth: 1,
      labels: {
        align: "center",
        style: {
          color: "#666",
        },
        y: 35,
      },
      tickInterval: stepInterval,
      gridLineWidth: 1,
      gridLineColor: "#e6e6e6",
      tickmarkPlacement: "on",
      endOnTick: false,
      startOnTick: false,
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
    yAxis: {
      title,
      gridLineWidth: 1,
      gridLineColor: "#e6e6e6",
      gridLineDashStyle: "Dash",
      min: 0,
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
