open LogicUtils
open EntityType

let merchantId = ""
let mid = Recoil.atom(. "mid", merchantId)

let os = ""
let platform = Recoil.atom(. "platform", os)

let makeMultiInputFieldInfo = FormRenderer.makeMultiInputFieldInfo
let makeInputFieldInfo = FormRenderer.makeInputFieldInfo
let makeFieldInfo = FormRenderer.makeFieldInfo
let (startTimeFilterKey, endTimeFilterKey, optFilterKey) = ("startTime", "endTime", "opt")
let tabKeys = ["merchant_id", "platform", "product"]
let filterKeys = ["merchant_id", "platform", "product"]

type mapper = {
  name: string,
  desc: Js.Json.t,
}

type product = {
  product_count: int,
  product_integrated: string,
}

type detailedTable = {
  status: string,
  category: string,
  stage: string,
  sample_sessions: array<string>,
  priority: string,
  tooltip: string,
  header: string,
  product_integrated: string,
  stage_name: string,
  test_case: string,
}

type errorTable = {
  error_code: string,
  actionable: string,
  error_message: string,
  error_count: int,
  sample_sessions: array<string>,
}

type integrationBody = {
  filter?: Js.Json.t,
  metrics?: array<string>,
  startDateTime: string,
  endDateTime: string,
  source: string,
  groupByNames?: array<string>,
  delta: bool,
}

type platformList = {platform: string}

type donutData = {
  total_checklist: int,
  success_checklist: int,
  total_critical: int,
  success_critical: int,
}

let apiStages = [
  "Create customer",
  "Get customer",
  "Update customer",
  "Create order",
  "order status",
  "Refund",
  "Create wallet",
  "List wallet",
  "Authenticate Wallet",
  "Link Wallet",
  "Delink Wallet",
  "Get Wallet",
  "Refresh Wallet",
  "Topup Wallet",
  "Credit/Debit Card payment",
  "NetBanking payment",
  "Wallet payment",
  "Wallet Direct Debit",
  "UPI COLLECT Payment",
  "UPI INTENT Payment",
  "Verify VPA",
  "Payment methods",
  "Eligibility",
  "List Mandate",
  "Revoke Mandate",
  "Mandate Execution",
  "Mandate Registration",
  "Notification API",
  "Delete Card",
  "List Stored Cards",
  "Session API",
  "x_merchant_id",
  "x_mid_sess",
  "x_mid_order_status",
  "payment_resp_verification",
  "unique_req_id",
  "refund_unique_id_len",
  "refund_success",
  "order_len",
  "alphanumeric_unique",
  "alphameric_unique",
  "Mandate with Payment Methods",
  "Mandate Order Status",
  "Card Info",
  "Order Create",
  "Bank Account Validation",
  "IFSC",
  "Validation Status",
  "Get Balance",
  "Attempted",
  "mandate_register",
  "mandate_execution",
  "mandate_register_upi",
  "mandate_register_card",
  "mandate_register_wallet",
  "mandate_register_nb",
  "mandate_execution_upi",
  "mandate_execution_card",
  "mandate_execution_wallet",
  "mandate_execution_nb",
  "conflicted_txn",
  "multiple_charged",
]

let nonPlatformSpecific = [
  "payment_resp_verification",
  "unique_req_id",
  "refund_unique_id_len",
  "refund_success",
  "order_len",
  "alphanumeric_unique",
  "alphameric_unique",
  "mandate_register",
  "mandate_execution",
  "mandate_register_upi",
  "mandate_register_card",
  "mandate_register_wallet",
  "mandate_register_nb",
  "mandate_execution_upi",
  "mandate_execution_card",
  "mandate_execution_wallet",
  "mandate_execution_nb",
  "conflicted_txn",
  "multiple_charged",
]

type colType =
  | Status
  | Category
  | Stage
  | Sample_sessions
  | Priority
  | Tooltip
  | Header
  | Product_integrated
  | Stage_name
  | Test_case

type errColType =
  | Error_code
  | Actionable
  | Error_message
  | Error_count
  | Sample_sessions

let colMapper = (colType: colType) => {
  switch colType {
  | Status => "status"
  | Category => "category"
  | Stage => "stage"
  | Sample_sessions => "sample_sessions"
  | Priority => "priority"
  | Tooltip => "tooltip"
  | Header => "header"
  | Product_integrated => "product_integrated"
  | Stage_name => "stage_name"
  | Test_case => "test_case"
  }
}

