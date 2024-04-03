type pageStateType = Loading | Failed | Success | NoData

open LogicUtils
open DynamicSingleStat

open HSAnalyticsUtils
open AnalyticsTypes
let domain = "disputes"
let makeMultiInputFieldInfo = FormRenderer.makeMultiInputFieldInfo
let makeInputFieldInfo = FormRenderer.makeInputFieldInfo

let colMapper = (col: disputeColType) => {
  switch col {
  | Connector => "connector"
  | DisputeStage => "dispute_stage"
  | TotalAmountDisputed => "total_amount_disputed"
  | TotalDisputeLostAmount => "total_dispute_lost_amount"
  | DisputesChallenged => "disputes_challenged"
  | DisputesWon => "disputes_won"
  | DisputesLost => "disputes_lost"
  | TotalDispute => "total_dispute"
  | NoCol => ""
  }
}

let reverseColMapper = (column: string) => {
  switch column {
  | "total_amount_disputed" => TotalAmountDisputed
  | "total_dispute_lost_amount" => TotalDisputeLostAmount
  | "connector" => Connector
  | "dispute_stage" => DisputeStage
  | "disputes_challenged" => DisputesChallenged
  | "disputes_won" => DisputesWon
  | "disputes_lost" => DisputesLost
  | "total_dispute" => TotalDispute
  | _ => NoCol
  }
}

let percentFormat = value => {
  `${value->Float.toFixedWithPrecision(~digits=2)}%`
}

let distribution =
  [
    ("distributionFor", "dispute_error_message"->JSON.Encode.string),
    ("distributionCardinality", "TOP_5"->JSON.Encode.string),
  ]->LogicUtils.getJsonFromArrayOfJson

let tableItemToObjMapper: Dict.t<JSON.t> => disputeTableType = dict => {
  {
    connector: dict->getString(Connector->colMapper, "Other"),
    dispute_stage: dict->getString(DisputeStage->colMapper, "Other"),
    total_amount_disputed: dict->getFloat(TotalAmountDisputed->colMapper, 0.0),
    total_dispute_lost_amount: dict->getFloat(TotalDisputeLostAmount->colMapper, 0.0),
    disputes_challenged: dict->getInt(DisputesChallenged->colMapper, 0),
    disputes_won: dict->getInt(DisputesWon->colMapper, 0),
    disputes_lost: dict->getInt(DisputesLost->colMapper, 0),
    total_dispute: dict->getInt(TotalDispute->colMapper, 0),
  }
}

let getUpdatedHeading = (
  ~item as _: option<disputeTableType>,
  ~dateObj as _: option<AnalyticsUtils.prevDates>,
) => {
  let getHeading = colType => {
    let key = colType->colMapper
    switch colType {
    | Connector =>
      Table.makeHeaderInfo(~key, ~title="Connector", ~dataType=NumericType, ~showSort=false, ())
    | DisputeStage =>
      Table.makeHeaderInfo(~key, ~title="Dispute Stage", ~dataType=NumericType, ~showSort=false, ())
    | TotalAmountDisputed =>
      Table.makeHeaderInfo(
        ~key,
        ~title="Total Amount Disputed",
        ~dataType=NumericType,
        ~showSort=false,
        (),
      )
    | TotalDisputeLostAmount =>
      Table.makeHeaderInfo(
        ~key,
        ~title="Total Dispute Lost Amount",
        ~dataType=NumericType,
        ~showSort=false,
        (),
      )
    | DisputesChallenged =>
      Table.makeHeaderInfo(
        ~key,
        ~title="Disputes Challenged",
        ~dataType=NumericType,
        ~showSort=false,
        (),
      )
    | DisputesWon =>
      Table.makeHeaderInfo(~key, ~title="Disputes Won", ~dataType=NumericType, ~showSort=false, ())
    | DisputesLost =>
      Table.makeHeaderInfo(~key, ~title="Disputes Lost", ~dataType=NumericType, ~showSort=false, ())
    | TotalDispute =>
      Table.makeHeaderInfo(~key, ~title="Total Dispute", ~dataType=NumericType, ~showSort=false, ())
    | NoCol => Table.makeHeaderInfo(~key, ~title="", ~showSort=false, ())
    }
  }
  getHeading
}

