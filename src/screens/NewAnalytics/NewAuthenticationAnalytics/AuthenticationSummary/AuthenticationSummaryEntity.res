type pageStateType = Loading | Failed | Success | NoData

open LogicUtils

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
  | ClientSource => "client_source"
  | ClientVersion => "client_version"
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
  `${value->Float.toFixedWithPrecision(~digits=2)}%`
}

let getWeeklySR = dict => {
  switch dict->LogicUtils.getOptionFloat(WeeklySuccessRate->colMapper) {
  | Some(val) => val->percentFormat
  | _ => "NA"
  }
}

let distribution =
  [
    ("distributionFor", "payment_error_message"->JSON.Encode.string),
    ("distributionCardinality", "TOP_5"->JSON.Encode.string),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object

let tableItemToObjMapper: Dict.t<JSON.t> => paymentTableType = dict => {
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
    connector: dict->getString(Connector->colMapper, "NA")->snakeToTitle,
    payment_method: dict->getString(PaymentMethod->colMapper, "NA")->snakeToTitle,
    payment_method_type: dict->getString(PaymentMethodType->colMapper, "NA")->snakeToTitle,
    currency: dict->getString(Currency->colMapper, "NA")->snakeToTitle,
    authentication_type: dict->getString(AuthType->colMapper, "NA")->snakeToTitle,
    refund_status: dict->getString(Status->colMapper, "NA")->snakeToTitle,
    client_source: dict->getString(ClientSource->colMapper, "NA")->snakeToTitle,
    client_version: dict->getString(ClientVersion->colMapper, "NA")->snakeToTitle,
    weekly_payment_success_rate: dict->getWeeklySR->String.toUpperCase,
    payment_error_message: dict->parseErrorReasons,
  }
}

let getUpdatedHeading = (~item as _, ~dateObj as _) => {
  let getHeading = colType => {
    let key = colType->colMapper
    switch colType {
    | SuccessRate => Table.makeHeaderInfo(~key, ~title="Success Rate", ~dataType=NumericType)
    | WeeklySuccessRate =>
      Table.makeHeaderInfo(~key, ~title="Current Week S.R", ~dataType=NumericType)
    | Count => Table.makeHeaderInfo(~key, ~title="Payment Count", ~dataType=NumericType)
    | SuccessCount =>
      Table.makeHeaderInfo(~key, ~title="Payment Success Count", ~dataType=NumericType)
    | ProcessedAmount =>
      Table.makeHeaderInfo(~key, ~title="Payment Processed Amount", ~dataType=NumericType)
    | PaymentErrorMessage =>
      Table.makeHeaderInfo(~key, ~title="Top 5 Error Reasons", ~dataType=TextType)
    | AvgTicketSize => Table.makeHeaderInfo(~key, ~title="Avg Ticket Size", ~dataType=NumericType)
    | Connector => Table.makeHeaderInfo(~key, ~title="Connector", ~dataType=DropDown)
    | Currency => Table.makeHeaderInfo(~key, ~title="Currency", ~dataType=DropDown)
    | PaymentMethod => Table.makeHeaderInfo(~key, ~title="Payment Method", ~dataType=DropDown)
    | PaymentMethodType =>
      Table.makeHeaderInfo(~key, ~title="Payment Method Type", ~dataType=DropDown)
    | AuthType => Table.makeHeaderInfo(~key, ~title="Authentication Type", ~dataType=DropDown)
    | Status => Table.makeHeaderInfo(~key, ~title="Status", ~dataType=DropDown)
    | ClientSource => Table.makeHeaderInfo(~key, ~title="Client Source", ~dataType=DropDown)
    | ClientVersion => Table.makeHeaderInfo(~key, ~title="Client Version", ~dataType=DropDown)

    | NoCol => Table.makeHeaderInfo(~key, ~title="")
    }
  }
  getHeading
}

let getCell = (paymentTable, colType): Table.cell => {
  let usaNumberAbbreviation = labelValue => {
    shortNum(~labelValue, ~numberFormat=getDefaultNumberFormat())
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
  | ClientSource => Text(paymentTable.client_source)
  | ClientVersion => Text(paymentTable.client_version)
  | WeeklySuccessRate => Text(paymentTable.weekly_payment_success_rate)
  | PaymentErrorMessage =>
    Table.CustomCell(<ErrorReasons errors={paymentTable.payment_error_message} />, "NA")
  | NoCol => Text("")
  }
}

let getPaymentTable: JSON.t => array<paymentTableType> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let makeFieldInfo = FormRenderer.makeFieldInfo

let paymentTableEntity = (~uri) =>
  EntityType.makeEntity(
    ~uri,
    ~getObjects=getPaymentTable,
    ~dataKey="queryData",
    ~defaultColumns=defaultPaymentColumns,
    ~requiredSearchFieldsList=[startTimeFilterKey, endTimeFilterKey],
    ~allColumns=allPaymentColumns,
    ~getCell,
    ~getHeading=getUpdatedHeading(~item=None, ~dateObj=None),
  )

let metricsConfig: array<LineChartUtils.metricsConfig> = [
  {
    metric_name_db: "payment_success_rate",
    metric_label: "Success Rate",
    metric_type: Rate,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Current, Overall),
  },
  {
    metric_name_db: "payment_count",
    metric_label: "Volume",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
    legendOption: (Average, Overall),
  },
]

let chartEntity = (tabKeys, ~uri) =>
  DynamicChart.makeEntity(
    ~uri=String(uri),
    ~filterKeys=tabKeys,
    ~dateFilterKeys=(startTimeFilterKey, endTimeFilterKey),
    ~currentMetrics=("Success Rate", "Volume"), // 2nd metric will be static and we won't show the 2nd metric option to the first metric
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
    ~moduleName="Payment Analytics",
    ~enableLoaders=true,
  )
