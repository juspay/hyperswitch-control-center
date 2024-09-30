open NewPaymentAnalyticsUtils
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
let tabs = [{label: "Daily", value: (#G_ONEDAY: granularity :> string)}]

let defaulGranularity = {
  label: "Hourly",
  value: (#G_ONEDAY: granularity :> string),
}