let getCell = (disputeTable: disputeTableType, colType): Table.cell => {
  let usaNumberAbbreviation = labelValue => {
    shortNum(~labelValue, ~numberFormat=getDefaultNumberFormat(), ())
  }

  switch colType {
  | TotalAmountDisputed =>
    Numeric(disputeTable.total_amount_disputed /. 100.00, usaNumberAbbreviation)
  | TotalDisputeLostAmount =>
    Numeric(disputeTable.total_dispute_lost_amount /. 100.00, usaNumberAbbreviation)
  | Connector => Text(disputeTable.connector)
  | DisputeStage => Text(disputeTable.dispute_stage)
  | DisputesChallenged =>
    Numeric(disputeTable.disputes_challenged->Int.toFloat, usaNumberAbbreviation)
  | DisputesWon => Numeric(disputeTable.disputes_won->Int.toFloat, usaNumberAbbreviation)
  | DisputesLost => Numeric(disputeTable.disputes_lost->Int.toFloat, usaNumberAbbreviation)
  | TotalDispute => Numeric(disputeTable.total_dispute->Int.toFloat, usaNumberAbbreviation)
  | NoCol => Text("")
  }
}

let getDisputeTable: JSON.t => array<disputeTableType> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let makeFieldInfo = FormRenderer.makeFieldInfo

let disputeTableEntity = EntityType.makeEntity(
  ~uri=`${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`,
  ~getObjects=getDisputeTable,
  ~dataKey="queryData",
  ~defaultColumns=defaultDisputeColumns,
  ~requiredSearchFieldsList=[startTimeFilterKey, endTimeFilterKey],
  ~allColumns=allDisputeColumns,
  ~getCell,
  ~getHeading=getUpdatedHeading(~item=None, ~dateObj=None),
  (),
)

let singleStateInitialValue = {
  total_amount_disputed: 0.0,
  total_dispute_lost_amount: 0.0,
  disputes_challenged: 0,
  disputes_won: 0,
  disputes_lost: 0,
  total_dispute: 0,
}

let singleStateSeriesInitialValue = {
  total_amount_disputed: 0.0,
  total_dispute_lost_amount: 0.0,
  disputes_challenged: 0,
  disputes_won: 0,
  disputes_lost: 0,
  total_dispute: 0,
  time_series: "",
}

let singleStateItemToObjMapper = json => {
  json
  ->JSON.Decode.object
  ->Option.map(dict => {
    total_amount_disputed: dict->getFloat("total_amount_disputed", 0.0),
    total_dispute_lost_amount: dict->getFloat("total_dispute_lost_amount", 0.0),
    disputes_challenged: dict->getInt("disputes_challenged", 0),
    disputes_won: dict->getInt("disputes_won", 0),
    disputes_lost: dict->getInt("disputes_lost", 0),
    total_dispute: dict->getInt("total_dispute", 0),
  })
  ->Option.getOr({
    singleStateInitialValue
  })
}

let singleStateSeriesItemToObjMapper = json => {
  json
  ->JSON.Decode.object
  ->Option.map(dict => {
    total_amount_disputed: dict->getFloat("total_amount_disputed", 0.0),
    total_dispute_lost_amount: dict->getFloat("total_dispute_lost_amount", 0.0),
    disputes_challenged: dict->getInt("disputes_challenged", 0),
    disputes_won: dict->getInt("disputes_won", 0),
    disputes_lost: dict->getInt("disputes_lost", 0),
    total_dispute: dict->getInt("total_dispute", 0),
    time_series: dict->getString("time_bucket", ""),
  })
  ->Option.getOr({
    singleStateSeriesInitialValue
  })
}

let itemToObjMapper = json => {
  let data = json->getQueryData->Array.map(singleStateItemToObjMapper)
  switch data[0] {
  | Some(ele) => ele
  | None => singleStateInitialValue
  }
}

let timeSeriesObjMapper = json =>
  json->getQueryData->Array.map(json => singleStateSeriesItemToObjMapper(json))

type colT =
  | TotalAmountDisputed
  | TotalDisputeLostAmount
  | DisputesChallenged
  | DisputesWon
  | DisputesLost
  | TotalDispute

let getColumns: unit => array<DynamicSingleStat.columns<colT>> = () => [
  {
    sectionName: "",
    columns: [
      TotalAmountDisputed,
      TotalDisputeLostAmount,
      DisputesChallenged,
      DisputesWon,
      DisputesLost,
      TotalDispute,
    ],
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

let constructData = (
  key,
  singlestatTimeseriesData: array<AnalyticsTypes.disputeSingleSeriesState>,
) => {
  switch key {
  | "total_amount_disputed" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.total_amount_disputed /. 100.00,
    ))
  | "total_dispute_lost_amount" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.total_dispute_lost_amount /. 100.00,
    ))
  | "disputes_challenged" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.disputes_challenged->Int.toFloat,
    ))
  | "disputes_won" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.disputes_won->Int.toFloat,
    ))
  | "disputes_lost" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.disputes_lost->Int.toFloat,
    ))
  | "total_dispute" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.total_dispute->Int.toFloat,
    ))
  | _ => []
  }
}

