open DynamicSingleStat
let domain = "payments"
open HSAnalyticsUtils
open LogicUtils

type paymentsSingleState = {
  successful_smart_retries: int,
  total_smart_retries: int,
  smart_retried_amount: float,
  currency: string,
}

type paymentsSingleStateSeries = {
  successful_smart_retries: int,
  total_smart_retries: int,
  smart_retried_amount: float,
  time_series: string,
  currency: string,
}

let singleStateInitialValue = {
  successful_smart_retries: 0,
  total_smart_retries: 0,
  smart_retried_amount: 0.0,
  currency: "NA",
}

let singleStateSeriesInitialValue = {
  successful_smart_retries: 0,
  total_smart_retries: 0,
  smart_retried_amount: 0.0,
  time_series: "",
  currency: "NA",
}

let singleStateItemToObjMapper = json => {
  json
  ->JSON.Decode.object
  ->Option.map(dict => {
    successful_smart_retries: dict->getInt("successful_smart_retries", 0),
    total_smart_retries: dict->getInt("total_smart_retries", 0),
    smart_retried_amount: dict->getFloat("smart_retried_amount", 0.0),
    currency: dict->getString("currency", "NA"),
  })
  ->Option.getOr({
    singleStateInitialValue
  })
}

let singleStateSeriesItemToObjMapper = json => {
  json
  ->JSON.Decode.object
  ->Option.map(dict => {
    successful_smart_retries: dict->getInt("successful_smart_retries", 0),
    total_smart_retries: dict->getInt("total_smart_retries", 0),
    smart_retried_amount: dict->getFloat("smart_retried_amount", 0.0),
    time_series: dict->getString("time_bucket", ""),
    currency: dict->getString("currency", "NA"),
  })
  ->Option.getOr({
    singleStateSeriesInitialValue
  })
}

let itemToObjMapper = json => {
  json->getQueryData->Array.map(singleStateItemToObjMapper)
}

let timeSeriesObjMapper = json =>
  json->getQueryData->Array.map(json => singleStateSeriesItemToObjMapper(json))

type colT =
  | SuccessfulSmartRetries
  | TotalSmartRetries
  | SmartRetriedAmount

let constructData = (key, singlestatTimeseriesData: array<paymentsSingleStateSeries>) => {
  switch key {
  | "successful_smart_retries" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.successful_smart_retries->Int.toFloat,
    ))
  | "smart_retried_amount" =>
    singlestatTimeseriesData
    ->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.smart_retried_amount /. 100.00,
    ))
    ->Array.toSorted(compareLogic)
  | "total_smart_retries" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.total_smart_retries->Int.toFloat,
    ))
  | _ => []
  }
}

