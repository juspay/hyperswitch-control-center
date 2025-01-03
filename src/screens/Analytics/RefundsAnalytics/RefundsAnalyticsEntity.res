open LogicUtils
open DynamicSingleStat

open AnalyticsTypes
open HSAnalyticsUtils
let domain = "refunds"

let colMapper = (col: refundColType) => {
  switch col {
  | SuccessRate => "refund_success_rate"
  | Count => "refund_count"
  | SuccessCount => "refund_success_count"
  | ProcessedAmount => "refund_processed_amount"
  | Connector => "connector"
  | RefundMethod => "refund_method"
  | Currency => "currency"
  | Status => "refund_status"
  | NoCol => ""
  }
}

let tableItemToObjMapper: 'a => refundTableType = dict => {
  {
    refund_success_rate: dict->getFloat(SuccessRate->colMapper, 0.0),
    refund_count: dict->getFloat(Count->colMapper, 0.0),
    refund_success_count: dict->getFloat(SuccessCount->colMapper, 0.0),
    refund_processed_amount: dict->getFloat(ProcessedAmount->colMapper, 0.0),
    connector: dict->getString(Connector->colMapper, "NA")->snakeToTitle,
    refund_method: dict->getString(RefundMethod->colMapper, "NA")->snakeToTitle,
    currency: dict->getString(Currency->colMapper, "NA")->snakeToTitle,
    refund_status: dict->getString(Status->colMapper, "NA")->snakeToTitle,
  }
}

let getUpdatedHeading = (~item as _, ~dateObj as _) => {
  let getHeading = colType => {
    let key = colType->colMapper
    switch colType {
    | SuccessRate => Table.makeHeaderInfo(~key, ~title="Success Rate", ~dataType=NumericType)
    | Count => Table.makeHeaderInfo(~key, ~title="Refund Count", ~dataType=NumericType)
    | SuccessCount =>
      Table.makeHeaderInfo(~key, ~title="Refund Success Count", ~dataType=NumericType)
    | ProcessedAmount =>
      Table.makeHeaderInfo(~key, ~title="Refund Processed Amount", ~dataType=NumericType)
    | Connector => Table.makeHeaderInfo(~key, ~title="Connector", ~dataType=DropDown)
    | Currency => Table.makeHeaderInfo(~key, ~title="Currency", ~dataType=DropDown)
    | RefundMethod => Table.makeHeaderInfo(~key, ~title="RefundMethod", ~dataType=DropDown)
    | Status => Table.makeHeaderInfo(~key, ~title="Status", ~dataType=DropDown)

    | NoCol => Table.makeHeaderInfo(~key, ~title="")
    }
  }
  getHeading
}

let getCell = (refundTable: refundTableType, colType: refundColType): Table.cell => {
  let usaNumberAbbreviation = labelValue => {
    shortNum(~labelValue, ~numberFormat=getDefaultNumberFormat())
  }

  let percentFormat = value => {
    `${value->Float.toFixedWithPrecision(~digits=2)}%`
  }
  switch colType {
  | SuccessRate => Numeric(refundTable.refund_success_rate, percentFormat)
  | Count => Numeric(refundTable.refund_count, usaNumberAbbreviation)
  | SuccessCount => Numeric(refundTable.refund_success_count, usaNumberAbbreviation)
  | ProcessedAmount => Numeric(refundTable.refund_processed_amount /. 100.00, usaNumberAbbreviation)
  | Connector => Text(refundTable.connector)
  | RefundMethod => Text(refundTable.refund_method)
  | Currency => Text(refundTable.currency)
  | Status => Text(refundTable.refund_status)
  | NoCol => Text("")
  }
}

let getRefundTable: JSON.t => array<refundTableType> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let refundTableEntity = (~uri) =>
  EntityType.makeEntity(
    ~uri,
    ~getObjects=getRefundTable,
    ~dataKey="queryData",
    ~defaultColumns=defaultRefundColumns,
    ~requiredSearchFieldsList=[startTimeFilterKey, endTimeFilterKey],
    ~allColumns=allRefundColumns,
    ~getCell,
    ~getHeading=getUpdatedHeading(~item=None, ~dateObj=None),
  )

