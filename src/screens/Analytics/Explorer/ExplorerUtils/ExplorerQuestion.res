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

let previousWindow = question =>
  DateRangeUtils.getComparisonTimePeriod(~startDate=question.startTime, ~endDate=question.endTime)

let currentWindow = question => (question.startTime, question.endTime)

let getCountRequestBody = (question, ~window as (startDateTime, endDateTime)) =>
  [
    AnalyticsUtils.getFilterRequestBody(
      ~groupByNames=Some(question->countGroupBy->Array.map(item => (item :> string))),
      ~metrics=Some(question->countMetrics->Array.map(item => (item :> string))),
      ~delta=false,
      ~startDateTime,
      ~endDateTime,
    )->JSON.Encode.object,
  ]->JSON.Encode.array

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
