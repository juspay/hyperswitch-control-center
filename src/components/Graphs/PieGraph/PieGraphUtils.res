open PieGraphTypes

let getPieChartOptions = (pieGraphOptions: pieGraphPayload<'t>) => {
  let {
    data,
    title,
    legendFormatter,
    tooltipFormatter,
    chartSize,
    startAngle,
    endAngle,
    legend,
  } = pieGraphOptions
  let pieGraphTitle = {
    ...title,
    align: "center",
    verticalAlign: "bottom", // Centered vertically within the chart
    y: 9, // Adjust this value to fine-tune vertical position
    x: 0,
    style: {
      fontSize: "14px",
      fontWeight: "400",
      color: "#797979",
      fontStyle: "InterDisplay",
    },
    useHTML: true,
  }
  {
    chart: {
      \"type": "pie",
      height: 200,
      width: 200,
      spacing: [0, 0, 0, 0],
      margin: [0, 0, 0, 0],
    },
    accessibility: {
      enabled: false, // Disables accessibility features
    },
    title: pieGraphTitle,
    plotOptions: {
      pie: {
        innerSize: "50%", // Creates the donut shape
        startAngle, // Start angle for full donut
        endAngle, // End angle for full donut
        showInLegend: true, // Ensures each point shows in the legend
        dataLabels: {
          enabled: false,
        },
        // borderRadius: 8,
        size: chartSize,
        // center: ["50%", "83%"],
      },
    },
    tooltip: {
      style: {
        padding: "0px",
        fontFamily: "Inter Display, sans-serif", // Set the desired font family
        fontSize: "14px", // Optional: Set the font size
      },
      shadow: false,
      backgroundColor: "transparent",
      borderWidth: 0.0,
      formatter: tooltipFormatter,
      useHTML: true,
    },
    series: data,
    credits: {
      enabled: false,
    },
    legend: {
      ...legend,
      labelFormatter: legendFormatter,
    },
  }
}

let pieGraphColorSeries = [
  "#72BEF4",
  "#CB80DC",
  "#BCBD22",
  "#5CB7AF",
  "#F36960",
  "#9467BD",
  "#7F7F7F",
]

let pieGraphTooltipFormatter = (
  ~title: string,
  ~valueFormatterType: LogicUtilsTypes.valueType,
  ~currency="",
  ~suffix="",
) => {
  (
    @this
    (this: PieGraphTypes.pointFormatter) => {
      let value = this.y < 0.0 ? this.y *. -1.0 : this.y

      let valueString = value->LogicUtils.valueFormatter(valueFormatterType, ~currency, ~suffix)
      let title = `<div style="font-size: 16px; font-weight: bold;">${title}</div>`

      let tableItems = `
        <div style="display: flex; align-items: center;">
            <div style="width: 10px; height: 10px; background-color:${this.color}; border-radius:3px;"></div>
            <div style="margin-left: 8px;">${this.point.name}</div>
            <div style="flex: 1; text-align: right; font-weight: bold;margin-left: 25px;">${valueString}</div>
        </div>
      `
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
  )->PieGraphTypes.asTooltipPointFormatter
}

let pieGraphLegendFormatter = () => {
  (
    @this
    (this: PieGraphTypes.legendLabelFormatter) => {
      let name = this.name->LogicUtils.snakeToTitle
      let title = `<div style="font-size: 10px; font-weight: bold;">${name} | ${this.y->Int.toString}</div>`
      title
    }
  )->PieGraphTypes.asLegendPointFormatter
}

let getCategoryWisePieChartPayload = (
  ~data: array<categoryWiseBreakDown>,
  ~chartSize,
  ~toolTipStyle: toolTipStyle,
  ~showInLegend: bool=true,
  ~legend: legend,
) => {
  let totalAmount = data->Array.reduce(0.0, (acc, item) => {
    acc +. item.total
  })

  let horizontalAlignTitle = switch showInLegend {
  | true => -95
  | false => 0
  }

  let title: PieGraphTypes.title = {
    text: `
    <div className="flex flex-col items-center justify-center">
      <p class="text-center mt-1 text-gray-800 text-2xl font-semibold font-inter-style">${totalAmount->LogicUtils.valueFormatter(
        toolTipStyle.valueFormatterType,
      )}</p>
    <p class="text-sm text-grey-500 font-inter-style px-4">${toolTipStyle.title}</p>
    </div>
    `,
    x: horizontalAlignTitle,
  }
  let pieGraphData = data->Array.mapWithIndex((ele, index) => {
    let data: PieGraphTypes.pieGraphDataType = {
      name: ele.name,
      y: ele.total,
      color: switch ele.color {
      | Some(color) => color
      | None => pieGraphColorSeries[index]->Option.getOr("")
      },
    }
    data
  })
  let pieGraphDataObj: PieGraphTypes.dataObj<'t> = {
    \"type": "pie",
    innerSize: "80%",
    showInLegend,
    name: "",
    data: pieGraphData,
  }
  let pieChatData = [pieGraphDataObj]
  let payLoad: PieGraphTypes.pieGraphPayload<'t> = {
    data: pieChatData,
    title,
    tooltipFormatter: pieGraphTooltipFormatter(
      ~title=toolTipStyle.title,
      ~valueFormatterType=toolTipStyle.valueFormatterType,
    ),
    legendFormatter: pieGraphLegendFormatter(),
    chartSize,
    startAngle: 0,
    endAngle: 360,
    legend,
  }
  payLoad
}
