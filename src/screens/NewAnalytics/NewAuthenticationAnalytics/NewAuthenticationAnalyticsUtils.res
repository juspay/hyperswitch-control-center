open NewAuthenticationAnalyticsTypes
open LogicUtils
open DateRangeUtils

@module("./authDummyData.json")
external authDummyData: JSON.t = "default"

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
  authentication_exemption_accepted: None,
  authentication_exemption_requested: None,
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
    authentication_exemption_accepted: getOptionInt(dict, "authentication_exemption_accepted"),
    authentication_exemption_requested: getOptionInt(dict, "authentication_exemption_requested"),
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
      valueType: Default,
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
    {
      title: "SCA Exemption request rate",
      value: queryData.authentication_exemption_requested->Option.getOr(0)->Int.toFloat /.
      queryData.authentication_count->Int.toFloat *. 100.0,
      valueType: Rate,
      tooltip_description: "Total no. of Exemptions requested by the merchant / Total no. of Payments initiated",
    },
    {
      title: "SCA Exemption approval rate",
      value: queryData.authentication_exemption_accepted->Option.getOr(0)->Int.toFloat /.
      queryData.authentication_exemption_requested->Option.getOr(0)->Int.toFloat *. 100.0,
      valueType: Rate,
      tooltip_description: "Total no. of Exemptions approved by the issuer / Total no. of Exemptions requested by the merchant",
    },
    {
      title: "Chargebacks on Exempted transactions",
      value: 0.0,
      valueType: Default,
      tooltip_description: "Number of chargebacks received for transactions with exemptions",
    },
    {
      title: "Authorization decline rate on exempted transactions",
      value: (1.0 -.
      queryData.frictionless_success_count->Int.toFloat /.
        queryData.frictionless_flow_count->Int.toFloat) *. 100.0,
      valueType: Rate,
      tooltip_description: "Percentage of exempted transactions that were declined during authorization",
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

let initialFixedFilterFields = (~events=?) => {
  let events = switch events {
  | Some(fn) => fn
  | _ => () => ()
  }
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
            ~events,
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

// colors
let redColor = "#BA3535"
let blue = "#1059C1B2"
let green = "#0EB025B2"
let barGreenColor = "#7CC88F"
let sankyBlue = "#E4EFFF"
let sankyRed = "#F7E0E0"
let sankyLightBlue = "#91B7EE"
let sankyLightRed = "#EC6262"

let renderValueInp = () => (_fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
  React.null
}

let (
  startTimeFilterKey,
  endTimeFilterKey,
  smartRetryKey,
  compareToStartTimeKey,
  compareToEndTimeKey,
  comparisonKey,
  sampleDataKey,
) = (
  "startTime",
  "endTime",
  "is_smart_retry_enabled",
  "compareToStartTime",
  "compareToEndTime",
  "comparison",
  "is_sample_data_enabled",
)

let globalFilter: array<filters> = [#currency]
let globalExcludeValue = [(#all_currencies: defaultFilters :> string)]

let requestBody = (
  ~startTime: string,
  ~endTime: string,
  ~metrics: array<metrics>,
  ~groupByNames: option<array<string>>=None,
  ~filter: option<JSON.t>,
  ~delta: option<bool>=None,
  ~granularity: option<string>=None,
  ~distributionValues: option<JSON.t>=None,
  ~mode: option<string>=None,
) => {
  let metrics = metrics->Array.map(v => (v: metrics :> string))

  [
    AnalyticsUtils.getFilterRequestBody(
      ~metrics=Some(metrics),
      ~delta=delta->Option.getOr(false),
      ~groupByNames,
      ~filter,
      ~startDateTime=startTime,
      ~endDateTime=endTime,
      ~granularity,
      ~distributionValues,
      ~mode,
    )->JSON.Encode.object,
  ]->JSON.Encode.array
}

let getMonthName = month => {
  switch month {
  | 0 => "Jan"
  | 1 => "Feb"
  | 2 => "Mar"
  | 3 => "Apr"
  | 4 => "May"
  | 5 => "Jun"
  | 6 => "Jul"
  | 7 => "Aug"
  | 8 => "Sep"
  | 9 => "Oct"
  | 10 => "Nov"
  | 11 => "Dec"
  | _ => ""
  }
}

let formatDateValue = (value: string, ~includeYear=false) => {
  let dateObj = value->DayJs.getDayJsForString

  if includeYear {
    `${dateObj.month()->getMonthName} ${dateObj.format("DD")} ${dateObj.year()->Int.toString} `
  } else {
    `${dateObj.month()->getMonthName} ${dateObj.format("DD")}`
  }
}

let getLabelName = (~key, ~index, ~points) => {
  let getDateObject = (array, index) => {
    array
    ->getValueFromArray(index, Dict.make()->JSON.Encode.object)
    ->getDictFromJsonObject
    ->getString(key, "")
  }

  if key === "time_bucket" {
    let pointsArray = points->getArrayFromJson([])
    let startPoint = pointsArray->getDateObject(0)
    let endPoint = pointsArray->getDateObject(pointsArray->Array.length - 1)

    let startDate = startPoint->formatDateValue
    let endDate = endPoint->formatDateValue
    `${startDate} - ${endDate}`
  } else {
    `Series ${(index + 1)->Int.toString}`
  }
}

// removes the NA buckets
let filterQueryData = (query, key) => {
  query->Array.filter(data => {
    let valueDict = data->getDictFromJsonObject
    valueDict->getString(key, "")->isNonEmptyString
  })
}

let sortQueryDataByDate = query => {
  query->Array.sort((a, b) => {
    let valueA = a->getDictFromJsonObject->getString("time_bucket", "")
    let valueB = b->getDictFromJsonObject->getString("time_bucket", "")
    compareLogic(valueB, valueA)
  })
  query
}

let getMaxValue = (data: JSON.t, index: int, key: string) => {
  data
  ->getArrayFromJson([])
  ->getValueFromArray(index, []->JSON.Encode.array)
  ->getArrayFromJson([])
  ->Array.reduce(0.0, (acc, item) => {
    let value = item->getDictFromJsonObject->getFloat(key, 0.0)
    Math.max(acc, value)
  })
}

let isEmptyGraph = (data: JSON.t, key: string) => {
  let primaryMaxValue = data->getMaxValue(0, key)
  let secondaryMaxValue = data->getMaxValue(1, key)

  Math.max(primaryMaxValue, secondaryMaxValue) == 0.0
}

let checkTimePresent = (options, key) => {
  options->Array.reduce(false, (flag, item) => {
    let value = item->getDictFromJsonObject->getString(key, "NA")
    if value->isNonEmptyString && key == "time_bucket" {
      let dateObj = value->DayJs.getDayJsForString
      dateObj.format("HH") != "00" || flag
    } else {
      false
    }
  })
}

let formatTime = time => {
  let hour =
    time->String.split(":")->Array.get(0)->Option.getOr("00")->Int.fromString->Option.getOr(0)
  let mimute =
    time->String.split(":")->Array.get(1)->Option.getOr("00")->Int.fromString->Option.getOr(0)

  let newHour = Int.mod(hour, 12)
  let newHour = newHour == 0 ? 12 : newHour

  let period = hour >= 12 ? "PM" : "AM"

  if mimute > 0 {
    `${newHour->Int.toString}:${mimute->Int.toString} ${period}`
  } else {
    `${newHour->Int.toString} ${period}`
  }
}

let getCategories = (data: JSON.t, index: int, key: string) => {
  let options =
    data
    ->getArrayFromJson([])
    ->getValueFromArray(index, []->JSON.Encode.array)
    ->getArrayFromJson([])

  let isShowTime = options->checkTimePresent(key)

  options->Array.map(item => {
    let value = item->getDictFromJsonObject->getString(key, "NA")

    if value->isNonEmptyString && key == "time_bucket" {
      let dateObj = value->DayJs.getDayJsForString
      let date = `${dateObj.month()->getMonthName} ${dateObj.format("DD")}`
      if isShowTime {
        let time = dateObj.format("HH:mm")->formatTime
        `${date}, ${time}`
      } else {
        date
      }
    } else {
      value
    }
  })
}

let getColor = index => {
  [blue, green]->Array.get(index)->Option.getOr(blue)
}

let getAmountValue = (data, ~id) => {
  switch data->getOptionFloat(id) {
  | Some(value) => value /. 100.0
  | _ => 0.0
  }
}

let getLineGraphObj = (
  ~array: array<JSON.t>,
  ~key: string,
  ~name: string,
  ~color,
  ~isAmount=false,
): LineGraphTypes.dataObj => {
  let data = array->Array.map(item => {
    let dict = item->getDictFromJsonObject
    if isAmount {
      dict->getAmountValue(~id=key)
    } else {
      dict->getFloat(key, 0.0)
    }
  })
  let dataObj: LineGraphTypes.dataObj = {
    showInLegend: true,
    name,
    data,
    color,
  }
  dataObj
}

let getLineGraphData = (data, ~xKey, ~yKey, ~isAmount=false) => {
  data
  ->getArrayFromJson([])
  ->Array.mapWithIndex((item, index) => {
    let name = getLabelName(~key=yKey, ~index, ~points=item)
    let color = index->getColor
    getLineGraphObj(~array=item->getArrayFromJson([]), ~key=xKey, ~name, ~color, ~isAmount)
  })
}

let generateFilterObject = (~globalFilters, ~localFilters=None) => {
  let filters = Dict.make()

  let globalFiltersList = globalFilter->Array.map(filter => {
    (filter: filters :> string)
  })

  let parseStringValue = string => {
    string
    ->JSON.Decode.string
    ->Option.getOr("")
    ->String.split(",")
    ->Array.filter(value => {
      !(globalExcludeValue->Array.includes(value))
    })
    ->Array.map(JSON.Encode.string)
  }

  globalFilters
  ->Dict.toArray
  ->Array.forEach(item => {
    let (key, value) = item
    if globalFiltersList->Array.includes(key) && value->parseStringValue->Array.length > 0 {
      filters->Dict.set(key, value->parseStringValue->JSON.Encode.array)
    }
  })

  switch localFilters {
  | Some(dict) =>
    dict
    ->Dict.toArray
    ->Array.forEach(item => {
      let (key, value) = item
      filters->Dict.set(key, value)
    })
  | None => ()
  }

  filters->JSON.Encode.object
}

let getGranularityLabel = option => {
  switch option {
  | #G_ONEDAY => "Day-wise"
  | #G_ONEHOUR => "Hour-wise"
  | #G_THIRTYMIN => "30min-wise"
  | #G_FIFTEENMIN => "15min-wise"
  }
}

let defaulGranularity = {
  label: #G_ONEDAY->getGranularityLabel,
  value: (#G_ONEDAY: granularity :> string),
}

let getGranularityOptions = (~startTime, ~endTime) => {
  let startingPoint = startTime->DayJs.getDayJsForString
  let endingPoint = endTime->DayJs.getDayJsForString
  let gap = endingPoint.diff(startingPoint.toString(), "hour") // diff between points

  let options = if gap < 1 {
    [#G_THIRTYMIN, #G_FIFTEENMIN]
  } else if gap < 24 {
    [#G_ONEHOUR, #G_THIRTYMIN, #G_FIFTEENMIN]
  } else if gap < 168 {
    [#G_ONEDAY, #G_ONEHOUR]
  } else {
    [#G_ONEDAY]
  }

  options->Array.map(option => {
    label: option->getGranularityLabel,
    value: (option: granularity :> string),
  })
}

let getDefaultGranularity = (~startTime, ~endTime, ~granularity) => {
  let options = getGranularityOptions(~startTime, ~endTime)
  if granularity {
    options->Array.get(options->Array.length - 1)->Option.getOr(defaulGranularity)
  } else {
    defaulGranularity
  }
}

let getGranularityGap = option => {
  switch option {
  | "G_ONEHOUR" => 60
  | "G_THIRTYMIN" => 30
  | "G_FIFTEENMIN" => 15
  | "G_ONEDAY" | _ => 1440
  }
}

let fillMissingDataPoints = (
  ~data,
  ~startDate,
  ~endDate,
  ~timeKey="time_bucket",
  ~defaultValue: JSON.t,
  ~granularity: string,
  ~isoStringToCustomTimeZone: string => TimeZoneHook.dateTimeString,
  ~granularityEnabled,
) => {
  let dataDict = Dict.make()

  data->Array.forEach(item => {
    let time = switch (granularityEnabled, granularity != (#G_ONEDAY: granularity :> string)) {
    | (true, true) => {
        let value =
          item
          ->getDictFromJsonObject
          ->getObj("time_range", Dict.make())

        let time = value->getString("start_time", "")

        let {year, month, date, hour, minute} = isoStringToCustomTimeZone(time)

        if (
          granularity == (#G_THIRTYMIN: granularity :> string) ||
            granularity == (#G_FIFTEENMIN: granularity :> string)
        ) {
          (`${year}-${month}-${date} ${hour}:${minute}`->DayJs.getDayJsForString).format(
            "YYYY-MM-DD HH:mm:ss",
          )
        } else {
          (`${year}-${month}-${date} ${hour}:${minute}`->DayJs.getDayJsForString).format(
            "YYYY-MM-DD HH:00:00",
          )
        }
      }
    | _ =>
      item
      ->getDictFromJsonObject
      ->getString(timeKey, "")
    }

    let newItem = item->getDictFromJsonObject
    newItem->Dict.set("time_bucket", time->JSON.Encode.string)

    dataDict->Dict.set(time, newItem->JSON.Encode.object)
  })

  let dataPoints = Dict.make()
  let startingPoint = startDate->DayJs.getDayJsForString
  let startingPoint = startingPoint.format("YYYY-MM-DD HH:00:00")->DayJs.getDayJsForString
  let endingPoint = endDate->DayJs.getDayJsForString
  let gap = "minute"
  let devider = granularity->getGranularityGap
  let limit =
    (endingPoint.diff(startingPoint.toString(), gap)->Int.toFloat /. devider->Int.toFloat)
    ->Math.floor
    ->Float.toInt

  let format =
    granularity != (#G_ONEDAY: granularity :> string)
      ? "YYYY-MM-DD HH:mm:ss"
      : "YYYY-MM-DD 00:00:00"

  for x in 0 to limit {
    let newDict = defaultValue->getDictFromJsonObject->Dict.copy
    let timeVal = startingPoint.add(x * devider, gap).format(format)
    switch dataDict->Dict.get(timeVal) {
    | Some(val) => {
        newDict->Dict.set(timeKey, timeVal->JSON.Encode.string)
        dataPoints->Dict.set(timeVal, val)
      }
    | None => {
        newDict->Dict.set(timeKey, timeVal->JSON.Encode.string)
        dataPoints->Dict.set(timeVal, newDict->JSON.Encode.object)
      }
    }
  }

  dataPoints->Dict.valuesToArray
}

let getSampleDateRange = (~useSampleDates) => {
  let defaultDateRange: HSwitchRemoteFilter.filterBody = HSwitchRemoteFilter.getDateFilteredObject(
    ~range=7,
  )
  let sampleDateRange: HSwitchRemoteFilter.filterBody = {
    start_time: "2024-09-04T00:00:00.000Z",
    end_time: "2024-10-03T00:00:00.000Z",
  }
  let dates = useSampleDates ? sampleDateRange : defaultDateRange
  let comparison = useSampleDates ? (EnableComparison :> string) : (DisableComparison :> string)
  let (compareStart, compareEnd) = getComparisionTimePeriod(
    ~startDate=dates.start_time,
    ~endDate=dates.end_time,
  )
  let values =
    [
      (startTimeFilterKey, dates.start_time),
      (endTimeFilterKey, dates.end_time),
      (compareToStartTimeKey, compareStart),
      (compareToEndTimeKey, compareEnd),
      (comparisonKey, comparison),
    ]->Dict.fromArray
  values
}

let getSmartRetryMetricType = isSmartRetryEnabled => {
  open NewAuthenticationAnalyticsTypes
  switch isSmartRetryEnabled {
  | true => Smart_Retry
  | false => Default
  }
}
