open NewAuthenticationAnalyticsTypes
open LogicUtils

let defaultQueryData: queryDataType = {
  authentication_count: 0,
  authentication_attempt_count: 0,
  authentication_success_count: 0,
  challenge_flow_count: 0,
  challenge_attempt_count: 0,
  challenge_success_count: 0,
  frictionless_flow_count: 0,
  frictionless_success_count: 0,
  error_message_count: 0,
  authentication_funnel: 0,
  authentication_status: None,
  trans_status: None,
  error_message: "",
  authentication_connector: None,
  message_version: None,
  time_range: {
    start_time: "",
    end_time: "",
  },
  time_bucket: "",
}

let defaultSecondFunnelData = {
  authentication_count: 0,
  authentication_attempt_count: 0,
  authentication_success_count: 0,
  challenge_flow_count: 0,
  challenge_attempt_count: 0,
  challenge_success_count: 0,
  frictionless_flow_count: 0,
  frictionless_success_count: 0,
  error_message_count: None,
  authentication_funnel: 0,
  authentication_status: None,
  trans_status: None,
  error_message: None,
  authentication_connector: None,
  message_version: None,
  time_range: {
    start_time: "",
    end_time: "",
  },
  time_bucket: "",
}

let defaultMetaData: metaDataType = {
  total_error_message_count: 0,
}

let itemToObjMapperForQueryData: Dict.t<JSON.t> => queryDataType = dict => {
  {
    authentication_count: getInt(dict, "authentication_count", 0),
    authentication_attempt_count: getInt(dict, "authentication_attempt_count", 0),
    authentication_success_count: getInt(dict, "authentication_success_count", 0),
    challenge_flow_count: getInt(dict, "challenge_flow_count", 0),
    challenge_attempt_count: getInt(dict, "challenge_attempt_count", 0),
    challenge_success_count: getInt(dict, "challenge_success_count", 0),
    frictionless_flow_count: getInt(dict, "frictionless_flow_count", 0),
    frictionless_success_count: getInt(dict, "frictionless_success_count", 0),
    error_message_count: getInt(dict, "error_message_count", 0),
    authentication_funnel: getInt(dict, "authentication_funnel", 0),
    authentication_status: getOptionString(dict, "authentication_status"),
    trans_status: getOptionString(dict, "trans_status"),
    error_message: getString(dict, "error_message", ""),
    authentication_connector: getOptionString(dict, "authentication_connector"),
    message_version: getOptionString(dict, "message_version"),
    time_range: {
      start_time: getString(dict, "start_time", ""),
      end_time: getString(dict, "end_time", ""),
    },
    time_bucket: getString(dict, "time_bucket", ""),
  }
}

let itemToObjMapperForSecondFunnelData: Dict.t<JSON.t> => secondFunnelDataType = dict => {
  {
    authentication_count: getInt(dict, "authentication_count", 0),
    authentication_attempt_count: getInt(dict, "authentication_attempt_count", 0),
    authentication_success_count: getInt(dict, "authentication_success_count", 0),
    challenge_flow_count: getInt(dict, "challenge_flow_count", 0),
    challenge_attempt_count: getInt(dict, "challenge_attempt_count", 0),
    challenge_success_count: getInt(dict, "challenge_success_count", 0),
    frictionless_flow_count: getInt(dict, "frictionless_flow_count", 0),
    frictionless_success_count: getInt(dict, "frictionless_success_count", 0),
    error_message_count: getOptionInt(dict, "error_message_count"),
    authentication_funnel: getInt(dict, "authentication_funnel", 0),
    authentication_status: getOptionString(dict, "authentication_status"),
    trans_status: getOptionString(dict, "trans_status"),
    error_message: getOptionString(dict, "error_message"),
    authentication_connector: getOptionString(dict, "authentication_connector"),
    message_version: getOptionString(dict, "message_version"),
    time_range: {
      start_time: getString(dict, "start_time", ""),
      end_time: getString(dict, "end_time", ""),
    },
    time_bucket: getString(dict, "time_bucket", ""),
  }
}

