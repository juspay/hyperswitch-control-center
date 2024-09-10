open NewAnalyticsTypes

let paymentsProcessedEntity = {
  requestBodyConfig: {
    delta: false,
    groupBy: [#currency],
    metrics: [#payment_processed_amount, #payment_success_rate],
  },
  title: "Payments Processed",
  domain: #payments,
}
