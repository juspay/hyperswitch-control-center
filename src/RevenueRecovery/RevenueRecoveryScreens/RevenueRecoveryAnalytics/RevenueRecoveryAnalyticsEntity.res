open InsightsTypes
open BarGraphTypes

// Auth Rate Summary
let authRateSummaryEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [],
  },
  title: "Auth Rate Summary",
  domain: #payments,
}

let authRateSummaryChartEntity: chartEntity<barGraphPayload, barGraphOptions, JSON.t> = {
  getObjects: AuthRateSummaryUtils.authRateSummaryMapper,
  getChatOptions: AuthRateSummaryUtils.getAuthRateSummaryOptions,
}