let itemToObjMapperForMetaData: Dict.t<JSON.t> => metaDataType = dict => {
  {
    total_error_message_count: getInt(dict, "total_error_message_count", 0),
  }
}

let itemToObjMapperForInsightsData: Dict.t<JSON.t> => insightsDataType = dict => {
  {
    queryData: getArrayDataFromJson(
      dict->getArrayFromDict("queryData", [])->JSON.Encode.array,
      itemToObjMapperForQueryData,
    ),
    metaData: getArrayDataFromJson(
      dict->getArrayFromDict("metaData", [])->JSON.Encode.array,
      itemToObjMapperForMetaData,
    ),
  }
}

let itemToObjMapperForFunnelData: Dict.t<JSON.t> => funnelDataType = dict => {
  {
    payments_requiring_3ds_2_authentication: dict->getInt(
      "payments_requiring_3ds_2_authentication",
      0,
    ),
    authentication_initiated: dict->getInt("authentication_initiated", 0),
    authentication_attemped: dict->getInt("authentication_attemped", 0),
    authentication_successful: dict->getInt("authentication_successful", 0),
  }
}

let metrics: array<LineChartUtils.metricsConfig> = [
  {
    metric_name_db: "payments_requiring_3ds_2_authentication",
    metric_label: "Payments Requiring 3DS 2.0 Authentication",
    thresholdVal: None,
    step_up_threshold: None,
    metric_type: Rate,
    disabled: false,
  },
  {
    metric_name_db: "authentication_initiated",
    metric_label: "Authentication Initiated",
    thresholdVal: None,
    step_up_threshold: None,
    metric_type: Rate,
    disabled: false,
  },
  {
    metric_name_db: "authentication_attemped",
    metric_label: "Authentication Attempted",
    thresholdVal: None,
    step_up_threshold: None,
    metric_type: Rate,
    disabled: false,
  },
  {
    metric_name_db: "authentication_successful",
    metric_label: "Authentication Successful",
    thresholdVal: None,
    step_up_threshold: None,
    metric_type: Rate,
    disabled: false,
  },
]

let getFunnelChartData = funnelData => {
  let funnelDict = Dict.make()
  funnelDict->Dict.set(
    "payments_requiring_3ds_2_authentication",
    (funnelData.payments_requiring_3ds_2_authentication->Int.toFloat /.
    funnelData.payments_requiring_3ds_2_authentication->Int.toFloat *. 100.0)
    ->Float.toString
    ->JSON.Encode.string,
  )
  funnelDict->Dict.set(
    "authentication_initiated",
    (funnelData.authentication_initiated->Int.toFloat /.
    funnelData.payments_requiring_3ds_2_authentication->Int.toFloat *. 100.0)
    ->Float.toString
    ->JSON.Encode.string,
  )
  funnelDict->Dict.set(
    "authentication_attemped",
    (funnelData.authentication_attemped->Int.toFloat /.
    funnelData.payments_requiring_3ds_2_authentication->Int.toFloat *. 100.0)
    ->Float.toString
    ->JSON.Encode.string,
  )
  funnelDict->Dict.set(
    "authentication_successful",
    (funnelData.authentication_successful->Int.toFloat /.
    funnelData.payments_requiring_3ds_2_authentication->Int.toFloat *. 100.0)
    ->Float.toString
    ->JSON.Encode.string,
  )
  let funnelDataArray = [funnelDict->JSON.Encode.object]

  funnelDataArray
}

