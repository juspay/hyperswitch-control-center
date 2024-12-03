open NewAnalyticsTypes
// Successful SmartRetry Distribution
let successfulSmartRetryDistributionEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#payments_distribution],
  },
  title: "Successful Distribution of Smart Retry Payments",
  domain: #payments,
}

let successfulSmartRetryDistributionChartEntity: chartEntity<
  BarGraphTypes.barGraphPayload,
  BarGraphTypes.barGraphOptions,
  JSON.t,
> = {
  getObjects: SuccessfulSmartRetryDistributionUtils.successfulSmartRetryDistributionMapper,
  getChatOptions: BarGraphUtils.getBarGraphOptions,
}

let successfulSmartRetryDistributionTableEntity = {
  open SuccessfulSmartRetryDistributionUtils
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects,
    ~dataKey="queryData",
    ~defaultColumns=[],
    ~requiredSearchFieldsList=[],
    ~allColumns=[],
    ~getCell,
    ~getHeading,
  )
}

// Failed SmartRetry Distribution
let failedSmartRetryDistributionEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#payments_distribution],
  },
  title: "Failed Distribution of Smart Retry Payments",
  domain: #payments,
}

let failedSmartRetryDistributionChartEntity: chartEntity<
  BarGraphTypes.barGraphPayload,
  BarGraphTypes.barGraphOptions,
  JSON.t,
> = {
  getObjects: FailureSmartRetryDistributionUtils.failedSmartRetryDistributionMapper,
  getChatOptions: BarGraphUtils.getBarGraphOptions,
}

let failedSmartRetryDistributionTableEntity = {
  open FailureSmartRetryDistributionUtils
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects,
    ~dataKey="queryData",
    ~defaultColumns=[],
    ~requiredSearchFieldsList=[],
    ~allColumns=[],
    ~getCell,
    ~getHeading,
  )
}
