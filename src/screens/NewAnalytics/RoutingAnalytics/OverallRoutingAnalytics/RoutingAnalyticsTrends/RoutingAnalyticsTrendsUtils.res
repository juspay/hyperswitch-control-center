open RoutingAnalyticsTrendsTypes
open LogicUtils
open LogicUtilsTypes
open NewAnalyticsUtils
open CurrencyFormatUtils

type routingMapperConfig = {
  title: string,
  tooltipTitle: string,
  yAxisMaxValue: option<int>,
  statType: valueType,
  suffix: string,
}

let customLegendFormatter = (
  @this
  (this: LineGraphTypes.legendPoint) => {
    `<div style="display: flex; align-items: center;">
        <div style="width: 13px; height: 13px; background-color:${this.color}; border-radius:3px;"></div>
        <div style="margin-left: 5px;">${this.name->snakeToTitle}</div>
    </div>`
  }
)->LineGraphTypes.asLegendsFormatter

let getRoutingTrendsSuccessOverTimeLineGraphTooltipFormatter = (
  ~title: string,
  ~valueFormatterType=Rate,
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
          getRowHtml(~iconColor=point.color, ~name=point.series.name, ~value=point.y)
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

let modifyQueryDataForSucessGraph = data => {
  data->Array.map(item => {
    let valueDict = item->getDictFromJsonObject
    let connector = valueDict->getString((#connector: routingTrendsMetrics :> string), "Unknown")
    let timeBucket =
      valueDict->getString((#time_bucket: routingTrendsMetrics :> string)->String.toLowerCase, "")
    let paymentSuccessRate =
      valueDict->getFloat(
        (#payment_success_rate: routingTrendsMetrics :> string)->String.toLowerCase,
        0.0,
      )
    let timeRange = valueDict->getObj("time_range", Dict.make())

    [
      ((#connector: routingTrendsMetrics :> string), connector->JSON.Encode.string),
      (
        (#time_bucket: routingTrendsMetrics :> string)->String.toLowerCase,
        timeBucket->JSON.Encode.string,
      ),
      (
        (#payment_success_rate: routingTrendsMetrics :> string)->String.toLowerCase,
        paymentSuccessRate->JSON.Encode.float,
      ),
      ((#time_range: routingTrendsMetrics :> string), timeRange->JSON.Encode.object),
    ]->getJsonFromArrayOfJson
  })
}
let modifyQueryDataForVolumeGraph = data => {
  data->Array.map(item => {
    let valueDict = item->getDictFromJsonObject
    let connector = valueDict->getString((#connector: routingTrendsMetrics :> string), "Unknown")
    let timeBucket =
      valueDict->getString((#time_bucket: routingTrendsMetrics :> string)->String.toLowerCase, "")
    let paymentCount =
      valueDict->getInt((#payment_count: routingTrendsMetrics :> string)->String.toLowerCase, 0)
    let timeRange = valueDict->getObj("time_range", Dict.make())

    [
      ((#connector: routingTrendsMetrics :> string), connector->JSON.Encode.string),
      (
        (#time_bucket: routingTrendsMetrics :> string)->String.toLowerCase,
        timeBucket->JSON.Encode.string,
      ),
      (
        (#payment_count: routingTrendsMetrics :> string)->String.toLowerCase,
        paymentCount->JSON.Encode.int,
      ),
      ((#time_range: routingTrendsMetrics :> string), timeRange->JSON.Encode.object),
    ]->getJsonFromArrayOfJson
  })
}

let fillMissingDataPointsForConnectors = (
  ~data,
  ~startDate,
  ~endDate,
  ~timeKey="time_bucket",
  ~defaultValue: JSON.t,
  ~granularity: string,
  ~isoStringToCustomTimeZone: string => TimeZoneHook.dateTimeString,
  ~granularityEnabled,
  ~groupByKey="connector",
) => {
  let groupedData = Dict.make()

  data->Array.forEach(item => {
    let itemDict = item->getDictFromJsonObject
    let groupValue = itemDict->getString(groupByKey, "Unknown")

    switch groupedData->Dict.get(groupValue) {
    | Some(existingData) => {
        let updatedData = existingData->Array.concat([item])
        groupedData->Dict.set(groupValue, updatedData)
      }
    | None => groupedData->Dict.set(groupValue, [item])
    }
  })

  let completeDataPoints = []
  groupedData
  ->Dict.toArray
  ->Array.forEach(((groupValue, groupData)) => {
    let timeDict = extractTimeDict(
      ~data=groupData,
      ~granularityEnabled,
      ~granularity,
      ~isoStringToCustomTimeZone,
      ~timeKey,
    )

    let defaultValueWithGroup = defaultValue->getDictFromJsonObject->Dict.copy
    defaultValueWithGroup->Dict.set(groupByKey, groupValue->JSON.Encode.string)

    let filledTimeDict = fillForMissingTimeRange(
      ~existingTimeDict=timeDict,
      ~timeKey,
      ~defaultValue=defaultValueWithGroup->JSON.Encode.object,
      ~startDate,
      ~endDate,
      ~granularity,
    )

    filledTimeDict
    ->Dict.valuesToArray
    ->Array.forEach(item => {
      completeDataPoints->Array.push(item)
    })
  })
  completeDataPoints
}

let genericRoutingMapper = (
  ~params: getObjects<JSON.t>,
  ~config: routingMapperConfig,
  ~tooltipValueFormatterType=Rate,
): LineGraphTypes.lineGraphPayload => {
  let {data, xKey, yKey} = params
  let dataArray = data->getArrayFromJson([])
  let connectorGroups = Dict.make()

  dataArray->Array.forEach(item => {
    let itemDict = item->getDictFromJsonObject
    let connector = itemDict->getString("connector", "Unknown")
    switch connectorGroups->Dict.get(connector) {
    | Some(existingData) => {
        let updatedData = existingData->Array.concat([item])
        connectorGroups->Dict.set(connector, updatedData)
      }
    | None => connectorGroups->Dict.set(connector, [item])
    }
  })

  let connectorData =
    connectorGroups
    ->Dict.valuesToArray
    ->getValueFromArray(0, [])

  let allTimeBuckets =
    connectorData
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

  let lineGraphData =
    connectorGroups
    ->Dict.toArray
    ->Array.mapWithIndex(((connectorName, connectorData), index) => {
      let color = index->getColor
      getLineGraphObj(~array=connectorData, ~key=yKey, ~name=connectorName, ~color, ~isAmount=false)
    })

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
    tooltipFormatter: getRoutingTrendsSuccessOverTimeLineGraphTooltipFormatter(
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
    legendFormatter: customLegendFormatter,
  }
}

let routingSuccessRateMapper = (~params: getObjects<JSON.t>): LineGraphTypes.lineGraphPayload => {
  genericRoutingMapper(
    ~params,
    ~config={
      title: "Auth Rate",
      tooltipTitle: "Success Rate",
      yAxisMaxValue: Some(150),
      statType: Rate,
      suffix: "%",
    },
  )
}

let routingVolumeMapper = (~params: getObjects<JSON.t>): LineGraphTypes.lineGraphPayload => {
  genericRoutingMapper(
    ~params,
    ~config={
      title: "Payment Count",
      tooltipTitle: "Volume",
      yAxisMaxValue: None,
      statType: Volume,
      suffix: "",
    },
    ~tooltipValueFormatterType=Amount,
  )
}
