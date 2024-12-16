open NewAnalyticsTypes
// OverView section
let overviewSectionEntity: moduleEntity = {
  requestBodyConfig: {
    delta: true,
    metrics: [],
  },
  title: "OverView Section",
  domain: #refunds,
}

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
