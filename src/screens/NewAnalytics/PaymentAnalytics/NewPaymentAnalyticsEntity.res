open NewAnalyticsTypes
let paymentsProcessedEntity = {
  requestBodyConfig: {
    delta: false,
    metrics: [#payment_processed_amount],
  },
  title: "Payments Processed",
  domain: #payments,
  getObjects: NewPaymentAnalyticsUtils.getPaymentsProcessed,
  getChatOptions: NewPaymentAnalyticsUtils.getPaymentsProcessedOptions,
}
