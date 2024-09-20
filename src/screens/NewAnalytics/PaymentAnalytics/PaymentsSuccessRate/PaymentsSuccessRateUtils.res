open LogicUtils

let getTimeBucket = (json: JSON.t): array<string> => {
  json
  ->getArrayFromJson([])
  ->Array.map(item => item->getDictFromJsonObject->getString("time_bucket", ""))
}

let getPaymentSuccessRateData = (json: JSON.t) => {
  json
  ->getArrayFromJson([])
  ->Array.map(item => item->getDictFromJsonObject->getInt("payments_success_rate", 0))
}

let paymentsSuccessRateMapper = (json: JSON.t): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  let categories = [
    "2024-08-13 18:30:00",
    "2024-08-14 18:30:00",
    "2024-08-15 18:30:00",
    "2024-08-16 18:30:00",
    "2024-08-17 18:30:00",
    "2024-08-18 18:30:00",
    "2024-08-19 18:30:00",
  ]
  //  getTimeBucket(json)
  let data = {
    showInLegend: false,
    name: "Series 1",
    data: [40, 35, 60, 70, 75, 65, 50],
    // getPaymentSuccessRateData(json),
    color: "#2f7ed8",
  }
  let title = {
    text: "Payments Success Rate",
  }
  {categories, data, title}
}
