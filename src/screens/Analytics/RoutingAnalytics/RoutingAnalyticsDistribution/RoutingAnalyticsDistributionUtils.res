open LogicUtils

let customLegendFormatter = () => {
  (
    @this
    (this: PieGraphTypes.legendLabelFormatter) => {
      this.name->snakeToTitle
    }
  )->PieGraphTypes.asLegendPointFormatter
}

let distributionPayloadMapper = (
  ~data: JSON.t,
  ~groupByText,
  ~tooltipTitle,
): PieGraphTypes.pieGraphPayload<int> => {
  let queryArray = data->getDictFromJsonObject->getArrayFromDict("queryData", [])
  let array = queryArray->Array.map(item => {
    let dict = item->getDictFromJsonObject
    let groupedByText = dict->getString(groupByText, "NA")
    let paymentCount = dict->getFloat("payment_count", 0.0)
    (groupedByText, paymentCount)
  })

  let dataArr: array<PieGraphTypes.pieGraphDataType> = array->Array.map(item => {
    let (groupedByText, paymentCount) = item
    let dataObj: PieGraphTypes.pieGraphDataType = {
      name: groupedByText->snakeToTitle,
      y: paymentCount,
    }
    dataObj
  })

  let data: PieGraphTypes.pieCartData<int> = [
    {
      \"type": "",
      name: "",
      showInLegend: true,
      data: dataArr,
      innerSize: "70%",
    },
  ]

  {
    chartSize: "80%",
    title: {
      text: "",
    },
    data,
    tooltipFormatter: PieGraphUtils.pieGraphTooltipFormatter(
      ~title=tooltipTitle,
      ~valueFormatterType=Amount,
    ),
    legendFormatter: customLegendFormatter(),
    startAngle: 0,
    endAngle: 360,
    legend: {
      align: "right",
      verticalAlign: "middle",
      enabled: true,
    },
  }
}

let chartOptions = (data, ~groupByText, ~tooltipTitle) => {
  let defaultOptions =
    distributionPayloadMapper(~data, ~groupByText, ~tooltipTitle)->PieGraphUtils.getPieChartOptions

  {
    ...defaultOptions,
    chart: {
      ...defaultOptions.chart,
      width: 400,
      height: 190,
    },
    plotOptions: {
      pie: {
        ...defaultOptions.plotOptions.pie,
        center: ["25%", "50%"],
      },
    },
  }
}