let singleStateInitialValue = {
  refund_success_rate: 0.0,
  refund_count: 0,
  refund_success_count: 0,
  refund_processed_amount: 0.0,
}

let singleStateSeriesInitialValue = {
  refund_success_rate: 0.0,
  refund_count: 0,
  refund_success_count: 0,
  time_series: "",
  refund_processed_amount: 0.0,
}

let singleStateItemToObjMapper = json => {
  json
  ->JSON.Decode.object
  ->Option.map(dict => {
    refund_success_rate: dict->getFloat("refund_success_rate", 0.0),
    refund_count: dict->getInt("refund_count", 0),
    refund_success_count: dict->getInt("refund_success_count", 0),
    refund_processed_amount: dict->getFloat("refund_processed_amount_in_usd", 0.0),
  })
  ->Option.getOr({
    singleStateInitialValue
  })
}

let singleStateSeriesItemToObjMapper = json => {
  json
  ->JSON.Decode.object
  ->Option.map(dict => {
    refund_success_rate: dict->getFloat("refund_success_rate", 0.0)->setPrecision,
    refund_count: dict->getInt("refund_count", 0),
    refund_success_count: dict->getInt("refund_success_count", 0),
    time_series: dict->getString("time_bucket", ""),
    refund_processed_amount: dict->getFloat("refund_processed_amount", 0.0)->setPrecision,
  })
  ->Option.getOr({
    singleStateSeriesInitialValue
  })
}

let itemToObjMapper = json => {
  let refund_count = ref(0)
  let refund_processed_amount = ref(0.0)
  let refund_success_count = ref(0)
  let refund_success_rate = ref(0.0)

  let dataObj = json->getQueryData->Array.map(json => singleStateItemToObjMapper(json))

  dataObj->Array.forEach(item => {
    refund_count := refund_count.contents + item.refund_count
    refund_processed_amount := refund_processed_amount.contents +. item.refund_processed_amount
    refund_success_count := refund_success_count.contents + item.refund_success_count
    refund_success_rate := refund_success_rate.contents +. item.refund_success_rate
  })

  [
    {
      refund_success_rate: refund_success_rate.contents,
      refund_count: refund_count.contents,
      refund_success_count: refund_success_count.contents,
      refund_processed_amount: refund_processed_amount.contents,
    },
  ]
}

let timeSeriesObjMapper = json =>
  json->getQueryData->Array.map(json => singleStateSeriesItemToObjMapper(json))

type colT =
  | SuccessRate
  | Count
  | SuccessCount
  | ProcessedAmount

