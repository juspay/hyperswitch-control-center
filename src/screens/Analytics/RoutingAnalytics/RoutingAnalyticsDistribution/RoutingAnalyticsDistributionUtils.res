open LogicUtils

let customLegendFormatter = () => {
  (
    @this
    (this: PieGraphTypes.legendLabelFormatter) => {
      this.name->LogicUtils.snakeToTitle
    }
  )->PieGraphTypes.asLegendPointFormatter
}
let distributionPayloadMapper = (~data: JSON.t, ~groupByText): PieGraphTypes.pieGraphPayload<int> => {
  let queryArray = data->getDictFromJsonObject->getArrayFromDict("queryData", [])
  let array = queryArray->Array.map(item => {
    let dict = item->getDictFromJsonObject
    let routingApproach = dict->getString(groupByText, "NA")
    let paymentCount = dict->getFloat("payment_count", 0.0)
    (routingApproach, paymentCount)
  })
  let pieGraphColorSeries = [
    "#72BEF4",
    "#CB80DC",
    "#BCBD22",
    "#5CB7AF",
    "#F36960",
    "#9467BD",
    "#7F7F7F",
  ]
  let data: array<PieGraphTypes.pieGraphDataType> = array->Array.mapWithIndex((item, index) => {
    let (routingApproach, paymentCount) = item
    let dataObj: PieGraphTypes.pieGraphDataType = {
      name: routingApproach,
      y: paymentCount,
      color: pieGraphColorSeries[index]->Option.getOr(""),
    }
    dataObj
  })

  let data: PieGraphTypes.pieCartData<int> = [
    {
      \"type": "",
      name: "",
      showInLegend: true,
      data,
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
      ~title="Routing Approach",
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