let getStatData = (
  singleStatData: disputeSingleStateType,
  timeSeriesData: array<disputeSingleSeriesState>,
  deltaTimestampData: DynamicSingleStat.deltaRange,
  colType,
  _mode,
) => {
  switch colType {
  | TotalAmountDisputed => {
      title: `Total Amount Disputed`,
      tooltipText: "Total amount that is disputed",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.total_amount_disputed /. 100.00,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.total_amount_disputed /. 100.00,
      delta: {
        Js.Float.fromString(
          Float.toFixedWithPrecision(singleStatData.total_amount_disputed /. 100.00, ~digits=2),
        )
      },
      data: constructData("total_amount_disputed", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  | TotalDisputeLostAmount => {
      title: `Total Dispute Lost Amount`,
      tooltipText: "Total amount lost due to a dispute",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.total_dispute_lost_amount /. 100.00,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.total_dispute_lost_amount /. 100.00,
      delta: {
        Js.Float.fromString(
          Float.toFixedWithPrecision(singleStatData.total_dispute_lost_amount /. 100.00, ~digits=2),
        )
      },
      data: constructData("total_dispute_lost_amount", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  | DisputesChallenged => {
      title: "Disputes Challenged",
      tooltipText: "Total number of disputes challenged",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.disputes_challenged->Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.disputes_challenged->Int.toFloat,
      delta: {
        Js.Float.fromString(
          Float.toFixedWithPrecision(singleStatData.disputes_challenged->Int.toFloat, ~digits=2),
        )
      },
      data: constructData("disputes_challenged", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  | DisputesWon => {
      title: `Disputes Won`,
      tooltipText: "Total number of disputes challenged and won",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.disputes_won->Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.disputes_won->Int.toFloat,
      delta: {
        Js.Float.fromString(
          Float.toFixedWithPrecision(singleStatData.disputes_won->Int.toFloat, ~digits=2),
        )
      },
      data: constructData("disputes_won", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  | DisputesLost => {
      title: `Disputes Lost`,
      tooltipText: "Total number of disputes lost",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.disputes_lost->Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.disputes_lost->Int.toFloat,
      delta: {
        Js.Float.fromString(
          Float.toFixedWithPrecision(singleStatData.disputes_lost->Int.toFloat, ~digits=2),
        )
      },
      data: constructData("disputes_lost", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  | TotalDispute => {
      title: "Total Dispute",
      tooltipText: "Total number of disputes",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.total_dispute->Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.total_dispute->Int.toFloat,
      delta: {
        Js.Float.fromString(
          Float.toFixedWithPrecision(singleStatData.total_dispute->Int.toFloat, ~digits=2),
        )
      },
      data: constructData("total_dispute", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  }
}

let getSingleStatEntity = (metrics, connector_success_rate) => {
  urlConfig: [
    {
      uri: `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`,
      metrics: metrics->getStringListFromArrayDict,
    },
  ],
  getObjects: itemToObjMapper,
  getTimeSeriesObject: timeSeriesObjMapper,
  defaultColumns: getColumns(connector_success_rate),
  getData: getStatData,
  totalVolumeCol: None,
  matrixUriMapper: _ => `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`,
}

let metricsConfig: array<LineChartUtils.metricsConfig> = [
  {
    metric_name_db: "total_amount_disputed",
    metric_label: "Total Amount Disputed",
    metric_type: Amount,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Current, Overall),
  },
  {
    metric_name_db: "total_dispute_lost_amount",
    metric_label: "Total Dispute Lost Amount",
    metric_type: Amount,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
  {
    metric_name_db: "disputes_challenged",
    metric_label: "Disputes Challenged",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Current, Overall),
  },
  {
    metric_name_db: "disputes_won",
    metric_label: "Disputes Won",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
  {
    metric_name_db: "disputes_lost",
    metric_label: "Disputes Lost",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Current, Overall),
  },
  {
    metric_name_db: "total_dispute",
    metric_label: "Total Dispute",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
]

let chartEntity = tabKeys =>
  DynamicChart.makeEntity(
    ~uri=String(`${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`),
    ~filterKeys=tabKeys,
    ~dateFilterKeys=(startTimeFilterKey, endTimeFilterKey),
    ~currentMetrics=("Dispute Status Metric", "Total Amount Disputed"), // 2nd metric will be static and we won't show the 2nd metric option to the first metric
    ~cardinality=[],
    ~granularity=[],
    ~chartTypes=[Line],
    ~uriConfig=[
      {
        uri: `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`,
        timeSeriesBody: DynamicChart.getTimeSeriesChart,
        legendBody: DynamicChart.getLegendBody,
        metrics: metricsConfig,
        timeCol: "time_bucket",
        filterKeys: tabKeys,
      },
    ],
    ~moduleName="Dispute Analytics",
    (),
  )
