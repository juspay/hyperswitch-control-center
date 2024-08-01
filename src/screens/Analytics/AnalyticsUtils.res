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
  initialFixedFilters: JSON.t => array<EntityType.initialFilters<'t>>,
  initialFilters: JSON.t => array<EntityType.initialFilters<'t>>,
  filterDropDownOptions: JSON.t => array<EntityType.optionType<'t>>,
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
  initialFixedFilters: JSON.t => array<EntityType.initialFilters<'t>>,
  initialFilters: (JSON.t, string => unit) => array<EntityType.initialFilters<'t>>,
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
  filterValueFromUrl?: JSON.t,
  currenltySelectedTab?: array<string>,
  deltaMetrics: array<string>,
  isIndustry: bool,
  distributionArray?: array<JSON.t>,
  deltaPrefixArr: array<string>,
  tableMetrics: array<string>,
  mode?: string,
  customFilter: string,
  moduleName: string,
  showDeltaMetrics: bool,
  source: string,
}

type newApiBodyEntity = {
  timeObj: Dict.t<JSON.t>,
  metric?: string,
  groupBy?: array<Js_string.t>,
  granularityConfig?: (int, string),
  cardinality?: float,
  filterValueFromUrl?: JSON.t,
  customFilterValue?: string,
  jsonFormattedFilter?: JSON.t,
  cardinalitySortDims?: string,
  domain: string,
}

