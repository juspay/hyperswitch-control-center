open RetriesComparisionAnalyticsTypes
open LogicUtils

let getStringFromVariant = (col: retryAttemptsTrendCols): string => {
  switch col {
  | TimeBucket => (#time_bucket: retryAttemptsTrendKeys :> string)
  | SuccessRate => (#success_rate: retryAttemptsTrendKeys :> string)
  | HadRetryAttempt => (#had_retry_attempt: retryAttemptsTrendKeys :> string)
  | StaticRetries => (#static_retries: retryAttemptsTrendKeys :> string)
  | SmartRetries => (#smart_retries: retryAttemptsTrendKeys :> string)
  }
}

type scatterPoint = {
  x: int,
  y: float,
}

let yAxisFormatter = LineScatterGraphUtils.lineGraphYAxisFormatter(
  ~statType=AmountWithSuffix,
  ~currency="",
  ~suffix="%",
  ~scaleFactor=1.0,
)

let title: LineScatterGraphTypes.title = {
  text: "",
}

let smartRetriesComparisionMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
): LineScatterGraphTypes.lineScatterGraphPayload => {
  open InsightsUtils
  let {data, yKey} = params

  let icon = params.icon->Option.getOr("")

  let successRates = []
  let scatterData = []
  let helperScatterData = []

  let categories = getCategories([data]->Identity.genericTypeToJson, 0, yKey)

  data
  ->getArrayFromJson([])
  ->Array.forEachWithIndex((item, index) => {
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
    name: "Success Rate",
    data: successRates,
    color: "#6BBDF6",
  }

  let label = params.title->Option.getOr("")

  let scatterGraphData: LineScatterGraphTypes.dataObj = {
    \"type": "scatter",
    showInLegend: true,
    name: `${label} attempts`,
    data: scatterData,
    color: "#EBD35C",
  }

  let helperScatterGraphData: LineScatterGraphTypes.dataObj = {
    \"type": "line",
    showInLegend: false,
    name: `${label} attempts`,
    data: helperScatterData,
    color: "transparent",
  }

  open LogicUtilsTypes

  let tooltipFormatter = LineScatterGraphUtils.tooltipFormatter(
    ~title=`${label}`,
    ~metricType=Rate,
    ~svgIconUrl=icon,
  )

  let valueFormatter = (
    @this
    this => {
      open LineScatterGraphTypes
      let icon = switch this.name {
      | "Static Retries attempts" => "/assets/icons/static-retry.svg"
      | "Smart Retries attempts" => "/assets/icons/smart-retry.svg"
      | _ => ""
      }

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
    symbol: `url(${icon})`,
  }
}
