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

// Retry Strategies
let retryStrategiesEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [],
  },
  title: "Retry Strategies",
  domain: #payments,
}

// Overall Retry Strategy
let overallRetryStrategysEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [],
  },
  title: "Overall Retry Strategy Comparison",
  domain: #payments,
}

// Retries Comparision
let retriesComparisionEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [],
  },
  title: "Static vs Smart Retries",
  domain: #payments,
}

// Smart Retry Strategy
let smartRetryStrategyEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [],
  },
  title: "Smart Retry Strategy",
  domain: #payments,
}
