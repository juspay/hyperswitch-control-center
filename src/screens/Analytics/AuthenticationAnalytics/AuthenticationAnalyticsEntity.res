open LogicUtils
open DynamicSingleStat

open HSAnalyticsUtils
open AnalyticsTypes
let domain = "auth_events"

let singleStatInitialValue = {
  three_ds_sdk_count: 0,
  authentication_success_count: 0,
  authentication_attempt_count: 0,
  challenge_flow_count: 0,
  challenge_attempt_count: 0,
  challenge_success_count: 0,
  frictionless_flow_count: 0,
  frictionless_success_count: 0,
}

let singleStatSeriesInitialValue = {
  three_ds_sdk_count: 0,
  authentication_success_count: 0,
  authentication_attempt_count: 0,
  challenge_flow_count: 0,
  challenge_attempt_count: 0,
  challenge_success_count: 0,
  frictionless_flow_count: 0,
  frictionless_success_count: 0,
  time_series: "",
}

let singleStatItemToObjMapper = json => {
  json
  ->JSON.Decode.object
  ->Option.map(dict => {
    three_ds_sdk_count: dict->getInt("three_ds_sdk_count", 0),
    authentication_success_count: dict->getInt("authentication_success_count", 0),
    authentication_attempt_count: dict->getInt("authentication_attempt_count", 0),
    challenge_flow_count: dict->getInt("challenge_flow_count", 0),
    challenge_attempt_count: dict->getInt("challenge_attempt_count", 0),
    challenge_success_count: dict->getInt("challenge_success_count", 0),
    frictionless_flow_count: dict->getInt("frictionless_flow_count", 0),
    frictionless_success_count: dict->getInt("frictionless_success_count", 0),
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
    three_ds_sdk_count: dict->getInt("three_ds_sdk_count", 0),
    authentication_success_count: dict->getInt("authentication_success_count", 0),
    authentication_attempt_count: dict->getInt("authentication_attempt_count", 0),
    challenge_flow_count: dict->getInt("challenge_flow_count", 0),
    challenge_attempt_count: dict->getInt("challenge_attempt_count", 0),
    challenge_success_count: dict->getInt("challenge_success_count", 0),
    frictionless_flow_count: dict->getInt("frictionless_flow_count", 0),
    frictionless_success_count: dict->getInt("frictionless_success_count", 0),
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
  | ThreeDsCount
  | AuthenticationSuccessRate
  | ChallengeFlowRate
  | FrictionlessFlowRate
  | ChallengeAttemptRate
  | ChallengeSuccessRate
  | FrictionlessSuccessRate

let defaultColumns: array<DynamicSingleStat.columns<colT>> = [
  {
    sectionName: "",
    columns: [
      ThreeDsCount,
      AuthenticationSuccessRate,
      ChallengeFlowRate,
      FrictionlessFlowRate,
      ChallengeAttemptRate,
      ChallengeSuccessRate,
      FrictionlessSuccessRate,
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
  | ThreeDsCount =>
    singlestatTimeseriesData->Array.map(ob => {
      (ob.time_series->DateTimeUtils.parseAsFloat, ob.three_ds_sdk_count->Int.toFloat)
    })
  | AuthenticationSuccessRate =>
    singlestatTimeseriesData->Array.map(ob => {
      (
        ob.time_series->DateTimeUtils.parseAsFloat,
        ob.authentication_success_count->Int.toFloat *.
        100. /.
        ob.authentication_attempt_count->Int.toFloat,
      )
    })

  | ChallengeFlowRate =>
    singlestatTimeseriesData->Array.map(ob => {
      (
        ob.time_series->DateTimeUtils.parseAsFloat,
        ob.challenge_flow_count->Int.toFloat *. 100. /. ob.three_ds_sdk_count->Int.toFloat,
      )
    })
  | FrictionlessFlowRate =>
    singlestatTimeseriesData->Array.map(ob => {
      (
        ob.time_series->DateTimeUtils.parseAsFloat,
        ob.frictionless_flow_count->Int.toFloat *. 100. /. ob.three_ds_sdk_count->Int.toFloat,
      )
    })
  | ChallengeAttemptRate =>
    singlestatTimeseriesData->Array.map(ob => {
      (
        ob.time_series->DateTimeUtils.parseAsFloat,
        ob.challenge_attempt_count->Int.toFloat *. 100. /. ob.challenge_flow_count->Int.toFloat,
      )
    })
  | ChallengeSuccessRate =>
    singlestatTimeseriesData->Array.map(ob => {
      (
        ob.time_series->DateTimeUtils.parseAsFloat,
        ob.challenge_success_count->Int.toFloat *. 100. /. ob.challenge_flow_count->Int.toFloat,
      )
    })
  | FrictionlessSuccessRate =>
    singlestatTimeseriesData->Array.map(ob => {
      (
        ob.time_series->DateTimeUtils.parseAsFloat,
        ob.frictionless_success_count->Int.toFloat *.
        100. /.
        ob.frictionless_flow_count->Int.toFloat,
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
  | ThreeDsCount => {
      title: "Payments requiring 3DS Authentication",
      tooltipText: "Total number of payments which require 3DS 2.0 Authentication.",
      deltaTooltipComponent: _ => React.null,
      value: singleStatData.three_ds_sdk_count->Int.toFloat,
      delta: 0.0,
      data: constructData(ThreeDsCount, timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  | AuthenticationSuccessRate => {
      title: "Authentication Success Rate",
      tooltipText: "Successful Authentication Requests over Total Requests.",
      deltaTooltipComponent: _ => React.null,
      value: singleStatData.authentication_success_count->Int.toFloat *.
      100.0 /.
      singleStatData.authentication_attempt_count->Int.toFloat,
      delta: 0.0,
      data: constructData(AuthenticationSuccessRate, timeSeriesData),
      statType: "Rate",
      showDelta: false,
    }
  | ChallengeFlowRate => {
      title: "Challenge Flow Rate",
      tooltipText: "Payments requiring a challenge to be passed over total number of payments which require 3DS 2.0 Authentication.",
      deltaTooltipComponent: _ => React.null,
      value: singleStatData.challenge_flow_count->Int.toFloat *.
      100.0 /.
      singleStatData.three_ds_sdk_count->Int.toFloat,
      delta: 0.0,
      data: constructData(ChallengeFlowRate, timeSeriesData),
      statType: "Rate",
      showDelta: false,
    }
  | FrictionlessFlowRate => {
      title: "Frictionless Flow Rate",
      tooltipText: "Payments going through a frictionless flow over total number of payments which require 3DS 2.0 Authentication.",
      deltaTooltipComponent: _ => React.null,
      value: singleStatData.frictionless_flow_count->Int.toFloat *.
      100.0 /.
      singleStatData.three_ds_sdk_count->Int.toFloat,
      delta: 0.0,
      data: constructData(FrictionlessFlowRate, timeSeriesData),
      statType: "Rate",
      showDelta: false,
    }
  | ChallengeAttemptRate => {
      title: "Challenge Attempt Rate",
      tooltipText: "Percentage of payments where user attempted the challenge.",
      deltaTooltipComponent: _ => React.null,
      value: singleStatData.challenge_attempt_count->Int.toFloat *.
      100. /.
      singleStatData.challenge_flow_count->Int.toFloat,
      delta: 0.0,
      data: constructData(ChallengeAttemptRate, timeSeriesData),
      statType: "Rate",
      showDelta: false,
    }
  | ChallengeSuccessRate => {
      title: "Challenge Success Rate",
      tooltipText: "Total number of payments authenticated where user successfully attempted the challenge over the total number of payments requiring a challenge to be passed.",
      deltaTooltipComponent: _ => React.null,
      value: singleStatData.challenge_success_count->Int.toFloat *.
      100. /.
      singleStatData.challenge_flow_count->Int.toFloat,
      delta: 0.0,
      data: constructData(ChallengeSuccessRate, timeSeriesData),
      statType: "Rate",
      showDelta: false,
    }
  | FrictionlessSuccessRate => {
      title: "Frictionless Success Rate",
      tooltipText: "Total number of payments authenticated over a frictionless flow successfully over the total number of payments going through a frictionless flow.",
      deltaTooltipComponent: _ => React.null,
      value: singleStatData.challenge_success_count->Int.toFloat *.
      100. /.
      singleStatData.challenge_flow_count->Int.toFloat,
      delta: 0.0,
      data: constructData(FrictionlessSuccessRate, timeSeriesData),
      statType: "Rate",
      showDelta: false,
    }
  }
}

let getSingleStatEntity: 'a => DynamicSingleStat.entityType<'colType, 't, 't2> = metrics => {
  urlConfig: [
    {
      uri: `${Window.env.apiBaseUrl}/analytics/v1/metrics/${domain}`,
      metrics: metrics->getStringListFromArrayDict,
    },
  ],
  getObjects: itemToObjMapper,
  getTimeSeriesObject: timeSeriesObjMapper,
  defaultColumns,
  getData: getStatData,
  totalVolumeCol: None,
  matrixUriMapper: _ => `${Window.env.apiBaseUrl}/analytics/v1/metrics/${domain}`,
  statSentiment: Dict.make(),
  statThreshold: Dict.make(),
}

let paymentMetricsConfig: array<LineChartUtils.metricsConfig> = [
  {
    metric_name_db: "three_ds_sdk_count",
    metric_label: "Volume",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
]

let authenticationMetricsConfig: array<LineChartUtils.metricsConfig> = [
  {
    metric_name_db: "three_ds_sdk_count",
    metric_label: "Volume",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
]

let authenticationFunnelMetricsConfig: array<LineChartUtils.metricsConfig> = [
  {
    metric_name_db: "three_ds_sdk_count",
    metric_label: "Payments requiring 3DS 2.0 Authentication",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
  {
    metric_name_db: "authentication_attempt_count",
    metric_label: "Authentication Request Attempt",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
  {
    metric_name_db: "authentication_success_count",
    metric_label: "Authentication Request Successful",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
  {
    metric_name_db: "frictionless_flow_count",
    metric_label: "Frictionless Attempted",
    disabled: true,
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
  {
    metric_name_db: "challenge_attempt_count",
    metric_label: "Authentication Attempted",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
    data_transformation_func: dict => {
      let total_auth_attempts =
        dict->getFloat("challenge_attempt_count", 0.0) +.
          dict->getFloat("frictionless_flow_count", 0.0)
      dict->Dict.set("challenge_attempt_count", total_auth_attempts->JSON.Encode.float)
      dict
    },
  },
  {
    metric_name_db: "frictionless_success_count",
    metric_label: "Frictionless Successful",
    disabled: true,
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
  {
    metric_name_db: "challenge_success_count",
    metric_label: "Authentication Successful",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
    data_transformation_func: dict => {
      let total_auth_attempts =
        dict->getFloat("challenge_success_count", 0.0) +.
          dict->getFloat("frictionless_success_count", 0.0)
      dict->Dict.set("challenge_success_count", total_auth_attempts->JSON.Encode.float)
      dict
    },
  },
]

let commonAuthenticationChartEntity = tabKeys =>
  DynamicChart.makeEntity(
    ~uri=String(`${Window.env.apiBaseUrl}/analytics/v1/metrics/${domain}`),
    ~filterKeys=tabKeys,
    ~dateFilterKeys=(startTimeFilterKey, endTimeFilterKey),
    ~currentMetrics=("Success Rate", "Volume"), // 2nd metric will be static and we won't show the 2nd metric option to the first metric
    ~cardinality=[],
    ~granularity=[],
    ~chartTypes=[SemiDonut],
    ~uriConfig=[
      {
        uri: `${Window.env.apiBaseUrl}/analytics/v1/metrics/${domain}`,
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

let authenticationFunnelChartEntity = tabKeys => {
  ...commonAuthenticationChartEntity(tabKeys),
  chartTypes: [Funnel],
  uriConfig: [
    {
      uri: `${Window.env.apiBaseUrl}/analytics/v1/metrics/${domain}`,
      timeSeriesBody: DynamicChart.getTimeSeriesChart,
      legendBody: DynamicChart.getLegendBody,
      metrics: authenticationFunnelMetricsConfig,
      timeCol: "time_bucket",
      filterKeys: tabKeys,
    },
  ],
  chartDescription: "Breakdown of ThreeDS 2.0 Journey",
}
