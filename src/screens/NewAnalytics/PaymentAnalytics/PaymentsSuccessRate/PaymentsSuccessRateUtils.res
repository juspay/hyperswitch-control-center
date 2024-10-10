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
  let primaryCategories = data->getCategories(0, yKey)
  let secondaryCategories = data->getCategories(1, yKey)

  let lineGraphData =
    data
    ->getArrayFromJson([])
    ->Array.mapWithIndex((item, index) => {
      let name = NewAnalyticsUtils.getLabelName(~key=yKey, ~index, ~points=item)
      let color = index->getColor
      getLineGraphObj(~array=item->getArrayFromJson([]), ~key=xKey, ~name, ~color)
    })
  let title = {
    text: "Payments Success Rate",
  }
  {
    categories: primaryCategories,
    data: lineGraphData,
    title,
    tooltipFormatter: tooltipFormatter(
      ~secondaryCategories,
      ~title="Payments Success Rate",
      ~metricType=Rate,
    ),
  }
}

open NewAnalyticsTypes
let tabs = [{label: "Daily", value: (#G_ONEDAY: granularity :> string)}]

let defaulGranularity = {
  label: "Hourly",
  value: (#G_ONEDAY: granularity :> string),
}
