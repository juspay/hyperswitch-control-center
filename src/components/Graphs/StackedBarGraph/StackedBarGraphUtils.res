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
      y: 20,
      floating: true,
      symbolHeight: 10,
      symbolWidth: 10,
      symbolRadius: 2,
      reversed: true,
      itemDistance: labelItemDistance,
      labelFormatter,
      width: 700,
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

let stackedBarGraphLabelFormatter = (~statType: LogicUtilsTypes.valueType) => {
  open LogicUtils

  (
    @this
    (this: labelFormatter) => {
      let name = this.name
      let yData = this.yData->getValueFromArray(0, 0)
      let formatDollarAmount = amount => {
        let rec addCommas = str => {
          let len = Js.String.length(str)
          if len <= 3 {
            str
          } else {
            let prefix = Js.String.slice(~from=0, ~to_=len - 3, str)
            let suffix = Js.String.slice(~from=len - 3, ~to_=len, str)
            addCommas(prefix) ++ "," ++ suffix
          }
        }

        let strAmount = amount->Int.toString
        "$ " ++ addCommas(strAmount)
      }
      let valueDisplay = switch statType {
      | No_Type => yData->Int.toString
      | Amount => formatDollarAmount(yData)
      | _ => yData->Int.toString
      }

      let title = `<div style="color: #525866; font-weight: 500;">${name}<span style="color: #99A0AE"> | ${valueDisplay}</span></div>`
      title
    }
  )->asLabelFormatter
}
