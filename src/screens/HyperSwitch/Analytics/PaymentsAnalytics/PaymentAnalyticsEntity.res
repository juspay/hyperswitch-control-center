type pageStateType = Loading | Failed | Success | NoData

open LogicUtils
open DynamicSingleStat

open HSAnalyticsUtils
open AnalyticsTypes
let domain = "payments"
let makeMultiInputFieldInfo = FormRenderer.makeMultiInputFieldInfo
let makeInputFieldInfo = FormRenderer.makeInputFieldInfo

let colMapper = (col: paymentColType) => {
  switch col {
  | SuccessRate => "payment_success_rate"
  | Count => "payment_count"
  | SuccessCount => "payment_success_count"
  | PaymentErrorMessage => "payment_error_message"
  | ProcessedAmount => "payment_processed_amount"
  | AvgTicketSize => "avg_ticket_size"
  | Connector => "connector"
  | PaymentMethod => "payment_method"
  | PaymentMethodType => "payment_method_type"
  | Currency => "currency"
  | AuthType => "authentication_type"
  | Status => "status"
  | WeeklySuccessRate => "weekly_payment_success_rate"
  | NoCol => ""
  }
}

let reverseColMapper = (column: string) => {
  switch column {
  | "payment_success_rate" => SuccessRate
  | "payment_count" => Count
  | "payment_success_count" => SuccessCount
  | "payment_processed_amount" => ProcessedAmount
  | "avg_ticket_size" => AvgTicketSize
  | "connector" => Connector
  | "payment_method" => PaymentMethod
  | "payment_method_type" => PaymentMethodType
  | "currency" => Currency
  | "authentication_type" => AuthType
  | "status" => Status
  | "weekly_payment_success_rate" => WeeklySuccessRate
  | _ => NoCol
  }
}

let weeklyTableMetricsCols = [
  {
    refKey: SuccessRate->colMapper,
    newKey: WeeklySuccessRate->colMapper,
  },
]

let percentFormat = value => {
  `${value->Js.Float.toFixedWithPrecision(~digits=2)}%`
}

let getWeeklySR = dict => {
  switch dict->LogicUtils.getOptionFloat(WeeklySuccessRate->colMapper) {
  | Some(val) => val->percentFormat
  | _ => "NA"
  }
}

let distribution =
  [
    ("distributionFor", "payment_error_message"->Js.Json.string),
    ("distributionCardinality", "TOP_5"->Js.Json.string),
  ]
  ->Dict.fromArray
  ->Js.Json.object_

let tableItemToObjMapper: Dict.t<Js.Json.t> => paymentTableType = dict => {
  let parseErrorReasons = dict => {
    dict
    ->getArrayFromDict(PaymentErrorMessage->colMapper, [])
    ->Array.map(errorJson => {
      let dict = errorJson->getDictFromJsonObject

      {
        reason: dict->getString("reason", ""),
        count: dict->getInt("count", 0),
        percentage: dict->getFloat("percentage", 0.0),
      }
    })
  }

  {
    payment_success_rate: dict->getFloat(SuccessRate->colMapper, 0.0),
    payment_count: dict->getFloat(Count->colMapper, 0.0),
    payment_success_count: dict->getFloat(SuccessCount->colMapper, 0.0),
    payment_processed_amount: dict->getFloat(ProcessedAmount->colMapper, 0.0),
    avg_ticket_size: dict->getFloat(AvgTicketSize->colMapper, 0.0),
    connector: dict->getString(Connector->colMapper, "OTHER")->LogicUtils.getFirstLetterCaps(),
    payment_method: dict
    ->getString(PaymentMethod->colMapper, "OTHER")
    ->LogicUtils.getFirstLetterCaps(),
    payment_method_type: dict
    ->getString(PaymentMethodType->colMapper, "OTHER")
    ->LogicUtils.getFirstLetterCaps(),
    currency: dict->getString(Currency->colMapper, "OTHER")->String.toUpperCase,
    authentication_type: dict->getString(AuthType->colMapper, "OTHER")->String.toUpperCase,
    refund_status: dict->getString(Status->colMapper, "OTHER")->String.toUpperCase,
    weekly_payment_success_rate: dict->getWeeklySR->String.toUpperCase,
    payment_error_message: dict->parseErrorReasons,
  }
}

