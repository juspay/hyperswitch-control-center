open NewAnalyticsTypes
let paymentsProcessedEntity: entity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#payment_processed_amount],
  },
  title: "Payments Processed",
  domain: #payments,
}

let paymentsProcessedChartEntity: chartEntity<
  LineGraphTypes.lineGraphPayload,
  LineGraphTypes.lineGraphOptions,
> = {
  getObjects: OverViewAnalyticsUtils.paymentsProcessedMapper,
  getChatOptions: LineGraphUtils.getLineGraphOptions,
}
