open SmartRetryStrategyAnalyticsTypes

let getStringFromVariant = (variant: smartRetryStatergyCols): string => {
  switch variant {
  | TimeBucket => (#time_bucket: responseKeys :> string)
  | SuccessRate => (#success_rate: responseKeys :> string)
  | HadRetryAttempt => (#had_retry_attempt: responseKeys :> string)
  | GroupId => (#group_id: responseKeys :> string)
  | GroupName => (#group_name: responseKeys :> string)
  | SuccessRateSeries => (#success_rate_series: responseKeys :> string)
  | Category => (#category: responseKeys :> string)
  | OverallSuccessRate => (#overall_success_rate: responseKeys :> string)
  | GroupwiseData => (#groupwise_data: responseKeys :> string)
  | ErrorCategoryAnalysis => (#error_category_analysis: responseKeys :> string)
  }
}

open LogicUtils

let yAxisFormatter = LineScatterGraphUtils.lineGraphYAxisFormatter(
  ~statType=AmountWithSuffix,
  ~currency="",
  ~suffix="%",
  ~scaleFactor=1.0,
)

let title: LineScatterGraphTypes.title = {
  text: "",
}

type scatterPoint = {
  x: int,
  y: float,
}

let smartRetriesMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
): LineScatterGraphTypes.lineScatterGraphPayload => {
  open InsightsUtils
  let {data, yKey, xKey} = params

  let dataDict = data->getDictFromJsonObject

  let titleName = dataDict->getString(GroupName->getStringFromVariant, "")
  let list = dataDict->getArrayFromDict(SuccessRateSeries->getStringFromVariant, [])

  let successRates = []
  let scatterData = []
  let helperScatterData = []

  let categories = getCategories([list]->Identity.genericTypeToJson, 0, yKey)

  list->Array.forEachWithIndex((item, index) => {
    let itemDict = item->getDictFromJsonObject

    if itemDict->getBool(HadRetryAttempt->getStringFromVariant, false) {
      scatterData->Array.push(
        {
          x: index,
          y: 0.0,
        }->Identity.genericTypeToJson,
      )

      helperScatterData->Array.push(
        {
          x: index,
          y: itemDict->getFloat(SuccessRate->getStringFromVariant, 0.0),
        }->Identity.genericTypeToJson,
      )
    }

    successRates->Array.push(
      {
        x: index,
        y: itemDict->getFloat(SuccessRate->getStringFromVariant, 0.0),
      }->Identity.genericTypeToJson,
    )
  })

  let lineGraphData: LineScatterGraphTypes.dataObj = {
    \"type": "line",
    showInLegend: true,
    name: `${titleName} (S.R)`,
    data: successRates,
    color: "#6BBDF6",
  }

  let scatterGraphData: LineScatterGraphTypes.dataObj = {
    \"type": "scatter",
    showInLegend: true,
    name: "Smart Retry attempts",
    data: scatterData,
    color: "#AE99FF",
  }

  let helperScatterGraphData: LineScatterGraphTypes.dataObj = {
    \"type": "line",
    showInLegend: false,
    name: "Smart Retry attempts",
    data: helperScatterData,
    color: "transparent",
  }

  open LogicUtilsTypes

  let tooltipFormatter = LineScatterGraphUtils.tooltipFormatter(
    ~title="Smart Retries",
    ~metricType=Rate,
    ~svgIconUrl=xKey,
  )

  let valueFormatter = (
    @this
    this => {
      open LineScatterGraphTypes
      let icon = this.name == "Smart Retry attempts" ? "/icons/smart-retry.svg" : ""

      icon->String.length > 0
        ? `<div style="display: flex; align-items: center;margin-bottom:15px;">
              <img src=${icon} alt="Smart Retry Icon" width="16" height="16" style="margin-right: 5px;" />
              <div style="margin-left: 0px;">${this.name}</div>
            </div>`
        : `<div style="display: flex; align-items: center;margin-bottom:15px;">
        <div style="width: 13px; height: 13px; background-color:${this.color}; border-radius:3px;"></div>
        <div style="margin-left: 5px;">${this.name}</div>
    </div>`
    }
  )->LineScatterGraphTypes.asLegendsFormatter

  {
    chartHeight: DefaultHeight,
    chartLeftSpacing: DefaultLeftSpacing,
    categories,
    data: [helperScatterGraphData, lineGraphData, scatterGraphData],
    title,
    yAxisMaxValue: Some(100),
    yAxisMinValue: Some(0),
    tooltipFormatter,
    yAxisFormatter,
    legend: {
      useHTML: true,
      labelFormatter: valueFormatter,
      align: "left",
      verticalAlign: "top",
      y: -10,
    },
    symbol: `url(${xKey})`,
  }
}

let overallSRMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  open InsightsUtils
  let {data, xKey, yKey} = params

  let primaryCategories = [data]->Identity.genericTypeToJson->getCategories(0, yKey)

  let lineGraphData = [data]->Identity.genericTypeToJson->getLineGraphData(~xKey, ~yKey)

  open LogicUtilsTypes

  let tooltipFormatter = tooltipFormatter(
    ~secondaryCategories=[],
    ~title=`${params.title->Option.getOr("")} Success Rate`,
    ~metricType=Rate,
  )

  {
    chartHeight: DefaultHeight,
    chartLeftSpacing: DefaultLeftSpacing,
    categories: primaryCategories,
    data: lineGraphData,
    title: {
      text: "",
    },
    yAxisMaxValue: None,
    yAxisMinValue: Some(0),
    tooltipFormatter,
    yAxisFormatter: LineGraphUtils.lineGraphYAxisFormatter(
      ~statType=AmountWithSuffix,
      ~currency="",
      ~suffix="%",
    ),
    legend: {
      useHTML: true,
      labelFormatter: LineGraphUtils.valueFormatter,
    },
  }
}
