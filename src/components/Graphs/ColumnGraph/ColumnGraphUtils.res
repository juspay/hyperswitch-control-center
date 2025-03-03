// constants
let fontFamily = "Arial, sans-serif"
let darkGray = "#525866"

open ColumnGraphTypes
let getColumnGraphOptions = (barGraphOptions: columnGraphPayload) => {
  let {data, title, tooltipFormatter, yAxisFormatter} = barGraphOptions

  let style = {
    fontFamily,
    fontSize: "12px",
    color: darkGray,
    fill: darkGray,
  }

  {
    chart: {
      \"type": "column",
      spacingLeft: 0,
      spacingRight: 0,
      height: 270,
      style,
    },
    title,
    xAxis: {
      \"type": "category",
    },
    yAxis: {
      labels: {
        formatter: yAxisFormatter,
      },
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
        borderRadius: 5,
        stacking: "normal",
        pointWidth: 30,
      },
    },
    series: data,
    credits: {
      enabled: false,
    },
  }
}

let columnGraphTooltipFormatter = (~title, ~metricType: LogicUtilsTypes.valueType) => {
  open LogicUtils

  (
    @this
    (this: pointFormatter) => {
      let title = `<div style="font-size: 16px; font-weight: bold;">${title}</div>`

      let defaultValue = {color: "", x: "", y: 0.0, point: {index: 0}, key: ""}
      let primartPoint = this.points->getValueFromArray(0, defaultValue)

      let getRowsHtml = (~iconColor, ~date, ~value, ~comparisionComponent="") => {
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

          let strAmount = amount->Float.toString
          "$ " ++ addCommas(strAmount)
        }
        let displayValue = switch metricType {
        | No_Type => value->Float.toString
        | Amount => value->formatDollarAmount
        | _ => value->Float.toString
        }
        `<div style="display: flex; align-items: center;">
            <div style="width: 10px; height: 10px; background-color:${iconColor}; border-radius:3px;"></div>
            <div style="margin-left: 8px;">${date}${comparisionComponent}</div>
            <div style="flex: 1; text-align: right; font-weight: bold;margin-left: 25px;">${displayValue}</div>
        </div>`
      }

      let tableItems =
        [
          getRowsHtml(~iconColor=primartPoint.color, ~date=primartPoint.key, ~value=primartPoint.y),
        ]->Array.joinWith("")

      let content = `
          <div style=" 
          padding:5px 12px;
          display:flex;
          flex-direction:column;
          justify-content: space-between;
          gap: 7px;">
              ${title}
              <div style="
                margin-top: 5px;
                display:flex;
                flex-direction:column;
                gap: 7px;">
                ${tableItems}
              </div>
        </div>`

      `<div style="
    padding: 10px;
    width:fit-content;
    border-radius: 7px;
    background-color:#FFFFFF;
    padding:10px;
    box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);
    border: 1px solid #E5E5E5;
    position:relative;">
        ${content}
    </div>`
    }
  )->asTooltipPointFormatter
}

let columnGraphYAxisFormatter = (~statType: LogicUtilsTypes.valueType) => {
  (
    @this
    (this: yAxisFormatter) => {
      let value = this.value
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
      | No_Type => value->Int.toString
      | Amount => value->formatDollarAmount
      | _ => value->Int.toString
      }

      valueDisplay
    }
  )->asTooltipPointFormatter
}