let errColMapper = (errColType: errColType) => {
  switch errColType {
  | Error_code => "error_code"
  | Actionable => "actionable"
  | Error_message => "error_message"
  | Error_count => "error_count"
  | Sample_sessions => "sample_sessions"
  }
}

let errItemToObj = dict => {
  {
    error_code: dict->getString(Error_code->errColMapper, ""),
    actionable: dict->getString(Actionable->errColMapper, ""),
    error_message: dict->getString(Error_message->errColMapper, ""),
    error_count: dict->getInt(Error_count->errColMapper, 0),
    sample_sessions: LogicUtils.getStrArrayFromDict(dict, "sample_sessions", []),
  }
}

let tableItemToObjMapper = dict => {
  {
    product_integrated: dict->getString(Product_integrated->colMapper, ""),
    status: dict->getString(Status->colMapper, "NOT ATTEMPTED"),
    category: dict->getString(Category->colMapper, ""),
    stage: dict->getString(Stage->colMapper, ""),
    sample_sessions: LogicUtils.getStrArrayFromDict(dict, "sample_sessions", []),
    priority: dict->getString(Priority->colMapper, ""),
    tooltip: dict->getString(Tooltip->colMapper, ""),
    header: dict->getString(Header->colMapper, ""),
    stage_name: dict->getString(Stage_name->colMapper, ""),
    test_case: dict->getString(Test_case->colMapper, ""),
  }
}

let objMapper = dict => {
  {
    name: dict->getString("name", ""),
    desc: Dict.get(dict, "desc")->Belt.Option.getWithDefault(Js.Json.null),
  }
}

let formatDate = date => {
  date
  ->Js.Date.fromFloat
  ->Js.Date.toISOString
  ->TimeZoneHook.formattedISOString("YYYY-MM-DDTHH:mm:ss[Z]")
}

let platformItemToObj = dict => {
  {
    platform: LogicUtils.getString(dict, "platform", ""),
  }
}

let donutItemToObj = dict => {
  {
    total_checklist: LogicUtils.getInt(dict, "total_checklist", 0),
    success_checklist: LogicUtils.getInt(dict, "success_checklist", 0),
    total_critical: LogicUtils.getInt(dict, "total_critical", 0),
    success_critical: LogicUtils.getInt(dict, "success_critical", 0),
  }
}

let productItemToObj = dict => {
  {
    product_count: getInt(dict, "product_count", 0),
    product_integrated: getString(dict, "product_integrated", ""),
  }
}

let getHeading = colType => {
  let key = colType->colMapper
  switch colType {
  | Product_integrated =>
    Table.makeHeaderInfo(~key, ~title="Product Integrated", ~showSort=true, ())
  | Status => Table.makeHeaderInfo(~key, ~title="Status", ~dataType=DropDown, ~showSort=true, ())
  | Category =>
    Table.makeHeaderInfo(~key, ~title="Category", ~dataType=TextType, ~showSort=true, ())
  | Stage =>
    Table.makeHeaderInfo(~key, ~title="Integration Stage", ~dataType=DropDown, ~showSort=true, ())
  | Sample_sessions => Table.makeHeaderInfo(~key, ~title="Sample ID's", ~showSort=true, ())
  | Priority =>
    Table.makeHeaderInfo(~key, ~title="Priority", ~dataType=DropDown, ~showSort=true, ())
  | Tooltip => Table.makeHeaderInfo(~key, ~title="Tooltip", ~showSort=true, ())
  | Header => Table.makeHeaderInfo(~key, ~title="Header", ~showSort=true, ())
  | Stage_name => Table.makeHeaderInfo(~key, ~title="Stage", ~showSort=true, ())
  | Test_case => Table.makeHeaderInfo(~key, ~title="Actionable", ~showSort=true, ())
  }
}

let getErrHeading = errColType => {
  let key = errColType->errColMapper
  switch errColType {
  | Error_code => Table.makeHeaderInfo(~key, ~title="Error Code", ~showSort=true, ())
  | Actionable => Table.makeHeaderInfo(~key, ~title="Actionable", ~showSort=true, ())
  | Error_message => Table.makeHeaderInfo(~key, ~title="Error Message", ~showSort=true, ())
  | Error_count => Table.makeHeaderInfo(~key, ~title="Error Count", ~showSort=true, ())
  | Sample_sessions => Table.makeHeaderInfo(~key, ~title="Sample ID's", ~showSort=true, ())
  }
}