let getMetricsData = (queryData: queryDataType) => {
  let dataArray = [
    {
      title: "Payments Requiring 3DS authentication",
      value: queryData.authentication_count->Int.toFloat,
      valueType: No_Type,
      tooltip_description: "Total number of payments which requires 3DS 2.0 authentication",
    },
    {
      title: "Authentication Success Rate",
      value: queryData.authentication_success_count->Int.toFloat /.
      queryData.authentication_count->Int.toFloat *. 100.0,
      valueType: Rate,
      tooltip_description: "Successful authentication requests over total authentication requests",
    },
    {
      title: "Challenge Flow Rate",
      value: queryData.challenge_flow_count->Int.toFloat /.
      queryData.authentication_count->Int.toFloat *. 100.0,
      valueType: Rate,
      tooltip_description: "Challenge flow requests over total authentication requests",
    },
    {
      title: "Frictionless Flow Rate",
      value: queryData.frictionless_flow_count->Int.toFloat /.
      queryData.authentication_count->Int.toFloat *. 100.0,
      valueType: Rate,
      tooltip_description: "Frictionless flow requests over total authentication requests",
    },
    {
      title: "Challenge Attempt Rate",
      value: queryData.challenge_attempt_count->Int.toFloat /.
      queryData.challenge_flow_count->Int.toFloat *. 100.0,
      valueType: Rate,
      tooltip_description: "Attempted challenge requests over total challenge requests",
    },
    {
      title: "Challenge Success Rate",
      value: queryData.challenge_success_count->Int.toFloat /.
      queryData.challenge_flow_count->Int.toFloat *. 100.0,
      valueType: Rate,
      tooltip_description: "Successful challenge requests over total challenge requests",
    },
    {
      title: "Frictionless Success Rate",
      value: queryData.frictionless_success_count->Int.toFloat /.
      queryData.frictionless_flow_count->Int.toFloat *. 100.0,
      valueType: Rate,
      tooltip_description: "Successful frictionless requests over total frictionless requests",
    },
  ]

  dataArray
}

let getUpdatedFilterValueJson = (filterValueJson: Dict.t<JSON.t>) => {
  let updatedFilterValueJson = Js.Dict.map(t => t, filterValueJson)
  let authConnectors =
    filterValueJson->getArrayFromDict("authentication_connector", [])->getNonEmptyArray
  let messageVersions = filterValueJson->getArrayFromDict("message_version", [])->getNonEmptyArray

  updatedFilterValueJson->LogicUtils.setOptionArray("authentication_connector", authConnectors)
  updatedFilterValueJson->LogicUtils.setOptionArray("message_version", messageVersions)
  updatedFilterValueJson->deleteNestedKeys(["startTime", "endTime"])

  updatedFilterValueJson
}

let renderValueInp = () => (_fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
  React.null
}

let compareToInput = (~comparisonKey) => {
  FormRenderer.makeMultiInputFieldInfoOld(
    ~label="",
    ~comboCustomInput=renderValueInp(),
    ~inputFields=[
      FormRenderer.makeInputFieldInfo(~name=`${comparisonKey}`),
      FormRenderer.makeInputFieldInfo(~name=`extraKey`),
    ],
    (),
  )
}

let (startTimeFilterKey, endTimeFilterKey) = ("startTime", "endTime")

let initialFixedFilterFields = () => {
  let newArr = [
    (
      {
        localFilter: None,
        field: FormRenderer.makeMultiInputFieldInfo(
          ~label="",
          ~comboCustomInput=InputFields.filterDateRangeField(
            ~startKey=startTimeFilterKey,
            ~endKey=endTimeFilterKey,
            ~format="YYYY-MM-DDTHH:mm:ss[Z]",
            ~showTime=true,
            ~disablePastDates={false},
            ~disableFutureDates={true},
            ~predefinedDays=[
              Hour(0.5),
              Hour(1.0),
              Hour(2.0),
              Today,
              Yesterday,
              Day(2.0),
              Day(7.0),
              Day(30.0),
              ThisMonth,
              LastMonth,
            ],
            ~numMonths=2,
            ~disableApply=false,
            ~dateRangeLimit=180,
          ),
          ~inputFields=[],
          ~isRequired=false,
        ),
      }: EntityType.initialFilters<'t>
    ),
    (
      {
        localFilter: None,
        field: compareToInput(~comparisonKey=""),
      }: EntityType.initialFilters<'t>
    ),
  ]

  newArr
}
