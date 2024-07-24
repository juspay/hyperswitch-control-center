open LogicUtils
open DynamicSingleStat

open HSAnalyticsUtils
open AnalyticsTypes
let domain = "sdk_events"

let singleStatInitialValue = {
  payment_attempts: 0,
  sdk_rendered_count: 0,
  average_payment_time: 0.0,
  load_time: 0.0,
}

let singleStatSeriesInitialValue = {
  payment_attempts: 0,
  time_series: "",
  sdk_rendered_count: 0,
  average_payment_time: 0.0,
  load_time: 0.0,
}

let singleStatItemToObjMapper = json => {
  json
  ->JSON.Decode.object
  ->Option.map(dict => {
    payment_attempts: dict->getInt("payment_attempts", 0),
    sdk_rendered_count: dict->getInt("sdk_rendered_count", 0),
    average_payment_time: dict->getFloat("average_payment_time", 0.0) /. 1000.,
    load_time: dict->getFloat("load_time", 0.0) /. 1000.,
  })
  ->Option.getOr({
    singleStatInitialValue
  })
}

let singleStatSeriesItemToObjMapper = json => {
  json
  ->JSON.Decode.object
  ->Option.map(dict => {
    payment_attempts: dict->getInt("payment_attempts", 0),
    time_series: dict->getString("time_bucket", ""),
    sdk_rendered_count: dict->getInt("sdk_rendered_count", 0),
    average_payment_time: dict->getFloat("average_payment_time", 0.0)->setPrecision() /. 1000.,
    load_time: dict->getFloat("load_time", 0.0) /. 1000.,
  })
  ->Option.getOr({
    singleStatSeriesInitialValue
  })
}

let itemToObjMapper = json => {
  json->getQueryData->Array.map(singleStatItemToObjMapper)
}

let timeSeriesObjMapper = json =>
  json->getQueryData->Array.map(json => singleStatSeriesItemToObjMapper(json))

type colT =
  | SdkRenderedCount
  | Count
  | ConversionRate
  | DropOutRate
  | AvgPaymentTime
  | LoadTime

