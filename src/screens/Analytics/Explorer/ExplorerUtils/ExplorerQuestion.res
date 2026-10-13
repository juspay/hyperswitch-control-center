open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils

let sourceFromFilters = filterValueJson =>
  filterValueJson->getString(urlKey(#source), "")->sourceFromString

let questionFromFilters = (filterValueJson, ~backendDimensions) => {
  let source = filterValueJson->sourceFromFilters
  let measure = source->measureFromString(filterValueJson->getString(urlKey(#measure), ""))
  let dimensions = source->getOfferedDimensions(~backendDimensions)
  let splitOptions = getSplitDimensions(measure, ~dimensions)
  {
    source,
    measure,
    split: filterValueJson
    ->getStrArrayFromDict(urlKey(#split), [])
    ->Array.filterMap(id => splitOptions->findDimension(id))
    ->Array.slice(~start=0, ~end=2),
    dimensions,
    currency: filterValueJson->getString(urlKey(#currency), ""),
    startTime: filterValueJson->getString(HSAnalyticsUtils.startTimeFilterKey, ""),
    endTime: filterValueJson->getString(HSAnalyticsUtils.endTimeFilterKey, ""),
  }
}

let hasDates = question =>
  question.startTime->isNonEmptyString && question.endTime->isNonEmptyString

let splitOptions = question => getSplitDimensions(question.measure, ~dimensions=question.dimensions)

let needsCurrency = question => isAmount(question.measure)

let countGroupBy = (question): array<dimension> => {
  let threeDsColumn = switch getMeasureFormula(question.source, question.measure) {
  | Rate(_, ThreeDsAttempts) => [#authentication_type]
  | _ => []
  }
  let fixed =
    [#status]->Array.concat(threeDsColumn)->Array.concat(needsCurrency(question) ? [#currency] : [])
  fixed->Array.concat(question.split->Array.filter(key => !(fixed->Array.includes(key))))
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

let splitValue = (split: array<dimension>) =>
  `[${split->Array.map(item => (item :> string))->Array.joinWith(",")}]`

let splitAt = (question, index, key: option<dimension>) =>
  question.split
  ->Array.slice(~start=0, ~end=index)
  ->Array.concat(key->mapOptionOrDefault([], key => [key]))
  ->Array.concat(
    key->Option.isSome
      ? question.split->Array.sliceToEnd(~start=index + 1)->Array.filter(item => Some(item) != key)
      : [],
  )
