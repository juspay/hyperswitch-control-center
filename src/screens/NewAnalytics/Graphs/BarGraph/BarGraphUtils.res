open BarGraphTypes
let getBarGraphOptions = (barGraphOptions: barGraphPayload) => {
  let {categories, data, title} = barGraphOptions
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
      crosshair: true,
      barWidth: 1,
      labels: {
        align: "center",
        style: {
          color: "#999",
        },
      },
      gridLineDashStyle: "Dash",
    },
    yAxis: {
      title,
      gridLineWidth: 1,
      gridLineColor: "#e6e6e6",
      gridLineDashStyle: "Solid",
      tickmarkPlacement: "on",
      endOnTick: false,
      startOnTick: false,
      min: 0,
    },
    plotOptions: {
      bar: {
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
