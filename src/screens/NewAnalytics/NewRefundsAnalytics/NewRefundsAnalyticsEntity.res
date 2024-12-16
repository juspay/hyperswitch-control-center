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

// Refunds Reasons
let refundsReasonsEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#sessionized_refund_reason],
    groupBy: [#refund_reason, #connector],
  },
  title: "Refund Reasons",
  domain: #refunds,
}

let refundsReasonsTableEntity = {
  open RefundsReasonsUtils
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
