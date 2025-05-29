open ExemptionApprovalRateTypes
open LogicUtils

let getStringFromVariant = value => {
  switch value {
  | Authentication_Exemption_Accepted => "authentication_exemption_accepted"
  | Authentication_Exemption_Requested => "authentication_exemption_requested"
  | Exemption_Approval_Rate => "exemption_approval_rate"
  | Time_Bucket => "time_bucket"
  | _ => "unknown"
  }
}

let getVariantValueFromString = value => {
  switch value {
  | "authentication_exemption_accepted" => Authentication_Exemption_Accepted
  | "authentication_exemption_requested" => Authentication_Exemption_Requested
  | "time_bucket" | _ => Time_Bucket
  }
}

let isAmountMetric = key => {
  switch key->getVariantValueFromString {
  | _ => false
  }
}

let excemptionApprovalRateMapper = (
  ~params: NewAuthenticationAnalyticsTypes.getObjects<JSON.t>,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  open InsightsUtils
  let {data, xKey, yKey} = params
  let comparison = switch params.comparison {
  | Some(val) => Some(val)
  | None => None
  }
  let currency = params.currency->Option.getOr("")
  let primaryCategories = data->getCategories(0, yKey)
  let secondaryCategories = data->getCategories(1, yKey)

  let lineGraphData = data->getLineGraphData(~xKey, ~yKey)

  open LogicUtilsTypes
  let metricType = Amount

  let tooltipFormatter = tooltipFormatter(
    ~secondaryCategories,
    ~title="Exemption Approval Rate",
    ~metricType,
    ~comparison,
    ~currency,
  )

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
    tooltipFormatter,
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

let visibleColumns = [Time_Bucket]

let tableItemToObjMapper: Dict.t<JSON.t> => exemptionApprovalRateObject = dict => {
  {
    authentication_exemption_accepted: dict->getInt(
      Authentication_Exemption_Accepted->getStringFromVariant,
      0,
    ),
    authentication_exemption_requested: dict->getInt(
      Authentication_Exemption_Requested->getStringFromVariant,
      0,
    ),
    time_bucket: dict->getString(Time_Bucket->getStringFromVariant, "NA"),
  }
}

let getObjects: JSON.t => array<exemptionApprovalRateObject> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

open NewAuthenticationAnalyticsTypes

let defaultMetric = {
  label: "By Rate",
  value: Exemption_Approval_Rate->getStringFromVariant,
}

let defaulGranularity = {
  label: "Daily",
  value: (#G_ONEDAY: granularity :> string),
}

let getKey = id => {
  let key = switch id {
  | Time_Bucket => #time_bucket
  | Authentication_Exemption_Accepted => #authentication_exemption_accepted
  | Authentication_Exemption_Requested => #authentication_exemption_requested
  | Exemption_Approval_Rate => #exemption_approval_rate
  | _ => #time_bucket
  }
  (key: responseKeys :> string)
}

let modifyQueryData = data => {
  let dataDict = Dict.make()

  data->Array.forEach(item => {
    let valueDict = item->getDictFromJsonObject
    let time = valueDict->getString(Time_Bucket->getStringFromVariant, "")

    let authenticationExemptionAccepted =
      valueDict->getInt(Authentication_Exemption_Accepted->getKey, 0)

    let authenticationExemptionRequested =
      valueDict->getInt(Authentication_Exemption_Requested->getKey, 0)
    let exemptionApprovalRate = if authenticationExemptionRequested == 0 {
      0.0
    } else {
      float_of_int(authenticationExemptionAccepted) /.
      float_of_int(authenticationExemptionRequested) *. 100.0
    }

    valueDict->Dict.set(
      Exemption_Approval_Rate->getStringFromVariant,
      exemptionApprovalRate->JSON.Encode.float,
    )

    dataDict->Dict.set(time, valueDict)
  })

  dataDict->Dict.valuesToArray->Array.map(JSON.Encode.object)
}