let getCell = (detailedTable, colType): Table.cell => {
  switch colType {
  | Product_integrated => Text(detailedTable.product_integrated)
  | Status =>
    Label({
      title: detailedTable.status,
      color: switch detailedTable.status {
      | "PASSED" => LabelGreen
      | "FAILED" => LabelRed
      | "NOT ATTEMPTED" => LabelOrange
      | _ => LabelGray
      },
    })
  | Category => Text(detailedTable.category)
  | Stage => Text(detailedTable.stage)
  | Sample_sessions => Text(detailedTable.sample_sessions->Array.joinWith(", "))
  | Priority => Text(detailedTable.priority)
  | Tooltip => Text(detailedTable.tooltip)
  | Header => Text(detailedTable.header)
  | Stage_name => Text(detailedTable.stage_name)
  | Test_case => Text(detailedTable.test_case)
  }
}

let getErrCell = (errorTable: errorTable, errColType): Table.cell => {
  switch errColType {
  | Error_code => Text(errorTable.error_code)
  | Actionable => Text(errorTable.actionable)
  | Error_message => Text(errorTable.error_message)
  | Error_count => Numeric(errorTable.error_count->Belt.Int.toFloat, indianShortNum)
  | Sample_sessions => Text(errorTable.sample_sessions->Array.joinWith(", "))
  }
}

let getDefaultReportFilters = () => {
  let filterCreatedDict = Dict.make()

  let currentDate = Js.Date.now()

  let prevEndMins = {
    let presentDayInString = Js.Date.fromFloat(currentDate)
    let prevDateInFloat = Js.Date.getDate(presentDayInString) -. 1.0
    Js.Date.setDate(presentDayInString, prevDateInFloat)
  }

  Dict.set(filterCreatedDict, "endTime", Js.Json.string(formatDate(prevEndMins)))

  let prevStartMins = {
    let presentDayInString = Js.Date.fromFloat(currentDate)
    let prevDateInFloat = Js.Date.getDate(presentDayInString) -. 8.0
    Js.Date.setDate(presentDayInString, prevDateInFloat)
  }

  Dict.set(filterCreatedDict, "startTime", Js.Json.string(formatDate(prevStartMins)))

  filterCreatedDict
}

let getDefaultFilters = () => {
  let filterCreatedDict = Dict.make()

  let currentDate = Js.Date.now()
  let currentTimestamp = currentDate->Js.Date.fromFloat->Js.Date.toISOString
  filterCreatedDict->Dict.set(
    "endTime",
    Js.Json.string(currentTimestamp->TimeZoneHook.formattedISOString("YYYY-MM-DDTHH:mm:ss[Z]")),
  )

  let prevMins = {
    let presentDayInString = Js.Date.fromFloat(currentDate)
    let prevDateInFloat = Js.Date.getDate(presentDayInString) -. 7.0
    Js.Date.setDate(presentDayInString, prevDateInFloat)
  }

  Dict.set(filterCreatedDict, "startTime", Js.Json.string(formatDate(prevMins)))

  filterCreatedDict
}

