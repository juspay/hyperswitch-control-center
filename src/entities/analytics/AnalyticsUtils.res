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

type newApiBodyEntity = {
  timeObj: Dict.t<Js.Json.t>,
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
  let body: Dict.t<Js.Json.t> = Dict.make()
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

let sumOfArr = (arr: array<int>) => {
  arr->Belt.Array.reduce(0, (acc, value) => acc + value)
}

let sumOfArrFloat = (arr: array<float>) => {
  arr->Belt.Array.reduce(0., (acc, value) => acc +. value)
}

module NoDataFoundPage = {
  @react.component
  let make = () => {
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
