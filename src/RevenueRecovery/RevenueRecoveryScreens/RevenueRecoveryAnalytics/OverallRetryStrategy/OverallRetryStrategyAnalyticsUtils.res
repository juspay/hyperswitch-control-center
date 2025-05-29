open OverallRetryStrategyAnalyticsTypes
open LogicUtils

let getStringFromVariant = value => {
  switch value {
  | TimeBucket => (#time_bucket: retryTrendKeys :> string)
  | Transactions => (#transactions: retryTrendKeys :> string)
  | StaticRetrySuccessRate => (#static_retry_success_rate: retryTrendKeys :> string)
  | SmartRetrySuccessRate => (#smart_retry_success_rate: retryTrendKeys :> string)
  | SmartRetryBoosterSuccessRate => (#smart_retry_booster_success_rate: retryTrendKeys :> string)
  }
}

let itemToRetryTrendEntryMapper: Dict.t<JSON.t> => retryTrendEntry = dict => {
  {
    time_bucket: dict->getString(TimeBucket->getStringFromVariant, ""),
    transactions: dict->getFloat(Transactions->getStringFromVariant, 0.0),
    static_retry_success_rate: dict->getFloat(StaticRetrySuccessRate->getStringFromVariant, 0.0),
    smart_retry_success_rate: dict->getFloat(SmartRetrySuccessRate->getStringFromVariant, 0.0),
    smart_retry_booster_success_rate: dict->getFloat(
      SmartRetryBoosterSuccessRate->getStringFromVariant,
      0.0,
    ),
  }
}

open LineAndColumnGraphTypes
let customTooltipFormatter = (~title) => {
  (
    @this
    (this: pointFormatter) => {
      let title = `<div style="font-size: 16px; font-weight: bold;">${title}</div>`

      let defaultValue = {color: "", x: "", y: 0.0, point: {index: 0}, key: "", series: {name: ""}}
      let primaryPoint = this.points->getValueFromArray(0, defaultValue)
      let line1Point = this.points->getValueFromArray(1, defaultValue)
      let line2Point = this.points->getValueFromArray(2, defaultValue)
      let line3Point = this.points->getValueFromArray(3, defaultValue)

      let getRowsHtml = (~iconColor, ~value, ~metricType, ~comparisionComponent="", ~name="") => {
        let formattedValue = LogicUtils.valueFormatter(value, metricType)
        let key = name
        `<div style="display: flex; align-items: center;">
            <div style="width: 10px; height: 10px; background-color:${iconColor}; border-radius:3px;"></div>
            <div style="margin-left: 8px;">${key}${comparisionComponent}</div>
            <div style="flex: 1; text-align: right; font-weight: bold;margin-left: 50px;">${formattedValue}</div>
        </div>`
      }

      let tableItems =
        [
          getRowsHtml(
            ~iconColor=primaryPoint.color,
            ~value=primaryPoint.y,
            ~name=primaryPoint.series.name,
            ~metricType=Amount,
          ),
          getRowsHtml(
            ~iconColor=line1Point.color,
            ~value=line1Point.y,
            ~name=line1Point.series.name,
            ~metricType=Rate,
          ),
          getRowsHtml(
            ~iconColor=line2Point.color,
            ~value=line2Point.y,
            ~name=line2Point.series.name,
            ~metricType=Rate,
          ),
          getRowsHtml(
            ~iconColor=line3Point.color,
            ~value=line3Point.y,
            ~name=line3Point.series.name,
            ~metricType=Rate,
          ),
        ]->Array.joinWith("")

      let content = `
          <div style=" 
          padding:5px 12px;
          display:flex;
          flex-direction:column;
          justify-content: space-between;
          gap: 7px;">
              ${title}
              <div style="
                margin-top: 5px;
                display:flex;
                flex-direction:column;
                gap: 8px;">
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
  )->asTooltipPointFormatter
}

let retryStrategiesMapper = (~params: InsightsTypes.getObjects<JSON.t>) => {
  open InsightsUtils
  let {data, xKey} = params

  let transactions = []
  let staticRetries = []
  let smartRetries = []
  let smartRetryBoosters = []

  data
  ->getArrayFromJson([])
  ->Array.forEach(item => {
    let itemObject = item->getDictFromJsonObject->itemToRetryTrendEntryMapper

    transactions->Array.push(itemObject.transactions)
    staticRetries->Array.push(itemObject.static_retry_success_rate)
    smartRetries->Array.push(itemObject.smart_retry_success_rate)
    smartRetryBoosters->Array.push(itemObject.smart_retry_booster_success_rate)
  })

  let categories = [data]->JSON.Encode.array->getCategories(0, xKey)

  let style: LineAndColumnGraphTypes.style = {
    fontFamily: LineAndColumnGraphUtils.fontFamily,
    color: LineAndColumnGraphUtils.darkGray,
    fontSize: "14px",
  }

  {
    titleObj: {
      chartTitle: {
        text: "",
        align: "left",
        x: 10,
        y: 10,
        style: {
          fontSize: "14px",
          color: LineAndColumnGraphUtils.darkGray,
          fontWeight: "600",
        },
      },
      xAxisTitle: {
        text: "",
        style,
      },
      yAxisTitle: {
        text: "Volume of Transactions",
        style,
        x: -10,
        y: -10,
      },
      oppositeYAxisTitle: {
        text: "Success Rate",
        style,
        x: 10,
      },
    },
    categories,
    data: [
      {
        showInLegend: true,
        name: "Transactions Monitored",
        \"type": "column",
        data: transactions,
        color: "#91D9CE",
        yAxis: 1,
      },
      {
        showInLegend: true,
        name: "Static Retries",
        \"type": "line",
        data: staticRetries,
        color: "#C27AFF",
        yAxis: 0,
      },
      {
        showInLegend: true,
        name: "Smart Retries",
        \"type": "line",
        data: smartRetries,
        color: "#6BBDF6",
        yAxis: 0,
      },
      {
        showInLegend: true,
        name: "Smart Retry Booster",
        \"type": "line",
        data: smartRetryBoosters,
        color: "#EBD35C",
        yAxis: 0,
      },
    ],
    tooltipFormatter: customTooltipFormatter(~title="Overall Retry Strategy"),
    yAxisFormatter: LineAndColumnGraphUtils.lineColumnGraphYAxisFormatter(
      ~statType=AmountWithSuffix,
      ~currency="",
      ~suffix="%",
    ),
    minValY2: 0,
    maxValY2: 100,
    legend: {
      useHTML: true,
      labelFormatter: LineAndColumnGraphUtils.labelFormatter,
      symbolPadding: -7,
      symbolWidth: 0,
      symbolHeight: 0,
      symbolRadius: 4,
      align: "left",
      verticalAlign: "top",
      floating: false,
      itemDistance: 30,
      margin: 30,
    },
  }
}
