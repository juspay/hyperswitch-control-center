open NewAnalyticsTypes

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
