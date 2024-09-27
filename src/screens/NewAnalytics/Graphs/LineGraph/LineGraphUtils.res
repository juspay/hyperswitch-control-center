open LineGraphTypes
let tooltipFormatter = (
  @this
  (this: pointFormatter) => {
    let title = `<div style="font-size: 16px; font-weight: bold;">Payments Processed</div>`

    let tableItems =
      this.points
      ->Array.map(point =>
        `<div style="display: flex; align-items: center;">
                  <div style="width: 10px; height: 10px; background-color:${point.color}; border-radius:3px;"></div>
                  <div style="margin-left: 8px;">${point.x}</div>
                  <div style="flex: 1; text-align: right; font-weight: bold;">${point.y->Float.toString} USD</div>
                </div>`
      )
      ->Array.joinWith("")

    let content = `
          <div style=" 
          padding:5px 12px;
          border-left: 3px solid #0069FD;
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

let getLineGraphOptions = (lineGraphOptions: lineGraphPayload) => {
  let {categories, data, title} = lineGraphOptions
  {
    chart: {
      \"type": "line",
      spacingLeft: 20,
      spacingRight: 20,
    },
    title: {
      text: "",
    },
    xAxis: {
      categories,
      crosshair: true,
      lineWidth: 1,
      tickWidth: 1,
      labels: {
        align: "center",
        style: {
          color: "#666",
        },
        y: 35,
      },
      gridLineWidth: 1,
      gridLineColor: "#e6e6e6",
      tickmarkPlacement: "on",
      endOnTick: false,
      startOnTick: false,
    },
    tooltip: {
      style: {
        padding: "0px",
        fontFamily: "Arial, sans-serif", // Set the desired font family
        fontSize: "14px", // Optional: Set the font size
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
    yAxis: {
      title,
      gridLineWidth: 1,
      gridLineColor: "#e6e6e6",
      gridLineDashStyle: "Dash",
      min: 0,
    },
    plotOptions: {
      line: {
        marker: {
          enabled: false,
        },
      },
    },
    series: [data],
    credits: {
      enabled: false,
    },
  }
}