let initialFixedFilterFields = _json => {
  let newArr = [
    (
      {
        localFilter: None,
        field: makeMultiInputFieldInfo(
          ~label="",
          ~comboCustomInput=InputFields.dateRangeField(
            ~startKey=startTimeFilterKey,
            ~endKey=endTimeFilterKey,
            ~format="YYYY-MM-DDTHH:mm:ss[Z]",
            ~showTime=true,
            ~disablePastDates={false},
            ~disableFutureDates={true},
            ~predefinedDays=[
              Hour(0.5),
              Hour(1.0),
              Hour(6.0),
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
            ~dateRangeLimit=60,
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

let filterEntity: AnalyticsUtils.filterEntity<detailedTable> = {
  uri: "abv",
  moduleName: "IntegrationMonitoring",
  filterDropDownOptions: _ => {
    []
  },
  filterKeys: tabKeys,
  initialFixedFilters: _ => {
    []
  },
  initialFilters: _ => {
    []
  },
  timeKeys: {
    startTimeKey: startTimeFilterKey,
    endTimeKey: endTimeFilterKey,
  },
  defaultFilterKeys: [startTimeFilterKey, endTimeFilterKey, "merchant_id", "platform", "product"],
}

let getIntegrationTable: Js.Json.t => array<detailedTable> = json => {
  let val =
    json
    ->LogicUtils.getArrayFromJson([])
    ->Array.map(item => {
      tableItemToObjMapper(item->getDictFromJsonObject)
    })
  val
}

let getErrTable: Js.Json.t => array<errorTable> = json => {
  let val =
    json
    ->LogicUtils.getArrayFromJson([])
    ->Array.map(item => {
      errItemToObj(item->getDictFromJsonObject)
    })
  val
}

let detailedTableEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getIntegrationTable,
  ~defaultColumns=[Category, Stage_name, Status, Priority, Sample_sessions],
  ~getHeading,
  ~getCell,
  ~dataKey="",
  (),
)

let reportEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getIntegrationTable,
  ~defaultColumns=[Category, Stage_name, Status, Priority, Test_case],
  ~getHeading,
  ~getCell,
  ~dataKey="",
  (),
)

let errEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getErrTable,
  ~defaultColumns=[Error_code, Error_count, Error_message, Sample_sessions],
  ~getHeading=getErrHeading,
  ~getCell=getErrCell,
  ~dataKey="",
  (),
)

let reportErrEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getErrTable,
  ~defaultColumns=[Error_code, Error_count, Error_message, Actionable],
  ~getHeading=getErrHeading,
  ~getCell=getErrCell,
  ~dataKey="",
  (),
)

let integrationBodyDict = (bodyEntity: integrationBody) => {
  [
    AnalyticsUtils.getFilterRequestBody(
      ~filter=bodyEntity.filter,
      ~metrics=bodyEntity.metrics,
      ~startDateTime=bodyEntity.startDateTime,
      ~endDateTime=bodyEntity.endDateTime,
      ~source=bodyEntity.source,
      ~groupByNames=bodyEntity.groupByNames,
      ~delta=bodyEntity.delta,
      (),
    )->Js.Json.object_,
  ]
  ->Js.Json.array
  ->Js.Json.stringify
}

let metricsConfig: array<LineChartUtils.metricsConfig> = [
  {
    metric_name_db: "txn_total_volume",
    metric_label: "Transactions Volume",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
  },
  {
    metric_name_db: "order_total_volume",
    metric_label: "Orders Volume",
    metric_type: Volume,
    thresholdVal: None,
    step_up_threshold: None,
  },
]

let getTimeSeriesChartTxn = (chartEntity: DynamicChart.chartEntity) => {
  let source = switch chartEntity.mode {
  | Some(mode) => mode === "TXN" ? chartEntity.source : "BATCH"
  | None => chartEntity.source
  }
  [
    AnalyticsUtils.getFilterRequestBody(
      ~groupByNames=Some(["merchant_id"]),
      ~granularity=chartEntity.granularityOpts,
      ~filter=chartEntity.filters,
      ~metrics=Some(["total_volume"]),
      ~delta=chartEntity.delta,
      ~startDateTime=chartEntity.start_time,
      ~endDateTime=chartEntity.end_time,
      ~cardinality=chartEntity.cardinality,
      ~mode=Some("TXN"),
      ~customFilter=?chartEntity.customFilter,
      ~prefix=Some("txn"),
      ~source,
      (),
    )->Js.Json.object_,
    AnalyticsUtils.getFilterRequestBody(
      ~groupByNames=Some(["merchant_id"]),
      ~granularity=chartEntity.granularityOpts,
      ~filter=chartEntity.filters,
      ~metrics=Some(["total_volume"]),
      ~delta=chartEntity.delta,
      ~startDateTime=chartEntity.start_time,
      ~endDateTime=chartEntity.end_time,
      ~cardinality=chartEntity.cardinality,
      ~mode=Some("ORDER"),
      ~customFilter=?chartEntity.customFilter,
      ~prefix=Some("order"),
      ~source,
      (),
    )->Js.Json.object_,
  ]
  ->Js.Json.array
  ->Js.Json.stringify
}

let chartEntity = DynamicChart.makeEntity(
  ~uri=String(`/api/analytics/v1/ec/metrics`),
  ~filterKeys=["merchant_id"],
  ~dateFilterKeys=(startTimeFilterKey, endTimeFilterKey),
  ~currentMetrics=("Transactions Volume", "Orders Volume"), // 2nd metric will be static and we won't show the 2nd metric option to the first metric
  ~granularity=[G_ONEDAY, G_ONEHOUR],
  ~chartTypes=[Line, Bar],
  ~uriConfig=[
    {
      uri: `/api/analytics/v1/ec/metrics`,
      timeSeriesBody: getTimeSeriesChartTxn,
      metrics: metricsConfig,
      timeCol: "time_bucket",
      filterKeys,
    },
  ],
  ~moduleName="Integration Monitoring",
  ~source="BATCH",
  (),
)
