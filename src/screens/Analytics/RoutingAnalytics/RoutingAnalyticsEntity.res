open LogicUtils
open HSAnalyticsUtils
open DynamicSingleStat

let domain = "routing"

// Column types for routing analytics table
type routingColType =
  | RoutingApproach
  | TrafficPercent
  | PaymentCount
  | AuthRatePercent
  | ProcessedAmount
  | NoCol

// Single stat column types for summary cards
type routingStatColType =
  | PaymentSuccessRate
  | PaymentCount
  | PaymentSuccessCount
  | PaymentProcessedAmount
  | NoStatCol

// Summary stats data type
type routingSummaryStats = {
  payment_success_rate: float,
  payment_count: int,
  payment_success_count: int,
  payment_processed_amount: float,
}

// Single stat time series data type
type routingSingleStateSeries = {
  time_series: string,
  payment_success_rate: float,
  payment_count: int,
  payment_success_count: int,
  payment_processed_amount: float,
}

let colMapper = (col: routingColType) => {
  switch col {
  | RoutingApproach => "routing_approach"
  | TrafficPercent => "traffic_percent"
  | PaymentCount => "payment_count"
  | AuthRatePercent => "payment_success_rate"
  | ProcessedAmount => "payment_processed_amount"
  | NoCol => ""
  }
}

let reverseColMapper = (column: string) => {
  switch column {
  | "routing_approach" => RoutingApproach
  | "traffic_percent" => TrafficPercent
  | "payment_count" => PaymentCount
  | "payment_success_rate" => AuthRatePercent
  | "payment_processed_amount" => ProcessedAmount
  | _ => NoCol
  }
}

// Table type for routing analytics
type routingTableType = {
  routing_approach: string,
  traffic_percent: float,
  payment_count: float,
  auth_rate_percent: float,
  processed_amount: float,
}

let statColMapper = (col: routingStatColType) => {
  switch col {
  | PaymentSuccessRate => "payment_success_rate"
  | PaymentCount => "payment_count"
  | PaymentSuccessCount => "payment_success_count"
  | PaymentProcessedAmount => "payment_processed_amount"
  | NoStatCol => ""
  }
}

let percentFormat = value => {
  `${value->Float.toFixedWithPrecision(~digits=2)}%`
}

let usaNumberAbbreviation = labelValue => {
  shortNum(~labelValue, ~numberFormat=getDefaultNumberFormat())
}

let tableItemToObjMapper: Dict.t<JSON.t> => routingTableType = dict => {
  {
    routing_approach: dict->getString(RoutingApproach->colMapper, "NA")->snakeToTitle,
    traffic_percent: dict->getFloat(TrafficPercent->colMapper, 0.0),
    payment_count: dict->getFloat(PaymentCount->colMapper, 0.0),
    auth_rate_percent: dict->getFloat(AuthRatePercent->colMapper, 0.0),
    processed_amount: dict->getFloat(ProcessedAmount->colMapper, 0.0),
  }
}

let getUpdatedHeading = (~item as _, ~dateObj as _) => {
  let getHeading = colType => {
    let key = colType->colMapper
    switch colType {
    | RoutingApproach => Table.makeHeaderInfo(~key, ~title="Routing Logic", ~dataType=DropDown)
    | TrafficPercent => Table.makeHeaderInfo(~key, ~title="Traffic %", ~dataType=NumericType)
    | PaymentCount => Table.makeHeaderInfo(~key, ~title="# of Payments", ~dataType=NumericType)
    | AuthRatePercent => Table.makeHeaderInfo(~key, ~title="Auth Rate %", ~dataType=NumericType)
    | ProcessedAmount =>
      Table.makeHeaderInfo(~key, ~title="Processed Amount", ~dataType=NumericType)
    | NoCol => Table.makeHeaderInfo(~key, ~title="")
    }
  }
  getHeading
}

let getCell = (routingTable, colType): Table.cell => {
  switch colType {
  | RoutingApproach => Text(routingTable.routing_approach)
  | TrafficPercent => Numeric(routingTable.traffic_percent, percentFormat)
  | PaymentCount => Numeric(routingTable.payment_count, usaNumberAbbreviation)
  | AuthRatePercent => Numeric(routingTable.auth_rate_percent, percentFormat)
  | ProcessedAmount => Numeric(routingTable.processed_amount /. 100.00, usaNumberAbbreviation)
  | NoCol => Text("")
  }
}

