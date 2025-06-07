open ExemptionGraphsTypes
open LogicUtils

let getStringFromVariant = value => {
  switch value {
  | Authentication_Connector => "authentication_connector"
  | Authentication_Count => "authentication_count"
  | Authentication_Success_Count => "authentication_success_count"
  | Authentication_Success_Rate => "authentication_success_rate"
  | Authentication_Exemption_Approved_Count => "authentication_exemption_approved_count"
  | Authentication_Exemption_Requested_Count => "authentication_exemption_requested_count"
  | Exemption_Approval_Rate => "exemption_approval_rate"
  | Authentication_Attempt_Count => "authentication_attempt_count"
  | Exemption_Request_Rate => "exemption_request_rate"
  | User_Drop_Off_Rate => "user_drop_off_rate"
  | Time_Bucket => "time_bucket"
  | _ => "unknown"
  }
}

let getVariantValueFromString = value => {
  switch value {
  | "authentication_connector" => Authentication_Connector
  | "authentication_success_count" => Authentication_Success_Count
  | "authentication_count" => Authentication_Count
  | "authentication_success_rate" => Authentication_Success_Rate
  | "authentication_exemption_approved_count" => Authentication_Exemption_Approved_Count
  | "authentication_exemption_requested_count" => Authentication_Exemption_Requested_Count
  | "exemption_approval_rate" => Exemption_Approval_Rate
  | "authentication_attempt_count" => Authentication_Attempt_Count
  | "exemption_request_rate" => Exemption_Request_Rate
  | "user_drop_off_rate" => User_Drop_Off_Rate
  | "time_bucket" | _ => Time_Bucket
  }
}

