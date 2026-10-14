open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils

let sourceFromFilters = filterValueJson =>
  filterValueJson->getString(filterKey(#source), "")->sourceFromString

let selectionFromFilters = (filterValueJson, ~backendDimensions) => {
  let source = filterValueJson->sourceFromFilters
  let measure = source->measureFromString(filterValueJson->getString(filterKey(#measure), ""))
  let splitOptions = getSplitDimensions(
    measure,
    ~dimensions=source->getOfferedDimensions(~backendDimensions),
  )
  {
    source,
    measure,
    split: filterValueJson
    ->getStrArrayFromDict(filterKey(#split), [])
    ->Array.filterMap(id => splitOptions->findDimension(id))
    ->Array.slice(~start=0, ~end=2),
    splitOptions,
    view: filterValueJson->getString(filterKey(#view), "")->viewFromString,
    currency: filterValueJson->getString(filterKey(#currency), ""),
    startTime: filterValueJson->getString(HSAnalyticsUtils.startTimeFilterKey, ""),
    endTime: filterValueJson->getString(HSAnalyticsUtils.endTimeFilterKey, ""),
  }
}

let hasDates = selection =>
  selection.startTime->isNonEmptyString && selection.endTime->isNonEmptyString

let needsCurrency = selection => isAmount(selection.measure)

let countGroupBy = (selection): array<dimension> => {
  let threeDsColumn = switch getMeasureFormula(selection.source, selection.measure) {
  | Rate(_, ThreeDsAttempts) => [#authentication_type]
  | _ => []
  }
  let fixed =
    [#status]
    ->Array.concat(threeDsColumn)
    ->Array.concat(needsCurrency(selection) ? [#currency] : [])
  fixed->Array.concat(selection.split->Array.filter(key => !(fixed->Array.includes(key))))
}

let countMetrics = selection => {
  let config = sourceConfig(selection.source)
  [config.countMetric]->Array.concat(isAmount(selection.measure) ? [config.amountMetric] : [])
}

let previousWindow = selection =>
  DateRangeUtils.getComparisonTimePeriod(~startDate=selection.startTime, ~endDate=selection.endTime)

let currentWindow = selection => (selection.startTime, selection.endTime)

let getCountRequestBody = (selection, ~window as (startDateTime, endDateTime), ~daily=false) =>
  [
    AnalyticsUtils.getFilterRequestBody(
      ~granularity=daily ? Some("G_ONEDAY") : None,
      ~groupByNames=Some(selection->countGroupBy->Array.map(item => (item :> string))),
      ~metrics=Some(selection->countMetrics->Array.map(item => (item :> string))),
      ~delta=false,
      ~startDateTime,
      ~endDateTime,
    )->JSON.Encode.object,
  ]->JSON.Encode.array

let requestKey = selection =>
  [
    (selection.source :> string),
    selection->countGroupBy->Array.map(key => (key :> string))->Array.joinWith(","),
    selection->countMetrics->Array.map(metric => (metric :> string))->Array.joinWith(","),
    selection.startTime,
    selection.endTime,
  ]->Array.joinWith("|")

let selectionUpdate = (updates: array<(selectionKey, string)>) =>
  updates->Array.map(((key, value)) => (filterKey(key), value))->Dict.fromArray

let splitValue = (split: array<dimension>) =>
  `[${split->Array.map(item => (item :> string))->Array.joinWith(",")}]`

let splitAt = (selection, index, key: option<dimension>) =>
  switch key {
  | Some(key) =>
    selection.split
    ->Array.slice(~start=0, ~end=index)
    ->Array.concat([key])
    ->Array.concat(
      selection.split->Array.sliceToEnd(~start=index + 1)->Array.filter(item => item != key),
    )
  | None => selection.split->Array.filterWithIndex((_, position) => position != index)
  }
