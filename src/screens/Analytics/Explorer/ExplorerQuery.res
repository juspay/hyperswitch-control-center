open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils

let questionFromFilters = filterValueJson => {
  let source = filterValueJson->getString(urlKey(#source), "")->sourceFromString
  {
    source,
    measure: source->measureFromString(filterValueJson->getString(urlKey(#measure), "")),
    currency: filterValueJson->getString(urlKey(#currency), ""),
    startTime: filterValueJson->getString(HSAnalyticsUtils.startTimeFilterKey, ""),
    endTime: filterValueJson->getString(HSAnalyticsUtils.endTimeFilterKey, ""),
  }
}

let hasDates = question =>
  question.startTime->isNonEmptyString && question.endTime->isNonEmptyString

let needsCurrency = question => isAmount(question.measure)

let countGroupBy = (question): array<dimension> => {
  let threeDsColumn = switch getMeasureFormula(question.source, question.measure) {
  | Rate(_, ThreeDsAttempts) => [#authentication_type]
  | _ => []
  }
  [#status]->Array.concat(threeDsColumn)->Array.concat(needsCurrency(question) ? [#currency] : [])
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

let currentWindow = question => (question.startTime, question.endTime)

let getCountRequestBody = (question, ~window) =>
  requestBody(~window, ~groupBy=question->countGroupBy, ~metrics=question->countMetrics)

let requestKey = question =>
  [
    (question.source :> string),
    question->countGroupBy->Array.map(key => (key :> string))->Array.joinWith(","),
    question->countMetrics->Array.map(metric => (metric :> string))->Array.joinWith(","),
    question.startTime,
    question.endTime,
  ]->Array.joinWith("|")

let selectionUpdate = (updates: array<(selectionKey, string)>) =>
  updates->Array.map(((key, value)) => (urlKey(key), value))->Dict.fromArray
