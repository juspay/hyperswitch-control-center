open LineAndColumnGraphTypes

let darkGray = "#525866"
let lightGray = "#999999"
let gridLineColor = "#e6e6e6"
let fontFamily = "InterDisplay"

let labelFormatter = (
  @this
  this => {
    `<div style="display: flex; align-items: center;">
        <div style="width: 13px; height: 13px; background-color:${this.color}; border-radius:3px;"></div>
        <div style="margin-left: 5px;">${this.name}</div>
    </div>`
  }
)->asLegendsFormatter

let getLineColumnGraphOptions = (lineColumnGraphOptions: lineColumnGraphPayload) => {
  let {
    categories,
    data,
    tooltipFormatter,
    yAxisFormatter,
    titleObj,
    minValY2,
    maxValY2,
    legend,
  } = lineColumnGraphOptions

  let stepInterval = Js.Math.max_int(
    Js.Math.ceil_int(categories->Array.length->Int.toFloat /. 10.0),
    1,
  )

  let yAxis: LineAndColumnGraphTypes.yAxis = [
    {
      title: titleObj.oppositeYAxisTitle,
      opposite: true,
      gridLineWidth: 1,
      gridLineColor,
      gridLineDashStyle: "Dash",
      labels: {
        align: "center",
        style: {
          color: lightGray,
          fontFamily,
        },
        x: 5,
        formatter: yAxisFormatter,
      },
      min: minValY2,
      max: Some(maxValY2),
    },
    {
      title: titleObj.yAxisTitle,
      opposite: false,
      gridLineWidth: 1,
      gridLineColor,
      gridLineDashStyle: "Dash",
      labels: {
        align: "center",
        style: {
          color: lightGray,
          fontFamily,
        },
        x: 5,
      },
      min: 0,
    },
  ]

  {
    chart: {
      zoomType: "xy",
      spacingLeft: 20,
      spacingRight: 20,
      style: {
        color: darkGray,
        fontFamily,
        fontSize: "12px",
      },
    },
    title: titleObj.chartTitle,
    xAxis: {
      title: titleObj.xAxisTitle,
      categories,
      crosshair: true,
      lineWidth: 1,
      tickWidth: 1,
      labels: {
        align: "center",
        style: {
          color: lightGray,
          fontFamily,
        },
        y: 35,
      },
      tickInterval: stepInterval,
      gridLineWidth: 1,
      gridLineColor,
      gridLineDashStyle: "Dash",
      tickmarkPlacement: "on",
      endOnTick: false,
      startOnTick: false,
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
      shared: true, // Allows multiple series' data to be shown in a single tooltip
    },
    yAxis,
    legend: {
      ...legend,
      useHTML: true,
      labelFormatter,
      symbolPadding: -7,
      symbolWidth: 0,
      symbolHeight: 0,
      symbolRadius: 4,
      itemStyle: {
        fontFamily,
        fontSize: "12px",
        color: darkGray,
        fontWeight: "400",
      },
    },
    plotOptions: {
      line: {
        marker: {
          enabled: false,
        },
      },
      column: {
        pointWidth: 10, // Adjust width of bars
        borderRadius: 3, // Rounds the top corners
      },
    },
    series: data,
    credits: {
      enabled: false,
    },
  }
}

let lineColumnGraphTooltipFormatter = (
  ~title,
  ~metricType: LogicUtilsTypes.valueType,
  ~currency="$",
  ~showNameInTooltip=false,
) => {
  open LogicUtils

  (
    @this
    (this: pointFormatter) => {
      let title = `<div style="font-size: 16px; font-weight: bold;">${title}</div>`

      let defaultValue = {color: "", x: "", y: 0.0, point: {index: 0}, key: "", series: {name: ""}}
      let primartPoint = this.points->getValueFromArray(0, defaultValue)
      let line1Point = this.points->getValueFromArray(1, defaultValue)
      let line2Point = this.points->getValueFromArray(2, defaultValue)

      let getRowsHtml = (~iconColor, ~date, ~value, ~comparisionComponent="", ~name="") => {
        let formattedValue = LogicUtils.valueFormatter(value, metricType, ~currency)
        let key = showNameInTooltip ? name : date
        `<div style="display: flex; align-items: center;">
            <div style="width: 10px; height: 10px; background-color:${iconColor}; border-radius:3px;"></div>
            <div style="margin-left: 8px;">${key}${comparisionComponent}</div>
            <div style="flex: 1; text-align: right; font-weight: bold;margin-left: 25px;">${formattedValue}</div>
        </div>`
      }

      let tableItems =
        [
          getRowsHtml(
            ~iconColor=primartPoint.color,
            ~date=primartPoint.key,
            ~value=primartPoint.y,
            ~name=primartPoint.series.name,
          ),
          getRowsHtml(
            ~iconColor=line1Point.color,
            ~date=line1Point.key,
            ~value=line1Point.y,
            ~name=line1Point.series.name,
          ),
          getRowsHtml(
            ~iconColor=line2Point.color,
            ~date=line2Point.key,
            ~value=line2Point.y,
            ~name=line2Point.series.name,
          ),
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

let lineColumnGraphYAxisFormatter = (
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
