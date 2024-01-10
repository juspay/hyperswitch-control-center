open LogicUtils
open DynamicSingleStat

open HSAnalyticsUtils
open AnalyticsTypes
let domain = "sdk_events"

// edited
//// single stat

let singleStateInitialValue = {
  payment_attempts: 0,
  sdk_rendered_count: 0,
  average_payment_time: 0.0,
}

let singleStateSeriesInitialValue = {
  payment_attempts: 0,
  time_series: "",
  sdk_rendered_count: 0,
  average_payment_time: 0.0,
}

let singleStatItemToObjMapper = json => {
  open Belt.Option
  json
  ->Js.Json.decodeObject
  ->map(dict => {
    payment_attempts: dict->getInt("payment_attempts", 0),
    sdk_rendered_count: dict->getInt("sdk_rendered_count", 0),
    average_payment_time: dict->getFloat("average_payment_time", 0.0) /. 1000.,
  })
  ->Belt.Option.getWithDefault({
    singleStateInitialValue
  })
}

let singleStateSeriesItemToObjMapper = json => {
  open Belt.Option
  json
  ->Js.Json.decodeObject
  ->map(dict => {
    payment_attempts: dict->getInt("payment_attempts", 0),
    time_series: dict->getString("time_bucket", ""),
    sdk_rendered_count: dict->getInt("sdk_rendered_count", 0),
    average_payment_time: dict->getFloat("average_payment_time", 0.0)->setPrecision() /. 1000.,
  })
  ->getWithDefault({
    singleStateSeriesInitialValue
  })
}

let itemToObjMapper = json => {
  let data = json->getQueryData->Array.map(singleStatItemToObjMapper)
  switch data[0] {
  | Some(ele) => ele
  | None => singleStateInitialValue
  }
}

let timeSeriesObjMapper = json =>
  json->getQueryData->Array.map(json => singleStateSeriesItemToObjMapper(json))

type colT =
  | SdkRenderedCount
  | Count
  | ConversionRate
  | DropOutRate
  | AvgPaymentTime

let defaultColumns: array<DynamicSingleStat.columns<colT>> = [
  {
    sectionName: "",
    columns: [SdkRenderedCount, Count, ConversionRate, DropOutRate, AvgPaymentTime],
  },
]

let compareLogic = (firstValue, secondValue) => {
  let (temp1, _) = firstValue
  let (temp2, _) = secondValue
  if temp1 == temp2 {
    0
  } else if temp1 > temp2 {
    -1
  } else {
    1
  }
}

let constructData = (key, singlestatTimeseriesData) => {
  switch key {
  | "payment_attempts" =>
    singlestatTimeseriesData
    ->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.payment_attempts->Belt.Int.toFloat,
    ))
    ->Js.Array2.sortInPlaceWith(compareLogic)
  | "conversion_rate" =>
    singlestatTimeseriesData
    ->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      100. *. ob.payment_attempts->Belt.Int.toFloat /. ob.sdk_rendered_count->Belt.Int.toFloat,
    ))
    ->Js.Array2.sortInPlaceWith(compareLogic)
  | "drop_out_rate" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      100. -.
      100. *. ob.payment_attempts->Belt.Int.toFloat /. ob.sdk_rendered_count->Belt.Int.toFloat,
    ))
  | "sdk_rendered_count" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.sdk_rendered_count->Belt.Int.toFloat,
    ))
  | "average_payment_time" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.average_payment_time,
    ))
  | _ => []
  }
}

