open NewPaymentAnalyticsUtils
open LogicUtils
open PaymentsSuccessRateTypes

let getStringFromVariant = value => {
  switch value {
  | Successful_Payments => "successful_payments"
  | Successful_Payments_Without_Smart_Retries => "successful_payments_without_smart_retries"
  | Total_Payments => "total_payments"
  | Payments_Success_Rate => "payments_success_rate"
  | Payments_Success_Rate_Without_Smart_Retries => "payments_success_rate_without_smart_retries"
  | Total_Success_Rate => "total_success_rate"
  | Total_Success_Rate_Without_Smart_Retries => "total_success_rate_without_smart_retries"
  | Time_Bucket => "time_bucket"
  }
}

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

let getMetaDataMapper = key => {
  switch key {
  | "payments_success_rate" => "total_success_rate"
  | "payments_success_rate_without_smart_retries" => "total_success_rate_without_smart_retries"
  | _ => ""
  }
}
