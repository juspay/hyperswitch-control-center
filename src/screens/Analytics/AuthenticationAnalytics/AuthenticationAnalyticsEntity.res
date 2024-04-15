open LogicUtils
open DynamicSingleStat

open HSAnalyticsUtils
open AnalyticsTypes
let domain = "sdk_events"

let singleStatInitialValue = {
  authentication_unsuccessful_count: 0,
  three_ds_challenge_flow_count: 0,
  three_ds_frictionless_flow_count: 0,
  three_ds_method_invoked_count: 0,
  three_ds_method_skipped_count: 0,
  three_ds_method_successful_count: 0,
  three_ds_method_unsuccessful_count: 0,
}

let singleStatSeriesInitialValue = {
  authentication_unsuccessful_count: 0,
  three_ds_challenge_flow_count: 0,
  three_ds_frictionless_flow_count: 0,
  three_ds_method_invoked_count: 0,
  three_ds_method_skipped_count: 0,
  three_ds_method_successful_count: 0,
  three_ds_method_unsuccessful_count: 0,
  time_series: "",
}

let singleStatItemToObjMapper = json => {
  json
  ->JSON.Decode.object
  ->Option.map(dict => {
    authentication_unsuccessful_count: dict->getInt("authentication_unsuccessful_count", 0),
    three_ds_challenge_flow_count: dict->getInt("three_ds_challenge_flow_count", 0),
    three_ds_frictionless_flow_count: dict->getInt("three_ds_frictionless_flow_count", 0),
    three_ds_method_invoked_count: dict->getInt("three_ds_method_invoked_count", 0),
    three_ds_method_skipped_count: dict->getInt("three_ds_method_skipped_count", 0),
    three_ds_method_successful_count: dict->getInt("three_ds_method_successful_count", 0),
    three_ds_method_unsuccessful_count: dict->getInt("three_ds_method_unsuccessful_count", 0),
  })
  ->Option.getOr({
    singleStatInitialValue
  })
}

let singleStatSeriesItemToObjMapper = json => {
  json
  ->JSON.Decode.object
  ->Option.map(dict => {
    time_series: dict->getString("time_bucket", ""),
    authentication_unsuccessful_count: dict->getInt("authentication_unsuccessful_count", 0),
    three_ds_challenge_flow_count: dict->getInt("three_ds_challenge_flow_count", 0),
    three_ds_frictionless_flow_count: dict->getInt("three_ds_frictionless_flow_count", 0),
    three_ds_method_invoked_count: dict->getInt("three_ds_method_invoked_count", 0),
    three_ds_method_skipped_count: dict->getInt("three_ds_method_skipped_count", 0),
    three_ds_method_successful_count: dict->getInt("three_ds_method_successful_count", 0),
    three_ds_method_unsuccessful_count: dict->getInt("three_ds_method_unsuccessful_count", 0),
  })
  ->Option.getOr({
    singleStatSeriesInitialValue
  })
}

let itemToObjMapper = json => {
  let data = json->getQueryData->Array.map(singleStatItemToObjMapper)
  switch data[0] {
  | Some(ele) => ele
  | None => singleStatInitialValue
  }
}

let timeSeriesObjMapper = json =>
  json->getQueryData->Array.map(json => singleStatSeriesItemToObjMapper(json))

type colT =
  | AuthenticationSuccessRate
  | ThreeDsChallengeFlowRate
  | ThreeDsFrictionlessFlowRate
  | ThreeDsMethodInvokedRate
  | ThreeDsMethodSkippedRate
  | ThreeDsMethodSuccessRate

let defaultColumns: array<DynamicSingleStat.columns<colT>> = [
  {
    sectionName: "",
    columns: [
      AuthenticationSuccessRate,
      ThreeDsChallengeFlowRate,
      ThreeDsFrictionlessFlowRate,
      ThreeDsMethodInvokedRate,
      ThreeDsMethodSkippedRate,
      ThreeDsMethodSuccessRate,
    ],
  },
]

let compareLogic = (firstValue, secondValue) => {
  let (temp1, _) = firstValue
  let (temp2, _) = secondValue
  if temp1 == temp2 {
    0.
  } else if temp1 > temp2 {
    -1.
  } else {
    1.
  }
}

