open LineGraphTypes
let getLineGraphOptions = (lineGraphOptions: lineGraphPayload) => {
  let {categories, data, title} = lineGraphOptions
  Js.log(categories)
  Js.log(data)
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
