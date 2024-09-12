open NewAnalyticsTypes
let paymentsProcessedEntity: entity<LineGraphTypes.seriresType, RescriptCore.JSON.t> = {
  requestBodyConfig: {
    delta: false,
    metrics: [#payment_processed_amount],
  },
  title: "Payments Processed",
  domain: #payments,
  getObjects: NewPaymentAnalyticsUtils.getPaymentsProcessed,
  getChatOptions: NewPaymentAnalyticsUtils.getPaymentsProcessedOptions,
}

// Need to be changed later
let paymentLifeCycleEntity: entity<
  SankeyGraphTypes.sankeyPayload,
  SankeyGraphTypes.sankeyGraphOptions,
> = {
  requestBodyConfig: {
    delta: false,
    metrics: [#payment_processed_amount],
  },
  title: "Payments Lifecycle",
  domain: #payments,
  getObjects: NewPaymentAnalyticsUtils.transformPaymentLifeCycle,
  getChatOptions: SankeyGraphUtils.getSankyGraphOptions,
}
