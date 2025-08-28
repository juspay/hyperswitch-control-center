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

let getVariantValueFromString = value => {
  switch value {
  | "successful_payments" => Successful_Payments
  | "successful_payments_without_smart_retries" => Successful_Payments_Without_Smart_Retries
  | "total_payments" => Total_Payments
  | "payments_success_rate" => Payments_Success_Rate
  | "payments_success_rate_without_smart_retries" => Payments_Success_Rate_Without_Smart_Retries
  | "total_success_rate" => Total_Success_Rate
  | "total_success_rate_without_smart_retries" => Total_Success_Rate_Without_Smart_Retries
  | "time_bucket" | _ => Time_Bucket
  }
}

let paymentsSuccessRateMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  open InsightsUtils
  let {data, xKey, yKey} = params
  let comparison = switch params.comparison {
  | Some(val) => Some(val)
  | None => None
  }
  let primaryCategories = data->getCategories(0, yKey)
  let secondaryCategories = data->getCategories(1, yKey)

  let lineGraphData = data->getLineGraphData(~xKey, ~yKey)

  {
    chartHeight: DefaultHeight,
    chartLeftSpacing: DefaultLeftSpacing,
    categories: primaryCategories,
    data: lineGraphData,
    title: {
      text: "",
    },
    yAxisMaxValue: 100->Some,
    yAxisMinValue: Some(0),
    tooltipFormatter: tooltipFormatter(
      ~secondaryCategories,
      ~title="Payments Success Rate",
      ~metricType=Rate,
      ~comparison,
    ),
    yAxisFormatter: LineGraphUtils.lineGraphYAxisFormatter(
      ~statType=Default,
      ~currency="",
      ~suffix="",
    ),
    legend: {
      useHTML: true,
      labelFormatter: LineGraphUtils.valueFormatter,
    },
  }
}

open InsightsTypes
open NewAnalyticsTypes
let tabs = [{label: "Daily", value: (#G_ONEDAY: granularity :> string)}]

let defaulGranularity = {
  label: "Hourly",
  value: (#G_ONEDAY: granularity :> string),
}

let getKeyForModule = (field, ~isSmartRetryEnabled) => {
  switch (field, isSmartRetryEnabled) {
  | (Payments_Success_Rate, Smart_Retry) => Payments_Success_Rate
  | (Payments_Success_Rate, Default) | _ => Payments_Success_Rate_Without_Smart_Retries
  }->getStringFromVariant
}

let getMetaDataMapper = (key, ~isSmartRetryEnabled) => {
  let field = key->getVariantValueFromString
  switch (field, isSmartRetryEnabled) {
  | (Payments_Success_Rate, Smart_Retry) => Total_Success_Rate
  | (Payments_Success_Rate, Default) | _ => Total_Success_Rate_Without_Smart_Retries
  }->getStringFromVariant
}
