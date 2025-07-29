open RoutingAnalyticsTrendsTypes
open InsightsUtils
open LogicUtils
open LogicUtilsTypes

let getStringFromVariant = value => {
  switch value {
  | Payment_Success_Rate => "payment_success_rate"
  | Payment_Count => "payment_count"
  | Time_Bucket => "time_bucket"
  }
}

let getVariantValueFromString = value => {
  switch value {
  | "payment_success_rate" => Payment_Success_Rate
  | "payment_count" => Payment_Count
  | "time_bucket" | _ => Time_Bucket
  }
}

let isAmountMetric = key => {
  switch key->getVariantValueFromString {
  | Payment_Success_Rate | Payment_Count | Time_Bucket => false
  }
}

let modifyQueryData = data => {
  data->Array.map(item => {
    let valueDict = item->getDictFromJsonObject
    let connector = valueDict->getString("connector", "Unknown")
    let timeBucket = valueDict->getString(Time_Bucket->getStringFromVariant, "")
    let paymentSuccessRate = valueDict->getFloat(Payment_Success_Rate->getStringFromVariant, 0.0)
    let paymentCount = valueDict->getInt(Payment_Count->getStringFromVariant, 0)
    let resultDict = Dict.make()
    resultDict->Dict.set("connector", connector->JSON.Encode.string)
    resultDict->Dict.set(Time_Bucket->getStringFromVariant, timeBucket->JSON.Encode.string)
    resultDict->Dict.set(
      Payment_Success_Rate->getStringFromVariant,
      paymentSuccessRate->JSON.Encode.float,
    )
    resultDict->Dict.set(Payment_Count->getStringFromVariant, paymentCount->JSON.Encode.int)
    resultDict->JSON.Encode.object
  })
}

let routingSuccessRateMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  let {data, xKey, yKey} = params
  let currency = params.currency->Option.getOr("")
  let comparison = switch params.comparison {
  | Some(val) => Some(val)
  | None => None
  }
  let secondaryCategories = data->getCategories(1, yKey)
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

  open LogicUtilsTypes
  let metricType = switch xKey->getVariantValueFromString {
  | Payment_Success_Rate => Rate
  | Payment_Count => Volume
  | _ => Volume
  }

  let tooltipFormatter = tooltipFormatter(
    ~secondaryCategories,
    ~title="Payment Success Rate",
    ~metricType,
    ~comparison,
    ~currency,
  )
  {
    chartHeight: DefaultHeight,
    chartLeftSpacing: DefaultLeftSpacing,
    categories,
    data: lineGraphData,
    title: {
      text: "Auth Rate",
      style: {
        color: "white",
      },
    },
    yAxisMaxValue: Some(100),
    yAxisMinValue: Some(0),
    tooltipFormatter,
    yAxisFormatter: LineGraphUtils.lineGraphYAxisFormatter(
      ~statType=Rate,
      ~currency="",
      ~suffix="%",
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

let routingVolumeMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes

  let {data, xKey, yKey} = params
  let currency = params.currency->Option.getOr("")
  let comparison = switch params.comparison {
  | Some(val) => Some(val)
  | None => None
  }

  let secondaryCategories = data->getCategories(1, yKey)

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

  let metricType = switch xKey->getVariantValueFromString {
  | Payment_Success_Rate => Rate
  | Payment_Count => Volume
  | _ => Volume
  }

  let tooltipFormatter = tooltipFormatter(
    ~secondaryCategories,
    ~title="Volume",
    ~metricType,
    ~comparison,
    ~currency,
  )

  {
    chartHeight: DefaultHeight,
    chartLeftSpacing: DefaultLeftSpacing,
    categories,
    data: lineGraphData,
    title: {
      text: "Auth Rate",
      style: {
        color: "white",
      },
    },
    yAxisMaxValue: None,
    yAxisMinValue: Some(0),
    tooltipFormatter,
    yAxisFormatter: LineGraphUtils.lineGraphYAxisFormatter(
      ~statType=Volume,
      ~currency="",
      ~suffix="",
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
