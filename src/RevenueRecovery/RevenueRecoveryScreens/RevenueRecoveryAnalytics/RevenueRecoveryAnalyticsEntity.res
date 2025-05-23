open InsightsTypes
open BarGraphTypes

// Overall Retry Strategy
let overallRetryStrategysEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [],
  },
  title: "Overall Retry Strategy Comparison",
  domain: #payments,
}

open LineAndColumnGraphTypes
let overallRetryStrategyChartEntity: chartEntity<
  lineColumnGraphPayload,
  lineColumnGraphOptions,
  JSON.t,
> = {
  getObjects: OverallRetryStrategyAnalyticsUtils.retryStrategiesMapper,
  getChatOptions: LineAndColumnGraphUtils.getLineColumnGraphOptions,
}