let getRoutingTable: JSON.t => array<routingTableType> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

// Default columns for routing analytics table
let defaultRoutingColumns = [
  RoutingApproach,
  TrafficPercent,
  PaymentCount,
  AuthRatePercent,
  ProcessedAmount,
]

// All available columns for routing analytics table
let allRoutingColumns = [
  RoutingApproach,
  TrafficPercent,
  PaymentCount,
  AuthRatePercent,
  ProcessedAmount,
]

let routingTableEntity = (~uri) =>
  EntityType.makeEntity(
    ~uri,
    ~getObjects=getRoutingTable,
    ~dataKey="queryData",
    ~defaultColumns=defaultRoutingColumns,
    ~requiredSearchFieldsList=[startTimeFilterKey, endTimeFilterKey],
    ~allColumns=allRoutingColumns,
    ~getCell,
    ~getHeading=getUpdatedHeading(~item=None, ~dateObj=None),
  )

// JSON-compatible table entity for LoadedTableWithCustomColumns
let routingTableEntityForLoadedTable = (~uri) => {
  let getObjectsFromJson = (json: JSON.t) => {
    json->getArrayFromJson([])
  }

  let getCellFromJson = (jsonItem: JSON.t, colType): Table.cell => {
    let dict = jsonItem->getDictFromJsonObject
    let routingTable = tableItemToObjMapper(dict)
    getCell(routingTable, colType)
  }

  EntityType.makeEntity(
    ~uri,
    ~getObjects=getObjectsFromJson,
    ~dataKey="queryData",
    ~defaultColumns=defaultRoutingColumns,
    ~requiredSearchFieldsList=[startTimeFilterKey, endTimeFilterKey],
    ~allColumns=allRoutingColumns,
    ~getCell=getCellFromJson,
    ~getHeading=getUpdatedHeading(~item=None, ~dateObj=None),
  )
}

// Summary stats functions
let summaryStatsInitialValue = {
  payment_success_rate: 0.0,
  payment_count: 0,
  payment_success_count: 0,
  payment_processed_amount: 0.0,
}

let summaryStatsItemToObjMapper: Dict.t<JSON.t> => routingSummaryStats = dict => {
  {
    payment_success_rate: dict->getFloat(PaymentSuccessRate->statColMapper, 0.0),
    payment_count: dict->getInt(PaymentCount->statColMapper, 0),
    payment_success_count: dict->getInt(PaymentSuccessCount->statColMapper, 0),
    payment_processed_amount: dict->getFloat(PaymentProcessedAmount->statColMapper, 0.0),
  }
}

let getSummaryStatsData: JSON.t => array<routingSummaryStats> = json => {
  json
  ->getQueryData
  ->Array.map(item => {
    summaryStatsItemToObjMapper(item->getDictFromJsonObject)
  })
}

let timeSeriesObjMapper: Dict.t<JSON.t> => routingSingleStateSeries = dict => {
  {
    time_series: dict->getString("time_bucket", ""),
    payment_success_rate: dict->getFloat(PaymentSuccessRate->statColMapper, 0.0),
    payment_count: dict->getInt(PaymentCount->statColMapper, 0),
    payment_success_count: dict->getInt(PaymentSuccessCount->statColMapper, 0),
    payment_processed_amount: dict->getFloat(PaymentProcessedAmount->statColMapper, 0.0),
  }
}

let getTimeSeriesData: JSON.t => array<routingSingleStateSeries> = json => {
  json
  ->getQueryData
  ->Array.map(item => {
    timeSeriesObjMapper(item->getDictFromJsonObject)
  })
}

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

