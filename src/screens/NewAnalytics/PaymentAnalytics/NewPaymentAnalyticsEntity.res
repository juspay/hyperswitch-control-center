open NewAnalyticsTypes
// Payments Lifecycle
let paymentsLifeCycleEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#payment_processed_amount],
  },
  title: "Payments Lifecycle",
  domain: #payments,
}

let paymentsLifeCycleChartEntity: chartEntity<
  SankeyGraphTypes.sankeyPayload,
  SankeyGraphTypes.sankeyGraphOptions,
> = {
  getObjects: PaymentsLifeCycleUtils.paymentsLifeCycleMapper,
  getChatOptions: SankeyGraphUtils.getSankyGraphOptions,
}

// Payments Processed
let paymentsProcessedEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#payment_processed_amount],
  },
  title: "Payments Processed",
  domain: #payments,
}

let paymentsProcessedChartEntity: chartEntity<
  LineGraphTypes.lineGraphPayload,
  LineGraphTypes.lineGraphOptions,
> = {
  getObjects: PaymentsProcessedUtils.paymentsProcessedMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}

let paymentsProcessedTableEntity = {
  open PaymentsProcessedUtils
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

// Payments Success Rate
let paymentsSuccessRateEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#payment_success_rate],
  },
  title: "Payments Success Rate",
  domain: #payments,
}

let paymentsSuccessRateChartEntity: chartEntity<
  LineGraphTypes.lineGraphPayload,
  LineGraphTypes.lineGraphOptions,
> = {
  getObjects: PaymentsSuccessRateUtils.paymentsSuccessRateMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}

// Payments Distribution
let successfulPaymentsDistributionEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#payment_success_rate],
  },
  title: "Payments Distribution",
  domain: #payments,
}

let successfulPaymentsDistributionChartEntity: chartEntity<
  BarGraphTypes.barGraphPayload,
  BarGraphTypes.barGraphOptions,
> = {
  getObjects: SuccessfulPaymentsDistributionUtils.successfulPaymentsDistributionMapper,
  getChatOptions: BarGraphUtils.getBarGraphOptions,
}

let successfulPaymentsDistributionTableEntity = {
  open SuccessfulPaymentsDistributionUtils
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
