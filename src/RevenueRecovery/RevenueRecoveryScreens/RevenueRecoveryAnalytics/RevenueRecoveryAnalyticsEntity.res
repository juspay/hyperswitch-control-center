open InsightsTypes

// Auth Rate Summary
let authRateSummaryEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [],
  },
  title: "Auth Rate Summary",
  domain: #payments,
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