let defaultColumns: array<DynamicSingleStat.columns<colT>> = [
  {
    sectionName: "",
    columns: [SuccessRate, Count, SuccessCount, ProcessedAmount]->generateDefaultStateColumns,
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

let constructData = (key, singlestatTimeseriesData: array<refundsSingleStateSeries>) => {
  switch key {
  | "refund_success_rate" =>
    singlestatTimeseriesData
    ->Array.map(ob => (
      ob.time_series
      ->DateTimeUtils.parseAsFloat
      ->Js.Date.fromFloat
      ->DateTimeUtils.utcToISTDate
      ->Js.Date.valueOf,
      ob.refund_success_rate,
    ))
    ->Array.toSorted(compareLogic)
  | "refund_count" =>
    singlestatTimeseriesData
    ->Array.map(ob => (
      ob.time_series
      ->DateTimeUtils.parseAsFloat
      ->Js.Date.fromFloat
      ->DateTimeUtils.utcToISTDate
      ->Js.Date.valueOf,
      ob.refund_count->Int.toFloat,
    ))
    ->Array.toSorted(compareLogic)
  | "refund_success_count" =>
    singlestatTimeseriesData
    ->Array.map(ob => (
      ob.time_series
      ->DateTimeUtils.parseAsFloat
      ->Js.Date.fromFloat
      ->DateTimeUtils.utcToISTDate
      ->Js.Date.valueOf,
      ob.refund_success_count->Int.toFloat,
    ))
    ->Array.toSorted(compareLogic)
  | "refund_processed_amount" =>
    singlestatTimeseriesData
    ->Array.map(ob => (
      ob.time_series
      ->DateTimeUtils.parseAsFloat
      ->Js.Date.fromFloat
      ->DateTimeUtils.utcToISTDate
      ->Js.Date.valueOf,
      ob.refund_processed_amount /. 100.00,
    ))
    ->Array.toSorted(compareLogic)
  | _ => []
  }
}

let getStatData = (
  singleStatData: refundsSingleState,
  timeSeriesData: array<refundsSingleStateSeries>,
  deltaTimestampData: DynamicSingleStat.deltaRange,
  colType,
  _mode,
) => {
  switch colType {
  | SuccessRate => {
      title: `${domain->LogicUtils.getFirstLetterCaps} Success Rate`,
      tooltipText: "Successful refund over total refund initiated",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.refund_success_rate,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.refund_success_rate,
      delta: {
        Js.Float.fromString(
          Float.toFixedWithPrecision(singleStatData.refund_success_rate, ~digits=2),
        )
      },
      data: constructData("refund_success_rate", timeSeriesData),
      statType: "Rate",
      showDelta: false,
    }
  | Count => {
      title: "Overall Refunds",
      tooltipText: "Total refund initiated",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.refund_count->Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.refund_count->Int.toFloat,
      delta: {
        Js.Float.fromString(
          Float.toFixedWithPrecision(singleStatData.refund_count->Int.toFloat, ~digits=2),
        )
      },
      data: constructData("refund_count", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  | SuccessCount => {
      title: "Success Refunds",
      tooltipText: "Total successful refunds",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.refund_success_count->Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.refund_success_count->Int.toFloat,
      delta: {
        Js.Float.fromString(
          Float.toFixedWithPrecision(singleStatData.refund_success_count->Int.toFloat, ~digits=2),
        )
      },
      data: constructData("refund_success_count", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  | ProcessedAmount => {
      title: `Processed Amount`,
      tooltipText: `Total amount processed successfully`,
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.refund_processed_amount /. 100.00,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.refund_processed_amount /. 100.00,
      delta: {
        Js.Float.fromString(
          Float.toFixedWithPrecision(singleStatData.refund_processed_amount /. 100.00, ~digits=2),
        )
      },
      data: constructData("refund_processed_amount", timeSeriesData),
      statType: "Amount",
      showDelta: false,
    }
  }
}

let getStatSentiment = {
  open AnalyticsUtils
  [
    ("Success Refunds", Negative),
    ("Overall Refunds", Negative),
    ("Processed Amount", Negative),
  ]->Dict.fromArray
}

let getSingleStatEntity: ('a, string) => DynamicSingleStat.entityType<'colType, 't, 't2> = (
  metrics,
  uri,
) => {
  urlConfig: [
    {
      uri,
      metrics: metrics->getStringListFromArrayDict,
    },
  ],
  getObjects: itemToObjMapper,
  getTimeSeriesObject: timeSeriesObjMapper,
  defaultColumns,
  getData: getStatData,
  totalVolumeCol: None,
  matrixUriMapper: _ => uri,
  statSentiment: getStatSentiment,
}

let metricsConfig: array<LineChartUtils.metricsConfig> = [
  {
    metric_name_db: "refund_success_rate",
    metric_label: "Success Rate",
    metric_type: Rate,
    thresholdVal: None,
    step_up_threshold: None,
  },
  {
    metric_name_db: "refund_count",
    metric_label: "Volume",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
  },
]

let chartEntity = (tabKeys, ~uri) =>
  DynamicChart.makeEntity(
    ~uri=String(uri),
    ~filterKeys=tabKeys,
    ~dateFilterKeys=(startTimeFilterKey, endTimeFilterKey),
    ~currentMetrics=("refund_success_rate", "refund_count"), // 2nd metric will be static and we won't show the 2nd metric option to the first metric
    ~cardinality=[],
    ~granularity=[],
    ~chartTypes=[Line],
    ~uriConfig=[
      {
        uri,
        timeSeriesBody: DynamicChart.getTimeSeriesChart,
        legendBody: DynamicChart.getLegendBody,
        metrics: metricsConfig,
        timeCol: "time_bucket",
        filterKeys: tabKeys,
      },
    ],
    ~moduleName="Refunds Analytics",
  )
