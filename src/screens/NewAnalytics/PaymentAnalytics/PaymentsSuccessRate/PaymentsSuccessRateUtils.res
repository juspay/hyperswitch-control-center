open NewPaymentAnalyticsUtils

let getPaymentQueryDataString = queryData =>
  switch queryData {
  | #PaymentSuccessRate => "payments_success_rate"
  | #TimeBucket => "time_bucket"
  }

let paymentsSuccessRateMapper = (json: JSON.t): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  let categories = getCategories(json)
  let data = getData(json, getPaymentQueryDataString(#PaymentSuccessRate))
  let title = {
    text: "Payments Success Rate",
  }
  {categories, data, title}
}
