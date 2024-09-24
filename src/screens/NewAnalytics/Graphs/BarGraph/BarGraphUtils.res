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
      labels: {
        align: "center",
        style: {
          color: "#999",
        },
      },
      tickWidth: 1,
      tickmarkPlacement: "on",
      endOnTick: false,
      startOnTick: false,
      gridLineDashStyle: "Dash",
      gridLineWidth: 1,
      gridLineColor: "#e6e6e6",
      min: 0,
    },
    yAxis: {
      title,
      gridLineWidth: 1,
      gridLineColor: "#e6e6e6",
      gridLineDashStyle: "Solid",
      tickInterval: 25,
      min: 0,
      max: 100,
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
