open InsightsTypes
// OverView section
let overviewSectionEntity: moduleEntity = {
  requestBodyConfig: {
    delta: true,
    metrics: [],
  },
  title: "OverView Section",
  domain: #payments,
}

// Payments Lifecycle
let paymentsLifeCycleEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#sessionized_payment_processed_amount],
  },
  title: "Payments Lifecycle",
  domain: #payments,
}

let paymentsLifeCycleChartEntity: chartEntity<
  SankeyGraphTypes.sankeyPayload,
  SankeyGraphTypes.sankeyGraphOptions,
  PaymentsLifeCycleTypes.paymentLifeCycle,
> = {
  getObjects: PaymentsLifeCycleUtils.paymentsLifeCycleMapper,
  getChatOptions: SankeyGraphUtils.getSankyGraphOptions,
}

// Payments Processed
let paymentsProcessedEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#sessionized_payment_processed_amount],
  },
  title: "Payments Processed",
  domain: #payments,
}

let paymentsProcessedChartEntity: chartEntity<
  LineGraphTypes.lineGraphPayload,
  LineGraphTypes.lineGraphOptions,
  JSON.t,
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
    metrics: [#sessionized_payments_success_rate],
  },
  title: "Payments Success Rate",
  domain: #payments,
}

let paymentsSuccessRateChartEntity: chartEntity<
  LineGraphTypes.lineGraphPayload,
  LineGraphTypes.lineGraphOptions,
  JSON.t,
> = {
  getObjects: PaymentsSuccessRateUtils.paymentsSuccessRateMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}

// Successful Payments Distribution
let successfulPaymentsDistributionEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#payments_distribution],
  },
  title: "Successful Payments Distribution",
  domain: #payments,
}

let successfulPaymentsDistributionChartEntity: chartEntity<
  BarGraphTypes.barGraphPayload,
  BarGraphTypes.barGraphOptions,
  JSON.t,
> = {
  getObjects: SuccessfulPaymentsDistributionUtils.successfulPaymentsDistributionMapper,
  getChatOptions: payload => BarGraphUtils.getBarGraphOptions(payload),
}

let successfulPaymentsDistributionTableEntity = {
  open SuccessfulPaymentsDistributionUtils
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

// Failed Payments Distribution
let failedPaymentsDistributionEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#payments_distribution],
  },
  title: "Failed Payments Distribution",
  domain: #payments,
}

let failedPaymentsDistributionChartEntity: chartEntity<
  BarGraphTypes.barGraphPayload,
  BarGraphTypes.barGraphOptions,
  JSON.t,
> = {
  getObjects: FailedPaymentsDistributionUtils.failedPaymentsDistributionMapper,
  getChatOptions: payload => BarGraphUtils.getBarGraphOptions(payload),
}

let failedPaymentsDistributionTableEntity = {
  open FailedPaymentsDistributionUtils
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

// Payments Failure Reasons
let failureReasonsEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#failure_reasons],
    groupBy: [#error_reason],
  },
  title: "Failure Reasons ",
  domain: #payments,
}

let failureReasonsTableEntity = {
  open FailureReasonsPaymentsUtils
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
