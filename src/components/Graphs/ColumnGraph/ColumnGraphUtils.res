// constants
let fontFamily = "InterDisplay"
let darkGray = "#525866"

open ColumnGraphTypes

let labelFormatter = (
  @this
  (this: legendPoint) => {
    `<div style="display: flex; align-items: center;">
        <div style="width: 13px; height: 13px; background-color:${this.color}; border-radius:3px;"></div>
        <div style="margin-left: 5px;">${this.name}</div>
    </div>`
  }
)->asLegendsFormatter

let getColumnGraphOptions = (columnGraphOptions: columnGraphPayload) => {
  let {data, title, tooltipFormatter, yAxisFormatter} = columnGraphOptions

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
      height: 300,
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
      gridLineDashStyle: "Dash",
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
      useHTML: false,
      labelFormatter,
      symbolPadding: 12,
      symbolWidth: 0,
      symbolHeight: 0,
      symbolRadius: 3,
      itemStyle: {
        fontFamily,
        fontSize: "12px",
        color: darkGray,
      },
      align: "right",
      verticalAlign: "top",
      x: 0,
      y: 0,
    },
    plotOptions: {
      series: {
        borderWidth: 0,
        borderRadius: 5,
        stacking: "",
        grouping: true,
        pointWidth: 30,
      },
    },
    series: data,
    credits: {
      enabled: false,
    },
  }
}

let columnGraphTooltipFormatter = (
  ~title,
  ~metricType: LogicUtilsTypes.valueType,
  ~comparison: option<DateRangeUtils.comparison>=None,
) => {
  (
    @this
    (this: pointFormatter) => {
      let title = `<div style="font-size: 16px; font-weight: bold;">${title}</div>`
      let _defaultValue = {color: "", x: "", y: 0.0, point: {index: 0}, key: ""}

      let getRowsHtml = (~iconColor, ~date, ~value, ~comparisionComponent="") => {
        let formattedValue = LogicUtils.valueFormatter(value, metricType, ~currency="$")

        `<div style="display: flex; align-items: center;">
            <div style="width: 10px; height: 10px; background-color:${iconColor}; border-radius:3px;"></div>
            <div style="margin-left: 8px;">${date}${comparisionComponent}</div>
            <div style="flex: 1; text-align: right; font-weight: bold;margin-left: 25px;">${formattedValue}</div>
        </div>`
      }

      let tableItems = {
        this.points->Array.reverse
        this.points
        ->Array.mapWithIndex((point, index) => {
          let defaultValue = {color: "", x: "", y: 0.0, point: {index: 0}, key: ""}
          let {color, key, y} = point

          let showComparison = index == 0 ? true : false
          let secondaryPoint =
            this.points->LogicUtils.getValueFromArray(index == 1 ? 0 : 1, defaultValue)

          getRowsHtml(
            ~iconColor=color,
            ~date=key,
            ~value=y,
            ~comparisionComponent={
              switch comparison {
              | Some(value) =>
                value == DateRangeUtils.EnableComparison && showComparison
                  ? NewAnalyticsUtils.getToolTipConparision(
                      ~primaryValue=y,
                      ~secondaryValue=secondaryPoint.y,
                    )
                  : ""
              | None => ""
              }
            },
          )
        })
        ->Array.joinWith("")
      }

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

let columnGraphYAxisFormatter = (
  ~statType: LogicUtilsTypes.valueType,
  ~currency="",
  ~suffix="",
  ~scaleFactor=1.0,
) => {
  (
    @this
    (this: yAxisFormatter) => {
      let value = this.value->Int.toFloat /. scaleFactor
      let formattedValue = LogicUtils.valueFormatter(value, statType, ~currency, ~suffix)

      formattedValue
    }
  )->asTooltipPointFormatter
}
