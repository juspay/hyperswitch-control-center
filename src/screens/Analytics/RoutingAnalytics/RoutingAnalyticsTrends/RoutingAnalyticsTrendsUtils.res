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

let getRoutingTrendsSuccessOverTimeLineGraphTooltipFormatter = (~title: string) =>
  (
    @this
    (this: LineGraphTypes.pointFormatter) => {
      let titleHtml = `<div style="font-size: 14px; font-weight: bold;">${title}</div>`
      let getRowHtml = (~iconColor, ~name, ~value) => {
        let valueString = value->valueFormatter(Rate)
        `<div style="display: flex; align-items: center;">
              <div style="width: 10px; height: 10px; background-color:${iconColor}; border-radius:3px;"></div>
              <div style="margin-left: 8px;font-size: 12px;">${name}</div>
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

    [
      ("connector", connector->JSON.Encode.string),
      ((Time_Bucket :> string)->String.toLowerCase, timeBucket->JSON.Encode.string),
      ((Payment_Success_Rate :> string)->String.toLowerCase, paymentSuccessRate->JSON.Encode.float),
      ((Payment_Count :> string)->String.toLowerCase, paymentCount->JSON.Encode.int),
    ]->LogicUtils.getJsonFromArrayOfJson
  })
}

let genericRoutingMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
  ~config: routingMapperConfig,
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

  let allTimeBuckets =
    dataArray
    ->Array.map(item => {
      item->getDictFromJsonObject->getString(xKey, "")
    })
    ->Array.filter(timeBucket => timeBucket->isNonEmptyString)

  let categories =
    allTimeBuckets
    ->Array.map(timeBucket => {
      let dateObj = timeBucket->DayJs.getDayJsForString
      let date = `${dateObj.month()->getMonthName} ${dateObj.format("DD")}`
      date
    })
    ->Array.toSorted((a, b) => a <= b ? -1. : 1.)

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
    ),
    yAxisFormatter: LineGraphUtils.lineGraphYAxisFormatter(
      ~statType=config.statType,
      ~currency="",
      ~suffix=config.suffix,
    ),
    legend: {
      useHTML: true,
      labelFormatter: LineGraphUtils.valueFormatter,
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
      yAxisMaxValue: Some(100),
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
      title: "Auth Rate",
      tooltipTitle: "Volume",
      yAxisMaxValue: None,
      statType: Volume,
      suffix: "",
    },
  )
}