let constructData = (key, singlestatTimeseriesData: array<routingSingleStateSeries>) => {
  switch key {
  | "payment_success_rate" =>
    singlestatTimeseriesData
    ->Array.map(ob => (ob.time_series->DateTimeUtils.parseAsFloat, ob.payment_success_rate))
    ->Array.toSorted(compareLogic)
  | "payment_count" =>
    singlestatTimeseriesData
    ->Array.map(ob => (ob.time_series->DateTimeUtils.parseAsFloat, ob.payment_count->Int.toFloat))
    ->Array.toSorted(compareLogic)
  | "payment_success_count" =>
    singlestatTimeseriesData
    ->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.payment_success_count->Int.toFloat,
    ))
    ->Array.toSorted(compareLogic)
  | "payment_processed_amount" =>
    singlestatTimeseriesData
    ->Array.map(ob => (ob.time_series->DateTimeUtils.parseAsFloat, ob.payment_processed_amount))
    ->Array.toSorted(compareLogic)
  | _ => []
  }
}

let getStatData = (
  singleStatData: routingSummaryStats,
  timeSeriesData: array<routingSingleStateSeries>,
  deltaTimestampData: DynamicSingleStat.deltaRange,
  colType,
  _mode,
) => {
  switch colType {
  | PaymentSuccessRate => {
      title: "Overall Authentication Rate",
      tooltipText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.payment_success_rate,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.payment_success_rate,
      delta: singleStatData.payment_success_rate,
      data: constructData("payment_success_rate", timeSeriesData),
      statType: "Rate",
      showDelta: false,
    }
  | PaymentCount => {
      title: "First Attempt Authentication Rate (FAAR)",
      tooltipText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.payment_count->Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.payment_count->Int.toFloat,
      delta: singleStatData.payment_count->Int.toFloat,
      data: constructData("payment_count", timeSeriesData),
      statType: "Rate",
      showDelta: false,
    }
  | PaymentSuccessCount => {
      title: "Total Successful",
      tooltipText: "Out of 5000 transactions",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.payment_success_count->Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.payment_success_count->Int.toFloat,
      delta: singleStatData.payment_success_count->Int.toFloat,
      data: constructData("payment_success_count", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  | PaymentProcessedAmount => {
      title: "Total Failure",
      tooltipText: "Out of 5000 transactions",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.payment_processed_amount /. 100.0,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.payment_processed_amount /. 100.0,
      delta: singleStatData.payment_processed_amount /. 100.0,
      data: constructData("payment_processed_amount", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  | NoStatCol => {
      title: "",
      tooltipText: "",
      deltaTooltipComponent: _ => React.null,
      value: 0.0,
      delta: 0.0,
      data: [],
      statType: "Volume",
      showDelta: false,
    }
  }
}

// Single stat columns configuration
let summaryStatsColumns: array<DynamicSingleStat.columns<routingStatColType>> = [
  {
    sectionName: "",
    columns: [
      PaymentSuccessRate,
      PaymentCount,
      PaymentSuccessCount,
      PaymentProcessedAmount,
    ]->generateDefaultStateColumns,
  },
]

// Single stat entity
let routingSingleStatEntity = (~uri) => {
  urlConfig: [
    {
      uri,
      metrics: [
        PaymentSuccessRate->statColMapper,
        PaymentCount->statColMapper,
        PaymentSuccessCount->statColMapper,
        PaymentProcessedAmount->statColMapper,
      ],
    },
  ],
  getObjects: getSummaryStatsData,
  getTimeSeriesObject: getTimeSeriesData,
  defaultColumns: summaryStatsColumns,
  getData: getStatData,
  totalVolumeCol: None,
  matrixUriMapper: _ => uri,
  source: "BATCH",
}

// Chart metrics configuration for donut charts
let routingDistributionMetricsConfig: array<LineChartUtils.metricsConfig> = [
  {
    metric_name_db: "payment_count",
    metric_label: "Volume",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
]

let routingApproachDistributionMetricsConfig: array<LineChartUtils.metricsConfig> = [
  {
    metric_name_db: "payment_count",
    metric_label: "Routing Logic",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
]

// Volume Distribution Chart Entity
let volumeDistributionChartEntity = (tabKeys, uri) =>
  DynamicChart.makeEntity(
    ~uri=String(uri),
    ~filterKeys=tabKeys,
    ~dateFilterKeys=(startTimeFilterKey, endTimeFilterKey),
    ~currentMetrics=("Volume", "Volume"),
    ~cardinality=[],
    ~granularity=[],
    ~chartTypes=[SemiDonut],
    ~uriConfig=[
      {
        uri,
        timeSeriesBody: DynamicChart.getTimeSeriesChart,
        legendBody: DynamicChart.getLegendBody,
        metrics: routingDistributionMetricsConfig,
        timeCol: "time_bucket",
        filterKeys: tabKeys,
      },
    ],
    ~moduleName="Volume Distribution",
    ~getGranularity={
      (~startTime as _, ~endTime as _) => {
        [""]
      }
    },
  )

// Routing Logic Distribution Chart Entity
let routingLogicDistributionChartEntity = (tabKeys, uri) =>
  DynamicChart.makeEntity(
    ~uri=String(uri),
    ~filterKeys=tabKeys,
    ~dateFilterKeys=(startTimeFilterKey, endTimeFilterKey),
    ~currentMetrics=("Routing Logic", "Routing Logic"),
    ~cardinality=[],
    ~granularity=[],
    ~chartTypes=[SemiDonut],
    ~uriConfig=[
      {
        uri,
        timeSeriesBody: DynamicChart.getTimeSeriesChart,
        legendBody: DynamicChart.getLegendBody,
        metrics: routingApproachDistributionMetricsConfig,
        timeCol: "time_bucket",
        filterKeys: tabKeys,
      },
    ],
    ~moduleName="Routing Logic Distribution",
    ~getGranularity={
      (~startTime as _, ~endTime as _) => {
        [""]
      }
    },
  )

// Time Series Chart metrics configuration
let successOverTimeMetricsConfig: array<LineChartUtils.metricsConfig> = [
  {
    metric_name_db: "payment_success_rate",
    metric_label: "Success Rate",
    metric_type: Rate,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
]

let volumeOverTimeMetricsConfig: array<LineChartUtils.metricsConfig> = [
  {
    metric_name_db: "payment_count",
    metric_label: "Volume",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
]

// Success Over Time Chart Entity
let successOverTimeChartEntity = (tabKeys, uri) =>
  DynamicChart.makeEntity(
    ~uri=String(uri),
    ~filterKeys=tabKeys,
    ~dateFilterKeys=(startTimeFilterKey, endTimeFilterKey),
    ~currentMetrics=("Success Rate", "Success Rate"),
    ~cardinality=[],
    ~granularity=[],
    ~chartTypes=[Line],
    ~uriConfig=[
      {
        uri,
        timeSeriesBody: DynamicChart.getTimeSeriesChart,
        legendBody: DynamicChart.getLegendBody,
        metrics: successOverTimeMetricsConfig,
        timeCol: "time_bucket",
        filterKeys: tabKeys,
      },
    ],
    ~moduleName="Success Over Time",
    ~getGranularity={
      (~startTime as _, ~endTime as _) => {
        ["G_ONEDAY"]
      }
    },
  )

// Volume Over Time Chart Entity
let volumeOverTimeChartEntity = (tabKeys, uri) =>
  DynamicChart.makeEntity(
    ~uri=String(uri),
    ~filterKeys=tabKeys,
    ~dateFilterKeys=(startTimeFilterKey, endTimeFilterKey),
    ~currentMetrics=("Volume", "Volume"),
    ~cardinality=[],
    ~granularity=[],
    ~chartTypes=[Line],
    ~uriConfig=[
      {
        uri,
        timeSeriesBody: DynamicChart.getTimeSeriesChart,
        legendBody: DynamicChart.getLegendBody,
        metrics: volumeOverTimeMetricsConfig,
        timeCol: "time_bucket",
        filterKeys: tabKeys,
      },
    ],
    ~moduleName="Volume Over Time",
    ~getGranularity={
      (~startTime as _, ~endTime as _) => {
        ["G_ONEDAY"]
      }
    },
  )

// Filter functions for DynamicFilter component
let initialFixedFilterFields = (_json, ~events=?) => {
  let events = switch events {
  | Some(fn) => fn
  | None => _ => ()
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
            ~optFieldKey=optFilterKey,
            ~events,
          ),
          ~inputFields=[],
          ~isRequired=false,
        ),
      }: EntityType.initialFilters<'t>
    ),
  ]

  newArr
}
