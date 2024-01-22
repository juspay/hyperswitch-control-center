open LogicUtils
open DynamicSingleStat
open HSAnalyticsUtils
open AnalyticsTypes
let apiPath: analyticsAPIEndPoints = #PAYMENTS
let domain = (apiPath :> string)->String.toLowerCase
let (startTimeFilterKey, endTimeFilterKey, optFilterKey) = ("startTime", "endTime", "opt")

let singleStateInitialValue = {
  retries_count: 0,
  retries_amount_processe: 0.0,
}

let singleStateItemToObjMapper = json => {
  open Belt.Option
  json
  ->Js.Json.decodeObject
  ->map(dict => {
    retries_count: dict->getInt("retries_count", 0),
    retries_amount_processe: dict->getFloat("retries_amount_processed", 0.0),
  })
  ->Belt.Option.getWithDefault({
    singleStateInitialValue
  })
}

let itemToObjMapper = json => {
  let data = json->getQueryData->Array.map(singleStateItemToObjMapper)
  switch data[0] {
  | Some(ele) => ele
  | None => singleStateInitialValue
  }
}

let singleStateSeriesInitialValue = {
  retries_count: 0,
  retries_amount_processe: 0.0,
  time_series: "",
}

let singleStateSeriesItemToObjMapper = json => {
  open Belt.Option
  json
  ->Js.Json.decodeObject
  ->map(dict => {
    retries_count: dict->getInt("retries_count", 0),
    retries_amount_processe: dict->getFloat("retries_amount_processed", 0.0),
    time_series: dict->getString("time_bucket", ""),
  })
  ->getWithDefault({
    singleStateSeriesInitialValue
  })
}

let timeSeriesObjMapper = json =>
  json->getQueryData->Array.map(json => singleStateSeriesItemToObjMapper(json))

type metricsType =
  | RetriesCount
  | RetriesAmountProcessed

let defaultColumns: array<DynamicSingleStat.columns<metricsType>> = [
  {
    sectionName: "",
    columns: [RetriesCount, RetriesAmountProcessed],
  },
]

let constructData = (
  key,
  singlestatTimeseriesData: array<AnalyticsTypes.smartRetrySingleStateSeries>,
) => {
  switch key {
  | "retries_count" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.retries_count->Belt.Int.toFloat,
    ))
  | "retries_amount_processed" =>
    singlestatTimeseriesData
    ->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.retries_amount_processe /. 100.00,
    ))
    ->Js.Array2.sortInPlaceWith(compareLogic)
  | _ => []
  }
}

let getStatData = (
  singleStatData: smartRetrySingleState,
  timeSeriesData: array<smartRetrySingleStateSeries>,
  deltaTimestampData: DynamicSingleStat.deltaRange,
  colType,
  _mode,
) => {
  switch colType {
  | RetriesCount => {
      title: "Smart Retries made",
      tooltipText: "Total number of retries that were attempted after a failed payment attempt (Note: Only date range filters are supoorted currently)",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.retries_count->Belt.Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.retries_count->Belt.Int.toFloat,
      delta: {
        singleStatData.retries_count->Belt.Int.toFloat
      },
      data: constructData("retries_count", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  | RetriesAmountProcessed => {
      title: `Smart Retries Savings`,
      tooltipText: "Total savings in amount terms from retrying failed payments again through a second processor (Note: Only date range filters are supoorted currently)",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.retries_amount_processe /. 100.00,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.retries_amount_processe /. 100.00,
      delta: {
        Js.Float.fromString(
          Js.Float.toFixedWithPrecision(
            singleStatData.retries_amount_processe /. 100.00,
            ~digits=2,
          ),
        )
      },
      data: constructData("retries_amount_processe", timeSeriesData),
      statType: "Amount",
      showDelta: false,
    }
  }
}

let getSingleStatEntity = metrics => {
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
