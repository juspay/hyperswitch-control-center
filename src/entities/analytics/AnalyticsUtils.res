type node = {childNodes: array<Dom.element>}
@val external document: Dom.element = "document"
@send
external getElementsByClassName: ('a, string) => array<node> = "getElementsByClassName"

external toNode: Dom.element => node = "%identity"

type timeRanges = {
  fromTime: string,
  toTime: string,
}

type loaderType = SideLoader | Shimmer

type prevDates = {
  currentSr: timeRanges,
  prev7DaySr: timeRanges,
  yesterdaySr: timeRanges,
  currentWeekSr: timeRanges,
  currentMonthSr: timeRanges,
  industrySr: timeRanges,
}
type timeKeys = {
  startTimeKey: string,
  endTimeKey: string,
}
type filterBodyEntity = {
  startTime: string,
  endTime: string,
  groupByNames: array<string>,
  source: string,
  mode?: string,
}
// check the ISOLATING FILTERS Component section https://docs.google.com/document/d/1Wub6jhmKqJVrxthYZ_y8BNUOGv9MW_wU3LsY5shYdUE/edit for more info
type filterEntity<'t> = {
  uri: string,
  moduleName: string,
  initialFixedFilters: Js.Json.t => array<EntityType.initialFilters<'t>>,
  initialFilters: Js.Json.t => array<EntityType.initialFilters<'t>>,
  filterDropDownOptions: Js.Json.t => array<EntityType.optionType<'t>>,
  filterKeys: array<string>,
  timeKeys: timeKeys,
  defaultFilterKeys: array<string>,
  source?: string,
  filterBody?: filterBodyEntity => string,
  customFilterKey?: string,
}

type filterEntityNew<'t> = {
  uri: string,
  moduleName: string,
  initialFixedFilters: Js.Json.t => array<EntityType.initialFilters<'t>>,
  initialFilters: (Js.Json.t, string => unit) => array<EntityType.initialFilters<'t>>,
  filterKeys: array<string>,
  timeKeys: timeKeys,
  defaultFilterKeys: array<string>,
  source?: string,
  filterBody?: filterBodyEntity => string,
  customFilterKey?: string,
  sortingColumnLegend?: string,
}

type downloadDataApiBodyEntity = {
  startTime: string,
  endTime: string,
  columns: array<string>,
  compressed: bool,
}
type downloadDataEntity = {
  uri: string,
  downloadRawDataCols: array<string>,
  downloadDataBody: downloadDataApiBodyEntity => string,
  moduleName?: string,
  timeKeys: timeKeys,
  description?: string,
  customFilterKey?: string,
}

let modeTxnTabNames = [
  "txn_initiated",
  "txn_last_modified",
  "actual_payment_status",
  "status_sync_source",
  "gateway",
  "emi",
  "emi_bank",
  "emi_tenure",
  "using_stored_card",
  "card_exp_month",
  "card_exp_year",
  "resp_message",
  "txn_conflict",
  "prev_txn_status",
  "error_message",
  "card_issuer_country",
  "txn_object_type",
  "payment_method_type",
  "auth_type",
  "gateway_auth_req_params",
  "second_factor_auth_status",
  "lob",
  "bank",
  "payment_instrument_group",
  "card_brand",
  "txn_latency",
  "is_tokenized",
  "token_generated",
  "tokenization_consent_failure_reason",
  "tokenization_consent_ui_presented",
  "tokenization_consent",
  "token_status",
  "priority_logic_tag",
  "is_offer_txn",
  "emi_type",
  "payment_flow",
  "txn_latency_enum",
  "txn_flow_type",
  "is_token_bin",
  "token_repeat",
  "issuer_tokenization_consent_failure_reason",
  "issuer_token_reference",
  "token_reference",
  "tokenization_failure_reason",
  "stored_card_vault_provider",
  "card_bin",
]

type tableApiBodyEntity = {
  startTimeFromUrl: string,
  endTimeFromUrl: string,
  filterValueFromUrl?: Js.Json.t,
  currenltySelectedTab?: array<string>,
  deltaMetrics: array<string>,
  isIndustry: bool,
  distributionArray?: array<Js.Json.t>,
  deltaPrefixArr: array<string>,
  tableMetrics: array<string>,
  mode?: string,
  customFilter: string,
  moduleName: string,
  showDeltaMetrics: bool,
  source: string,
}

let dummyTableApiBody = {
  startTimeFromUrl: "",
  endTimeFromUrl: "",
  deltaMetrics: [],
  isIndustry: false,
  deltaPrefixArr: [],
  tableMetrics: [],
  customFilter: "",
  moduleName: "",
  showDeltaMetrics: false,
  source: "",
}
type newApiBodyEntity = {
  timeObj: Js.Dict.t<Js.Json.t>,
  metric?: string,
  groupBy?: Js.Array2.t<Js_string.t>,
  granularityConfig?: (int, string),
  cardinality?: float,
  filterValueFromUrl?: Js.Json.t,
  customFilterValue?: Js.String2.t,
  jsonFormattedFilter?: Js.Json.t,
  cardinalitySortDims?: string,
  domain: string,
}

