let fontFamily = "InterDisplay, sans-serif"
let darkGray = "#525866"

open StackedBarGraphTypes
let getStackedBarGraphOptions = (
  stackedBarGraphOptions: stackedBarGraphPayload,
  ~yMax,
  ~labelItemDistance,
) => {
  let {categories, data, labelFormatter} = stackedBarGraphOptions

  let style = {
    fontFamily,
    fontSize: "12px",
    color: darkGray,
    fill: darkGray,
  }

  {
    chart: {
      \"type": "bar",
      height: 80,
      spacingRight: 0,
      spacingLeft: 0,
      spacingTop: 0,
      style,
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
        text: "",
      },
      stackLabels: {
        enabled: true,
      },
      visible: false,
      max: yMax,
    },
    legend: {
      align: "left",
      x: 0,
      verticalAlign: "bottom",
      y: 10,
      floating: false,
      symbolHeight: 10,
      symbolWidth: 10,
      symbolRadius: 2,
      reversed: true,
      itemDistance: labelItemDistance,
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
        borderWidth: 3,
        pointWidth: 30,
        borderRadius: 5,
      },
    },
    series: data,
    credits: {
      enabled: false,
    },
  }
}

let stackedBarGraphLabelFormatter = (~statType: LogicUtilsTypes.valueType, ~currency="") => {
  open LogicUtils

  (
    @this
    (this: labelFormatter) => {
      let name = this.name
      let yData = this.yData->getValueFromArray(0, 0)->Int.toFloat
      let formattedValue = LogicUtils.valueFormatter(yData, statType, ~currency)

      let title = `<div style="color: #525866; font-weight: 500;">${name}<span style="color: #99A0AE"> | ${formattedValue}</span></div>`
      title
    }
  )->asLabelFormatter
}
