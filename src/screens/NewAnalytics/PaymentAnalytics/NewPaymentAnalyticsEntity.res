open NewAnalyticsTypes
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
  getObjects: NewPaymentAnalyticsUtils.paymentsLifeCycleMapper,
  getChatOptions: SankeyGraphUtils.getSankyGraphOptions,
}