type analyticsTableEntity<'colType, 't> = {
  metrics: array<string>,
  deltaMetrics: array<string>,
  headerMetrics: array<string>,
  distributionArray: option<array<Js.Json.t>>,
  tableEntity: EntityType.entityType<'colType, 't>,
  deltaPrefixArr: array<string>,
  isIndustry: bool,
  tableUpdatedHeading: option<
    (
      ~item: option<'t>,
      ~dateObj: option<prevDates>,
      ~mode: option<string>,
      'colType,
    ) => Table.header,
  >,
  tableGlobalFilter: option<(array<Js.Nullable.t<'t>>, Js.Json.t) => array<Js.Nullable.t<'t>>>,
  moduleName: string,
  defaultSortCol: string,
  filterKeys: array<string>,
  timeKeys: timeKeys,
  modeKey: option<string>,
  moduleNamePrefix: string,
  getUpdatedCell?: (tableApiBodyEntity, 't, 'colType) => Table.cell,
  defaultColumn?: array<'colType>,
  colDependentDeltaPrefixArr?: 'colType => option<string>,
  source: string,
  tableSummaryBody?: tableApiBodyEntity => string,
  tableBodyEntity?: tableApiBodyEntity => string,
  sampleApiBody?: tableApiBodyEntity => string,
  customFilterKey?: string,
  newTableBodyMaker?: newApiBodyEntity => Js.Json.t,
  jsonTransformer?: (string, array<Js.Json.t>, array<string>) => array<Js.Json.t>,
}

type statSentiment = Positive | Negative | Neutral

let makeAnalyticsTableEntity = (
  ~metrics=[],
  ~deltaMetrics=[],
  ~distributionArray: option<array<Js.Json.t>>=?,
  ~tableEntity: EntityType.entityType<'colType, 't>,
  ~deltaPrefixArr=[],
  ~isIndustry=false,
  ~tableUpdatedHeading: option<
    (
      ~item: option<'t>,
      ~dateObj: option<prevDates>,
      ~mode: option<string>,
      'colType,
    ) => Table.header,
  >=?,
  ~headerMetrics=[],
  ~tableGlobalFilter: option<(array<Js.Nullable.t<'t>>, Js.Json.t) => array<Js.Nullable.t<'t>>>=?,
  ~moduleName: string,
  ~defaultSortCol: string,
  ~filterkeys: array<string>=[],
  ~timeKeys: timeKeys,
  ~modeKey: option<string>=?,
  ~customFilterKey: option<string>=?,
  ~moduleNamePrefix: string="",
  ~getUpdatedCell: option<(tableApiBodyEntity, 't, 'colType) => Table.cell>=?,
  ~defaultColumn: option<array<'colType>>=?,
  ~colDependentDeltaPrefixArr: option<'colType => option<string>>=?,
  ~source: string="BATCH",
  ~tableSummaryBody: option<tableApiBodyEntity => string>=?,
  ~tableBodyEntity: option<tableApiBodyEntity => string>=?,
  ~sampleApiBody: option<tableApiBodyEntity => string>=?,
  ~newTableBodyMaker: option<newApiBodyEntity => Js.Json.t>=?,
  ~jsonTransformer: option<(string, array<Js.Json.t>, array<string>) => array<Js.Json.t>>=?,
  (),
) => {
  {
    metrics,
    deltaMetrics,
    distributionArray,
    headerMetrics,
    tableEntity,
    deltaPrefixArr,
    isIndustry,
    tableUpdatedHeading,
    tableGlobalFilter,
    moduleName,
    defaultSortCol,
    filterKeys: filterkeys,
    timeKeys,
    modeKey,
    moduleNamePrefix,
    ?getUpdatedCell,
    ?defaultColumn,
    ?colDependentDeltaPrefixArr,
    source,
    ?tableSummaryBody,
    ?tableBodyEntity,
    ?sampleApiBody,
    ?customFilterKey,
    ?newTableBodyMaker,
    ?jsonTransformer,
  }
}
let multi_mid_merchants = ["vodafone", "bigbasket", "cred", "swiggy", "paypal"]

let (startTimeFilterKey, endTimeFilterKey, optFilterKey) = ("startTime", "endTime", "opt")
let getDateCreatedObject = () => {
  let currentDate = Js.Date.now()
  let filterCreatedDict = Dict.make()
  let currentTimestamp = currentDate->Js.Date.fromFloat->Js.Date.toISOString
  let dateFormat = "YYYY-MM-DDTHH:mm:[00][Z]"
  Dict.set(
    filterCreatedDict,
    endTimeFilterKey,
    Js.Json.string(currentTimestamp->TimeZoneHook.formattedISOString(dateFormat)),
  )

  let prevTime = {
    let presentDayInString = Js.Date.fromFloat(currentDate)
    Js.Date.setHoursMS(presentDayInString, ~hours=0.0, ~minutes=0.0, ~seconds=0.0, ())
  }

  let defaultStartTime = {
    Js.Json.string(
      prevTime
      ->Js.Date.fromFloat
      ->Js.Date.toISOString
      ->TimeZoneHook.formattedISOString("YYYY-MM-DDTHH:mm:[00][Z]"),
    )
  }
  Dict.set(filterCreatedDict, startTimeFilterKey, defaultStartTime)
  Dict.set(filterCreatedDict, "opt", Js.Json.string("today"))

  filterCreatedDict
}

module TableModalContent = {
  @react.component
  let make = (
    ~defaultFilters,
    ~domain,
    ~filterByData,
    ~summayTableEntity: EntityType.entityType<'colType, 't>,
  ) => {
    open LogicUtils
    let fetchApi = AuthHooks.useApiFetcher()
    let (data, setData) = React.useState(_ => [])
    let (offset, setOffset) = React.useState(() => 0)
    let (tableDataLoading, setTableDataLoading) = React.useState(_ => false)
    let parentToken = AuthWrapperUtils.useTokenParent(Original)
    let addLogsAroundFetch = EulerAnalyticsLogUtils.useAddLogsAroundFetch()
    let searchText = ReactFinalForm.useField("searchTable").input.value

    React.useEffect1(() => {
      open Promise

      setTableDataLoading(_ => true)
      if parentToken->Belt.Option.isSome {
        fetchApi(
          `/api/analytics/v1/${domain}/sample`,
          ~method_=Post,
          ~bodyStr={defaultFilters->Js.Json.object_->Js.Json.stringify},
          ~authToken=parentToken,
          ~headers=[("QueryType", "TableSampleData")]->Dict.fromArray,
          (),
        )
        ->addLogsAroundFetch(~logTitle="Table Sample Data Api")
        ->then(data => {
          let arrData =
            data
            ->getDictFromJsonObject
            ->getJsonObjectFromDict("queryData")
            ->summayTableEntity.getObjects
            ->Array.map(Js.Nullable.return)
          setData(_ => arrData)
          resolve()
        })
        ->catch(_err => {
          resolve()
        })
        ->finally(_ => {
          setTableDataLoading(_ => false)
        })
        ->ignore
      }
      None
    }, [parentToken])
    let actualData = React.useMemo2(() => {
      data->filterByData(searchText)
    }, (searchText, data))
    if tableDataLoading {
      <Shimmer styleClass="w-full h-96 dark:bg-black bg-white" shimmerType={Big} />
    } else {
      <LoadedTable
        actualData
        totalResults={actualData->Array.length}
        offset
        setOffset
        entity=summayTableEntity
        currrentFetchCount={actualData->Array.length}
        title="Analytics Summary Table OnClickDetails"
        hideTitle=true
        resultsPerPage=10
        tableDataLoading
        ignoreHeaderBg=true
      />
    }
  }
}

module TableErrorModalContent = {
  @react.component
  let make = (
    ~defaultFilters,
    ~domain,
    ~filterByData,
    ~summayTableEntity: EntityType.entityType<'colType, 't>,
    ~groupBy,
    ~metrics,
    ~customFilterValue,
    ~defSort: Table.sortedObject,
    ~defaultFiltersToModal as _: option<Js.Json.t>=?,
  ) => {
    open LogicUtils
    let betaEndPointConfig = React.useContext(BetaEndPointConfigProvider.betaEndPointConfig)
    let fetchApi = AuthHooks.useApiFetcher(~betaEndpointConfig=?betaEndPointConfig, ())
    let (data, setData) = React.useState(_ => [])
    let (offset, setOffset) = React.useState(() => 0)
    let (tableDataLoading, setTableDataLoading) = React.useState(_ => false)
    let parentToken = AuthWrapperUtils.useTokenParent(Original)
    let addLogsAroundFetch = EulerAnalyticsLogUtils.useAddLogsAroundFetchNew()
    let searchText = ReactFinalForm.useField("searchTable").input.value
    let timeRange = defaultFilters->getJsonObjectFromDict("timeRange")->getDictFromJsonObject
    let startTime = timeRange->getString("startTime", "")
    let endTime = timeRange->getString("endTime", "")
    React.useEffect3(() => {
      open Promise
      setTableDataLoading(_ => true)
      let filters = defaultFilters->getJsonObjectFromDict("filters")->Some
      let timeObj = Dict.fromArray([
        ("start", startTime->Js.Json.string),
        ("end", endTime->Js.Json.string),
      ])
      if parentToken->Belt.Option.isSome {
        fetchApi(
          `${summayTableEntity.uri}?query-type=tableSampleApi&metrics=${metrics}&groupBy=${groupBy->Array.joinWith(
              ",",
            )}`,
          ~method_=Post,
          ~bodyStr=AnalyticsNewUtils.apiBodyMaker(
            ~timeObj,
            ~groupBy,
            ~metric=metrics,
            ~filterValueFromUrl=?filters,
            ~domain,
            ~customFilterValue,
            (),
          )->Js.Json.stringify,
          ~authToken=parentToken,
          ~headers=[("QueryType", "TableSampleData")]->Dict.fromArray,
          (),
        )
        ->addLogsAroundFetch(~logTitle="Table Sample Data Api")
        ->then(data => {
          setData(
            _ =>
              summayTableEntity.getObjects(
                data->convertNewLineSaperatedDataToArrayOfJson->Js.Json.array,
              )->Array.map(Js.Nullable.return),
          )
          resolve()
        })
        ->catch(_err => {
          resolve()
        })
        ->finally(_ => {
          setTableDataLoading(_ => false)
        })
        ->ignore
      }
      None
    }, (parentToken, startTime, endTime))
    let actualData = React.useMemo2(() => {
      data->filterByData(searchText)
    }, (searchText, data))
    let {parentAuthInfo} = React.useContext(TokenContextProvider.tokenContext)
    let (startTimeFilter, endTimeFilter) = (startTime, endTime)
    let userInfoText = React.useMemo1(() => {
      switch parentAuthInfo {
      | Some(info) => `${info.merchantId}_distributionTable_${info.username}_currentTime` // tab name also need to be added based on tab currentTime need to be added
      | None => ""
      }
    }, [parentAuthInfo])

    let downloadDataText = `${userInfoText}_${startTimeFilter}_${endTimeFilter}`
    let downloadCsv =
      <ExportTable
        title=downloadDataText
        tableData=actualData
        visibleColumns={summayTableEntity.defaultColumns}
        colMapper={col => {
          let k = summayTableEntity.getHeading(col)
          k.title
        }}
        getHeading=summayTableEntity.getHeading
      />

    if tableDataLoading {
      <Shimmer styleClass="w-full h-96 dark:bg-black bg-white" shimmerType={Big} />
    } else {
      <LoadedTable
        actualData
        totalResults={actualData->Array.length}
        offset
        setOffset
        entity=summayTableEntity
        currrentFetchCount={actualData->Array.length}
        title="Analytics Summary Table OnClickDetails"
        hideTitle=true
        resultsPerPage=10
        tableDataLoading
        ignoreHeaderBg=true
        rightTitleElement={React.null}
        downloadCsv={downloadCsv}
        defaultSort=defSort
      />
    }
  }
}

open LogicUtils
let getFilterRequestBody = (
  ~granularity: option<string>=None,
  ~groupByNames: option<array<string>>=None,
  ~filter: option<Js.Json.t>=None,
  ~metrics: option<array<string>>=None,
  ~delta: bool=true,
  ~prefix: option<string>=None,
  ~distributionValues: option<Js.Json.t>=None,
  ~startDateTime,
  ~endDateTime,
  ~cardinality: option<string>=None,
  ~mode: option<string>=None,
  ~customFilter: string="",
  ~source: string="BATCH",
  (),
) => {
  let body: Js.Dict.t<Js.Json.t> = Dict.make()
  let timeRange = Dict.make()
  let timeSeries = Dict.make()

  Dict.set(timeRange, "startTime", startDateTime->Js.Json.string)
  Dict.set(timeRange, "endTime", endDateTime->Js.Json.string)
  Dict.set(body, "timeRange", timeRange->Js.Json.object_)

  switch groupByNames {
  | Some(groupByNames) =>
    if groupByNames->Array.length != 0 {
      Dict.set(
        body,
        "groupByNames",
        groupByNames
        ->ArrayUtils.getUniqueStrArray
        ->Belt.Array.keepMap(item => Some(item->Js.Json.string))
        ->Js.Json.array,
      )
    }
  | None => ()
  }

  switch filter {
  | Some(filters) =>
    if !(filters->checkEmptyJson) {
      Dict.set(body, "filters", filters)
    }
  | None => ()
  }

  switch distributionValues {
  | Some(distributionValues) =>
    if !(distributionValues->checkEmptyJson) {
      Dict.set(body, "distribution", distributionValues)
    }
  | None => ()
  }

  if customFilter != "" {
    Dict.set(body, "customFilter", customFilter->Js.Json.string)
  }
  switch granularity {
  | Some(granularity) => {
      Dict.set(timeSeries, "granularity", granularity->Js.Json.string)
      Dict.set(body, "timeSeries", timeSeries->Js.Json.object_)
    }

  | None => ()
  }

  switch cardinality {
  | Some(cardinality) => Dict.set(body, "cardinality", cardinality->Js.Json.string)
  | None => ()
  }
  switch mode {
  | Some(mode) => Dict.set(body, "mode", mode->Js.Json.string)
  | None => ()
  }

  switch prefix {
  | Some(prefix) => Dict.set(body, "prefix", prefix->Js.Json.string)
  | None => ()
  }

  Dict.set(body, "source", source->Js.Json.string)

  switch metrics {
  | Some(metrics) =>
    if metrics->Array.length != 0 {
      Dict.set(
        body,
        "metrics",
        metrics
        ->ArrayUtils.getUniqueStrArray
        ->Belt.Array.keepMap(item => Some(item->Js.Json.string))
        ->Js.Json.array,
      )
    }
  | None => ()
  }
  if delta {
    Dict.set(body, "delta", true->Js.Json.boolean)
  }

  body
}

let filterBody = (filterBodyEntity: filterBodyEntity) => {
  let (startTime, endTime) = try {
    (
      (filterBodyEntity.startTime->DayJs.getDayJsForString).subtract(.
        1,
        "day",
      ).toDate(.)->Js.Date.toISOString,
      (filterBodyEntity.endTime->DayJs.getDayJsForString).add(.
        1,
        "day",
      ).toDate(.)->Js.Date.toISOString,
    )
  } catch {
  | _ => (filterBodyEntity.startTime, filterBodyEntity.endTime)
  }

  getFilterRequestBody(
    ~startDateTime=startTime,
    ~endDateTime=endTime,
    ~groupByNames=Some(filterBodyEntity.groupByNames),
    ~source=filterBodyEntity.source,
    (),
  )
}

let deltaDate = (~fromTime: string, ~_toTime: string, ~typeTime: string) => {
  let fromTime = fromTime
  let nowtime = Js.Date.make()->Js.Date.toString->DayJs.getDayJsForString
  let dateTimeFormat = "YYYY-MM-DDTHH:mm:ss[Z]"
  if typeTime == "last7" {
    let last7FromTime = (fromTime->DayJs.getDayJsForString).subtract(. 7, "day")
    let last7ToTime = (fromTime->DayJs.getDayJsForString).subtract(. 1, "day")

    let timeArray = Dict.fromArray([
      ("fromTime", last7FromTime.format(. dateTimeFormat)),
      ("toTime", last7ToTime.format(. dateTimeFormat)),
    ])

    [timeArray]
  } else if typeTime == "yesterday" {
    let yesterdayFromTime =
      Js.Date.fromFloat(
        Js.Date.setHoursMS(
          nowtime.subtract(. 1, "day").toDate(.),
          ~hours=0.0,
          ~minutes=0.0,
          ~seconds=0.0,
          (),
        ),
      )->DayJs.getDayJsForJsDate
    let yesterdayToTime =
      Js.Date.fromFloat(
        Js.Date.setHoursMS(
          nowtime.subtract(. 1, "day").toDate(.),
          ~hours=23.0,
          ~minutes=59.0,
          ~seconds=59.0,
          (),
        ),
      )->DayJs.getDayJsForJsDate

    let timeArray = Dict.fromArray([
      ("fromTime", yesterdayFromTime.format(. dateTimeFormat)),
      ("toTime", yesterdayToTime.format(. dateTimeFormat)),
    ])

    [timeArray]
  } else if typeTime == "currentmonth" {
    let currentMonth = Js.Date.fromFloat(Js.Date.setDate(Js.Date.make(), 1.0))
    let currentMonthFromTime =
      Js.Date.fromFloat(
        Js.Date.setHoursMS(currentMonth, ~hours=0.0, ~minutes=0.0, ~seconds=0.0, ()),
      )
      ->Js.Date.toString
      ->DayJs.getDayJsForString
    let currentMonthToTime = nowtime
    let timeArray = Dict.fromArray([
      ("fromTime", currentMonthFromTime.format(. dateTimeFormat)),
      ("toTime", currentMonthToTime.format(. dateTimeFormat)),
    ])

    [timeArray]
  } else if typeTime == "currentweek" {
    let currentWeekFromTime = Js.Date.make()->DateTimeUtils.getStartOfWeek(Monday)
    let currentWeekToTime = Js.Date.make()->DayJs.getDayJsForJsDate

    let timeArray = Dict.fromArray([
      ("fromTime", currentWeekFromTime.format(. dateTimeFormat)),
      ("toTime", currentWeekToTime.format(. dateTimeFormat)),
    ])

    [timeArray]
  } else {
    let timeArray = Dict.make()
    [timeArray]
  }
}
let generateDateArray = (~startTime, ~endTime, ~deltaPrefixArr) => {
  let dateArray = Belt.Array.map(deltaPrefixArr, x =>
    deltaDate(~fromTime=startTime, ~_toTime=endTime, ~typeTime=x)
  )
  dateArray
}
let generatePayload = (
  ~startTime,
  ~endTime,
  ~metrics,
  ~delta,
  ~mode: option<string>=None,
  ~groupByNames,
  ~prefix,
  ~source,
  ~filters: option<Js.Json.t>,
  ~customFilter,
) => {
  let timeArr = Dict.fromArray([
    ("startTime", startTime->Js.Json.string),
    ("endTime", endTime->Js.Json.string),
  ])
  let newDict = switch groupByNames {
  | Some(groupByNames) =>
    Dict.fromArray([
      ("timeRange", timeArr->Js.Json.object_),
      ("metrics", metrics->Js.Json.stringArray),
      ("groupByNames", groupByNames->Js.Json.stringArray),
      ("prefix", prefix->Js.Json.string),
      ("source", source->Js.Json.string),
      ("delta", delta->Js.Json.boolean),
    ])
  | None =>
    Dict.fromArray([
      ("timeRange", timeArr->Js.Json.object_),
      ("metrics", metrics->Js.Json.stringArray),
      ("prefix", prefix->Js.Json.string),
      ("source", source->Js.Json.string),
      ("delta", delta->Js.Json.boolean),
    ])
  }

  switch mode {
  | Some(mode) => Dict.set(newDict, "mode", mode->Js.Json.string)
  | None => ()
  }
  if customFilter != "" {
    Dict.set(newDict, "customFilter", customFilter->Js.Json.string)
  }
  switch filters {
  | Some(filters) =>
    if !(filters->checkEmptyJson) {
      Dict.set(newDict, "filters", filters)
    }
  | None => ()
  }
  newDict
}

let generatedeltaTablePayload = (
  ~deltaDateArr,
  ~metrics,
  ~groupByNames: option<array<string>>,
  ~source,
  ~mode: option<string>,
  ~deltaPrefixArr,
  ~filters: option<Js.Json.t>,
  ~showDeltaMetrics=false,
  ~customFilter,
) => {
  let dictOfDates = Belt.Array.concatMany(deltaDateArr)
  let tablePayload = Belt.Array.zipBy(dictOfDates, deltaPrefixArr, (x, y) =>
    generatePayload(
      ~startTime=x->Dict.get("fromTime")->Belt.Option.getWithDefault(""),
      ~endTime=x->Dict.get("toTime")->Belt.Option.getWithDefault(""),
      ~metrics,
      ~groupByNames,
      ~mode,
      ~prefix=y,
      ~source,
      ~delta=showDeltaMetrics,
      ~filters,
      ~customFilter,
    )
  )
  tablePayload
}
let generateTablePayload = (
  ~startTimeFromUrl: string,
  ~endTimeFromUrl: string,
  ~filterValueFromUrl: option<Js.Json.t>,
  ~currenltySelectedTab: option<array<string>>,
  ~tableMetrics: array<string>,
  ~distributionArray: option<array<Js.Json.t>>,
  ~deltaMetrics: array<string>,
  ~deltaPrefixArr: array<string>,
  ~isIndustry: bool,
  ~mode: option<string>,
  ~customFilter,
  ~showDeltaMetrics=false,
  ~moduleName as _: string,
  ~source: string="BATCH",
  (),
) => {
  let metrics = tableMetrics
  let startTime = startTimeFromUrl
  let endTime = endTimeFromUrl

  let deltaDateArr =
    {deltaMetrics->Array.length === 0}
      ? []
      : generateDateArray(~startTime, ~endTime, ~deltaPrefixArr)

  let deltaPayload = generatedeltaTablePayload(
    ~deltaDateArr,
    ~metrics=deltaMetrics,
    ~groupByNames=currenltySelectedTab,
    ~source,
    ~mode,
    ~deltaPrefixArr,
    ~filters=filterValueFromUrl,
    ~customFilter,
    ~showDeltaMetrics,
  )
  let tableBodyWithNonDeltaMetrix = if metrics->Array.length > 0 {
    [
      getFilterRequestBody(
        ~groupByNames=currenltySelectedTab,
        ~filter=filterValueFromUrl,
        ~metrics=Some(metrics),
        ~delta=showDeltaMetrics,
        ~mode,
        ~startDateTime=startTime,
        ~endDateTime=endTime,
        ~customFilter,
        ~source,
        (),
      ),
    ]
  } else {
    []
  }

  let tableBodyWithDeltaMetrix = if deltaMetrics->Array.length > 0 {
    [
      getFilterRequestBody(
        ~groupByNames=currenltySelectedTab,
        ~filter=filterValueFromUrl,
        ~metrics=Some(deltaMetrics),
        ~delta=showDeltaMetrics,
        ~mode,
        ~startDateTime=startTime,
        ~endDateTime=endTime,
        ~customFilter,
        ~source,
        (),
      ),
    ]
  } else {
    []
  }

  let tableIndustryPayload = if isIndustry {
    [
      getFilterRequestBody(
        ~groupByNames=currenltySelectedTab,
        ~filter=filterValueFromUrl,
        ~metrics=Some(deltaMetrics),
        ~delta=showDeltaMetrics,
        ~mode,
        ~prefix=Some("industry"),
        ~startDateTime=startTime,
        ~endDateTime=endTime,
        ~customFilter,
        ~source,
        (),
      ),
    ]
  } else {
    []
  }
  let tableBodyValues = Belt.Array.concatMany([
    tableBodyWithNonDeltaMetrix,
    tableBodyWithDeltaMetrix,
    tableIndustryPayload,
  ])

  let distributionPayload = switch distributionArray {
  | Some(distributionArray) =>
    distributionArray->Belt.Array.map(arr =>
      getFilterRequestBody(
        ~groupByNames=currenltySelectedTab,
        ~filter=filterValueFromUrl,
        ~delta=false,
        ~mode,
        ~distributionValues=Some(arr),
        ~startDateTime=startTime,
        ~endDateTime=endTime,
        ~customFilter,
        ~source,
        (),
      )
    )
  | None => []
  }

  let tableBody =
    Belt.Array.concatMany([tableBodyValues, deltaPayload, distributionPayload])
    ->Belt.Array.map(Js.Json.object_)
    ->Js.Json.array
  tableBody
}

let getDownloadDataBody = (downloadDataApiEntity: downloadDataApiBodyEntity) => {
  let {startTime, endTime, columns, compressed} = downloadDataApiEntity
  Dict.fromArray([
    (
      "timeRange",
      Dict.fromArray([
        ("startTime", startTime->Js.Json.string),
        ("endTime", endTime->Js.Json.string),
      ])->Js.Json.object_,
    ),
    ("columns", columns->Js.Json.stringArray),
    ("compressed", compressed->Js.Json.boolean),
  ])
  ->Js.Json.object_
  ->Js.Json.stringify
}

let generateTablePayloadFromEntity = (tableApiBodyEntity: tableApiBodyEntity) => {
  generateTablePayload(
    ~startTimeFromUrl=tableApiBodyEntity.startTimeFromUrl,
    ~endTimeFromUrl=tableApiBodyEntity.endTimeFromUrl,
    ~filterValueFromUrl=tableApiBodyEntity.filterValueFromUrl,
    ~currenltySelectedTab=tableApiBodyEntity.currenltySelectedTab,
    ~deltaMetrics=tableApiBodyEntity.deltaMetrics,
    ~deltaPrefixArr=tableApiBodyEntity.deltaPrefixArr,
    ~isIndustry=tableApiBodyEntity.isIndustry,
    ~distributionArray=tableApiBodyEntity.distributionArray,
    ~tableMetrics=tableApiBodyEntity.tableMetrics,
    ~mode=tableApiBodyEntity.mode,
    ~customFilter=tableApiBodyEntity.customFilter,
    ~moduleName=tableApiBodyEntity.moduleName,
    ~showDeltaMetrics=tableApiBodyEntity.showDeltaMetrics,
    ~source=tableApiBodyEntity.source,
    (),
  )->Js.Json.stringify
}

let sampleApiBody = (tableApiBodyEntity: tableApiBodyEntity) => {
  let timeRange =
    [
      ("startTime", tableApiBodyEntity.startTimeFromUrl->Js.Json.string),
      ("endTime", tableApiBodyEntity.endTimeFromUrl->Js.Json.string),
    ]->Dict.fromArray

  let defaultFilters =
    [
      ("timeRange", timeRange->Js.Json.object_),
      (
        "filters",
        tableApiBodyEntity.filterValueFromUrl->Belt.Option.getWithDefault(
          Js.Json.object_(Dict.make()),
        ),
      ),
      ("source", tableApiBodyEntity.source->Js.Json.string),
      ("mode", tableApiBodyEntity.mode->Belt.Option.getWithDefault("")->Js.Json.string),
    ]->Dict.fromArray

  [
    (
      "activeTab",
      tableApiBodyEntity.currenltySelectedTab
      ->Belt.Option.getWithDefault([])
      ->Array.map(Js.Json.string)
      ->Js.Json.array,
    ),
    ("filter", defaultFilters->Js.Json.object_),
  ]
  ->Dict.fromArray
  ->Js.Json.object_
  ->Js.Json.stringify
}

let deltaTimeRangeMapper = (arrJson: array<Js.Json.t>) => {
  let emptyDict = Dict.make()
  let _ = arrJson->Array.map(item => {
    let dict = item->getDictFromJsonObject
    let name = dict->getString("requestPrefix", "")
    let deltaTimeRange = dict->getJsonObjectFromDict("deltaTimeRange")->getDictFromJsonObject
    let fromTime = deltaTimeRange->getString("startTime", "")
    let toTime = deltaTimeRange->getString("endTime", "")
    if name === "" && deltaTimeRange->Dict.toArray->Array.length > 0 {
      emptyDict->Dict.set("currentSr", {fromTime, toTime})
    } else if name === "last7" {
      emptyDict->Dict.set("prev7DaySr", {fromTime, toTime})
    } else if name === "yesterday" {
      emptyDict->Dict.set("yesterdaySr", {fromTime, toTime})
    } else if name === "currentweek" {
      emptyDict->Dict.set("currentWeekSr", {fromTime, toTime})
    } else if name === "currentmonth" {
      emptyDict->Dict.set("currentMonthSr", {fromTime, toTime})
    } else if name === "industry" {
      emptyDict->Dict.set("industrySr", {fromTime, toTime})
    }
  })

  {
    currentSr: emptyDict
    ->Dict.get("currentSr")
    ->Belt.Option.getWithDefault({
      fromTime: "",
      toTime: "",
    }),
    prev7DaySr: emptyDict
    ->Dict.get("prev7DaySr")
    ->Belt.Option.getWithDefault({
      fromTime: "",
      toTime: "",
    }),
    yesterdaySr: emptyDict
    ->Dict.get("yesterdaySr")
    ->Belt.Option.getWithDefault({
      fromTime: "",
      toTime: "",
    }),
    currentWeekSr: emptyDict
    ->Dict.get("currentWeekSr")
    ->Belt.Option.getWithDefault({
      fromTime: "",
      toTime: "",
    }),
    currentMonthSr: emptyDict
    ->Dict.get("currentMonthSr")
    ->Belt.Option.getWithDefault({
      fromTime: "",
      toTime: "",
    }),
    industrySr: emptyDict
    ->Dict.get("industrySr")
    ->Belt.Option.getWithDefault({
      fromTime: "",
      toTime: "",
    }),
  }
}

let datatableDateDescFormat = (timeRanges: timeRanges) => {
  if timeRanges.fromTime !== "" && timeRanges.toTime !== "" {
    `S.R comparing to ${timeRanges.fromTime
      ->Js.Date.fromString
      ->DateTimeUtils.utcToIST
      ->TimeZoneHook.formattedISOString("YYYY-MM-DD HH:mm:ss")}- ${timeRanges.toTime
      ->Js.Date.fromString
      ->DateTimeUtils.utcToIST
      ->TimeZoneHook.formattedISOString("YYYY-MM-DD HH:mm:ss")}`
  } else {
    ""
  }
}

let singlestatDeltaTooltipFormat = (value: float, timeRanges: timeRanges, statType: string) => {
  let timeText = if timeRanges.fromTime !== "" && timeRanges.toTime !== "" {
    `${"\n"} ${timeRanges.fromTime
      ->Js.Date.fromString
      ->DateTimeUtils.utcToIST
      ->TimeZoneHook.formattedISOString("YYYY-MM-DD HH:mm:ss")}- ${"\n"} ${timeRanges.toTime
      ->Js.Date.fromString
      ->DateTimeUtils.utcToIST
      ->TimeZoneHook.formattedISOString("YYYY-MM-DD HH:mm:ss")}`
  } else {
    ""
  }

  let tooltipComp = if timeText !== "" {
    if statType === "Latency" || statType === "NegativeRate" {
      if value > 0. {
        let text = "Increased by "
        let value = Js.Math.abs_float(value)->Belt.Float.toString ++ "%"
        <div className="whitespace-pre-line">
          <AddDataAttributes attributes=[("data-text", text)]>
            <div> {React.string(text)} </div>
          </AddDataAttributes>
          <AddDataAttributes attributes=[("data-numeric", value)]>
            <div className="text-red-500 text-base font-bold font-fira-code">
              {React.string(value)}
            </div>
          </AddDataAttributes>
          {React.string(`comparing to ${timeText}`)}
        </div>
      } else if value < 0. {
        let text = "Decreased by "
        let value = value->Belt.Float.toString ++ "%"
        <div className="whitespace-pre-line">
          <AddDataAttributes attributes=[("data-text", text)]>
            <div> {React.string(text)} </div>
          </AddDataAttributes>
          <AddDataAttributes attributes=[("data-numeric", value)]>
            <div className="text-status-green text-base font-bold font-fira-code">
              {React.string(value)}
            </div>
          </AddDataAttributes>
          {React.string(`comparing to ${timeText}`)}
        </div>
      } else {
        let text = "Changed by "
        let value = value->Belt.Float.toString ++ "%"
        <div className="whitespace-pre-line">
          <AddDataAttributes attributes=[("data-text", text)]>
            <div> {React.string(text)} </div>
          </AddDataAttributes>
          <AddDataAttributes attributes=[("data-numeric", value)]>
            <div className="text-sankey_labels text-base font-bold font-fira-code">
              {React.string(value)}
            </div>
          </AddDataAttributes>
          {React.string(`comparing to ${timeText}`)}
        </div>
      }
    } else if value < 0. {
      let text = "Decreased by "
      let value = Js.Math.abs_float(value)->Belt.Float.toString ++ "%"
      <div className="whitespace-pre-line">
        <AddDataAttributes attributes=[("data-text", text)]>
          <div> {React.string(text)} </div>
        </AddDataAttributes>
        <AddDataAttributes attributes=[("data-numeric", value)]>
          <div className="text-red-500 text-base font-bold font-fira-code">
            {React.string(value)}
          </div>
        </AddDataAttributes>
        {React.string(`comparing to ${timeText}`)}
      </div>
    } else if value > 0. {
      let text = "Increased by "
      let value = value->Belt.Float.toString ++ "%"
      <div className="whitespace-pre-line">
        <AddDataAttributes attributes=[("data-text", text)]>
          <div> {React.string(text)} </div>
        </AddDataAttributes>
        <AddDataAttributes attributes=[("data-numeric", value)]>
          <div className="text-status-green text-base font-bold font-fira-code">
            {React.string(value)}
          </div>
        </AddDataAttributes>
        {React.string(`comparing to ${timeText}`)}
      </div>
    } else {
      let text = "Changed by "
      let value = value->Belt.Float.toString ++ "%"
      <div className="whitespace-pre-line">
        <AddDataAttributes attributes=[("data-text", text)]>
          <div> {React.string(text)} </div>
        </AddDataAttributes>
        <AddDataAttributes attributes=[("data-numeric", value)]>
          <div className="text-sankey_labels text-base font-bold font-fira-code">
            {React.string(value)}
          </div>
        </AddDataAttributes>
        {React.string(`comparing to ${timeText}`)}
      </div>
    }
  } else {
    {React.string("")}
  }
  <div className="p-2"> {tooltipComp} </div>
}

let modeLabelMapper = str => {
  if str === "TXN" {
    "By Transactions"
  } else {
    "By Orders"
  }
}
let getModeName = mode => {
  if mode === "TXN" {
    "Transactions"
  } else {
    "Orders"
  }
}

let sumOfArr = (arr: array<int>) => {
  arr->Belt.Array.reduce(0, (acc, value) => acc + value)
}

let sumOfArrFloat = (arr: array<float>) => {
  arr->Belt.Array.reduce(0., (acc, value) => acc +. value)
}

open IntroJsReact

let transactionAnalyticsSteps = [
  makeStep(
    ~element=".daterangSelection",
    ~title="Calendar",
    ~intro="Update the dashboard with the selected daterange",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".modeSelection",
    ~title="Analytics Mode",
    ~intro="Switch between Transaction/ Order modes to view different levels of the data",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".syncButton",
    ~title="Refresh View",
    ~intro="Refresh the dashboard with the applied settings",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".showFilterButton",
    ~title="Add Filters",
    ~intro="Apply filters from the exhaustive list of dimensions",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".singlestatBox",
    ~title="Singlestats",
    ~intro="A broader picture into transaction analytics",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".singleStatTooltip",
    ~title="Singlestats Tooltip",
    ~intro="Hover here for metrics definition",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".analyticsTabs",
    ~title="Pick your Segment",
    ~intro="Pick one of the pre-added segments to update the charts, table and sankey view",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".analyticsTabsAdd",
    ~title="Build new Segment",
    ~intro="Select upto 3 segments in a combination from our list of dimensions",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".dynamicChart",
    ~title="Chart View",
    ~intro="Make your own chart area",
    ~position=#top,
    (),
  ),
  makeStep(
    ~element=".inputGranButton",
    ~title="Chart Time Bucket",
    ~intro="Update the chart's time bucket",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".inputCardButton",
    ~title="Chart Cardinality",
    ~intro="Update the chart's cardinality",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".metricButton",
    ~title="Chart Metric",
    ~intro="Update the chart's metric",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".loadedTable",
    ~title="Summary Table",
    ~intro="A detailed aggregated anaysis of your performance",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableSearch",
    ~title="Search Datatable",
    ~intro="Search Datatable for specific content",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableColumnButton",
    ~title="Customize Columns",
    ~intro="Add / Remove columns to / from the datatable",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableHeader",
    ~title="Sort Columns",
    ~intro="Click on a column header to sort the column",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".filterColumns",
    ~title="Filter Columns",
    ~intro="Filter the datatable view with columnwise conditions",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".highchart-sankey ",
    ~title="Performance Sankey",
    ~intro="An aesthetic representation of the conversion funnel",
    ~position=#bottom,
    (),
  ),
]

let tokenizationAnalyticsSteps = [
  makeStep(
    ~element=".daterangSelection",
    ~title="Calendar",
    ~intro="Update the dashboard with the selected daterange",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".modeSelection",
    ~title="Analytics Mode",
    ~intro="Switch between Transaction/ Order modes to view different levels of the data",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".syncButton",
    ~title="Refresh View",
    ~intro="Refresh the dashboard with the applied settings",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".showFilterButton",
    ~title="Add Filters",
    ~intro="Apply filters from the exhaustive list of dimensions",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".singlestatBox",
    ~title="Singlestats",
    ~intro="A broader picture into tokenization analytics",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".singleStatTooltip",
    ~title="Singlestats Tooltip",
    ~intro="Hover here for metrics definition",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".analyticsTabs",
    ~title="Pick your Segment",
    ~intro="Pick one of the pre-added segments to update the charts, table and sankey view",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".analyticsTabsAdd",
    ~title="Build new Segment",
    ~intro="Select upto 3 segments in a combination from our list of dimensions",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".dynamicChart",
    ~title="Chart View",
    ~intro="Make your own chart area",
    ~position=#top,
    (),
  ),
  makeStep(
    ~element=".inputGranButton",
    ~title="Chart Time Bucket",
    ~intro="Update the chart's time bucket",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".inputCardButton",
    ~title="Chart Cardinality",
    ~intro="Update the chart's cardinality",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".metricButton",
    ~title="Chart Metric",
    ~intro="Update the chart's metric",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".loadedTable",
    ~title="Summary Table",
    ~intro="A detailed aggregated anaysis of your performance",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableSearch",
    ~title="Search Datatable",
    ~intro="Search Datatable for specific content",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableColumnButton",
    ~title="Customize Columns",
    ~intro="Add / Remove columns to / from the datatable",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableHeader",
    ~title="Sort Columns",
    ~intro="Click on a column header to sort the column",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".filterColumns",
    ~title="Filter Columns",
    ~intro="Filter the datatable view with columnwise conditions",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".highchart-sankey ",
    ~title="Performance Sankey",
    ~intro="An aesthetic representation of the conversion funnel",
    ~position=#bottom,
    (),
  ),
]

let dotpAnalyticsSteps = [
  makeStep(
    ~element=".daterangSelection",
    ~title="Calendar",
    ~intro="Update the dashboard with the selected daterange",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".modeSelection",
    ~title="Analytics Mode",
    ~intro="Switch between Transaction/ Order modes to view different levels of the data",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".syncButton",
    ~title="Refresh View",
    ~intro="Refresh the dashboard with the applied settings",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".showFilterButton",
    ~title="Add Filters",
    ~intro="Apply filters from the exhaustive list of dimensions",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".singlestatBox",
    ~title="Singlestats",
    ~intro="A broader picture into native OTP analytics",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".singleStatTooltip",
    ~title="Singlestats Tooltip",
    ~intro="Hover here for metrics definition",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".analyticsTabs",
    ~title="Pick your Segment",
    ~intro="Pick one of the pre-added segments to update the charts, table and sankey view",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".analyticsTabsAdd",
    ~title="Build new Segment",
    ~intro="Select upto 3 segments in a combination from our list of dimensions",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".dynamicChart",
    ~title="Chart View",
    ~intro="Make your own chart area",
    ~position=#top,
    (),
  ),
  makeStep(
    ~element=".inputGranButton",
    ~title="Chart Time Bucket",
    ~intro="Update the chart's time bucket",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".inputCardButton",
    ~title="Chart Cardinality",
    ~intro="Update the chart's cardinality",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".metricButton",
    ~title="Chart Metric",
    ~intro="Update the chart's metric",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".loadedTable",
    ~title="Summary Table",
    ~intro="A detailed aggregated anaysis of your performance",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableSearch",
    ~title="Search Datatable",
    ~intro="Search Datatable for specific content",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableColumnButton",
    ~title="Customize Columns",
    ~intro="Add / Remove columns to / from the datatable",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableHeader",
    ~title="Sort Columns",
    ~intro="Click on a column header to sort the column",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".filterColumns",
    ~title="Filter Columns",
    ~intro="Filter the datatable view with columnwise conditions",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".highchart-sankey ",
    ~title="Performance Sankey",
    ~intro="An aesthetic representation of the conversion funnel",
    ~position=#bottom,
    (),
  ),
]

let refundsAnalyticsSteps = [
  makeStep(
    ~element=".daterangSelection",
    ~title="Calendar",
    ~intro="Update the dashboard with the selected daterange",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".modeSelection",
    ~title="Analytics Mode",
    ~intro="Switch between Transaction/ Order modes to view different levels of the data",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".syncButton",
    ~title="Refresh View",
    ~intro="Refresh the dashboard with the applied settings",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".showFilterButton",
    ~title="Add Filters",
    ~intro="Apply filters from the exhaustive list of dimensions",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".singlestatBox",
    ~title="Singlestats",
    ~intro="A broader picture into refund analytics",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".singleStatTooltip",
    ~title="Singlestats Tooltip",
    ~intro="Hover here for metrics definition",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".analyticsTabs",
    ~title="Pick your Segment",
    ~intro="Pick one of the pre-added segments to update the charts, table and sankey view",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".analyticsTabsAdd",
    ~title="Build new Segment",
    ~intro="Select upto 3 segments in a combination from our list of dimensions",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".dynamicChart",
    ~title="Chart View",
    ~intro="Make your own chart area",
    ~position=#top,
    (),
  ),
  makeStep(
    ~element=".inputGranButton",
    ~title="Chart Time Bucket",
    ~intro="Update the chart's time bucket",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".inputCardButton",
    ~title="Chart Cardinality",
    ~intro="Update the chart's cardinality",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".metricButton",
    ~title="Chart Metric",
    ~intro="Update the chart's metric",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".loadedTable",
    ~title="Summary Table",
    ~intro="A detailed aggregated anaysis of your performance",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableSearch",
    ~title="Search Datatable",
    ~intro="Search Datatable for specific content",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableColumnButton",
    ~title="Customize Columns",
    ~intro="Add / Remove columns to / from the datatable",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableHeader",
    ~title="Sort Columns",
    ~intro="Click on a column header to sort the column",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".filterColumns",
    ~title="Filter Columns",
    ~intro="Filter the datatable view with columnwise conditions",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".highchart-sankey ",
    ~title="Performance Sankey",
    ~intro="An aesthetic representation of the conversion funnel",
    ~position=#bottom,
    (),
  ),
]
let payoutAnalyticsSteps = [
  makeStep(
    ~element=".daterangSelection",
    ~title="Calendar",
    ~intro="Update the dashboard with the selected daterange",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".modeSelection",
    ~title="Analytics Mode",
    ~intro="Switch between Transaction/ Order modes to view different levels of the data",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".syncButton",
    ~title="Refresh View",
    ~intro="Refresh the dashboard with the applied settings",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".showFilterButton",
    ~title="Add Filters",
    ~intro="Apply filters from the exhaustive list of dimensions",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".singlestatBox",
    ~title="Singlestats",
    ~intro="A broader picture into payout analytics",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".singleStatTooltip",
    ~title="Singlestats Tooltip",
    ~intro="Hover here for metrics definition",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".analyticsTabs",
    ~title="Pick your Segment",
    ~intro="Pick one of the pre-added segments to update the charts, table and sankey view",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".analyticsTabsAdd",
    ~title="Build new Segment",
    ~intro="Select upto 3 segments in a combination from our list of dimensions",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".dynamicChart",
    ~title="Chart View",
    ~intro="Make your own chart area",
    ~position=#top,
    (),
  ),
  makeStep(
    ~element=".inputGranButton",
    ~title="Chart Time Bucket",
    ~intro="Update the chart's time bucket",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".inputCardButton",
    ~title="Chart Cardinality",
    ~intro="Update the chart's cardinality",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".metricButton",
    ~title="Chart Metric",
    ~intro="Update the chart's metric",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".loadedTable",
    ~title="Summary Table",
    ~intro="A detailed aggregated anaysis of your performance",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableSearch",
    ~title="Search Datatable",
    ~intro="Search Datatable for specific content",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableColumnButton",
    ~title="Customize Columns",
    ~intro="Add / Remove columns to / from the datatable",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableHeader",
    ~title="Sort Columns",
    ~intro="Click on a column header to sort the column",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".filterColumns",
    ~title="Filter Columns",
    ~intro="Filter the datatable view with columnwise conditions",
    ~position=#bottom,
    (),
  ),
]

let upiTxnAnalyticsSteps = [
  makeStep(
    ~element=".daterangSelection",
    ~title="Calendar",
    ~intro="Update the dashboard with the selected daterange",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".syncButton",
    ~title="Refresh View",
    ~intro="Refresh the dashboard with the applied settings",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".showFilterButton",
    ~title="Add Filters",
    ~intro="Apply filters from the exhaustive list of dimensions",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".singlestatBox",
    ~title="Singlestats",
    ~intro="A broader picture into UPI transactions analytics",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".singleStatTooltip",
    ~title="Singlestats Tooltip",
    ~intro="Hover here for metrics definition",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".analyticsTabs",
    ~title="Pick your Segment",
    ~intro="Pick one of the pre-added segments to update the charts, table and sankey view",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".analyticsTabsAdd",
    ~title="Build new Segment",
    ~intro="Select upto 3 segments in a combination from our list of dimensions",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".dynamicChart",
    ~title="Chart View",
    ~intro="Make your own chart area",
    ~position=#top,
    (),
  ),
  makeStep(
    ~element=".inputGranButton",
    ~title="Chart Time Bucket",
    ~intro="Update the chart's time bucket",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".inputCardButton",
    ~title="Chart Cardinality",
    ~intro="Update the chart's cardinality",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".metricButton",
    ~title="Chart Metric",
    ~intro="Update the chart's metric",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".loadedTable",
    ~title="Summary Table",
    ~intro="A detailed aggregated anaysis of your performance",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableSearch",
    ~title="Search Datatable",
    ~intro="Search Datatable for specific content",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableColumnButton",
    ~title="Customize Columns",
    ~intro="Add / Remove columns to / from the datatable",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableHeader",
    ~title="Sort Columns",
    ~intro="Click on a column header to sort the column",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".filterColumns",
    ~title="Filter Columns",
    ~intro="Filter the datatable view with columnwise conditions",
    ~position=#bottom,
    (),
  ),
]
let upiTxnRefundsAnalyticsSteps = [
  makeStep(
    ~element=".daterangSelection",
    ~title="Calendar",
    ~intro="Update the dashboard with the selected daterange",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".syncButton",
    ~title="Refresh View",
    ~intro="Refresh the dashboard with the applied settings",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".showFilterButton",
    ~title="Add Filters",
    ~intro="Apply filters from the exhaustive list of dimensions",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".singlestatBox",
    ~title="Singlestats",
    ~intro="A broader picture into UPI Refunds analytics",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".singleStatTooltip",
    ~title="Singlestats Tooltip",
    ~intro="Hover here for metrics definition",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".analyticsTabs",
    ~title="Pick your Segment",
    ~intro="Pick one of the pre-added segments to update the charts and table view",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".analyticsTabsAdd",
    ~title="Build new Segment",
    ~intro="Select upto 3 segments in a combination from our list of dimensions",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".dynamicChart",
    ~title="Chart View",
    ~intro="Make your own chart area",
    ~position=#top,
    (),
  ),
  makeStep(
    ~element=".inputGranButton",
    ~title="Chart Time Bucket",
    ~intro="Update the chart's time bucket",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".inputCardButton",
    ~title="Chart Cardinality",
    ~intro="Update the chart's cardinality",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".metricButton",
    ~title="Chart Metric",
    ~intro="Update the chart's metric",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".loadedTable",
    ~title="Summary Table",
    ~intro="A detailed aggregated anaysis of your performance",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableSearch",
    ~title="Search Datatable",
    ~intro="Search Datatable for specific content",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableColumnButton",
    ~title="Customize Columns",
    ~intro="Add / Remove columns to / from the datatable",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".tableHeader",
    ~title="Sort Columns",
    ~intro="Click on a column header to sort the column",
    ~position=#bottom,
    (),
  ),
  makeStep(
    ~element=".filterColumns",
    ~title="Filter Columns",
    ~intro="Filter the datatable view with columnwise conditions",
    ~position=#bottom,
    (),
  ),
]

let nameViewField = (~isDisabled) =>
  FormRenderer.makeFieldInfo(
    ~label="Name of View",
    ~name="name",
    ~placeholder="Enter Name of View(max 30 characters allowed)",
    ~customInput=InputFields.textInput(
      ~maxLength=30,
      ~autoFocus=true,
      ~isDisabled,
      ~customStyle="!font-medium !text-fs-14",
      (),
    ),
    ~isRequired=true,
    (),
  )

let descriptionField = FormRenderer.makeFieldInfo(
  ~label="View Description",
  ~placeholder="Describe this view for your own future reference",
  ~name="description",
  ~customInput=InputFields.multiLineTextInput(
    ~rows=Some(4),
    ~cols=Some(37),
    ~customClass="!font-medium !text-fs-14 !resize-none",
    ~isDisabled=false,
    (),
  ),
  ~isRequired=false,
  (),
)

let selectorsField = (~isHorizontal) =>
  FormRenderer.makeFieldInfo(
    ~label="",
    ~name="selectors",
    ~customInput={
      let buttonText = "Choose preferences"
      let options = ["Make this view Default", "Save with current timestamp"]->SelectBox.makeOptions

      InputFields.multiSelectInput(
        ~buttonText,
        ~options,
        ~isDropDown=false,
        ~isHorizontal,
        ~fullLength=true,
        ~dropdownCustomWidth="w-full",
        ~showSelectAll=false,
        ~customStyle="text-jp-2-light-gray-1600",
        (),
      )
    },
    ~isRequired=true,
    (),
  )

module NoDataFoundPage = {
  @react.component
  let make = () => {
    let _isAlreadyRendered =
      document->getElementsByClassName("noDataFoundPage")->Belt.Array.get(0)->Belt.Option.isSome
    let filterOnClick = () => {
      let element = document->getElementsByClassName("showFilterButton")->Belt.Array.get(0)
      switch element {
      | Some(domElement) => {
          let nodeElement = domElement.childNodes->Belt.Array.get(0)
          switch nodeElement {
          | Some(btnElement) => btnElement->DOMUtils.click()
          | None => ()
          }
        }

      | None => ()
      }
    }

    let dateRangeOnClick = () => {
      let element = document->getElementsByClassName("daterangSelection")->Belt.Array.get(0)
      switch element {
      | Some(domElement) => {
          let nodeElement = domElement.childNodes->Belt.Array.get(0)
          switch nodeElement {
          | Some(ele) => {
              let nodeElement = (ele->toNode).childNodes->Belt.Array.get(0)
              switch nodeElement {
              | Some(btnElement) => btnElement->DOMUtils.click()
              | None => ()
              }
            }

          | None => ()
          }
        }

      | None => ()
      }
    }

    <NoDataFound
      renderType={LoadError}
      message="Reduce the Range or narrow down the result by applying filter">
      <div className="flex gap-4 mt-5 noDataFoundPage">
        <Button text="Apply Filters" buttonType=Pagination onClick={_ => filterOnClick()} />
        <Button text="Reduce DateRange" buttonType=Pagination onClick={_ => dateRangeOnClick()} />
      </div>
    </NoDataFound>
  }
}

type analyticsSegmentDescription = {
  title: string,
  description: string,
}

type openingTab = NewTab | SameTab
module AnalyticsRedirectToOrder = {
  @react.component
  let make = (
    ~label,
    ~customurl="",
    ~customClass="",
    ~isMandate=false,
    ~openTabIn: openingTab=SameTab,
  ) => {
    let (isLoading, setLoading) = React.useState(_ => false)

    let onClick = _evt => {
      setLoading(_ => false)
    }

    <div onClick>
      <div className="flex items-center">
        <span className=customClass> {React.string(label)} </span>
        {if isLoading {
          <span className="px-3">
            <span className={`flex items-center animate-spin`}>
              <Loadericon />
            </span>
          </span>
        } else {
          React.null
        }}
      </div>
    </div>
  }
}

module RedirectToOrderTableModal = {
  type tableDetails = {
    orderId: string,
    merchantId: string,
    timestamp: string,
    error_message: string,
    order_status: string,
  }

  type colType =
    | OrderID
    | MerchantID
    | Timestamp
    | Error_Message
    | Order_Status

  let defaultColumns = [OrderID, MerchantID, Timestamp, Error_Message, Order_Status]

  let allColumns = defaultColumns

  let filterByData = (actualData, value) => {
    let searchText = getStringFromJson(value, "")->String.toLowerCase

    actualData
    ->Belt.Array.keepMap(Js.Nullable.toOption)
    ->Belt.Array.keepMap((data: tableDetails) => {
      let dict = Dict.fromArray([
        ("orderId", data.orderId),
        ("merchantId", data.merchantId),
        ("timestamp", data.timestamp),
        ("error_message", data.error_message),
        ("order_status", data.order_status),
      ])

      let isMatched =
        dict
        ->Dict.valuesToArray
        ->Array.map(val => {
          val->String.toLowerCase->String.includes(searchText)
        })
        ->Array.includes(true)

      if isMatched {
        data->Js.Nullable.return->Some
      } else {
        None
      }
    })
  }

  let itemToObjMapper = dict => {
    {
      orderId: getString(dict, "order_id", ""),
      merchantId: getString(dict, "merchant_id", ""),
      timestamp: getString(dict, "time_bucket", ""),
      error_message: getString(dict, "error_message", ""),
      order_status: getString(dict, "order_status", ""),
    }
  }

  let getTableDetails: Js.Json.t => array<tableDetails> = json => {
    getArrayDataFromJson(json, itemToObjMapper)
  }

  let getHeading = colType => {
    switch colType {
    | OrderID => Table.makeHeaderInfo(~key="orderId", ~title="Order ID", ~showSort=true, ())
    | MerchantID =>
      Table.makeHeaderInfo(~key="merchantId", ~title="Merchant ID", ~showSort=true, ())
    | Timestamp => Table.makeHeaderInfo(~key="timestamp", ~title="Timestamp", ~showSort=true, ())
    | Error_Message =>
      Table.makeHeaderInfo(~key="error_message", ~title="Error Message", ~showSort=true, ())
    | Order_Status =>
      Table.makeHeaderInfo(~key="order_status", ~title="Order Status", ~showSort=true, ())
    }
  }

  let getCell = (isMandate, tableDetails, colType): Table.cell => {
    switch colType {
    | OrderID =>
      CustomCell(
        <AnalyticsRedirectToOrder
          label=tableDetails.orderId
          customClass="text-blue-700 font-base cursor-pointer hover:font-medium"
          openTabIn={NewTab}
          isMandate
        />,
        tableDetails.orderId,
      )
    | MerchantID => Text(tableDetails.merchantId)

    | Timestamp => Date(tableDetails.timestamp)
    | Error_Message => Text(tableDetails.error_message)
    | Order_Status => Text(tableDetails.order_status)
    }
  }

  let summayTableEntity = (url, isMandate) =>
    EntityType.makeEntity(
      ~uri=url,
      ~getObjects=getTableDetails,
      ~allColumns,
      ~defaultColumns,
      ~getHeading,
      ~getCell=getCell(isMandate),
      (),
    )
}

let sampleApiBodyBQ = (tableApiBodyEntity: tableApiBodyEntity) => {
  let timeRange =
    [
      ("startTime", tableApiBodyEntity.startTimeFromUrl->Js.Json.string),
      ("endTime", tableApiBodyEntity.endTimeFromUrl->Js.Json.string),
    ]->Dict.fromArray

  let defaultFilters =
    [
      ("timeRange", timeRange->Js.Json.object_),
      (
        "filters",
        tableApiBodyEntity.filterValueFromUrl->Belt.Option.getWithDefault(
          Js.Json.object_(Dict.make()),
        ),
      ),
      ("source", "BQ"->Js.Json.string),
      ("mode", tableApiBodyEntity.mode->Belt.Option.getWithDefault("")->Js.Json.string),
    ]->Dict.fromArray

  [
    (
      "activeTab",
      tableApiBodyEntity.currenltySelectedTab
      ->Belt.Option.getWithDefault([])
      ->Array.map(Js.Json.string)
      ->Js.Json.array,
    ),
    ("filter", defaultFilters->Js.Json.object_),
  ]
  ->Dict.fromArray
  ->Js.Json.object_
  ->Js.Json.stringify
}

module AnalyticsTabsWrapper = {
  @react.component
  let make = (~children) => {
    <div className="flex flex-row">
      <div className="flex flex-col h-full w-full relative"> children </div>
    </div>
  }
}
module NoDataFound = {
  @react.component
  let make = () => {
    <div className="w-full flex flex-col items-center m-auto py-4">
      <div className="font-normal mt-2"> {React.string("No Data Found")} </div>
      <div className="text-gray-400 mt-2 max-w-[260px] text-center">
        {React.string("We couldn’t fetch any data for this. Please refresh this page.")}
      </div>
    </div>
  }
}

type getFilters = {
  startTime: string,
  endTime: string,
  filterValueFromUrl?: Js.Json.t,
}
let useGetFilters = (
  ~startTimeFilterKey: string="",
  ~endTimeFilterKey: string="",
  ~filterKeys: array<string>=[],
  ~moduleName: string="",
  ~modeKey: string="",
  ~customFilterKey: string="",
  (),
) => {
  let {filterValue} = React.useContext(FilterContext.filterContext)
  let getAllFilter =
    filterValue
    ->Dict.toArray
    ->Array.map(item => {
      let (key, value) = item
      (key, value->UrlFetchUtils.getFilterValue)
    })
    ->Dict.fromArray
  let getTopLevelSingleStatFilter = React.useMemo1(() => {
    getAllFilter
    ->Dict.toArray
    ->Belt.Array.keepMap(item => {
      let (key, value) = item
      let keyArr = key->String.split(".")
      let prefix = keyArr->Belt.Array.get(0)->Belt.Option.getWithDefault("")
      if prefix === moduleName && prefix !== "" {
        None
      } else {
        Some((prefix, value))
      }
    })
    ->Dict.fromArray
  }, [getAllFilter])

  let (topFiltersToSearchParam, _customFilter, _modeValue) = React.useMemo1(() => {
    let modeValue = Some(getTopLevelSingleStatFilter->LogicUtils.getString(modeKey, ""))
    let allFilterKeys = Array.concat(
      [startTimeFilterKey, endTimeFilterKey, modeValue->Belt.Option.getWithDefault("")],
      filterKeys,
    )
    let filterSearchParam =
      getTopLevelSingleStatFilter
      ->Dict.toArray
      ->Belt.Array.keepMap(entry => {
        let (key, value) = entry
        if allFilterKeys->Array.includes(key) {
          switch value->Js.Json.classify {
          | JSONString(str) => `${key}=${str}`->Some
          | JSONNumber(num) => `${key}=${num->String.make}`->Some
          | JSONArray(arr) => `${key}=[${arr->String.make}]`->Some
          | _ => None
          }
        } else {
          None
        }
      })
      ->Array.joinWith("&")

    (
      filterSearchParam,
      getTopLevelSingleStatFilter->LogicUtils.getString(customFilterKey, ""),
      modeValue,
    )
  }, [getTopLevelSingleStatFilter])
  let filterValueFromUrl = React.useMemo1(() => {
    getTopLevelSingleStatFilter
    ->Dict.toArray
    ->Belt.Array.keepMap(entries => {
      let (key, value) = entries
      filterKeys->Array.includes(key) ? Some((key, value)) : None
    })
    ->Dict.fromArray
    ->Js.Json.object_
    ->Some
  }, [topFiltersToSearchParam])

  let startTimeFromUrl = React.useMemo1(() => {
    getTopLevelSingleStatFilter->LogicUtils.getString(startTimeFilterKey, "")
  }, [topFiltersToSearchParam])
  let endTimeFromUrl = React.useMemo1(() => {
    getTopLevelSingleStatFilter->LogicUtils.getString(endTimeFilterKey, "")
  }, [topFiltersToSearchParam])

  {
    startTime: startTimeFromUrl,
    endTime: endTimeFromUrl,
    ?filterValueFromUrl,
  }
}