let getUpdatedHeading = (
  ~item as _: option<paymentTableType>,
  ~dateObj as _: option<AnalyticsUtils.prevDates>,
) => {
  let getHeading = colType => {
    let key = colType->colMapper
    switch colType {
    | SuccessRate =>
      Table.makeHeaderInfo(~key, ~title="Success Rate", ~dataType=NumericType, ~showSort=false, ())
    | WeeklySuccessRate =>
      Table.makeHeaderInfo(
        ~key,
        ~title="Current Week S.R",
        ~dataType=NumericType,
        ~showSort=false,
        (),
      )
    | Count =>
      Table.makeHeaderInfo(~key, ~title="Payment Count", ~dataType=NumericType, ~showSort=false, ())
    | SuccessCount =>
      Table.makeHeaderInfo(
        ~key,
        ~title="Payment Success Count",
        ~dataType=NumericType,
        ~showSort=false,
        (),
      )
    | ProcessedAmount =>
      Table.makeHeaderInfo(
        ~key,
        ~title="Payment Processed Amount",
        ~dataType=NumericType,
        ~showSort=false,
        (),
      )
    | PaymentErrorMessage =>
      Table.makeHeaderInfo(
        ~key,
        ~title="Top 5 Error Reasons",
        ~dataType=TextType,
        ~showSort=false,
        (),
      )
    | AvgTicketSize =>
      Table.makeHeaderInfo(
        ~key,
        ~title="Avg Ticket Size",
        ~dataType=NumericType,
        ~showSort=false,
        (),
      )
    | Connector =>
      Table.makeHeaderInfo(~key, ~title="Connector", ~dataType=DropDown, ~showSort=false, ())
    | Currency =>
      Table.makeHeaderInfo(~key, ~title="Currency", ~dataType=DropDown, ~showSort=false, ())
    | PaymentMethod =>
      Table.makeHeaderInfo(~key, ~title="Payment Method", ~dataType=DropDown, ~showSort=false, ())
    | PaymentMethodType =>
      Table.makeHeaderInfo(
        ~key,
        ~title="Payment Method Type",
        ~dataType=DropDown,
        ~showSort=false,
        (),
      )
    | AuthType =>
      Table.makeHeaderInfo(
        ~key,
        ~title="Authentication Type",
        ~dataType=DropDown,
        ~showSort=false,
        (),
      )
    | Status => Table.makeHeaderInfo(~key, ~title="Status", ~dataType=DropDown, ~showSort=false, ())

    | NoCol => Table.makeHeaderInfo(~key, ~title="", ~showSort=false, ())
    }
  }
  getHeading
}

let getCell = (paymentTable, colType): Table.cell => {
  let usaNumberAbbreviation = labelValue => {
    shortNum(~labelValue, ~numberFormat=getDefaultNumberFormat(), ())
  }

  switch colType {
  | SuccessRate => Numeric(paymentTable.payment_success_rate, percentFormat)
  | Count => Numeric(paymentTable.payment_count, usaNumberAbbreviation)
  | SuccessCount => Numeric(paymentTable.payment_success_count, usaNumberAbbreviation)
  | ProcessedAmount =>
    Numeric(paymentTable.payment_processed_amount /. 100.00, usaNumberAbbreviation)
  | AvgTicketSize => Numeric(paymentTable.avg_ticket_size /. 100.00, usaNumberAbbreviation)
  | Connector => Text(paymentTable.connector)
  | PaymentMethod => Text(paymentTable.payment_method)
  | PaymentMethodType => Text(paymentTable.payment_method_type)
  | Currency => Text(paymentTable.currency)
  | AuthType => Text(paymentTable.authentication_type)
  | Status => Text(paymentTable.refund_status)
  | WeeklySuccessRate => Text(paymentTable.weekly_payment_success_rate)
  | PaymentErrorMessage =>
    Table.CustomCell(<ErrorReasons errors={paymentTable.payment_error_message} />, "NA")
  | NoCol => Text("")
  }
}

let getPaymentTable: Js.Json.t => array<paymentTableType> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let makeFieldInfo = FormRenderer.makeFieldInfo

