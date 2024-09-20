open LineGraphTypes
let tooltipFormatter = (
  @this
  (this: pointFormatter) => {
    `
    <div style="border-radius: 12px;" >
    here
    </div>
    `
  }
)->asTooltipPointFormatter

let getLineGraphOptions = (lineGraphOptions: lineGraphPayload) => {
  let {categories, data, title} = lineGraphOptions
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
      gridLineWidth: 1,
      gridLineColor: "#e6e6e6",
      tickmarkPlacement: "on",
      endOnTick: false,
      startOnTick: false,
    },
    tooltip: {
      style: {
        fontFamily: "Arial, sans-serif", // Set the desired font family
        fontSize: "14px", // Optional: Set the font size
      },
      shape: "square",
      backgroundColor: "#FFFFFF",
      borderColor: "#E5E5E5",
      useHTML: true,
      formatter: tooltipFormatter,
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
