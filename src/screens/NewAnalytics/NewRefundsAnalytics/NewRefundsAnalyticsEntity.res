open NewAnalyticsTypes
// Refunds Processed
let refundsProcessedEntity: moduleEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#sessionized_refund_processed_amount, #sessionized_refund_success_count],
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