let paymentTableEntity = EntityType.makeEntity(
  ~uri=`${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`,
  ~getObjects=getPaymentTable,
  ~dataKey="queryData",
  ~defaultColumns=defaultPaymentColumns,
  ~requiredSearchFieldsList=[startTimeFilterKey, endTimeFilterKey],
  ~allColumns=allPaymentColumns,
  ~getCell,
  ~getHeading=getUpdatedHeading(~item=None, ~dateObj=None),
  (),
)

let singleStateInitialValue = {
  payment_success_rate: 0.0,
  payment_count: 0,
  retries_count: 0,
  retries_amount_processe: 0.0,
  payment_success_count: 0,
  connector_success_rate: 0.0,
  payment_processed_amount: 0.0,
  payment_avg_ticket_size: 0.0,
}

let singleStateSeriesInitialValue = {
  payment_success_rate: 0.0,
  payment_count: 0,
  retries_count: 0,
  retries_amount_processe: 0.0,
  payment_success_count: 0,
  time_series: "",
  payment_processed_amount: 0.0,
  connector_success_rate: 0.0,
  payment_avg_ticket_size: 0.0,
}

let singleStateItemToObjMapper = json => {
  open Belt.Option
  json
  ->Js.Json.decodeObject
  ->map(dict => {
    payment_success_rate: dict->getFloat("payment_success_rate", 0.0),
    payment_count: dict->getInt("payment_count", 0),
    payment_success_count: dict->getInt("payment_success_count", 0),
    payment_processed_amount: dict->getFloat("payment_processed_amount", 0.0),
    payment_avg_ticket_size: dict->getFloat("avg_ticket_size", 0.0),
    retries_count: dict->getInt("retries_count", 0),
    retries_amount_processe: dict->getFloat("retries_amount_processed", 0.0),
    connector_success_rate: dict->getFloat("connector_success_rate", 0.0),
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
    payment_success_rate: dict->getFloat("payment_success_rate", 0.0)->setPrecision(),
    payment_count: dict->getInt("payment_count", 0),
    payment_success_count: dict->getInt("payment_success_count", 0),
    time_series: dict->getString("time_bucket", ""),
    payment_processed_amount: dict->getFloat("payment_processed_amount", 0.0)->setPrecision(),
    payment_avg_ticket_size: dict->getFloat("avg_ticket_size", 0.0)->setPrecision(),
    retries_count: dict->getInt("retries_count", 0),
    retries_amount_processe: dict->getFloat("retries_amount_processed", 0.0),
    connector_success_rate: dict->getFloat("connector_success_rate", 0.0),
  })
  ->getWithDefault({
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
  | SuccessRate
  | Count
  | SuccessCount
  | ProcessedAmount
  | AvgTicketSize
  | RetriesCount
  | RetriesAmountProcessed
  | ConnectorSuccessRate

let getColumns: bool => array<DynamicSingleStat.columns<colT>> = connector_success_rate => [
  {
    sectionName: "",
    columns: connector_success_rate
      ? [
          SuccessRate,
          Count,
          SuccessCount,
          ProcessedAmount,
          AvgTicketSize,
          RetriesCount,
          RetriesAmountProcessed,
          ConnectorSuccessRate,
        ]
      : [
          SuccessRate,
          Count,
          SuccessCount,
          ProcessedAmount,
          AvgTicketSize,
          RetriesCount,
          RetriesAmountProcessed,
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
  singlestatTimeseriesData: array<AnalyticsTypes.paymentsSingleStateSeries>,
) => {
  switch key {
  | "payment_success_rate" =>
    singlestatTimeseriesData
    ->Array.map(ob => (ob.time_series->DateTimeUtils.parseAsFloat, ob.payment_success_rate))
    ->Js.Array2.sortInPlaceWith(compareLogic)
  | "payment_count" =>
    singlestatTimeseriesData
    ->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.payment_count->Belt.Int.toFloat,
    ))
    ->Js.Array2.sortInPlaceWith(compareLogic)
  | "payment_success_count" =>
    singlestatTimeseriesData
    ->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.payment_success_count->Belt.Int.toFloat,
    ))
    ->Js.Array2.sortInPlaceWith(compareLogic)
  | "payment_processed_amount" =>
    singlestatTimeseriesData
    ->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.payment_processed_amount /. 100.00,
    ))
    ->Js.Array2.sortInPlaceWith(compareLogic)
  | "payment_avg_ticket_size" =>
    singlestatTimeseriesData
    ->Array.map(ob => (
      ob.time_series->DateTimeUtils.parseAsFloat,
      ob.payment_avg_ticket_size /. 100.00,
    ))
    ->Js.Array2.sortInPlaceWith(compareLogic)
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
  | "connector_success_rate" =>
    singlestatTimeseriesData
    ->Array.map(ob => (ob.time_series->DateTimeUtils.parseAsFloat, ob.connector_success_rate))
    ->Js.Array2.sortInPlaceWith(compareLogic)
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
  | SuccessRate => {
      title: "Overall Conversion Rate",
      tooltipText: "Total successful payments processed out of total payments created (This includes user dropouts at shopping cart and checkout page)",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.payment_success_rate,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.payment_success_rate,
      delta: {
        singleStatData.payment_success_rate
      },
      data: constructData("payment_success_rate", timeSeriesData),
      statType: "Rate",
      showDelta: false,
    }
  | Count => {
      title: "Overall Payments",
      tooltipText: "Total payments initiated",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.payment_count->Belt.Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.payment_count->Belt.Int.toFloat,
      delta: {
        singleStatData.payment_count->Belt.Int.toFloat
      },
      data: constructData("payment_count", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  | SuccessCount => {
      title: "Success Payments",
      tooltipText: "Total number of payments with status as succeeded. ",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.payment_success_count->Belt.Int.toFloat,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.payment_success_count->Belt.Int.toFloat,
      delta: {
        Js.Float.fromString(
          Js.Float.toFixedWithPrecision(
            singleStatData.payment_success_count->Belt.Int.toFloat,
            ~digits=2,
          ),
        )
      },
      data: constructData("payment_success_count", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
  | ProcessedAmount => {
      title: `Processed Amount`,
      tooltipText: "Sum of amount of all payments with status = succeeded (Please note that there could be payments which could be authorized but not captured. Such payments are not included in the processed amount, because non-captured payments will not be settled to your merchant account by your payment processor)",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.payment_processed_amount /. 100.00,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.payment_processed_amount /. 100.00,
      delta: {
        Js.Float.fromString(
          Js.Float.toFixedWithPrecision(
            singleStatData.payment_processed_amount /. 100.00,
            ~digits=2,
          ),
        )
      },
      data: constructData("payment_processed_amount", timeSeriesData),
      statType: "Amount",
      showDelta: false,
    }
  | AvgTicketSize => {
      title: `Avg Ticket Size`,
      tooltipText: "The total amount for which payments were created divided by the total number of payments created.",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.payment_avg_ticket_size /. 100.00,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.payment_avg_ticket_size /. 100.00,
      delta: {
        Js.Float.fromString(
          Js.Float.toFixedWithPrecision(
            singleStatData.payment_avg_ticket_size /. 100.00,
            ~digits=2,
          ),
        )
      },
      data: constructData("payment_avg_ticket_size", timeSeriesData),
      statType: "Volume",
      showDelta: false,
    }
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
  | ConnectorSuccessRate => {
      title: "Payment Success Rate",
      tooltipText: "Total successful payments processed out of all user confirmed payments",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.connector_success_rate,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.connector_success_rate,
      delta: {
        singleStatData.connector_success_rate
      },
      data: constructData("connector_success_rate", timeSeriesData),
      statType: "Rate",
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
    metric_name_db: "payment_count",
    metric_label: "Volume",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
  {
    metric_name_db: "payment_success_rate",
    metric_label: "Success Rate",
    metric_type: Rate,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Current, Overall),
  },
  {
    metric_name_db: "payment_processed_amount",
    metric_label: "Processed Amount",
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
    ~currentMetrics=("Success Rate", "Volume"), // 2nd metric will be static and we won't show the 2nd metric option to the first metric
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
    ~moduleName="Payment Analytics",
    (),
  )
