open LineScatterGraphTypes

// colors
let darkGray = "#525866"
let lightGray = "#999999"
let gridLineColor = "#e6e6e6"
let fontFamily = "InterDisplay"

let valueFormatter = (
  @this
  this => {
    `<div style="display: flex; align-items: center;margin-bottom:15px;">
        <div style="width: 13px; height: 13px; background-color:${this.color}; border-radius:3px;"></div>
        <div style="margin-left: 5px;">${this.name}</div>
    </div>`
  }
)->asLegendsFormatter

let tooltipFormatter = (~title, ~metricType, ~currency="", ~suffix="") => {
  (
    @this
    (this: pointFormatter) => {
      try {
        let titleComponet = `<div style="font-size: 14px; font-weight: bold;">${title}</div>`

        let defaultValue = {color: "", x: "", y: 0.0, point: {index: 0}, series: {name: ""}}

        let primartPoint = this.points->Array.get(0)->Option.getOr(defaultValue)

        let getRowsHtml = (~value) => {
          let valueString = LogicUtils.valueFormatter(value, metricType, ~currency, ~suffix)
          `<div style="display: flex; align-items: center;">
            <div>Success Rate</div>
            <div style="flex: 1; text-align: right; font-weight: bold;margin-left: 25px;">${valueString}</div>
        </div>`
        }

        let tableItems = [getRowsHtml(~value=primartPoint.y)]->Array.joinWith("")

        let content = `
          <div style=" 
          padding:5px 12px;
          border-left: 3px solid #0069FD;
          display:flex;
          flex-direction:column;
          justify-content: space-between;
          gap: 7px;">
              ${titleComponet}
              <div style="font-size: 12px; color: #999999;">${primartPoint.x}</div>
              <div style="
                margin-top: 5px;
                display:flex;
                flex-direction:column;
                gap: 7px;">
                ${tableItems}
              </div>
        </div>`

        let noRetry = `<div style="
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

        let withRetry = `<div style="
        padding: 12px;
        width: fit-content;
        border-radius: 8px;
        background-color: #ffffff;
        box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);
        border: 1px solid #e5e5e5;
        font-family: 'Inter', sans-serif;
        color: #525866;
      ">
        <div style="border-left: 3px solid #0069FD;">
        <div style="display: flex; align-items: center; margin-bottom: 8px;padding-left:5px;">
          <span style="font-size: 16px; color: #0069fd; margin-right: 8px;">⚡</span>
          <span style="font-size: 14px; font-weight: bold;">${title} Attempted</span>
        </div>
        <div style="display: flex; flex-direction: column; gap: 8px;padding-left:10px;">
          <div style="font-size: 12px; color: #999999;">${primartPoint.x}</div>
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <span>Success Rate</span>
            <span style="flex: 1; text-align: right; font-weight: bold;margin-left: 25px;"">${LogicUtils.valueFormatter(
            primartPoint.y,
            metricType,
            ~currency,
            ~suffix,
          )}</span>
        </div>
          </div>
        </div>
      </div>`

        if this.points->Array.length > 1 {
          withRetry
        } else {
          noRetry
        }
      } catch {
      | _ => ""
      }
    }
  )->asTooltipPointFormatter
}

let lineGraphYAxisFormatter = (
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

let getLineGraphOptions = (lineGraphOptions: lineScatterGraphPayload) => {
  let {
    categories,
    data,
    title,
    tooltipFormatter,
    yAxisMaxValue,
    yAxisMinValue,
    yAxisFormatter,
    legend,
  } = lineGraphOptions

  let yAxis: yAxis = {
    title: {
      ...title,
      style: {
        color: LineGraphUtils.darkGray,
        fontFamily: LineGraphUtils.fontFamily, // Set the desired font family
        fontSize: "12px", // Set the font size
      },
    },
    gridLineWidth: 1,
    gridLineColor: LineGraphUtils.gridLineColor,
    gridLineDashStyle: "Dash",
    labels: {
      formatter: yAxisFormatter,
      align: "center",
      style: {
        color: LineGraphUtils.lightGray,
        fontFamily: LineGraphUtils.fontFamily, // Set the desired font family
      },
      x: -10,
    },
  }

  let color = LineGraphUtils.lightGray
  let gridLineColor = LineGraphUtils.gridLineColor
  let fontFamily = LineGraphUtils.fontFamily

  {
    chart: {
      height: 400,
      spacingLeft: 10,
      spacingRight: 10,
      style: {
        color,
        fontFamily, // Set the desired font family
      },
    },
    title,
    xAxis: {
      categories,
      crosshair: true,
      lineWidth: 1,
      tickWidth: 1,
      labels: {
        align: "center",
        style: {
          color,
          fontFamily,
        },
        y: 35,
      },
      tickInterval: 0,
      gridLineWidth: 0,
      gridLineColor,
      tickmarkPlacement: "on",
      endOnTick: false,
      startOnTick: false,
    },
    tooltip: {
      enabled: true,
      useHTML: true,
      shared: true,
      style: {
        padding: "0px",
        fontFamily, // Set the desired font family
        fontSize: "14px", // Optional: Set the font size
      },
      shape: "square",
      shadow: false,
      backgroundColor: "transparent",
      borderColor: "transparent",
      borderWidth: 0.0,
      formatter: tooltipFormatter,
    },
    yAxis: {
      switch (yAxisMaxValue, yAxisMinValue) {
      | (Some(maxVal), Some(minVal)) => {
          ...yAxis,
          max: Some(maxVal),
          min: Some(minVal),
        }
      | (Some(maxVal), None) => {
          ...yAxis,
          max: Some(maxVal),
        }
      | (None, Some(minVal)) => {
          ...yAxis,
          min: Some(minVal),
        }
      | (None, None) => yAxis
      }
    },
    legend: {
      ...legend,
      useHTML: true,
      labelFormatter: valueFormatter,
      symbolPadding: 0,
      symbolWidth: 0,
      itemStyle: {
        fontFamily,
        fontSize: "12px",
        color,
        fontWeight: "400",
      },
    },
    plotOptions: {
      line: {
        marker: {
          enabled: false,
        },
      },
      scatter: {
        marker: {
          enabled: true, // Enable markers for the scatter plot
          radius: 5.0, // Set the size of scatter points
        },
      },
      series: {
        states: {
          inactive: {
            enabled: false,
            opacity: 0.2,
          },
        },
      },
    },
    series: data,
    credits: {
      enabled: false,
    },
  }
}
