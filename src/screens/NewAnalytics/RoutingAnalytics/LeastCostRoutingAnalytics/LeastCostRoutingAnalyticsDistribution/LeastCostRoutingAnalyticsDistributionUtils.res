open LogicUtils
open NewAnalyticsUtils
open RoutingAnalyticsUtils
open LeastCostRoutingAnalyticsDistributionTypes
open LeastCostRoutingAnalyticsTypes

let filterDict =
  [
    (
      (#routing_approach: requestPayloadMetrics :> string),
      [(#debit_routing: requestPayloadMetrics :> string)->JSON.Encode.string]->JSON.Encode.array,
    ),
    (
      (#is_debit_routed: requestPayloadMetrics :> string),
      [true->JSON.Encode.bool]->JSON.Encode.array,
    ),
  ]->LogicUtils.getJsonFromArrayOfJson

//Functions related to Pie Graph
let mapPieGraphData = filtereddata => {
  let cardNetworkGroupedData =
    filtereddata->groupByField((#card_network: requestPayloadMetrics :> string))
  let cardNetworkData: array<PieGraphTypes.pieGraphDataType> =
    cardNetworkGroupedData
    ->Dict.toArray
    ->Array.map(((cardNetwork, records)) => {
      let recordsJson = records->getArrayFromJson([])
      let totalCount = sumFloatField(
        recordsJson,
        (#debit_routed_transaction_count: requestPayloadMetrics :> string),
      )
      let dataObj: PieGraphTypes.pieGraphDataType = {
        name: cardNetwork->snakeToTitle,
        y: totalCount,
      }
      dataObj
    })
  cardNetworkData
}

let payloadMapper = (~data: JSON.t, ~tooltipTitle): PieGraphTypes.pieGraphPayload<int> => {
  let queryArray = data->getDictFromJsonObject->getArrayFromDict("queryData", [])
  let dataArr = queryArray->mapPieGraphData

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

let chartOptions = (data, ~tooltipTitle) => {
  let defaultOptions = payloadMapper(~data, ~tooltipTitle)->PieGraphUtils.getPieChartOptions

  {
    ...defaultOptions,
    chart: {
      ...defaultOptions.chart,
      width: 400,
      height: 250,
    },
    plotOptions: {
      pie: {
        ...defaultOptions.plotOptions.pie,
        center: ["40%", "65%"],
      },
    },
  }
}

//Functions related to Savings Graph
let fillMissingDataForSavingsGraph = (
  ~data,
  ~startDate,
  ~endDate,
  ~timeKey="time_bucket",
  ~defaultValue: JSON.t,
  ~granularity: string,
  ~isoStringToCustomTimeZone: string => TimeZoneHook.dateTimeString,
  ~granularityEnabled,
) => {
  let existingTimeDict = extractTimeDict(
    ~data,
    ~granularity,
    ~granularityEnabled,
    ~isoStringToCustomTimeZone,
    ~timeKey,
  )

  let dateTimeRange = fillForMissingTimeRange(
    ~existingTimeDict,
    ~defaultValue,
    ~timeKey,
    ~endDate,
    ~startDate,
    ~granularity,
  )

  dateTimeRange->Dict.valuesToArray
}

let getSavingsTimeGraphTooltipFormatter = (
  ~title: string,
  ~valueFormatterType=LogicUtilsTypes.Rate,
) =>
  (
    @this
    (this: LineGraphTypes.pointFormatter) => {
      let titleHtml = `<div style="font-size: 14px; font-weight: bold;">${title}</div>`
      let getRowHtml = (~iconColor, ~name, ~value) => {
        let valueString = value->valueFormatter(valueFormatterType)
        `<div style="display: flex; align-items: center;">
              <div style="width: 10px; height: 10px; background-color:${iconColor}; border-radius:3px;"></div>
              <div style="margin-left: 8px;font-size: 12px;">${name->snakeToTitle}</div>
              <div style="flex: 1; text-align: right;font-size: 12px;font-weight: bold;margin-left: 25px;">${valueString}</div>
          </div>`
      }

      let tableItems =
        this.points
        ->Array.map(point => {
          getRowHtml(~iconColor=point.color, ~name=point.x, ~value=point.y)
        })
        ->Array.joinWith("")

      let content = `
            <div style=" 
            padding:5px 12px;
            display:flex;
            flex-direction:column;
            justify-content: space-between;
            gap: 7px;">
                ${titleHtml}
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
  )->LineGraphTypes.asTooltipPointFormatter

let savingsTimeMapper = (
  ~params: getObjects<JSON.t>,
  ~config: savingsTimeConfig,
  ~tooltipValueFormatterType=LogicUtilsTypes.Rate,
): LineGraphTypes.lineGraphPayload => {
  let {data, xKey, yKey} = params

  let dataArray = data->getArrayFromJson([])

  let allTimeBuckets =
    dataArray
    ->Array.map(item => {
      item->getDictFromJsonObject->getString(xKey, "")
    })
    ->Array.filter(timeBucket => timeBucket->isNonEmptyString)

  let isShowTime = dataArray->checkTimePresent(xKey)

  let categories = allTimeBuckets->Array.map(timeBucket => {
    let dateObj = timeBucket->DayJs.getDayJsForString
    let date = `${dateObj.month()->getMonthName} ${dateObj.format("DD")}`
    if isShowTime {
      let time = dateObj.format("HH:mm")->formatTimeString
      `${date}, ${time}`
    } else {
      date
    }
  })

  let lineGraphData = {
    let name = getLabelName(~key=xKey, ~index=0, ~points=dataArray->JSON.Encode.array)

    let obj = getLineGraphObj(
      ~array=dataArray,
      ~key=yKey,
      ~name,
      ~color=getColor(dataArray->Array.length),
      ~isAmount=false,
    )

    [obj]
  }

  {
    chartHeight: DefaultHeight,
    chartLeftSpacing: DefaultLeftSpacing,
    categories,
    data: lineGraphData,
    title: {
      text: config.title,
      style: {
        color: "white",
      },
    },
    yAxisMaxValue: config.yAxisMaxValue,
    yAxisMinValue: Some(0),
    tooltipFormatter: getSavingsTimeGraphTooltipFormatter(
      ~title=config.tooltipTitle,
      ~valueFormatterType=tooltipValueFormatterType,
    ),
    yAxisFormatter: LineGraphUtils.lineGraphYAxisFormatter(
      ~statType=config.statType,
      ~currency="",
      ~suffix=config.suffix,
    ),
    legend: {
      useHTML: true,
      symbolPadding: -7,
      symbolWidth: 0,
      align: "center",
      verticalAlign: "top",
      floating: false,
      margin: 30,
    },
  }
}
let savingsTimeConfig = {
  title: "Debit Routing Savings",
  yAxisMaxValue: Some(300),
  statType: LogicUtilsTypes.Amount,
  suffix: "$",
  tooltipTitle: "Debit Routed Savings",
}
let savingsChartOptions = (
  ~params: getObjects<JSON.t>,
  ~config: savingsTimeConfig,
  ~tooltipValueFormatterType=LogicUtilsTypes.Amount,
) => {
  let defaultOptions =
    savingsTimeMapper(
      ~params,
      ~config,
      ~tooltipValueFormatterType,
    )->LineGraphUtils.getLineGraphOptions

  {
    ...defaultOptions,
    chart: {
      ...defaultOptions.chart,
      height: 300,
    },
  }
}

let modifySavingsQueryData = (~data) => {
  let dataDict = Dict.make()

  data->Array.forEach(item => {
    let valueDict = item->getDictFromJsonObject
    let time = valueDict->getString((#time_bucket: requestPayloadMetrics :> string), "")
    let debitRoutingSavings =
      valueDict->getFloat(
        (#debit_routing_savings_in_usd: requestPayloadMetrics :> string),
        0.0,
      ) /. 100.00

    let prevData = dataDict->getDictfromDict(time)
    let prevdataLength = prevData->Dict.keysToArray->Array.length

    if prevdataLength > 0 {
      let prevdebitRoutingSavings =
        prevData->getFloat(
          (#debit_routing_savings_in_usd: requestPayloadMetrics :> string),
          0.0,
        ) /. 100.00
      valueDict->Dict.set(
        (#debit_routing_savings_in_usd: requestPayloadMetrics :> string),
        (debitRoutingSavings +. prevdebitRoutingSavings)->JSON.Encode.float,
      )
      dataDict->Dict.set(time, valueDict->JSON.Encode.object)
    } else {
      valueDict->Dict.set(
        (#debit_routing_savings_in_usd: requestPayloadMetrics :> string),
        debitRoutingSavings->JSON.Encode.float,
      )
      dataDict->Dict.set(time, valueDict->JSON.Encode.object)
    }
  })

  dataDict->Dict.valuesToArray
}
