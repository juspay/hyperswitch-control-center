open NewAnalyticsTypes
// Smart Retry Payments Processed
let smartRetryPaymentsProcessedEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#sessionized_payment_processed_amount],
  },
  title: "Smart Retry Payments Processed",
  domain: #payments,
}

let smartRetryPaymentsProcessedChartEntity: chartEntity<
  LineGraphTypes.lineGraphPayload,
  LineGraphTypes.lineGraphOptions,
  JSON.t,
> = {
  getObjects: SmartRetryPaymentsProcessedUtils.smartRetryPaymentsProcessedMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}

let smartRetryPaymentsProcessedTableEntity = {
  open SmartRetryPaymentsProcessedUtils
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects,
    ~dataKey="queryData",
    ~defaultColumns=visibleColumns,
    ~requiredSearchFieldsList=[],
    ~allColumns=visibleColumns,
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