let getStatData = (
  singleStatData: userJourneysSingleStat,
  timeSeriesData: array<userJourneysSingleStatSeries>,
  deltaTimestampData: DynamicSingleStat.deltaRange,
  colType,
  _mode,
) => {
  switch colType {
  | SdkRenderedCount => {
      title: "Checkout Page Renders",
      tooltipText: "Total SDK Renders",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.sdk_rendered_count->Belt.Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.sdk_rendered_count->Belt.Int.toFloat,
      delta: {
        Js.Float.fromString(
          Js.Float.toFixedWithPrecision(
            singleStatData.sdk_rendered_count->Belt.Int.toFloat,
            ~digits=2,
          ),
        )
      },
      data: constructData("sdk_rendered_count", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  | Count => {
      title: "Total Payments",
      tooltipText: "Sessions where users attempted a payment",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.payment_attempts->Belt.Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.payment_attempts->Belt.Int.toFloat,
      delta: {
        singleStatData.payment_attempts->Belt.Int.toFloat
      },
      data: constructData("payment_attempts", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  | ConversionRate => {
      title: "Converted User Sessions",
      tooltipText: "Percentage of sessions where users attempted a payment",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.payment_attempts->Belt.Int.toFloat *.
        100. /.
        singleStatData.sdk_rendered_count->Belt.Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.payment_attempts->Belt.Int.toFloat *.
      100. /.
      singleStatData.sdk_rendered_count->Belt.Int.toFloat,
      delta: {
        Js.Float.fromString(
          Js.Float.toFixedWithPrecision(
            singleStatData.payment_attempts->Belt.Int.toFloat *.
            100. /.
            singleStatData.sdk_rendered_count->Belt.Int.toFloat,
            ~digits=2,
          ),
        )
      },
      data: constructData("conversion_rate", timeSeriesData),
      statType: "Rate",
      showDelta: false,
    }
  | DropOutRate => {
      title: "Dropped Out User Sessions",
      tooltipText: "Sessions where users did not attempt a payment",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        100. -.
        singleStatData.payment_attempts->Belt.Int.toFloat *.
        100. /.
        singleStatData.sdk_rendered_count->Belt.Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: 100. -.
      singleStatData.payment_attempts->Belt.Int.toFloat *.
      100. /.
      singleStatData.sdk_rendered_count->Belt.Int.toFloat,
      delta: {
        Js.Float.fromString(
          Js.Float.toFixedWithPrecision(
            singleStatData.sdk_rendered_count->Belt.Int.toFloat,
            ~digits=2,
          ),
        )
      },
      data: constructData("drop_out_rate", timeSeriesData),
      statType: "Rate",
      showDelta: false,
    }
  | AvgPaymentTime => {
      title: "Average Payment Time",
      tooltipText: "Time taken to attempt payment",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.average_payment_time,
        deltaTimestampData.currentSr,
      ),
      value: {
        singleStatData.average_payment_time
      },
      delta: {
        Js.Float.fromString(
          Js.Float.toFixedWithPrecision(singleStatData.average_payment_time, ~digits=2),
        )
      },
      data: constructData("average_payment_time", timeSeriesData),
      statType: "LatencyMs",
      showDelta: false,
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

let userMetricsConfig: array<LineChartUtils.metricsConfig> = [
  {
    metric_name_db: "sdk_rendered_count",
    metric_label: "Volume",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
]

let userJourneyMetricsConfig: array<LineChartUtils.metricsConfig> = [
  {
    metric_name_db: "sdk_rendered_count",
    metric_label: "Checkout Page Rendered",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
  {
    metric_name_db: "payment_methods_call_count",
    metric_label: "Payment Methods Loaded",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
  {
    metric_name_db: "payment_method_selected_count",
    metric_label: "Payment Method Selected",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
  {
    metric_name_db: "payment_data_filled_count",
    metric_label: "Payment Method Data Entered",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
  {
    metric_name_db: "payment_attempts",
    metric_label: "Payment Attempted",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
]

let paymentChartEntity = tabKeys =>
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

let userChartEntity = tabKeys => {
  ...paymentChartEntity(tabKeys),
  uriConfig: [
    {
      uri: `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`,
      timeSeriesBody: DynamicChart.getTimeSeriesChart,
      legendBody: DynamicChart.getLegendBody,
      metrics: userMetricsConfig,
      timeCol: "time_bucket",
      filterKeys: tabKeys,
    },
  ],
}

let userBarChartEntity = tabKeys => {
  ...paymentChartEntity(tabKeys),
  chartTypes: [HorizontalBar],
  uriConfig: [
    {
      uri: `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`,
      timeSeriesBody: DynamicChart.getTimeSeriesChart,
      legendBody: DynamicChart.getLegendBody,
      metrics: userMetricsConfig,
      timeCol: "time_bucket",
      filterKeys: tabKeys,
    },
  ],
}

let userJourneyFunnelChartEntity = tabKeys => {
  ...paymentChartEntity(tabKeys),
  chartTypes: [Funnel],
  uriConfig: [
    {
      uri: `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`,
      timeSeriesBody: DynamicChart.getTimeSeriesChart,
      legendBody: DynamicChart.getLegendBody,
      metrics: userJourneyMetricsConfig,
      timeCol: "time_bucket",
      filterKeys: tabKeys,
    },
  ],
  chartDescription: "Breakdown of users based on journey checkpoints",
}