let constructData = (key, singlestatTimeseriesData: array<authenticationSingleStatSeries>) => {
  switch key {
  | AuthenticationSuccessRate =>
    singlestatTimeseriesData->Array.map(ob => {
      let total_authentication_requests =
        (ob.three_ds_method_invoked_count + ob.three_ds_method_skipped_count)->Int.toFloat
      (
        ob.time_series->DateTimeUtils.parseAsFloat,
        (total_authentication_requests -. ob.authentication_unsuccessful_count->Int.toFloat) *.
        100. /.
        total_authentication_requests,
      )
    })

  | ThreeDsChallengeFlowRate =>
    singlestatTimeseriesData->Array.map(ob => {
      let total_three_ds_requests =
        (ob.three_ds_challenge_flow_count + ob.three_ds_frictionless_flow_count)->Int.toFloat
      (
        ob.time_series->DateTimeUtils.parseAsFloat,
        ob.three_ds_challenge_flow_count->Int.toFloat *. 100. /. total_three_ds_requests,
      )
    })
  | ThreeDsFrictionlessFlowRate =>
    singlestatTimeseriesData->Array.map(ob => {
      let total_three_ds_requests =
        (ob.three_ds_challenge_flow_count + ob.three_ds_frictionless_flow_count)->Int.toFloat
      (
        ob.time_series->DateTimeUtils.parseAsFloat,
        ob.three_ds_frictionless_flow_count->Int.toFloat *. 100. /. total_three_ds_requests,
      )
    })
  | ThreeDsMethodInvokedRate =>
    singlestatTimeseriesData->Array.map(ob => {
      let total_three_ds_requests =
        (ob.three_ds_method_invoked_count + ob.three_ds_method_skipped_count)->Int.toFloat
      (
        ob.time_series->DateTimeUtils.parseAsFloat,
        ob.three_ds_method_invoked_count->Int.toFloat *. 100. /. total_three_ds_requests,
      )
    })
  | ThreeDsMethodSkippedRate =>
    singlestatTimeseriesData->Array.map(ob => {
      let total_three_ds_requests =
        (ob.three_ds_method_invoked_count + ob.three_ds_method_skipped_count)->Int.toFloat
      (
        ob.time_series->DateTimeUtils.parseAsFloat,
        ob.three_ds_method_skipped_count->Int.toFloat *. 100. /. total_three_ds_requests,
      )
    })
  | ThreeDsMethodSuccessRate =>
    singlestatTimeseriesData->Array.map(ob => {
      let total_three_ds_requests =
        (ob.three_ds_method_successful_count + ob.three_ds_method_unsuccessful_count)->Int.toFloat
      (
        ob.time_series->DateTimeUtils.parseAsFloat,
        ob.three_ds_method_successful_count->Int.toFloat *. 100. /. total_three_ds_requests,
      )
    })
  }->Array.toSorted(compareLogic)
}

