open NewAnalyticsTypes
let paymentsProcessed: entity<LineGraphTypes.lineGraphPayload, LineGraphTypes.lineGraphOptions> = {
  requestBodyConfig: {
    delta: false,
    metrics: [#payment_processed_amount],
  },
  title: "Payments Processed",
  domain: #payments,
  getObjects: OverViewAnalyticsUtils.paymentsProcessedMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}
