// constants
let fontFamily = "Arial, sans-serif"
let darkGray = "#666666"
let gridLineColor = "#e6e6e6"
open ColumnGraphTypes
let getColumnGraphOptions = (barGraphOptions: columnGraphPayload) => {
  let {data, title, tooltipFormatter} = barGraphOptions

  {
    chart: {
      \"type": "column",
      height: 270,
    },
    title,
    xAxis: {
      \"type": "category",
    },
    yAxis: {
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
        borderRadius: 10,
        stacking: "normal",
      },
    },
    series: data,
    credits: {
      enabled: false,
    },
  }
}

let columnGraphTooltipFormatter = (~title, ~metricType) => {
  open LogicUtils

  (
    @this
    (this: pointFormatter) => {
      let title = `<div style="font-size: 16px; font-weight: bold;">${title}</div>`

      let defaultValue = {color: "", x: "", y: 0.0, point: {index: 0}, key: ""}
      let primartPoint = this.points->getValueFromArray(0, defaultValue)

      let getRowsHtml = (~iconColor, ~date, ~value, ~comparisionComponent="") => {
        let valueString = valueFormatter(value, metricType)
        `<div style="display: flex; align-items: center;">
            <div style="width: 10px; height: 10px; background-color:${iconColor}; border-radius:3px;"></div>
            <div style="margin-left: 8px;">${date}${comparisionComponent}</div>
            <div style="flex: 1; text-align: right; font-weight: bold;margin-left: 25px;">${valueString}</div>
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