let defaultColumns: array<DynamicSingleStat.columns<colT>> = [
  {
    sectionName: "",
    columns: [
      SdkRenderedCount,
      Count,
      ConversionRate,
      DropOutRate,
      AvgPaymentTime,
      LoadTime,
    ]->generateDefaultStateColumns,
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

let constructData = (key, singlestatTimeseriesData) => {
  switch key {
  | "payment_attempts" =>
    singlestatTimeseriesData
    ->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.payment_attempts->Int.toFloat,
    ))
    ->Array.toSorted(compareLogic)
  | "conversion_rate" =>
    singlestatTimeseriesData
    ->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      100. *. ob.payment_attempts->Int.toFloat /. ob.sdk_rendered_count->Int.toFloat,
    ))
    ->Array.toSorted(compareLogic)
  | "drop_out_rate" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      100. -. 100. *. ob.payment_attempts->Int.toFloat /. ob.sdk_rendered_count->Int.toFloat,
    ))
  | "sdk_rendered_count" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.sdk_rendered_count->Int.toFloat,
    ))
  | "average_payment_time" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.average_payment_time,
    ))
  | "load_time" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.load_time,
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
        singleStatData.sdk_rendered_count->Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.sdk_rendered_count->Int.toFloat,
      delta: {
        Js.Float.fromString(
          Float.toFixedWithPrecision(singleStatData.sdk_rendered_count->Int.toFloat, ~digits=2),
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
        singleStatData.payment_attempts->Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.payment_attempts->Int.toFloat,
      delta: {
        singleStatData.payment_attempts->Int.toFloat
      },
      data: constructData("payment_attempts", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  | ConversionRate => {
      title: "Converted User Sessions",
      tooltipText: "Percentage of sessions where users attempted a payment",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.payment_attempts->Int.toFloat *.
        100. /.
        singleStatData.sdk_rendered_count->Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.payment_attempts->Int.toFloat *.
      100. /.
      singleStatData.sdk_rendered_count->Int.toFloat,
      delta: {
        Js.Float.fromString(
          Float.toFixedWithPrecision(
            singleStatData.payment_attempts->Int.toFloat *.
            100. /.
            singleStatData.sdk_rendered_count->Int.toFloat,
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
        singleStatData.payment_attempts->Int.toFloat *.
        100. /.
        singleStatData.sdk_rendered_count->Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: 100. -.
      singleStatData.payment_attempts->Int.toFloat *.
      100. /.
      singleStatData.sdk_rendered_count->Int.toFloat,
      delta: {
        Js.Float.fromString(
          Float.toFixedWithPrecision(singleStatData.sdk_rendered_count->Int.toFloat, ~digits=2),
        )
      },
      data: constructData("drop_out_rate", timeSeriesData),
      statType: "Rate",
      showDelta: false,
    }
  | AvgPaymentTime => {
      title: "Payment Time",
      tooltipText: "The time spent on Checkout upto the moment the payment request is sent to the backend server.",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.average_payment_time,
        deltaTimestampData.currentSr,
      ),
      value: {
        singleStatData.average_payment_time
      },
      delta: {
        Js.Float.fromString(
          Float.toFixedWithPrecision(singleStatData.average_payment_time, ~digits=2),
        )
      },
      data: constructData("average_payment_time", timeSeriesData),
      statType: "LatencyMs",
      showDelta: false,
    }
  | LoadTime => {
      title: "Checkout Load Time",
      tooltipText: "Time taken from Checkout creation to the start of its rendering",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.load_time,
        deltaTimestampData.currentSr,
      ),
      value: {
        singleStatData.load_time
      },
      delta: {
        Js.Float.fromString(Float.toFixedWithPrecision(singleStatData.load_time, ~digits=2))
      },
      data: constructData("load_time", timeSeriesData),
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
    ("TP-50 Payment Time", Negative),
    ("TP-50 Load Time", Negative),
  ]->Dict.fromArray
}

let getStatThresholds = {
  [("Dropped Out User Sessions", 40.), ("Converted User Sessions", 60.)]->Dict.fromArray
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

let userJourneyMetricsConfig: array<LineChartUtils.metricsConfig> = [
  {
    metric_name_db: "sdk_rendered_count",
    metric_label: "Volume",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
]

let userJourneyFunnelMetricsConfig: array<LineChartUtils.metricsConfig> = [
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

let commonUserJourneyChartEntity = tabKeys =>
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
    ~disableGranularity=true,
    (),
  )

let userJourneyChartEntity = tabKeys => {
  ...commonUserJourneyChartEntity(tabKeys),
  uriConfig: [
    {
      uri: `${Window.env.apiBaseUrl}/analytics/v1/metrics/${domain}`,
      timeSeriesBody: DynamicChart.getTimeSeriesChart,
      legendBody: DynamicChart.getLegendBody,
      metrics: userJourneyMetricsConfig,
      timeCol: "time_bucket",
      filterKeys: tabKeys,
    },
  ],
}

let userJourneyBarChartEntity = tabKeys => {
  ...commonUserJourneyChartEntity(tabKeys),
  chartTypes: [HorizontalBar],
  uriConfig: [
    {
      uri: `${Window.env.apiBaseUrl}/analytics/v1/metrics/${domain}`,
      timeSeriesBody: DynamicChart.getTimeSeriesChart,
      legendBody: DynamicChart.getLegendBody,
      metrics: userJourneyMetricsConfig,
      timeCol: "time_bucket",
      filterKeys: tabKeys,
    },
  ],
}

let userJourneyFunnelChartEntity = tabKeys => {
  ...commonUserJourneyChartEntity(tabKeys),
  chartTypes: [Funnel],
  uriConfig: [
    {
      uri: `${Window.env.apiBaseUrl}/analytics/v1/metrics/${domain}`,
      timeSeriesBody: DynamicChart.getTimeSeriesChart,
      legendBody: DynamicChart.getLegendBody,
      metrics: userJourneyFunnelMetricsConfig,
      timeCol: "time_bucket",
      filterKeys: tabKeys,
    },
  ],
  chartDescription: "Breakdown of users based on journey checkpoints",
}

let fixedFilterFields = _json => {
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
            ~predefinedDays=[Today, Yesterday, Day(2.0), Day(7.0), Day(30.0), ThisMonth, LastMonth],
            ~numMonths=2,
            ~disableApply=false,
            ~dateRangeLimit=180,
            ~optFieldKey=optFilterKey,
            (),
          ),
          ~inputFields=[],
          ~isRequired=false,
          (),
        ),
      }: EntityType.initialFilters<'t>
    ),
  ]

  newArr
}
