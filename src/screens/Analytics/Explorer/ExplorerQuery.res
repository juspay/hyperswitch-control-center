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
  {
    source,
    measure,
    split,
    dimensions,
    currency: filterValueJson->getString(urlKey("currency"), ""),
    startTime: filterValueJson->getString(HSAnalyticsUtils.startTimeFilterKey, ""),
    endTime: filterValueJson->getString(HSAnalyticsUtils.endTimeFilterKey, ""),
  }
}

let hasDates = question =>
  question.startTime->isNonEmptyString && question.endTime->isNonEmptyString

let splitOptions = question => getSplitDimensions(question.measure, ~dimensions=question.dimensions)

let needsCurrency = question => isAmount(question.measure)

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

let requestBody = (
  ~window as (startTime, endTime),
  ~groupBy: array<dimension>,
  ~metrics: array<metric>,
) =>
  [
    [
      ("timeRange", timeRangeJson(startTime, endTime)),
      ("groupByNames", groupBy->Array.map(item => (item :> string))->getJsonFromArrayOfString),
      ("metrics", metrics->Array.map(item => (item :> string))->getJsonFromArrayOfString),
    ]->getJsonFromArrayOfJson,
  ]->JSON.Encode.array

let previousWindow = question =>
  DateRangeUtils.getComparisonTimePeriod(~startDate=question.startTime, ~endDate=question.endTime)

let getCountRequestBody = (question, ~window) =>
  requestBody(~window, ~groupBy=question->countGroupBy, ~metrics=question->countMetrics)

let getRateRequestBody = (question, ~window, ~groupBy) =>
  question->getRateMetric->Option.map(metric => requestBody(~window, ~groupBy, ~metrics=[metric]))

let requestKey = question =>
  [
    question.source->sourceToString,
    question->countGroupBy->Array.map(key => (key :> string))->Array.joinWith(","),
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
