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
  getChatOptions: BarGraphUtils.getBarGraphOptions,
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
  getChatOptions: BarGraphUtils.getBarGraphOptions,
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

// Split Payments Section
let splitPaymentsSectionEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#sessionized_payments_distribution],
  },
  title: "Split Payments",
  domain: #payments,
}

let splitPaymentsSectionTableEntity = {
  open SplitPaymentsSectionUtils
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

// Platform Fees Over Time
let platformFeesOverTimeEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#sessionized_total_platform_fees],
  },
  title: "Platform Fees Over Time",
  domain: #payments,
}

let platformFeesOverTimeChartEntity: chartEntity<
  LineGraphTypes.lineGraphPayload,
  LineGraphTypes.lineGraphOptions,
  JSON.t,
> = {
  getObjects: PlatformFeesOverTimeUtils.platformFeesOverTimeMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}

let platformFeesOverTimeTableEntity = {
  open PlatformFeesOverTimeUtils
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

// Transfer Amount Over Time
let transferAmountOverTimeEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#sessionized_total_transfer_amount],
  },
  title: "Transfer Amount Over Time",
  domain: #payments,
}

let transferAmountOverTimeChartEntity: chartEntity<
  LineGraphTypes.lineGraphPayload,
  LineGraphTypes.lineGraphOptions,
  JSON.t,
> = {
  getObjects: TransferAmountOverTimeUtils.transferAmountOverTimeMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}

let transferAmountOverTimeTableEntity = {
  open TransferAmountOverTimeUtils
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

// Platform Fees by Connector
let platformFeesByConnectorEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#sessionized_total_platform_fees],
  },
  title: "Platform Fees by Connector",
  domain: #payments,
}

let platformFeesByConnectorTableEntity = {
  open PlatformFeesByConnectorUtils
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

// Platform Fee Rate by Connector
let platformFeeRateByConnectorEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#sessionized_avg_platform_fee_rate],
  },
  title: "Platform Fee Rate by Connector",
  domain: #payments,
}

let platformFeeRateByConnectorChartEntity: chartEntity<
  BarGraphTypes.barGraphPayload,
  BarGraphTypes.barGraphOptions,
  JSON.t,
> = {
  getObjects: PlatformFeeRateByConnectorUtils.platformFeeRateByConnectorMapper,
  getChatOptions: BarGraphUtils.getBarGraphOptions,
}

let platformFeeRateByConnectorTableEntity = {
  open PlatformFeeRateByConnectorUtils
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

// Fees by Charge Type
let feesByChargeTypeEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#sessionized_total_platform_fees],
  },
  title: "Fees by Charge Type",
  domain: #payments,
}

let feesByChargeTypeChartEntity: chartEntity<
  BarGraphTypes.barGraphPayload,
  BarGraphTypes.barGraphOptions,
  JSON.t,
> = {
  getObjects: FeesByChargeTypeUtils.feesByChargeTypeMapper,
  getChatOptions: BarGraphUtils.getBarGraphOptions,
}

let feesByChargeTypeTableEntity = {
  open FeesByChargeTypeUtils
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