let exemptionGraphsMapper = (
  ~params: NewAuthenticationAnalyticsTypes.getObjects<JSON.t>,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  open InsightsUtils
  open LogicUtilsTypes

  let {data, xKey, yKey} = params
  let title = params.title->Option.getOr("")
  let currency = params.currency->Option.getOr("")
  let primaryCategories = data->getCategories(0, yKey)
  let secondaryCategories = data->getCategories(1, yKey)

  let lineGraphData = data->getLineGraphData(~xKey, ~yKey)

  let tooltipFormatter = tooltipFormatter(
    ~secondaryCategories,
    ~title,
    ~metricType=Amount,
    ~comparison=params.comparison,
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
    yAxisMaxValue: Some(100),
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

let tableItemToObjMapper: Dict.t<JSON.t> => exemptionGraphsObject = dict => {
  {
    authentication_count: dict->getInt(Authentication_Count->getStringFromVariant, 0),
    authentication_success_count: dict->getInt(
      Authentication_Success_Count->getStringFromVariant,
      0,
    ),
    authentication_success_rate: dict->getFloat(
      Authentication_Success_Rate->getStringFromVariant,
      0.0,
    ),
    time_bucket: dict->getString(Time_Bucket->getStringFromVariant, "NA"),
    authentication_exemption_approved_count: dict->getInt(
      Authentication_Exemption_Approved_Count->getStringFromVariant,
      0,
    ),
    authentication_exemption_requested_count: dict->getInt(
      Authentication_Exemption_Requested_Count->getStringFromVariant,
      0,
    ),
    exemption_approval_rate: dict->getFloat(Exemption_Approval_Rate->getStringFromVariant, 0.0),
    authentication_attempt_count: dict->getInt(
      Authentication_Attempt_Count->getStringFromVariant,
      0,
    ),
    exemption_request_rate: dict->getFloat(Exemption_Request_Rate->getStringFromVariant, 0.0),
    user_drop_off_rate: dict->getFloat(User_Drop_Off_Rate->getStringFromVariant, 0.0),
    authentication_connector: dict->getString(Authentication_Connector->getStringFromVariant, "NA"),
  }
}

let getObjects: JSON.t => array<exemptionGraphsObject> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

open NewAuthenticationAnalyticsTypes

let defaulGranularity = {
  label: "Daily",
  value: (#G_ONEDAY: granularity :> string),
}

let getKey = id => {
  let key = switch id {
  | Time_Bucket => #time_bucket
  | Authentication_Connector => #authentication_connector
  | Authentication_Success_Count => #authentication_success_count
  | Authentication_Count => #authentication_count
  | Authentication_Success_Rate => #authentication_success_rate
  | Authentication_Exemption_Approved_Count => #authentication_exemption_approved_count
  | Authentication_Exemption_Requested_Count => #authentication_exemption_requested_count
  | Exemption_Approval_Rate => #exemption_approval_rate
  | Authentication_Attempt_Count => #authentication_attempt_count
  | Exemption_Request_Rate => #exemption_request_rate
  | User_Drop_Off_Rate => #user_drop_off_rate
  | _ => #time_bucket
  }
  (key: responseKeys :> string)
}

let getUpdatedFilterValueJson = (filterValueJson: Dict.t<JSON.t>) => {
  let updatedFilterValueJson = Js.Dict.map(t => t, filterValueJson)

  // Get all keys from the filter dictionary
  let filterKeys = updatedFilterValueJson->Dict.keysToArray

  // Process each key except startTime and endTime
  filterKeys->Array.forEach(key => {
    if key !== "startTime" && key !== "endTime" {
      let arrayValue = filterValueJson->getArrayFromDict(key, [])->getNonEmptyArray
      updatedFilterValueJson->LogicUtils.setOptionArray(key, arrayValue)
    }
  })

  // Remove nested keys
  updatedFilterValueJson->deleteNestedKeys(["startTime", "endTime"])

  updatedFilterValueJson
}

let modifyQueryData = data => {
  let dataDict = Dict.make()

  data->Array.forEach(item => {
    let valueDict = item->getDictFromJsonObject
    let time = valueDict->getString(Time_Bucket->getStringFromVariant, "")

    let authenticationCount = valueDict->getInt(Authentication_Count->getKey, 0)

    let authenticationSuccessCount = valueDict->getInt(Authentication_Success_Count->getKey, 0)

    let authenticationExemptionApprovedCount =
      valueDict->getInt(Authentication_Exemption_Approved_Count->getKey, 0)

    let authenticationExemptionRequestedCount =
      valueDict->getInt(Authentication_Exemption_Requested_Count->getKey, 0)

    let authenticationAttemptCount = valueDict->getInt(Authentication_Attempt_Count->getKey, 0)

    let authenticationSuccessRate = if authenticationCount == 0 {
      0.0
    } else {
      float_of_int(authenticationSuccessCount) /. float_of_int(authenticationCount) *. 100.0
    }

    let exemptionApprovalRate = if authenticationExemptionRequestedCount == 0 {
      0.0
    } else {
      float_of_int(authenticationExemptionApprovedCount) /.
      float_of_int(authenticationExemptionRequestedCount) *. 100.0
    }

    let exemptionRequestRate = if authenticationExemptionRequestedCount == 0 {
      0.0
    } else {
      float_of_int(authenticationExemptionRequestedCount) /.
      float_of_int(authenticationAttemptCount) *. 100.0
    }
    let userDropOffRate = if authenticationAttemptCount == 0 {
      0.0
    } else {
      float_of_int(authenticationAttemptCount - authenticationSuccessCount) /.
      float_of_int(authenticationAttemptCount) *. 100.0
    }
    valueDict->Dict.set(
      Authentication_Success_Rate->getStringFromVariant,
      authenticationSuccessRate->JSON.Encode.float,
    )

    valueDict->Dict.set(
      Exemption_Approval_Rate->getStringFromVariant,
      exemptionApprovalRate->JSON.Encode.float,
    )

    valueDict->Dict.set(
      Exemption_Request_Rate->getStringFromVariant,
      exemptionRequestRate->JSON.Encode.float,
    )

    valueDict->Dict.set(
      User_Drop_Off_Rate->getStringFromVariant,
      userDropOffRate->JSON.Encode.float,
    )

    dataDict->Dict.set(time, valueDict)
  })

  dataDict->Dict.valuesToArray->Array.map(JSON.Encode.object)
}

let getCell = (obj: exemptionGraphsObject, colType): Table.cell => {
  open InsightsUtils
  switch colType {
  | Authentication_Connector => Text(obj.authentication_connector)
  | Authentication_Success_Rate => Text(obj.authentication_success_rate->Float.toString ++ "%")
  | Exemption_Approval_Rate => Text(obj.exemption_approval_rate->Float.toString ++ "%")
  | Exemption_Request_Rate => Text(obj.exemption_request_rate->Float.toString ++ "%")
  | User_Drop_Off_Rate => Text(obj.user_drop_off_rate->Float.toString ++ "%")
  | Time_Bucket => Text(obj.time_bucket->formatDateValue(~includeYear=true))
  | _ => Text("")
  }
}

let getHeading = colType => {
  switch colType {
  | Authentication_Connector =>
    Table.makeHeaderInfo(
      ~key=Authentication_Connector->getStringFromVariant,
      ~title="Authentication Connector",
      ~dataType=TextType,
    )
  | Authentication_Success_Rate =>
    Table.makeHeaderInfo(
      ~key=Authentication_Success_Rate->getStringFromVariant,
      ~title="Authentication Success Rate",
      ~dataType=TextType,
    )
  | Exemption_Approval_Rate =>
    Table.makeHeaderInfo(
      ~key=Exemption_Approval_Rate->getStringFromVariant,
      ~title="Exemption Approval Rate",
      ~dataType=TextType,
    )
  | Exemption_Request_Rate =>
    Table.makeHeaderInfo(
      ~key=Exemption_Request_Rate->getStringFromVariant,
      ~title="Exemption Request Rate",
      ~dataType=TextType,
    )
  | User_Drop_Off_Rate =>
    Table.makeHeaderInfo(
      ~key=User_Drop_Off_Rate->getStringFromVariant,
      ~title="User Drop Off Rate",
      ~dataType=TextType,
    )
  | Time_Bucket =>
    Table.makeHeaderInfo(~key=Time_Bucket->getStringFromVariant, ~title="Date", ~dataType=TextType)
  | _ => Table.makeHeaderInfo(~key="", ~title="", ~dataType=TextType)
  }
}
