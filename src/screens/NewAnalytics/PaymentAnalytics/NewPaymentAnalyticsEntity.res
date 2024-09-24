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
open PaymentsProcessedUtils
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

let paymentsProcessedTableEntity = EntityType.makeEntity(
  ~uri=``,
  ~getObjects,
  ~dataKey="queryData",
  ~defaultColumns=visibleColumns,
  ~requiredSearchFieldsList=[],
  ~allColumns=visibleColumns,
  ~getCell,
  ~getHeading,
)

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
