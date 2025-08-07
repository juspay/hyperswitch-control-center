open RoutingAnalyticsTrendsTypes
open InsightsUtils
open LogicUtils
open LogicUtilsTypes

type routingMapperConfig = {
  title: string,
  tooltipTitle: string,
  yAxisMaxValue: option<int>,
  statType: LogicUtilsTypes.valueType,
  suffix: string,
}

let getVariantValueFromString = value => {
  switch value {
  | "payment_success_rate" => Payment_Success_Rate
  | "payment_count" => Payment_Count
  | "time_bucket" | _ => Time_Bucket
  }
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

let modifyQueryData = data => {
  data->Array.map(item => {
    let valueDict = item->getDictFromJsonObject
    let connector = valueDict->getString("connector", "Unknown")
    let timeBucket = valueDict->getString((Time_Bucket :> string)->String.toLowerCase, "")
    let paymentSuccessRate =
      valueDict->getFloat((Payment_Success_Rate :> string)->String.toLowerCase, 0.0)
    let paymentCount = valueDict->getInt((Payment_Count :> string)->String.toLowerCase, 0)
    let timeRange = valueDict->getObj("time_range", Dict.make())

    [
      ("connector", connector->JSON.Encode.string),
      ((Time_Bucket :> string)->String.toLowerCase, timeBucket->JSON.Encode.string),
      ((Payment_Success_Rate :> string)->String.toLowerCase, paymentSuccessRate->JSON.Encode.float),
      ((Payment_Count :> string)->String.toLowerCase, paymentCount->JSON.Encode.int),
      ("time_range", timeRange->JSON.Encode.object),
    ]->LogicUtils.getJsonFromArrayOfJson
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
) => {
  let connectorDataDict = Dict.make()

  data->Array.forEach(item => {
    let itemDict = item->getDictFromJsonObject
    let connector = itemDict->getString("connector", "Unknown")

    let time = switch (
      granularityEnabled,
      granularity != (#G_ONEDAY: InsightsTypes.granularity :> string),
    ) {
    | (true, true) => {
        let value =
          item
          ->getDictFromJsonObject
          ->getObj("time_range", Dict.make())
        let time = value->getString("start_time", "")
        let {year, month, date, hour, minute} = isoStringToCustomTimeZone(time)

        if (
          granularity == (#G_THIRTYMIN: InsightsTypes.granularity :> string) ||
            granularity == (#G_FIFTEENMIN: InsightsTypes.granularity :> string)
        ) {
          (`${year}-${month}-${date} ${hour}:${minute}`->DayJs.getDayJsForString).format(
            "YYYY-MM-DD HH:mm:ss",
          )
        } else {
          (`${year}-${month}-${date} ${hour}:${minute}`->DayJs.getDayJsForString).format(
            "YYYY-MM-DD HH:00:00",
          )
        }
      }
    | _ => itemDict->getString(timeKey, "")
    }

    let connectorDict = connectorDataDict->Dict.get(connector)->Option.getOr(Dict.make())

    let newItem = itemDict->Dict.copy
    newItem->Dict.set("time_bucket", time->JSON.Encode.string)

    connectorDict->Dict.set(time, newItem->JSON.Encode.object)
    connectorDataDict->Dict.set(connector, connectorDict)
  })

  let allConnectors = connectorDataDict->Dict.keysToArray

  let startingPoint = startDate->DayJs.getDayJsForString
  let startingPoint = startingPoint.format("YYYY-MM-DD HH:00:00")->DayJs.getDayJsForString
  let endingPoint = endDate->DayJs.getDayJsForString
  let gap = "minute"
  let devider = granularity->getGranularityGap
  let limit =
    (endingPoint.diff(startingPoint.toString(), gap)->Int.toFloat /. devider->Int.toFloat)
    ->Math.floor
    ->Float.toInt

  let format =
    granularity != (#G_ONEDAY: InsightsTypes.granularity :> string)
      ? "YYYY-MM-DD HH:mm:ss"
      : "YYYY-MM-DD 00:00:00"

  let completeDataPoints = []

  allConnectors->Array.forEach(connector => {
    let connectorDict = connectorDataDict->Dict.get(connector)->Option.getOr(Dict.make())

    for x in 0 to limit {
      let timeVal = startingPoint.add(x * devider, gap).format(format)

      switch connectorDict->Dict.get(timeVal) {
      | Some(val) => completeDataPoints->Array.push(val)
      | None => {
          let newDict = defaultValue->getDictFromJsonObject->Dict.copy
          newDict->Dict.set(timeKey, timeVal->JSON.Encode.string)
          newDict->Dict.set("connector", connector->JSON.Encode.string)
          completeDataPoints->Array.push(newDict->JSON.Encode.object)
        }
      }
    }
  })

  completeDataPoints
}

let genericRoutingMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
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
  
  let (_, connectorData) =
    connectorGroups
    ->Dict.toArray
    ->getValueFromArray(0, ("", [JSON.Encode.null]))

  let allTimeBuckets =
    connectorData
    ->Array.map(item => {
      item->getDictFromJsonObject->getString(xKey, "")
    })
    ->Array.filter(timeBucket => timeBucket->isNonEmptyString)

  let isShowTime = dataArray->InsightsUtils.checkTimePresent(xKey)
  let categories = allTimeBuckets->Array.map(timeBucket => {
    let dateObj = timeBucket->DayJs.getDayJsForString
    let date = `${dateObj.month()->getMonthName} ${dateObj.format("DD")}`
    if isShowTime {
      let time = dateObj.format("HH:mm")->formatTime
      `${date}, ${time}`
    } else {
      date
    }
  })

  let lineGraphData =
    connectorGroups
    ->Dict.toArray
    ->Array.mapWithIndex(((connectorName, connectorData), index) => {
      let color = index->InsightsUtils.getColor
      InsightsUtils.getLineGraphObj(
        ~array=connectorData,
        ~key=yKey,
        ~name=connectorName,
        ~color,
        ~isAmount=false,
      )
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
      labelFormatter: customLegendFormatter,
      symbolPadding: -7,
      symbolWidth: 0,
      align: "center",
      verticalAlign: "top",
      floating: false,
      margin: 30,
    },
  }
}

let routingSuccessRateMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
): LineGraphTypes.lineGraphPayload => {
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

let routingVolumeMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
): LineGraphTypes.lineGraphPayload => {
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
