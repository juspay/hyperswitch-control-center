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

let colMapper = queryData =>
  switch queryData {
  | PaymentSuccessRate => "payments_success_rate"
  | TimeBucket => "time_bucket"
  }

let paymentsSuccessRateMapper = (
  ~data: JSON.t,
  ~xKey: string,
  ~yKey: string,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  let categories = getCategories(data, yKey)
  let data = getLineGraphData(data, xKey)
  let title = {
    text: "Payments Success Rate",
  }
  {categories, data, title}
}

open NewAnalyticsTypes
let tabs = [
  {label: "Hourly", value: (#hour_wise: granularity :> string)},
  {label: "Daily", value: (#day_wise: granularity :> string)},
  {label: "Weekly", value: (#week_wise: granularity :> string)},
]

let defaulGranularity = {
  label: "Hourly",
  value: (#hour_wise: granularity :> string),
}
