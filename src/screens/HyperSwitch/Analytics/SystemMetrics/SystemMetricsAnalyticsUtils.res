open LogicUtils
open DynamicSingleStat
open HSAnalyticsUtils
open AnalyticsTypes
let domain = "api_events"

let singleStateInitialValue = {
  latency: 0.0,
  api_count: 0,
  status_code_count: 0,
}

let singleStateSeriesInitialValue = {
  latency: 0.0,
  api_count: 0,
  status_code_count: 0,
  time_series: "",
}

let singleStateItemToObjMapper = json => {
  open Belt.Option
  json
  ->Js.Json.decodeObject
  ->map(dict => {
    latency: dict->getFloat("latency", 0.0),
    api_count: dict->getInt("api_count", 0),
    status_code_count: dict->getInt("status_code_count", 0),
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
    latency: dict->getFloat("latency", 0.0),
    api_count: dict->getInt("api_count", 0),
    status_code_count: dict->getInt("status_code_count", 0),
    time_series: dict->getString("time_bucket", ""),
  })
  ->getWithDefault({
    singleStateSeriesInitialValue
  })
}

let itemToObjMapper = json => {
  let data = json->getQueryData->Array.map(singleStateItemToObjMapper)

  data->Belt.Array.get(0)->Belt.Option.getWithDefault(singleStateInitialValue)
}

let timeSeriesObjMapper = json =>
  json->getQueryData->Array.map(json => singleStateSeriesItemToObjMapper(json))

let defaultColumns: array<
  DynamicSingleStat.columns<AnalyticsTypes.systemMetricsSingleStateMetrics>,
> = [
  {
    sectionName: "",
    columns: [Latency, ApiCount],
  },
]

let constructData = (
  key,
  singlestatTimeseriesData: array<AnalyticsTypes.systemMetricsSingleStateSeries>,
) => {
  switch key {
  | "latency" =>
    singlestatTimeseriesData
    ->Array.map(ob => (ob.time_series->DateTimeUtils.parseAsFloat, ob.latency))
    ->Js.Array2.sortInPlaceWith(compareLogic)
  | "api_count" =>
    singlestatTimeseriesData
    ->Array.map(ob => (ob.time_series->DateTimeUtils.parseAsFloat, ob.api_count->Belt.Int.toFloat))
    ->Js.Array2.sortInPlaceWith(compareLogic)
  | "status_code_count" =>
    singlestatTimeseriesData
    ->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.status_code_count->Belt.Int.toFloat,
    ))
    ->Js.Array2.sortInPlaceWith(compareLogic)
  | _ => []
  }
}

let getStatData = (
  singleStatData: systemMetricsObjectType,
  timeSeriesData: array<systemMetricsSingleStateSeries>,
  deltaTimestampData: DynamicSingleStat.deltaRange,
  colType,
  _mode,
) => {
  switch colType {
  | Latency => {
      title: "APIs latency",
      tooltipText: "API latency refers to the time it takes for a request to travel from the client to the server and back, and it also includes the connector-side latency if it is involved.",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.latency,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.latency /. 1000.0,
      delta: {
        singleStatData.latency
      },
      data: constructData("latency", timeSeriesData),
      statType: "LatencyMs",
      showDelta: false,
    }
  | ApiCount => {
      title: "API Count",
      tooltipText: "API request count is the tally of requests made to the Hyperswitch APIs, reflecting the volume of interactions and usage during a defined timeframe.",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.api_count->Belt.Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.api_count->Belt.Int.toFloat,
      delta: {
        singleStatData.api_count->Belt.Int.toFloat
      },
      data: constructData("api_count", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  }
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
}

let chartEntity = tabKeys =>
  DynamicChart.makeEntity(
    ~uri=String(`${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`),
    ~filterKeys=tabKeys,
    ~dateFilterKeys=(startTimeFilterKey, endTimeFilterKey),
    ~currentMetrics=("Success Rate", "Volume"), // 2nd metric will be static and we won't show the 2nd metric option to the first metric
    ~cardinality=[],
    ~granularity=[],
    ~chartTypes=[Line],
    ~uriConfig=[],
    ~moduleName="Payment Analytics",
    (),
  )