let getStatData = (
  singleStatData: paymentsSingleState,
  timeSeriesData: array<paymentsSingleStateSeries>,
  deltaTimestampData: DynamicSingleStat.deltaRange,
  colType,
  _mode,
) => {
  switch colType {
  | TotalSmartRetries => {
      title: "Smart Retries made",
      tooltipText: "Total number of retries that were attempted after a failed payment attempt.",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.total_smart_retries->Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.total_smart_retries->Int.toFloat,
      delta: {
        singleStatData.total_smart_retries->Int.toFloat
      },
      data: constructData("total_smart_retries", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  | SuccessfulSmartRetries => {
      title: "Successful Smart Retries",
      tooltipText: "Total number of retries that succeeded out of all the retry attempts.",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.successful_smart_retries->Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.successful_smart_retries->Int.toFloat,
      delta: {
        singleStatData.successful_smart_retries->Int.toFloat
      },
      data: constructData("successful_smart_retries", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  | SmartRetriedAmount => {
      title: `Smart Retries Savings`,
      tooltipText: "Total savings in amount terms from retrying failed payments again through a second processor.",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.smart_retried_amount /. 100.00,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.smart_retried_amount /. 100.00,
      delta: {
        Js.Float.fromString(
          Float.toFixedWithPrecision(singleStatData.smart_retried_amount /. 100.00, ~digits=2),
        )
      },
      data: constructData("smart_retried_amount", timeSeriesData),
      statType: "Amount",
      showDelta: false,
      label: singleStatData.currency,
    }
  }
}

let getSmartRetriesSingleStatEntity = (metrics, defaultColumns) => {
  urlConfig: [
    {
      uri: `${Window.env.apiBaseUrl}/analytics/v2/metrics/${domain}`,
      metrics: metrics->getStringListFromArrayDict,
    },
  ],
  getObjects: itemToObjMapper,
  getTimeSeriesObject: timeSeriesObjMapper,
  defaultColumns,
  getData: getStatData,
  totalVolumeCol: None,
  matrixUriMapper: _ => `${Window.env.apiBaseUrl}/analytics/v2/metrics/${domain}`,
}

let getSmartRetriesAmountSingleStatEntity = (metrics, defaultColumns) => {
  urlConfig: [
    {
      uri: `${Window.env.apiBaseUrl}/analytics/v2/metrics/${domain}`,
      metrics: metrics->getStringListFromArrayDict,
    },
  ],
  getObjects: itemToObjMapper,
  getTimeSeriesObject: timeSeriesObjMapper,
  defaultColumns,
  getData: getStatData,
  totalVolumeCol: None,
  matrixUriMapper: _ => `${Window.env.apiBaseUrl}/analytics/v2/metrics/${domain}`,
}

let smartRetrivesColumns: array<DynamicSingleStat.columns<colT>> = [
  {
    sectionName: "",
    columns: [
      {
        colType: SuccessfulSmartRetries,
      },
      {
        colType: TotalSmartRetries,
      },
    ],
  },
]

let smartRetrivesAmountColumns: array<DynamicSingleStat.columns<colT>> = [
  {
    sectionName: "",
    columns: [
      {
        colType: SmartRetriedAmount,
        chartType: Table,
      },
    ],
  },
]

@react.component
let make = (~filterKeys, ~moduleName) => {
  let smartRetrieMetrics = [
    "successful_smart_retries",
    "total_smart_retries",
    "smart_retried_amount",
  ]

  let formatMetrics = arrMetrics => {
    arrMetrics->Array.map(metric => {
      [
        ("name", metric->JSON.Encode.string),
        ("desc", ""->JSON.Encode.string),
      ]->LogicUtils.getJsonFromArrayOfJson
    })
  }

  let singleStatEntity = getSmartRetriesSingleStatEntity(
    smartRetrieMetrics->formatMetrics,
    smartRetrivesColumns,
  )

  let singleStatAMountEntity = getSmartRetriesSingleStatEntity(
    smartRetrieMetrics->formatMetrics,
    smartRetrivesAmountColumns,
  )

  let formaPayload = (singleStatBodyEntity: DynamicSingleStat.singleStatBodyEntity) => {
    [
      AnalyticsUtils.getFilterRequestBody(
        ~filter=singleStatBodyEntity.filter,
        ~metrics=singleStatBodyEntity.metrics,
        ~delta=?singleStatBodyEntity.delta,
        ~startDateTime=singleStatBodyEntity.startDateTime,
        ~endDateTime=singleStatBodyEntity.endDateTime,
        ~mode=singleStatBodyEntity.mode,
        ~groupByNames=["currency"]->Some,
        ~customFilter=?singleStatBodyEntity.customFilter,
        ~source=?singleStatBodyEntity.source,
        ~granularity=singleStatBodyEntity.granularity,
        ~prefix=singleStatBodyEntity.prefix,
      )->JSON.Encode.object,
    ]
    ->JSON.Encode.array
    ->JSON.stringify
  }

  <div>
    <h2 className="font-bold text-xl text-black text-opacity-80">
      {"Smart Retries"->React.string}
    </h2>
    <div className={`flex items-start text-sm rounded-md gap-2 py-2 opacity-60`}>
      {"Note: Only date range filters are supported currently for Smart Retry metrics"->React.string}
    </div>
    <div className="relative">
      <div>
        <DynamicSingleStat
          entity={singleStatEntity}
          startTimeFilterKey
          endTimeFilterKey
          filterKeys
          moduleName
          showPercentage=false
          statSentiment={singleStatEntity.statSentiment->Option.getOr(Dict.make())}
        />
      </div>
      <div className="absolute top-0 w-full h-full grid grid-cols-3 grid-rows-2">
        <div className="col-span-2 " />
        <div className="row-span-2 h-full">
          <DynamicSingleStat
            entity=singleStatAMountEntity
            startTimeFilterKey
            endTimeFilterKey
            filterKeys
            moduleName
            showPercentage=false
            statSentiment={singleStatAMountEntity.statSentiment->Option.getOr(Dict.make())}
            formaPayload
          />
        </div>
      </div>
    </div>
  </div>
}
