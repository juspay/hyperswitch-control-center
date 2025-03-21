open NewAnalyticsUtils
open RefundsSuccessRateTypes

let getStringFromVariant = value => {
  switch value {
  | Refund_Success_Rate => "refund_success_rate"
  | Total_Refund_Success_Rate => "total_refund_success_rate"
  | Time_Bucket => "time_bucket"
  }
}

let getVariantValueFromString = value => {
  switch value {
  | "refund_success_rate" => Refund_Success_Rate
  | "total_refund_success_rate" => Total_Refund_Success_Rate
  | "time_bucket" | _ => Time_Bucket
  }
}

let refundsSuccessRateMapper = (
  ~params: NewAnalyticsTypes.getObjects<JSON.t>,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  let {data, xKey, yKey} = params
  let comparison = switch params.comparison {
  | Some(val) => Some(val)
  | None => None
  }
  let primaryCategories = data->getCategories(0, yKey)
  let secondaryCategories = data->getCategories(1, yKey)

  let lineGraphData = data->getLineGraphData(~xKey, ~yKey)

  let title = {
    text: "Refunds Success Rate",
  }

  {
    categories: primaryCategories,
    data: lineGraphData,
    title,
    yAxisMaxValue: 100->Some,
    tooltipFormatter: tooltipFormatter(
      ~secondaryCategories,
      ~title="Refunds Success Rate",
      ~metricType=Rate,
      ~comparison,
    ),
    yAxisFormatter: None,
  }
}

open NewAnalyticsTypes
let tabs = [{label: "Daily", value: (#G_ONEDAY: granularity :> string)}]

let defaulGranularity = {
  label: "Hourly",
  value: (#G_ONEDAY: granularity :> string),
}
