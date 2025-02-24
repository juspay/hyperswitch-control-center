let fontFamily = "InterDisplay, sans-serif"
let darkGray = "#666666"
let gridLineColor = "#e6e6e6"

open StackedBarGraphTypes
let getStackedBarGraphOptions = (stackedBarGraphOptions: stackedBarGraphPayload) => {
  let {categories, data, labelFormatter} = stackedBarGraphOptions

  {
    chart: {
      \"type": "bar",
      height: 100,
    },
    title: {
      text: "",
      visible: false,
    },
    xAxis: {
      categories,
      visible: false,
    },
    yAxis: {
      title: {
        text: "Count trophies",
      },
      stackLabels: {
        enabled: true,
      },
      visible: false,
    },
    legend: {
      align: "middle",
      x: 0,
      verticalAlign: "bottom",
      y: 20,
      floating: true,
      symbolHeight: 10,
      symbolWidth: 10,
      symbolRadius: 2,
      reversed: true,
      itemDistance: 20,
      labelFormatter,
    },
    tooltip: {
      enabled: false,
    },
    plotOptions: {
      bar: {
        stacking: "normal",
        dataLabels: {
          enabled: false,
        },
        borderWidth: 5,
        pointWidth: 40,
        borderRadius: 10,
      },
    },
    series: data,
    credits: {
      enabled: false,
    },
  }
}

let stackedBarGraphLabelFormatter = () => {
  open LogicUtils

  (
    @this
    (this: labelFormatter) => {
      let name = this.name
      let yData = this.yData->getValueFromArray(0, 0)
      let title = `<div style="font-size: 10px; font-weight: bold;">${name} | ${yData->Int.toString}</div>`
      title
    }
  )->asLabelFormatter
}
