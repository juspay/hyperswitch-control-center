open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils

let sourceFromFilters = filterValueJson =>
  filterValueJson->getString(urlKey("source"), "")->sourceFromString

let questionFromFilters = (filterValueJson, ~backendDimensions) => {
  let source = filterValueJson->sourceFromFilters
  let dimensions = source->getOfferedDimensions(~backendDimensions)
  let measure = {
    let selected = filterValueJson->getString(urlKey("measure"), "")->measureFromString
    sourceConfig(source).measures->Array.includes(selected) ? selected : SuccessRate
  }
  let splitOptions = getSplitDimensions(measure, ~dimensions)
  let split =
    filterValueJson
    ->getStrArrayFromDict(urlKey("split"), [])
    ->Array.filterMap(id => splitOptions->findDimension(id))
    ->Array.slice(~start=0, ~end=2)
  let filters =
    filterValueJson
    ->Dict.toArray
    ->Array.filterMap(((key, value)) =>
      key->String.startsWith(filterPrefix)
        ? dimensions
          ->findDimension(key->String.sliceToEnd(~start=filterPrefix->String.length))
          ->Option.map(dimension => (dimension, value->filterValuesFromJson))
          ->Option.filter(((_, values)) => values->isNonEmptyArray)
        : None
    )
  {
    source,
    measure,
    split,
    view: filterValueJson->getString(urlKey("view"), "")->viewFromString,
    dimensions,
    filters,
    currency: filterValueJson->getString(urlKey("currency"), ""),
    startTime: filterValueJson->getString(HSAnalyticsUtils.startTimeFilterKey, ""),
    endTime: filterValueJson->getString(HSAnalyticsUtils.endTimeFilterKey, ""),
  }
}

let hasDates = question =>
  question.startTime->isNonEmptyString && question.endTime->isNonEmptyString

let splitOptions = question => getSplitDimensions(question.measure, ~dimensions=question.dimensions)

let getSelectedFilterValues = (question, dimension) =>
  question.filters
  ->Array.find(((key, _)) => key == dimension)
  ->Option.mapOr([], ((_, values)) => values)

let needsCurrency = question =>
  isAmount(question.measure) && question->getSelectedFilterValues(#currency)->Array.length != 1

let getRateMetric = question =>
  question.measure == SuccessRate ? Some(sourceConfig(question.source).successRateMetric) : None

let countGroupBy = (question): array<dimension> => {
  let threeDsColumn = switch getMeasureFormula(question.source, question.measure) {
  | Rate(_, ThreeDsAttempts) => [#authentication_type]
  | _ => []
  }
  [#status]
  ->Array.concat(threeDsColumn)
  ->Array.concat(question.split)
  ->Array.concat(needsCurrency(question) ? [#currency] : [])
  ->uniqueItems
}

let countMetrics = question => {
  let config = sourceConfig(question.source)
  [config.countMetric]->Array.concat(isAmount(question.measure) ? [config.amountMetric] : [])
}

let timeRangeJson = (startTime, endTime) =>
  [
    ("startTime", startTime->JSON.Encode.string),
    ("endTime", endTime->JSON.Encode.string),
  ]->getJsonFromArrayOfJson

let filterField = (dimension: dimension) =>
  switch dimension {
  | #authentication_type => "auth_type"
  | _ => (dimension :> string)
  }

let filtersJson = question =>
  question.filters
  ->Array.map(((key, values)) => (key->filterField, values->getJsonFromArrayOfString))
  ->getJsonFromArrayOfJson

let requestBody = (
  question,
  ~window as (startTime, endTime),
  ~groupBy: array<dimension>,
  ~metrics: array<metric>,
  ~daily,
) => {
  let body = [
    ("timeRange", timeRangeJson(startTime, endTime)),
    ("groupByNames", groupBy->Array.map(item => (item :> string))->getJsonFromArrayOfString),
    ("filters", question->filtersJson),
    ("metrics", metrics->Array.map(item => (item :> string))->getJsonFromArrayOfString),
  ]
  let body = daily
    ? body->Array.concat([
        ("timeSeries", [("granularity", "G_ONEDAY"->JSON.Encode.string)]->getJsonFromArrayOfJson),
      ])
    : body
  [body->getJsonFromArrayOfJson]->JSON.Encode.array
}

let previousWindow = question =>
  DateRangeUtils.getComparisonTimePeriod(~startDate=question.startTime, ~endDate=question.endTime)

let getCountRequestBody = (question, ~window, ~daily=false) =>
  requestBody(
    question,
    ~window,
    ~groupBy=question->countGroupBy,
    ~metrics=question->countMetrics,
    ~daily,
  )

let getRateRequestBody = (question, ~window, ~groupBy, ~daily=false) =>
  question
  ->getRateMetric
  ->Option.map(metric => requestBody(question, ~window, ~groupBy, ~metrics=[metric], ~daily))

let requestKey = question =>
  [
    question.source->sourceToString,
    question->countGroupBy->Array.map(key => (key :> string))->Array.joinWith(","),
    question->filtersJson->JSON.stringify,
    question->countMetrics->Array.map(metric => (metric :> string))->Array.joinWith(","),
    question->getRateMetric->Option.mapOr("", metric => (metric :> string)),
    question.split->Array.map(key => (key :> string))->Array.joinWith(","),
    question.startTime,
    question.endTime,
  ]->Array.joinWith("|")

let selectionUpdate = (updates: array<(string, string)>) =>
  updates->Array.map(((key, value)) => (urlKey(key), value))->Dict.fromArray

let splitValue = (split: array<dimension>) =>
  `[${split->Array.map(item => (item :> string))->Array.joinWith(",")}]`

let splitAt = (question, index, key: option<dimension>) =>
  question.split
  ->Array.slice(~start=0, ~end=index)
  ->Array.concat(key->Option.mapOr([], key => [key]))
  ->Array.concat(key->Option.isSome ? question.split->Array.sliceToEnd(~start=index + 1) : [])
  ->uniqueItems

let filtersBody = (question, ~dimension: dimension) =>
  [
    ("timeRange", timeRangeJson(question.startTime, question.endTime)),
    ("groupByNames", [(dimension :> string)]->getJsonFromArrayOfString),
    ("source", "BATCH"->JSON.Encode.string),
  ]->getJsonFromArrayOfJson

let filterKey = (dimension: dimension) => `${filterPrefix}${(dimension :> string)}`

let filterValue = values => `[${values->Array.map(encodeFilterValue)->Array.joinWith(",")}]`

let filterUpdate = (dimension, values) =>
  [(filterKey(dimension), filterValue(values))]->Dict.fromArray

let getFocusUpdate = (question, group: group) =>
  question.split
  ->Array.mapWithIndex((key, index) => (key, group.values->getValueFromArray(index, "")))
  ->Array.filter(((_, value)) => value->isNonEmptyString)
  ->Array.map(((key, value)) => (filterKey(key), filterValue([value])))
  ->Array.concat([
    (urlKey("split"), "[]"),
    (urlKey("from"), question.split->Array.get(0)->Option.mapOr("", key => (key :> string))),
  ])
  ->Dict.fromArray

let getSplitSuggestions = (question, ~drilledFrom) => {
  let options = question->splitOptions
  suggestedNext(
    question.source,
    question.split->Array.get(0)->Option.orElse(drilledFrom),
  )->Array.filter(key => options->Array.includes(key) && !(question.split->Array.includes(key)))
}
