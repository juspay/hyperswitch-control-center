open NewAnalyticsTypes
// Refunds Processed
let refundsProcessedEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#sessionized_refund_processed_amount],
  },
  title: "Refunds Processed",
  domain: #refunds,
}

let refundsProcessedChartEntity: chartEntity<
  LineGraphTypes.lineGraphPayload,
  LineGraphTypes.lineGraphOptions,
  JSON.t,
> = {
  getObjects: RefundsProcessedUtils.refundsProcessedMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}

let refundsProcessedTableEntity = {
  open RefundsProcessedUtils
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

// Refunds Success Rate
let refundsSuccessRateEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#sessionized_refund_success_rate],
  },
  title: "Refunds Success Rate",
  domain: #refunds,
}

let refundsSuccessRateChartEntity: chartEntity<
  LineGraphTypes.lineGraphPayload,
  LineGraphTypes.lineGraphOptions,
  JSON.t,
> = {
  getObjects: RefundsSuccessRateUtils.refundsSuccessRateMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}

// Successful Refunds Distribution
let successfulRefundsDistributionEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    groupBy: [#connector],
    metrics: [#sessionized_refund_count, #sessionized_refund_success_count],
  },
  title: "Successful Refunds Distribution By Connector",
  domain: #refunds,
}

let successfulRefundsDistributionChartEntity: chartEntity<
  BarGraphTypes.barGraphPayload,
  BarGraphTypes.barGraphOptions,
  JSON.t,
> = {
  getObjects: SuccessfulRefundsDistributionUtils.successfulRefundsDistributionMapper,
  getChatOptions: BarGraphUtils.getBarGraphOptions,
}

let successfulRefundsDistributionTableEntity = {
  open SuccessfulRefundsDistributionUtils
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

// Failed Refunds Distribution
let failedRefundsDistributionEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    groupBy: [#connector],
    metrics: [#sessionized_refund_count],
  },
  title: "Failed Refunds Distribution By Connector",
  domain: #refunds,
}

let failedRefundsDistributionChartEntity: chartEntity<
  BarGraphTypes.barGraphPayload,
  BarGraphTypes.barGraphOptions,
  JSON.t,
> = {
  getObjects: FailedRefundsDistributionUtils.failedRefundsDistributionMapper,
  getChatOptions: BarGraphUtils.getBarGraphOptions,
}

let failedRefundsDistributionTableEntity = {
  open FailedRefundsDistributionUtils
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
