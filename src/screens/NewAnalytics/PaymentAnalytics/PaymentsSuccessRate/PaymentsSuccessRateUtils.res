// open PaymentsSuccessRateTypes

let getTimeBucket = (json: JSON.t): array<string> => {
  open LogicUtils
  json
  ->getArrayFromJson([])
  ->Array.map(item => item->getDictFromJsonObject->getString("time_bucket", ""))
}

let getPaymentSuccessRateData = (json: JSON.t) => {
  open LogicUtils
  json
  ->getArrayFromJson([])
  ->Array.map(item => item->getDictFromJsonObject->getInt("payments_success_rate", 0))
}

let paymentsSuccessRateMapper = (json: JSON.t): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  let categories = getTimeBucket(json)
  let data = {
    showInLegend: false,
    name: "Series 1",
    data: getPaymentSuccessRateData(json),
    color: "#2f7ed8",
  }
  let title = {
    text: "Payments Success Rate",
  }
  {categories, data, title}
}