let getStatData = (
  singleStatData: authenticationSingleStat,
  timeSeriesData: array<authenticationSingleStatSeries>,
  _deltaTimestampData: DynamicSingleStat.deltaRange,
  colType,
  _mode,
) => {
  switch colType {
  | AuthenticationSuccessRate => {
      let total_authentication_requests =
        (singleStatData.three_ds_method_invoked_count +
        singleStatData.three_ds_method_skipped_count)->Int.toFloat
      {
        title: "Authentication Success Rate",
        tooltipText: "Successful Authentication Requests over Total Requests",
        deltaTooltipComponent: _ => React.null,
        value: (total_authentication_requests -.
        singleStatData.authentication_unsuccessful_count->Int.toFloat) *.
        100.0 /.
        total_authentication_requests,
        delta: 0.0,
        data: constructData(AuthenticationSuccessRate, timeSeriesData),
        statType: "Rate",
        showDelta: false,
      }
    }
  | ThreeDsChallengeFlowRate => {
      let total_three_ds_requests =
        (singleStatData.three_ds_challenge_flow_count +
        singleStatData.three_ds_frictionless_flow_count)->Int.toFloat
      {
        title: "Challenge Flow Rate",
        tooltipText: "Percentage of sessions where users went through a challenge flow",
        deltaTooltipComponent: _ => React.null,
        value: singleStatData.three_ds_challenge_flow_count->Int.toFloat *.
        100.0 /.
        total_three_ds_requests,
        delta: 0.0,
        data: constructData(ThreeDsChallengeFlowRate, timeSeriesData),
        statType: "Rate",
        showDelta: false,
      }
    }
  | ThreeDsFrictionlessFlowRate => {
      let total_three_ds_requests =
        (singleStatData.three_ds_challenge_flow_count +
        singleStatData.three_ds_frictionless_flow_count)->Int.toFloat
      {
        title: "Frictionless Flow Rate",
        tooltipText: "Percentage of sessions where users went through a frictionless flow",
        deltaTooltipComponent: _ => React.null,
        value: singleStatData.three_ds_frictionless_flow_count->Int.toFloat *.
        100.0 /.
        total_three_ds_requests,
        delta: 0.0,
        data: constructData(ThreeDsFrictionlessFlowRate, timeSeriesData),
        statType: "Rate",
        showDelta: false,
      }
    }
  | ThreeDsMethodInvokedRate => {
      let total_three_ds_requests =
        (singleStatData.three_ds_method_invoked_count +
        singleStatData.three_ds_method_skipped_count)->Int.toFloat
      {
        title: "Three DS Method Invocation Rate",
        tooltipText: "Percentage of sessions where Three DS Method was invoked",
        deltaTooltipComponent: _ => React.null,
        value: singleStatData.three_ds_method_invoked_count->Int.toFloat *.
        100. /.
        total_three_ds_requests,
        delta: 0.0,
        data: constructData(ThreeDsMethodInvokedRate, timeSeriesData),
        statType: "Rate",
        showDelta: false,
      }
    }
  | ThreeDsMethodSkippedRate => {
      let total_three_ds_requests =
        (singleStatData.three_ds_method_invoked_count +
        singleStatData.three_ds_method_skipped_count)->Int.toFloat
      {
        title: "Three DS Method Skip Rate",
        tooltipText: "Percentage of sessions where Three DS Method was skipped",
        deltaTooltipComponent: _ => React.null,
        value: singleStatData.three_ds_method_skipped_count->Int.toFloat *.
        100. /.
        total_three_ds_requests,
        delta: 0.0,
        data: constructData(ThreeDsMethodSkippedRate, timeSeriesData),
        statType: "Rate",
        showDelta: false,
      }
    }
  | ThreeDsMethodSuccessRate => {
      let total_three_ds_requests =
        (singleStatData.three_ds_method_successful_count +
        singleStatData.three_ds_method_unsuccessful_count)->Int.toFloat
      {
        title: "Three DS Method Success Rate",
        tooltipText: "Successful Three DS Method Requests over Total Requests",
        deltaTooltipComponent: _ => React.null,
        value: singleStatData.three_ds_method_successful_count->Int.toFloat *.
        100. /.
        total_three_ds_requests,
        delta: 0.0,
        data: constructData(ThreeDsMethodSuccessRate, timeSeriesData),
        statType: "Rate",
        showDelta: false,
      }
    }
  }
}

let getStatSentiment = {
  open AnalyticsUtils
  [
    ("Checkout Page Impressions", Positive),
    ("Total Payments", Positive),
    ("Converted User Sessions", Positive),
    ("Dropped Out User Sessions", Negative),
    ("Average Payment Time", Negative),
  ]->Dict.fromArray
}

let getStatThresholds = {
  [("Dropped Out User Sessions", 40.), ("Converted User Sessions", 60.)]->Dict.fromArray
}

let getSingleStatEntity: 'a => DynamicSingleStat.entityType<'colType, 't, 't2> = metrics => {
  urlConfig: [
    {
      uri: `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`,
      metrics: metrics->getStringListFromArrayDict,
    },
  ],
  getObjects: itemToObjMapper,
  getTimeSeriesObject: timeSeriesObjMapper,
  defaultColumns,
  getData: getStatData,
  totalVolumeCol: None,
  matrixUriMapper: _ => `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`,
  statSentiment: getStatSentiment,
  statThreshold: getStatThresholds,
}

