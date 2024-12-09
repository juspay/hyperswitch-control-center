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
