open NewPaymentAnalyticsUtils
open PaymentsSuccessRateTypes
open LogicUtils

let getMetaData = json => {
  json
  ->getArrayFromJson([])
  ->getValueFromArray(0, JSON.Encode.array([]))
  ->getDictFromJsonObject
  ->getArrayFromDict("metaData", [])
  ->getValueFromArray(0, JSON.Encode.null)
  ->getDictFromJsonObject
}

let graphTitle = json => getMetaData(json)->getInt("payments_success_rate", 0)->Int.toString

let getPaymentQueryDataString = queryData =>
  switch queryData {
  | PaymentSuccessRate => "payments_success_rate"
  | TimeBucket => "time_bucket"
  }

let paymentsSuccessRateMapper = (json: JSON.t): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  let categories = getCategories(json, getPaymentQueryDataString(TimeBucket))
  let data = getLineGraphData(json, getPaymentQueryDataString(PaymentSuccessRate))
  let title = {
    text: "Payments Success Rate",
  }
  {categories, data, title}
}
