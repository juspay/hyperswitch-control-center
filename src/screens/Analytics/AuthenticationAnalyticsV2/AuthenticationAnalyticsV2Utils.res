open AuthenticationAnalyticsV2Types
open LogicUtils

let defaultFunnelData = {
  payments_requiring_3ds_2_authentication: 0.0,
  authentication_initiated: 0.0,
  authentication_attemped: 0.0,
  authentication_successful: 0.0,
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

let defaultQueryData: queryDataType = {
  authentication_count: 0,
  authentication_attempt_count: 0,
  authentication_success_count: 0,
  challenge_flow_count: 0,
  challenge_attempt_count: 0,
  challenge_success_count: 0,
  frictionless_flow_count: 0,
  frictionless_success_count: 0,
  error_message_count: None,
  authentication_funnel: None,
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

let (
  startTimeFilterKey,
  endTimeFilterKey,
  smartRetryKey,
  compareToStartTimeKey,
  compareToEndTimeKey,
  comparisonKey,
) = (
  "startTime",
  "endTime",
  "is_smart_retry_enabled",
  "compareToStartTime",
  "compareToEndTime",
  "comparison",
)

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
        field: compareToInput(~comparisonKey),
      }: EntityType.initialFilters<'t>
    ),
  ]

  newArr
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