let paymentMetricsConfig: array<LineChartUtils.metricsConfig> = [
  {
    metric_name_db: "payment_attempts",
    metric_label: "Volume",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
]

let authenticationMetricsConfig: array<LineChartUtils.metricsConfig> = [
  {
    metric_name_db: "three_ds_method_invoked_count",
    metric_label: "Volume",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
]

let authenticationFunnelMetricsConfig: array<LineChartUtils.metricsConfig> = [
  {
    metric_name_db: "three_ds_method_skipped_count",
    metric_label: "Payment Confirm with 3DS 2.0 Flow",
    disabled: true,
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
  {
    metric_name_db: "three_ds_method_invoked_count",
    metric_label: "Payments with 3DS 2.0 Flow",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
    data_transformation_func: dict => {
      let total_auth_attempts =
        dict->getFloat("three_ds_method_invoked_count", 0.0) +.
          dict->getFloat("three_ds_method_skipped_count", 0.0)
      dict->Dict.set("three_ds_method_invoked_count", total_auth_attempts->JSON.Encode.float)
      dict
    },
  },
  {
    metric_name_db: "three_ds_method_unsuccessful_count",
    metric_label: "3DS Method Call",
    disabled: true,
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
  {
    metric_name_db: "three_ds_method_successful_count",
    metric_label: "3DS Method Call",
    disabled: false,
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
    data_transformation_func: dict => {
      let total_auth_attempts =
        dict->getFloat("three_ds_method_successful_count", 0.0) +.
          dict->getFloat("three_ds_method_unsuccessful_count", 0.0)
      dict->Dict.set("three_ds_method_successful_count", total_auth_attempts->JSON.Encode.float)
      dict
    },
  },
  {
    metric_name_db: "authentication_unsuccessful_count",
    metric_label: "Authentication Successful",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
    data_transformation_func: dict => {
      let total_auth_attempts =
        dict->getFloat("three_ds_method_invoked_count", 0.0) -.
          dict->getFloat("authentication_unsuccessful_count", 0.0)
      dict->Dict.set("authentication_unsuccessful_count", total_auth_attempts->JSON.Encode.float)
      dict
    },
  },
]

let commonAuthenticationChartEntity = tabKeys =>
  DynamicChart.makeEntity(
    ~uri=String(`${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`),
    ~filterKeys=tabKeys,
    ~dateFilterKeys=(startTimeFilterKey, endTimeFilterKey),
    ~currentMetrics=("Success Rate", "Volume"), // 2nd metric will be static and we won't show the 2nd metric option to the first metric
    ~cardinality=[],
    ~granularity=[],
    ~chartTypes=[SemiDonut],
    ~uriConfig=[
      {
        uri: `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`,
        timeSeriesBody: DynamicChart.getTimeSeriesChart,
        legendBody: DynamicChart.getLegendBody,
        metrics: paymentMetricsConfig,
        timeCol: "time_bucket",
        filterKeys: tabKeys,
      },
    ],
    ~moduleName="User Journey Analytics",
    ~getGranularity={
      (~startTime as _, ~endTime as _) => {
        [""]
      }
    },
    (),
  )

let authenticationChartEntity = tabKeys => {
  ...commonAuthenticationChartEntity(tabKeys),
  uriConfig: [
    {
      uri: `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`,
      timeSeriesBody: DynamicChart.getTimeSeriesChart,
      legendBody: DynamicChart.getLegendBody,
      metrics: authenticationMetricsConfig,
      timeCol: "time_bucket",
      filterKeys: tabKeys,
    },
  ],
}

let authenticationBarChartEntity = tabKeys => {
  ...commonAuthenticationChartEntity(tabKeys),
  chartTypes: [HorizontalBar],
  uriConfig: [
    {
      uri: `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`,
      timeSeriesBody: DynamicChart.getTimeSeriesChart,
      legendBody: DynamicChart.getLegendBody,
      metrics: authenticationMetricsConfig,
      timeCol: "time_bucket",
      filterKeys: tabKeys,
    },
  ],
}

let authenticationFunnelChartEntity = tabKeys => {
  ...commonAuthenticationChartEntity(tabKeys),
  chartTypes: [Funnel],
  uriConfig: [
    {
      uri: `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`,
      timeSeriesBody: DynamicChart.getTimeSeriesChart,
      legendBody: DynamicChart.getLegendBody,
      metrics: authenticationFunnelMetricsConfig,
      timeCol: "time_bucket",
      filterKeys: tabKeys,
    },
  ],
  chartDescription: "Breakdown of ThreeDS 2.0 Journey",
}