type analyticsTableEntity<'colType, 't> = {
  metrics: array<string>,
  deltaMetrics: array<string>,
  headerMetrics: array<string>,
  distributionArray: option<array<JSON.t>>,
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
  tableGlobalFilter: option<(array<Nullable.t<'t>>, JSON.t) => array<Nullable.t<'t>>>,
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
  newTableBodyMaker?: newApiBodyEntity => JSON.t,
  jsonTransformer?: (string, array<JSON.t>, array<string>) => array<JSON.t>,
}

type statSentiment = Positive | Negative | Neutral

let (startTimeFilterKey, endTimeFilterKey, optFilterKey) = ("startTime", "endTime", "opt")
let getDateCreatedObject = () => {
  let currentDate = Date.now()
  let filterCreatedDict = Dict.make()
  let currentTimestamp = currentDate->Js.Date.fromFloat->Date.toISOString
  let dateFormat = "YYYY-MM-DDTHH:mm:[00][Z]"
  Dict.set(
    filterCreatedDict,
    endTimeFilterKey,
    JSON.Encode.string(currentTimestamp->TimeZoneHook.formattedISOString(dateFormat)),
  )

  let prevTime = {
    let presentDayInString = Js.Date.fromFloat(currentDate)
    Js.Date.setHoursMS(presentDayInString, ~hours=0.0, ~minutes=0.0, ~seconds=0.0, ())
  }

  let defaultStartTime = {
    JSON.Encode.string(
      prevTime
      ->Js.Date.fromFloat
      ->Date.toISOString
      ->TimeZoneHook.formattedISOString("YYYY-MM-DDTHH:mm:[00][Z]"),
    )
  }
  Dict.set(filterCreatedDict, startTimeFilterKey, defaultStartTime)
  Dict.set(filterCreatedDict, "opt", JSON.Encode.string("today"))

  filterCreatedDict
}

open LogicUtils
let getFilterRequestBody = (
  ~granularity: option<string>=None,
  ~groupByNames: option<array<string>>=None,
  ~filter: option<JSON.t>=None,
  ~metrics: option<array<string>>=None,
  ~delta: bool=true,
  ~prefix: option<string>=None,
  ~distributionValues: option<JSON.t>=None,
  ~startDateTime,
  ~endDateTime,
  ~cardinality: option<string>=None,
  ~mode: option<string>=None,
  ~customFilter: string="",
  ~source: string="BATCH",
  (),
) => {
  let body: Dict.t<JSON.t> = Dict.make()
  let timeRange = Dict.make()
  let timeSeries = Dict.make()

  Dict.set(timeRange, "startTime", startDateTime->JSON.Encode.string)
  Dict.set(timeRange, "endTime", endDateTime->JSON.Encode.string)
  Dict.set(body, "timeRange", timeRange->JSON.Encode.object)

  switch groupByNames {
  | Some(groupByNames) =>
    if groupByNames->Array.length != 0 {
      Dict.set(
        body,
        "groupByNames",
        groupByNames
        ->ArrayUtils.getUniqueStrArray
        ->Belt.Array.keepMap(item => Some(item->JSON.Encode.string))
        ->JSON.Encode.array,
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

  if customFilter->isNonEmptyString {
    Dict.set(body, "customFilter", customFilter->JSON.Encode.string)
  }
  switch granularity {
  | Some(granularity) => {
      Dict.set(timeSeries, "granularity", granularity->JSON.Encode.string)
      Dict.set(body, "timeSeries", timeSeries->JSON.Encode.object)
    }

  | None => ()
  }

  switch cardinality {
  | Some(cardinality) => Dict.set(body, "cardinality", cardinality->JSON.Encode.string)
  | None => ()
  }
  switch mode {
  | Some(mode) => Dict.set(body, "mode", mode->JSON.Encode.string)
  | None => ()
  }

  switch prefix {
  | Some(prefix) => Dict.set(body, "prefix", prefix->JSON.Encode.string)
  | None => ()
  }

  Dict.set(body, "source", source->JSON.Encode.string)

  switch metrics {
  | Some(metrics) =>
    if metrics->Array.length != 0 {
      Dict.set(
        body,
        "metrics",
        metrics
        ->ArrayUtils.getUniqueStrArray
        ->Belt.Array.keepMap(item => Some(item->JSON.Encode.string))
        ->JSON.Encode.array,
      )
    }
  | None => ()
  }
  if delta {
    Dict.set(body, "delta", true->JSON.Encode.bool)
  }

  body
}

let filterBody = (filterBodyEntity: filterBodyEntity) => {
  let (startTime, endTime) = try {
    (
      (filterBodyEntity.startTime->DayJs.getDayJsForString).subtract(
        1,
        "day",
      ).toDate()->Date.toISOString,
      (filterBodyEntity.endTime->DayJs.getDayJsForString).add(1, "day").toDate()->Date.toISOString,
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
  let nowtime = Date.make()->Date.toString->DayJs.getDayJsForString
  let dateTimeFormat = "YYYY-MM-DDTHH:mm:ss[Z]"
  if typeTime == "last7" {
    let last7FromTime = (fromTime->DayJs.getDayJsForString).subtract(7, "day")
    let last7ToTime = (fromTime->DayJs.getDayJsForString).subtract(1, "day")

    let timeArray = Dict.fromArray([
      ("fromTime", last7FromTime.format(dateTimeFormat)),
      ("toTime", last7ToTime.format(dateTimeFormat)),
    ])

    [timeArray]
  } else if typeTime == "yesterday" {
    let yesterdayFromTime =
      Js.Date.fromFloat(
        Js.Date.setHoursMS(
          nowtime.subtract(1, "day").toDate(),
          ~hours=0.0,
          ~minutes=0.0,
          ~seconds=0.0,
          (),
        ),
      )->DayJs.getDayJsForJsDate
    let yesterdayToTime =
      Js.Date.fromFloat(
        Js.Date.setHoursMS(
          nowtime.subtract(1, "day").toDate(),
          ~hours=23.0,
          ~minutes=59.0,
          ~seconds=59.0,
          (),
        ),
      )->DayJs.getDayJsForJsDate

    let timeArray = Dict.fromArray([
      ("fromTime", yesterdayFromTime.format(dateTimeFormat)),
      ("toTime", yesterdayToTime.format(dateTimeFormat)),
    ])

    [timeArray]
  } else if typeTime == "currentmonth" {
    let currentMonth = Js.Date.fromFloat(Js.Date.setDate(Date.make(), 1.0))
    let currentMonthFromTime =
      Js.Date.fromFloat(
        Js.Date.setHoursMS(currentMonth, ~hours=0.0, ~minutes=0.0, ~seconds=0.0, ()),
      )
      ->Date.toString
      ->DayJs.getDayJsForString
    let currentMonthToTime = nowtime
    let timeArray = Dict.fromArray([
      ("fromTime", currentMonthFromTime.format(dateTimeFormat)),
      ("toTime", currentMonthToTime.format(dateTimeFormat)),
    ])

    [timeArray]
  } else if typeTime == "currentweek" {
    let currentWeekFromTime = Date.make()->DateTimeUtils.getStartOfWeek(Monday)
    let currentWeekToTime = Date.make()->DayJs.getDayJsForJsDate

    let timeArray = Dict.fromArray([
      ("fromTime", currentWeekFromTime.format(dateTimeFormat)),
      ("toTime", currentWeekToTime.format(dateTimeFormat)),
    ])

    [timeArray]
  } else {
    let timeArray = Dict.make()
    [timeArray]
  }
}
let generateDateArray = (~startTime, ~endTime, ~deltaPrefixArr) => {
  let dateArray = Array.map(deltaPrefixArr, x =>
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
  ~filters: option<JSON.t>,
  ~customFilter,
) => {
  let timeArr = Dict.fromArray([
    ("startTime", startTime->JSON.Encode.string),
    ("endTime", endTime->JSON.Encode.string),
  ])
  let newDict = switch groupByNames {
  | Some(groupByNames) =>
    Dict.fromArray([
      ("timeRange", timeArr->JSON.Encode.object),
      ("metrics", metrics->getJsonFromArrayOfString),
      ("groupByNames", groupByNames->getJsonFromArrayOfString),
      ("prefix", prefix->JSON.Encode.string),
      ("source", source->JSON.Encode.string),
      ("delta", delta->JSON.Encode.bool),
    ])
  | None =>
    Dict.fromArray([
      ("timeRange", timeArr->JSON.Encode.object),
      ("metrics", metrics->getJsonFromArrayOfString),
      ("prefix", prefix->JSON.Encode.string),
      ("source", source->JSON.Encode.string),
      ("delta", delta->JSON.Encode.bool),
    ])
  }

  switch mode {
  | Some(mode) => Dict.set(newDict, "mode", mode->JSON.Encode.string)
  | None => ()
  }
  if customFilter->isNonEmptyString {
    Dict.set(newDict, "customFilter", customFilter->JSON.Encode.string)
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
  ~filters: option<JSON.t>,
  ~showDeltaMetrics=false,
  ~customFilter,
) => {
  let dictOfDates = Array.flat(deltaDateArr)
  let tablePayload = Belt.Array.zipBy(dictOfDates, deltaPrefixArr, (x, y) =>
    generatePayload(
      ~startTime=x->Dict.get("fromTime")->Option.getOr(""),
      ~endTime=x->Dict.get("toTime")->Option.getOr(""),
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
  ~filterValueFromUrl: option<JSON.t>,
  ~currenltySelectedTab: option<array<string>>,
  ~tableMetrics: array<string>,
  ~distributionArray: option<array<JSON.t>>,
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
  let tableBodyValues =
    tableBodyWithNonDeltaMetrix->Array.concatMany([tableBodyWithDeltaMetrix, tableIndustryPayload])

  let distributionPayload = switch distributionArray {
  | Some(distributionArray) =>
    distributionArray->Array.map(arr =>
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
    tableBodyValues
    ->Array.concatMany([deltaPayload, distributionPayload])
    ->Array.map(JSON.Encode.object)
    ->JSON.Encode.array
  tableBody
}

let singlestatDeltaTooltipFormat = (value: float, timeRanges: timeRanges) => (statType: string) => {
  let timeText = if timeRanges.fromTime->isNonEmptyString && timeRanges.toTime->isNonEmptyString {
    `${"\n"} ${timeRanges.fromTime
      ->Date.fromString
      ->DateTimeUtils.utcToIST
      ->TimeZoneHook.formattedISOString("YYYY-MM-DD HH:mm:ss")}- ${"\n"} ${timeRanges.toTime
      ->Date.fromString
      ->DateTimeUtils.utcToIST
      ->TimeZoneHook.formattedISOString("YYYY-MM-DD HH:mm:ss")}`
  } else {
    ""
  }

  let tooltipComp = if timeText->isNonEmptyString {
    if statType === "Latency" || statType === "NegativeRate" {
      if value > 0. {
        let text = "Increased by "
        let value = Math.abs(value)->Float.toString ++ "%"
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
        let value = value->Float.toString ++ "%"
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
        let value = value->Float.toString ++ "%"
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
      let value = Math.abs(value)->Float.toString ++ "%"
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
      let value = value->Float.toString ++ "%"
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
      let value = value->Float.toString ++ "%"
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
  arr->Array.reduce(0, (acc, value) => acc + value)
}

let sumOfArrFloat = (arr: array<float>) => {
  arr->Array.reduce(0., (acc, value) => acc +. value)
}

module NoDataFoundPage = {
  @react.component
  let make = () => {
    let filterOnClick = () => {
      let element = document->getElementsByClassName("showFilterButton")->Array.get(0)
      switch element {
      | Some(domElement) => {
          let nodeElement = domElement.childNodes->Array.get(0)
          switch nodeElement {
          | Some(btnElement) => btnElement->DOMUtils.click()
          | None => ()
          }
        }

      | None => ()
      }
    }

    let dateRangeOnClick = () => {
      let element = document->getElementsByClassName("daterangSelection")->Array.get(0)
      switch element {
      | Some(domElement) => {
          let nodeElement = domElement.childNodes->Array.get(0)
          switch nodeElement {
          | Some(ele) => {
              let nodeElement = (ele->toNode).childNodes->Array.get(0)
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

module NoDataFoundGaneral = {
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
  filterValueFromUrl?: JSON.t,
}

let filterFieldsPortalName = "analytics"

let setPrecision = (num, ~digit=2, ()) => {
  num->Float.toFixedWithPrecision(~digits=digit)->Js.Float.fromString
}

let getQueryData = json => {
  json->getDictFromJsonObject->getArrayFromDict("queryData", [])
}

let options: JSON.t => array<EntityType.optionType<'t>> = json => {
  json
  ->getDictFromJsonObject
  ->getOptionalArrayFromDict("queryData")
  ->Option.flatMap(arr => {
    arr
    ->Array.map(dimensionObject => {
      let dimensionObject = dimensionObject->getDictFromJsonObject
      let dimension = getString(dimensionObject, "dimension", "")
      let dimensionTitleCase = `Select ${snakeToTitle(dimension)}`
      let value = getArrayFromDict(dimensionObject, "values", [])->getStrArrayFromJsonArray
      let dropdownOptions: EntityType.optionType<'t> = {
        urlKey: dimension,
        field: {
          FormRenderer.makeFieldInfo(
            ~label="",
            ~name=dimension,
            ~customInput=InputFields.multiSelectInput(
              ~options={
                value
                ->SelectBox.makeOptions
                ->Array.map(
                  item => {
                    let value = {...item, label: item.value}
                    value
                  },
                )
              },
              ~buttonText=dimensionTitleCase,
              ~showSelectionAsChips=false,
              ~searchable=true,
              ~showToolTip=true,
              ~showNameAsToolTip=true,
              ~customButtonStyle="bg-none",
              (),
            ),
            (),
          )
        },
        parser: val => val,
        localFilter: None,
      }
      dropdownOptions
    })
    ->Some
  })
  ->Option.getOr([])
}

let filterByData = (txnArr, value) => {
  let searchText = LogicUtils.getStringFromJson(value, "")

  txnArr
  ->Belt.Array.keepMap(Nullable.toOption)
  ->Belt.Array.keepMap((data: 't) => {
    let valueArr =
      data
      ->Identity.genericTypeToDictOfJson
      ->Dict.toArray
      ->Array.map(item => {
        let (_, value) = item

        value->JSON.Decode.string->Option.getOr("")->String.toLowerCase->String.includes(searchText)
      })
      ->Array.reduce(false, (acc, item) => item || acc)
    if valueArr {
      data->Nullable.make->Some
    } else {
      None
    }
  })
}

let initialFilterFields = json => {
  let dropdownValue =
    json
    ->getDictFromJsonObject
    ->getOptionalArrayFromDict("queryData")
    ->Option.flatMap(arr => {
      arr
      ->Belt.Array.keepMap(item => {
        let dimensionObject = item->getDictFromJsonObject

        let dimension = getString(dimensionObject, "dimension", "")
        let dimensionTitleCase = `Select ${snakeToTitle(dimension)}`
        let value = getArrayFromDict(dimensionObject, "values", [])->getStrArrayFromJsonArray

        Some(
          (
            {
              field: FormRenderer.makeFieldInfo(
                ~label="",
                ~name=dimension,
                ~customInput=InputFields.filterMultiSelectInput(
                  ~options=value->FilterSelectBox.makeOptions,
                  ~buttonText=dimensionTitleCase,
                  ~showSelectionAsChips=false,
                  ~searchable=true,
                  ~showToolTip=true,
                  ~showNameAsToolTip=true,
                  ~customButtonStyle="bg-none",
                  (),
                ),
                (),
              ),
              localFilter: Some(filterByData),
            }: EntityType.initialFilters<'t>
          ),
        )
      })
      ->Some
    })
    ->Option.getOr([])

  dropdownValue
}

let initialFixedFilterFields = _json => {
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

let getStringListFromArrayDict = metrics => {
  metrics->Array.map(item => item->getDictFromJsonObject->getString("name", ""))
}

module NoData = {
  @react.component
  let make = (~title, ~subTitle) => {
    <div className="p-5">
      <PageUtils.PageHeading title subTitle />
      <NoDataFound message="No Data Available" renderType=Painting>
        <Button
          text={"Make a Payment"}
          buttonSize={Small}
          onClick={_ => RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/home"))}
          buttonType={Primary}
        />
      </NoDataFound>
    </div>
  }
}

let generateWeeklyTablePayload = (
  ~startTimeFromUrl: string,
  ~endTimeFromUrl: string,
  ~filterValueFromUrl: option<JSON.t>,
  ~currenltySelectedTab: option<array<string>>,
  ~tableMetrics: array<string>,
  ~distributionArray: option<array<JSON.t>>,
  ~deltaMetrics: array<string>,
  ~deltaPrefixArr: array<string>,
  ~isIndustry: bool,
  ~mode: option<string>,
  ~customFilter,
  ~showDeltaMetrics,
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
    switch distributionArray {
    | Some(distributionArray) =>
      distributionArray->Array.map(arr =>
        getFilterRequestBody(
          ~groupByNames=currenltySelectedTab,
          ~filter=filterValueFromUrl,
          ~metrics=Some(deltaMetrics),
          ~delta=showDeltaMetrics,
          ~mode,
          ~startDateTime=startTime,
          ~distributionValues=Some(arr),
          ~endDateTime=endTime,
          ~customFilter,
          ~source,
          (),
        )
      )
    | None => [
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
    }
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
  let tableBodyValues =
    tableBodyWithNonDeltaMetrix->Array.concatMany([tableBodyWithDeltaMetrix, tableIndustryPayload])

  let tableBody =
    tableBodyValues->Array.concat(deltaPayload)->Array.map(JSON.Encode.object)->JSON.Encode.array
  tableBody
}

open DateTimeUtils
type timeZone = UTC | IST
let calculateHistoricTime = (
  ~startTime: string,
  ~endTime: string,
  ~format: string="YYYY-MM-DDTHH:mm:ss[Z]",
  ~timeZone: timeZone=UTC,
  (),
) => {
  let toUtc = switch timeZone {
  | UTC => toUtc
  | IST => val => val
  }
  if startTime->LogicUtils.isNonEmptyString && endTime->LogicUtils.isNonEmptyString {
    let startDateTime = startTime->DateTimeUtils.parseAsFloat->Js.Date.fromFloat->toUtc

    let startTimeDayJs = startDateTime->DayJs.getDayJsForJsDate
    let endDateTime = endTime->DateTimeUtils.parseAsFloat->Js.Date.fromFloat->toUtc

    let endDateTimeJs = endDateTime->DayJs.getDayJsForJsDate
    let timediff = endDateTimeJs.diff(Date.toString(startDateTime), "hours")

    if timediff < 24 {
      (
        startTimeDayJs.subtract(24, "hours").format(format),
        endDateTimeJs.subtract(24, "hours").format(format),
      )
    } else {
      let fromTime = startDateTime->Js.Date.valueOf
      let toTime = endDateTime->Js.Date.valueOf
      let (startTime, endTime) = (
        (fromTime -. (toTime -. fromTime) -. 1.)->Js.Date.fromFloat->DayJs.getDayJsForJsDate,
        (fromTime -. 1.)->Js.Date.fromFloat->DayJs.getDayJsForJsDate,
      )

      (startTime.format(format), endTime.format(format))
    }
  } else {
    ("", "")
  }
}

let makeFilters = (~filters: JSON.t, ~cardinalityArr) => {
  let decodeFilter = filters->getDictFromJsonObject

  let expressionArr =
    decodeFilter
    ->Dict.toArray
    ->Array.map(item => {
      let (key, value) = item
      Dict.fromArray([
        ("field", key->JSON.Encode.string),
        ("condition", "In"->JSON.Encode.string),
        ("val", value),
      ])
    })
  let expressionArr = Array.concat(cardinalityArr, expressionArr)
  if expressionArr->Array.length === 1 {
    expressionArr->Array.get(0)
  } else if expressionArr->Array.length > 1 {
    let leftInitial = Array.pop(expressionArr)->Option.getOr(Dict.make())->JSON.Encode.object
    let rightInitial = Array.pop(expressionArr)->Option.getOr(Dict.make())->JSON.Encode.object

    let complexFilterDict = Dict.fromArray([
      ("and", Dict.fromArray([("left", leftInitial), ("right", rightInitial)])->JSON.Encode.object),
    ])
    expressionArr->Array.forEach(item => {
      let complextFilterDictCopy = complexFilterDict->Dict.toArray->Array.copy->Dict.fromArray
      complexFilterDict->Dict.set(
        "and",
        Dict.fromArray([
          ("left", complextFilterDictCopy->JSON.Encode.object),
          ("right", item->JSON.Encode.object),
        ])->JSON.Encode.object,
      )
    })
    Some(complexFilterDict)
  } else {
    None
  }
}

let getFilterBody = (
  filterValueFromUrl,
  customFilterValue,
  jsonFormattedFilter,
  cardinalityArrFilter,
) => {
  let customFilterBuild = switch customFilterValue {
  | Some(customFilterValue) => {
      let value =
        String.replaceRegExp(customFilterValue, %re("/ AND /gi"), "@@")
        ->String.replaceRegExp(%re("/ OR /gi"), "@@")
        ->String.split("@@")
      let strAr = ["or", "and"]

      let andAndOr = String.split(customFilterValue, " ")->Array.filter(item => {
        strAr->Array.includes(item->String.toLocaleLowerCase)
      })

      let filterValueArr =
        value
        ->Array.mapWithIndex((item, _index) => {
          if item->String.match(%re("/ != /gi"))->Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ != /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Option.getOr("")->JSON.Encode.string),
                  ("condition", "NotEquals"->JSON.Encode.string),
                  (
                    "val",
                    value[1]
                    ->Option.getOr("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->JSON.Encode.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if String.match(item, %re("/ > /gi"))->Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ > /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Option.getOr("")->JSON.Encode.string),
                  ("condition", "Greater"->JSON.Encode.string),
                  (
                    "val",
                    value[1]
                    ->Option.getOr("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->JSON.Encode.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if item->String.match(%re("/ < /gi"))->Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ < /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Option.getOr("")->JSON.Encode.string),
                  ("condition", "Less"->JSON.Encode.string),
                  (
                    "val",
                    value[1]
                    ->Option.getOr("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->JSON.Encode.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if item->String.match(%re("/ >= /gi"))->Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ >= /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Option.getOr("")->JSON.Encode.string),
                  ("condition", "GreaterThanEquall"->JSON.Encode.string),
                  (
                    "val",
                    value[1]
                    ->Option.getOr("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->JSON.Encode.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if item->String.match(%re("/ <= /gi"))->Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ <= /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Option.getOr("")->JSON.Encode.string),
                  ("condition", "LessThanEqual"->JSON.Encode.string),
                  (
                    "val",
                    value[1]
                    ->Option.getOr("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->JSON.Encode.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if item->String.match(%re("/ = /gi"))->Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ = /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Option.getOr("")->JSON.Encode.string),
                  ("condition", "Equals"->JSON.Encode.string),
                  (
                    "val",
                    value[1]
                    ->Option.getOr("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->JSON.Encode.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if item->String.match(%re("/ IN /gi"))->Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ IN /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Option.getOr("")->JSON.Encode.string),
                  ("condition", "In"->JSON.Encode.string),
                  (
                    "val",
                    value[1]
                    ->Option.getOr("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->String.replaceRegExp(%re("/\(/g"), "")
                    ->String.replaceRegExp(%re("/\)/g"), "")
                    ->String.split(",")
                    ->Array.map(item => item->String.trim)
                    ->LogicUtils.getJsonFromArrayOfString,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if item->String.match(%re("/ NOT IN /gi"))->Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ NOT IN /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Option.getOr("")->JSON.Encode.string),
                  ("condition", "NotIn"->JSON.Encode.string),
                  (
                    "val",
                    value[1]
                    ->Option.getOr("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->String.replaceRegExp(%re("/\(/g"), "")
                    ->String.replaceRegExp(%re("/\)/g"), "")
                    ->String.split(",")
                    ->Array.map(item => item->String.trim)
                    ->LogicUtils.getJsonFromArrayOfString,
                  ),
                ]),
              )
            } else {
              None
            }
          } else if item->String.match(%re("/ LIKE /gi"))->Option.isSome {
            let value =
              String.replaceRegExp(item, %re("/ LIKE /gi"), "@@")
              ->String.split("@@")
              ->Array.map(item => item->String.trim)
            if value->Array.length >= 2 {
              Some(
                Dict.fromArray([
                  ("field", value[0]->Option.getOr("")->JSON.Encode.string),
                  ("condition", "Like"->JSON.Encode.string),
                  (
                    "val",
                    value[1]
                    ->Option.getOr("")
                    ->String.replaceRegExp(%re("/'/gi"), "")
                    ->JSON.Encode.string,
                  ),
                ]),
              )
            } else {
              None
            }
          } else {
            None
          }
        })
        ->Belt.Array.keepMap(item => item)

      if filterValueArr->Array.length === 1 {
        filterValueArr->Array.get(0)
      } else if filterValueArr->Array.length >= 2 {
        let leftInitial = filterValueArr[0]->Option.getOr(Dict.make())
        let rightInitial = filterValueArr[1]->Option.getOr(Dict.make())
        let conditionInitital = andAndOr->Array.get(0)->Option.getOr("and")
        let complexFilterDict = Dict.fromArray([
          (
            conditionInitital,
            Dict.fromArray([
              ("left", leftInitial->JSON.Encode.object),
              ("right", rightInitial->JSON.Encode.object),
            ])->JSON.Encode.object,
          ),
        ])
        let filterValueArr = filterValueArr->Array.copy->Array.sliceToEnd(~start=2)
        let andAndOr = andAndOr->Array.copy->Array.sliceToEnd(~start=1)

        filterValueArr->Array.forEachWithIndex((item, index) => {
          let complextFilterDictCopy = complexFilterDict->Dict.toArray->Array.copy->Dict.fromArray
          complexFilterDict->Dict.set(
            andAndOr->Array.get(index)->Option.getOr("and"),
            Dict.fromArray([
              ("left", complextFilterDictCopy->JSON.Encode.object),
              ("right", item->JSON.Encode.object),
            ])->JSON.Encode.object,
          )
        })
        Some(complexFilterDict)
      } else {
        None
      }
    }

  | None => None
  }
  let filterValue = switch (filterValueFromUrl, customFilterBuild) {
  | (Some(value), Some(customFilter)) =>
    switch makeFilters(~filters=value, ~cardinalityArr=cardinalityArrFilter) {
    | Some(formattedFilters) => {
        let overallFilters = Dict.fromArray([
          (
            "and",
            Dict.fromArray([
              ("left", formattedFilters->JSON.Encode.object),
              ("right", customFilter->JSON.Encode.object),
            ])->JSON.Encode.object,
          ),
        ])
        overallFilters
      }

    | None => customFilter
    }

  | (Some(value), None) =>
    switch makeFilters(~filters=value, ~cardinalityArr=cardinalityArrFilter) {
    | Some(formattedFilters) => formattedFilters
    | None => Dict.make()
    }

  | (None, Some(customFilter)) => customFilter

  | (None, None) => Dict.make()
  }

  switch jsonFormattedFilter {
  | Some(jsonFormattedFilter) =>
    switch filterValue->Dict.toArray->Array.length > 0 {
    | true =>
      Dict.fromArray([
        (
          "and",
          Dict.fromArray([
            ("left", filterValue->JSON.Encode.object),
            ("right", jsonFormattedFilter),
          ])->JSON.Encode.object,
        ),
      ])
    | false => jsonFormattedFilter->JSON.Decode.object->Option.getOr(Dict.make())
    }
  | None => filterValue
  }
}

type ordering = [#Desc | #Asc]
type sortedBasedOn = {
  sortDimension: string,
  ordering: ordering,
}

let timeZoneMapper = timeZone => {
  switch timeZone {
  | IST => "Asia/Kolkata"
  | UTC => "UTC"
  }
}

let apiBodyMaker = (
  ~timeObj,
  ~metric,
  ~groupBy=?,
  ~granularityConfig=?,
  ~cardinality=?,
  ~filterValueFromUrl=?,
  ~customFilterValue=?,
  ~sortingParams: option<sortedBasedOn>=?,
  ~jsonFormattedFilter: option<JSON.t>=?,
  ~cardinalitySortDims="total_volume",
  ~timeZone: timeZone=IST,
  ~timeCol: string="txn_initiated",
  ~domain: string,
  ~dataLimit: option<float>=?,
  (),
) => {
  let finalBody = Dict.make()

  let cardinalityArrFilter = switch (cardinality, groupBy) {
  | (Some(cardinality), Some(groupBy)) =>
    groupBy->Array.map(item => {
      Dict.fromArray([
        ("field", item->JSON.Encode.string),
        ("condition", "In"->JSON.Encode.string),
        (
          "val",
          Dict.fromArray([
            (
              "sortedOn",
              Dict.fromArray([
                ("sortDimension", cardinalitySortDims->JSON.Encode.string),
                ("ordering", "Desc"->JSON.Encode.string),
              ])->JSON.Encode.object,
            ),
            ("limit", cardinality->JSON.Encode.float),
          ])->JSON.Encode.object,
        ),
      ])
    })
  | _ => []
  }

  let activeTabArr = groupBy->Option.getOr([])->Array.map(JSON.Encode.string)
  finalBody->Dict.set("metric", metric->JSON.Encode.string)
  let filterVal = getFilterBody(
    filterValueFromUrl,
    customFilterValue,
    jsonFormattedFilter,
    cardinalityArrFilter,
  )

  if filterVal->Dict.toArray->Array.length !== 0 {
    finalBody->Dict.set("filters", filterVal->JSON.Encode.object)
  }

  switch granularityConfig {
  | Some(config) => {
      let (granularityDuration, granularityUnit) = config
      let granularityDimension = Dict.make()
      let granularity = Dict.make()
      Dict.set(granularityDimension, "timeZone", timeZone->timeZoneMapper->JSON.Encode.string)
      Dict.set(granularityDimension, "intervalCol", timeCol->JSON.Encode.string)
      Dict.set(granularity, "unit", granularityUnit->JSON.Encode.string)
      Dict.set(granularity, "duration", granularityDuration->Int.toFloat->JSON.Encode.float)
      Dict.set(granularityDimension, "granularity", granularity->JSON.Encode.object)

      finalBody->Dict.set(
        "dimensions",
        Array.concat(activeTabArr, [granularityDimension->JSON.Encode.object])->JSON.Encode.array,
      )
    }

  | None => finalBody->Dict.set("dimensions", activeTabArr->JSON.Encode.array)
  }

  switch sortingParams {
  | Some(val) =>
    finalBody->Dict.set(
      "sortedOn",
      Dict.fromArray([
        ("sortDimension", val.sortDimension->JSON.Encode.string),
        (
          "ordering",
          val.ordering === #Desc ? "Desc"->JSON.Encode.string : "Asc"->JSON.Encode.string,
        ),
      ])->JSON.Encode.object,
    )
  | None => ()
  }
  switch dataLimit {
  | Some(dataLimit) => finalBody->Dict.set("limit", dataLimit->JSON.Encode.float)
  | None => ()
  }

  finalBody->Dict.set("domain", domain->JSON.Encode.string)
  finalBody->Dict.set("interval", timeObj->JSON.Encode.object)
  finalBody->JSON.Encode.object
}
