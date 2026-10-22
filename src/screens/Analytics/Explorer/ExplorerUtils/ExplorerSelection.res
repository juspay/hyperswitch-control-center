open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils

let sourceFromFilters = filterValueJson =>
  filterValueJson->getString(filterKey(#source), "")->sourceFromString

let selectionFromFilters = (filterValueJson, ~backendDimensions) => {
  let source = filterValueJson->sourceFromFilters
  let measure = source->measureFromString(filterValueJson->getString(filterKey(#measure), ""))
  let dimensions = source->getOfferedDimensions(~backendDimensions)
  let splitOptions = getSplitDimensions(measure, ~dimensions)
  let filterOptions = getFilterDimensions(measure, ~dimensions)
  let filters =
    filterValueJson
    ->Dict.toArray
    ->Array.filterMap(((key, value)) =>
      key->String.startsWith(filterPrefix)
        ? filterOptions
          ->findDimension(key->String.sliceToEnd(~start=filterPrefix->String.length))
          ->Option.map(dimension => (dimension, value->filterValuesFromJson))
          ->Option.filter(((_, values)) => values->isNonEmptyArray)
        : None
    )
  {
    source,
    measure,
    split: filterValueJson
    ->getStrArrayFromDict(filterKey(#split), [])
    ->getUniqueArray
    ->Array.filterMap(id => splitOptions->findDimension(id))
    ->Array.slice(~start=0, ~end=2),
    splitOptions,
    filterOptions,
    filters,
    drilledFrom: dimensions->findDimension(filterValueJson->getString(filterKey(#from), "")),
    view: filterValueJson->getString(filterKey(#view), "")->viewFromString,
    currency: filterValueJson->getString(filterKey(#currency), ""),
    startTime: filterValueJson->getString(HSAnalyticsUtils.startTimeFilterKey, ""),
    endTime: filterValueJson->getString(HSAnalyticsUtils.endTimeFilterKey, ""),
  }
}

let hasDates = selection =>
  selection.startTime->isNonEmptyString && selection.endTime->isNonEmptyString

let getSelectedFilterValues = (selection, dimension) =>
  selection.filters
  ->Array.find(((key, _)) => key == dimension)
  ->mapOptionOrDefault([], ((_, values)) => values)

let needsCurrency = selection =>
  isAmount(selection.measure) && selection->getSelectedFilterValues(#currency)->Array.length != 1

let getFilterFieldName = (dimension: dimension) =>
  switch dimension {
  | #authentication_type => "auth_type"
  | _ => (dimension :> string)
  }

let getFiltersJson = selection =>
  selection.filters
  ->Array.map(((key, values)) => (key->getFilterFieldName, values->getJsonFromArrayOfString))
  ->getJsonFromArrayOfJson

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
      ~granularity=daily ? Some((#G_ONEDAY: NewAnalyticsTypes.granularity :> string)) : None,
      ~groupByNames=Some(selection->countGroupBy->Array.map(item => (item :> string))),
      ~filter=Some(selection->getFiltersJson),
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
    selection->getFiltersJson->JSON.stringify,
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

let getFilterValuesKey = (selection, ~dimension: option<dimension>) =>
  [
    (selection.source :> string),
    dimension->mapOptionOrDefault("", key => (key :> string)),
    selection.startTime,
    selection.endTime,
  ]->Array.joinWith("|")

let getFilterValuesBody = (selection, ~dimension: dimension) =>
  AnalyticsUtils.filterBody({
    startTime: selection.startTime,
    endTime: selection.endTime,
    groupByNames: [(dimension :> string)],
    source: "BATCH",
  })->JSON.Encode.object

let getFilterValueString = values =>
  values->isEmptyArray ? "" : `[${values->Array.map(encodeFilterValue)->Array.joinWith(",")}]`

let getFilterUpdate = (dimension, values) =>
  [(getFilterUrlKey(dimension), getFilterValueString(values))]->Dict.fromArray

let getClearFiltersUpdate = selection =>
  selection.filters
  ->Array.map(((key, _)) => (getFilterUrlKey(key), ""))
  ->Array.concat([(filterKey(#from), "")])
  ->Dict.fromArray

let getMeasureUpdate = (selection, id) => {
  let filterOptions = getFilterDimensions(
    selection.source->measureFromString(id),
    ~dimensions=selection.filterOptions,
  )
  [
    selection.filters
    ->Array.filter(((key, _)) => !(filterOptions->Array.includes(key)))
    ->Array.map(((key, _)) => (getFilterUrlKey(key), ""))
    ->Dict.fromArray,
    [(#measure, id)]->selectionUpdate,
  ]->DictionaryUtils.mergeDicts
}

let getFocusUpdate = (selection, group: group) =>
  group.values->Array.every(isNonEmptyString)
    ? Some(
        selection.split
        ->Array.mapWithIndex((key, index) => (
          getFilterUrlKey(key),
          getFilterValueString([group.values->getValueFromArray(index, "")]),
        ))
        ->Array.concat(
          [
            (#split, "[]"),
            (#from, selection.split->Array.get(0)->mapOptionOrDefault("", key => (key :> string))),
          ]->Array.map(((key, value)) => (filterKey(key), value)),
        )
        ->Dict.fromArray,
      )
    : None

let getSplitSuggestions = selection =>
  suggestedNext(
    selection.source,
    selection.split->Array.get(0)->Option.orElse(selection.drilledFrom),
  )->Array.filter(key =>
    selection.splitOptions->Array.includes(key) && !(selection.split->Array.includes(key))
  )

let getSuggestionUpdate = (selection, key) =>
  [
    (
      #split,
      selection->splitAt(Math.Int.min(selection.split->Array.length, 1), Some(key))->splitValue,
    ),
  ]->selectionUpdate
