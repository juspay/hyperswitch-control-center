open LogicUtils
open RoutingAnalyticsDistributionTypes

let customLegendFormatter = () => {
  (
    @this
    (this: PieGraphTypes.legendLabelFormatter) => {
      this.name->snakeToTitle
    }
  )->PieGraphTypes.asLegendPointFormatter
}

let distributionPayloadMapper = (~data: JSON.t, ~groupByText): PieGraphTypes.pieGraphPayload<
  int,
> => {
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

  let dataArr: array<PieGraphTypes.pieGraphDataType> = array->Array.mapWithIndex((item, index) => {
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

let chartOptions = (data, ~groupByText) => {
  let defaultOptions =
    distributionPayloadMapper(~data, ~groupByText)->PieGraphUtils.getPieChartOptions

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

let globalFilter: array<filters> = [
  #connector,
  #payment_method,
  #payment_method_type,
  #currency,
  #authentication_type,
  #status,
  #client_source,
  #client_version,
  #profile_id,
  #card_network,
  #merchant_id,
  #routing_approach,
]

let generateFilterObject = (~globalFilters, ~localFilters=None) => {
  let filters = Dict.make()

  let globalFiltersList = globalFilter->Array.map(filter => {
    (filter: filters :> string)
  })

  let parseValue = value => {
    switch value->JSON.Classify.classify {
    | Array(arr) =>
      arr->Array.map(item => item->JSON.Decode.string->Option.getOr("")->JSON.Encode.string)
    | String(str) => str->String.split(",")->Array.map(JSON.Encode.string)
    | _ => []
    }
  }

  globalFilters
  ->Dict.toArray
  ->Array.forEach(item => {
    let (key, value) = item
    if globalFiltersList->Array.includes(key) && value->parseValue->Array.length > 0 {
      filters->Dict.set(key, value->parseValue->JSON.Encode.array)
    }
  })

  switch localFilters {
  | Some(dict) =>
    dict
    ->Dict.toArray
    ->Array.forEach(item => {
      let (key, value) = item
      filters->Dict.set(key, value)
    })
  | None => ()
  }

  filters->JSON.Encode.object
}
