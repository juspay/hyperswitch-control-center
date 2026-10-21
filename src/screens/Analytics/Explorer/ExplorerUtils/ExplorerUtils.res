open LogicUtils
open ExplorerTypes
open ExplorerCatalog

let emptyResponses = {
  currentRows: [],
  previousRows: [],
  currentDaily: [],
  previousDaily: [],
}

let filterKey = (key: selectionKey) => `explore.${(key :> string)}`

let filterPrefix = "explore.f."

let getFilterUrlKey = (dimension: dimension) => `${filterPrefix}${(dimension :> string)}`

let topGroupCount = 5

let maxBreakdownGroups = 12

let isRate = (measure: measure) =>
  switch measure {
  | #success_rate | #failure_rate | #three_ds_failure_rate | #not_completed_rate => true
  | #volume | #successful | #failed | #processed_amount | #avg_ticket => false
  }

let isAmount = (measure: measure) =>
  switch measure {
  | #processed_amount | #avg_ticket => true
  | #success_rate
  | #failure_rate
  | #three_ds_failure_rate
  | #not_completed_rate
  | #volume
  | #successful
  | #failed => false
  }

let getOfferedDimensions = (source, ~backendDimensions: option<array<string>>) =>
  sourceConfig(source).dimensions->Array.filter(key =>
    backendDimensions->mapOptionOrDefault(true, names => names->Array.includes((key :> string)))
  )

let getSplitDimensions = (measure, ~dimensions: array<dimension>) =>
  dimensions->Array.filter(key =>
    !((isRate(measure) || isAmount(measure)) && key == #status) &&
    !(isAmount(measure) && key == #currency)
  )

let findDimension = (dimensions: array<dimension>, id) =>
  dimensions->Array.find(key => (key :> string) == id)

let getDimensionValue = (dict, dimension: dimension) => dict->getString((dimension :> string), "")

let getOutcomesOfStatus = (source: source, status) =>
  switch source {
  | #intent =>
    intentStatuses
    ->Array.find(item => (item :> string) == status)
    ->mapOptionOrDefault([], intentStatusOutcomes)
  | #attempt =>
    attemptStatuses
    ->Array.find(item => (item :> string) == status)
    ->mapOptionOrDefault([], attemptStatusOutcomes)
  }

let encodeFilterValue = value =>
  value
  ->stringReplaceAll("%", "%25")
  ->stringReplaceAll(",", "%2C")
  ->stringReplaceAll("&", "%26")
  ->stringReplaceAll("=", "%3D")
  ->stringReplaceAll("#", "%23")

let decodeFilterValue = value =>
  value
  ->stringReplaceAll("%2C", ",")
  ->stringReplaceAll("%26", "&")
  ->stringReplaceAll("%3D", "=")
  ->stringReplaceAll("%23", "#")
  ->stringReplaceAll("%25", "%")

let filterValuesFromJson = json =>
  json
  ->getOptionStrArrayFromJson
  ->Option.getOr([json->getStringFromJson("")])
  ->Array.filter(isNonEmptyString)
  ->Array.map(decodeFilterValue)

let getRowKey = values => values->getJsonFromArrayOfString->JSON.stringify

let getDailyKey = (~groupKey, ~day) => [groupKey, day]->getRowKey

let getRowDay = dict => dict->getString("time_bucket", "")->String.replace(" ", "T") ++ "Z"

let getValuesLabel = (values, ~split: array<dimension>, ~labelFor) =>
  split
  ->Array.mapWithIndex((key, index) => labelFor(key, values->getValueFromArray(index, "")))
  ->Array.joinWith(" · ")

let sourceFromString = id =>
  sources->Array.find(source => (source :> string) == id)->Option.getOr(#intent)

let viewFromString = id => views->Array.find(view => (view :> string) == id)->Option.getOr(#trend)

let measureFromString = (source, id) =>
  sourceConfig(source).measures
  ->Array.find(measure => (measure :> string) == id)
  ->Option.getOr(#success_rate)

let formatPercentage = value => `${value->Float.toFixedWithPrecision(~digits=1)}%`

let formatSigned = value =>
  `${value > 0.0 ? "+" : ""}${value->Float.toFixedWithPrecision(~digits=1)}`

let formatDisplay = (measure, value, ~currency) =>
  if isRate(measure) {
    value->formatPercentage
  } else if isAmount(measure) {
    let digits = currency->CurrencyUtils.getAmountPrecisionDigits
    `${currency} ${value->formatNumberWithCommas(~digits)}`
  } else {
    value->formatNumberWithCommas
  }

let getDisplayedChange = (measure, current, previous) =>
  previous
  ->Option.flatMap(previousValue =>
    isRate(measure) || current == previousValue
      ? Some(current -. previousValue)
      : getPercentageChange(current, previousValue)
  )
  ->Option.map(change => Math.round(change *. 10.0) /. 10.0)

let formatChange = (measure, current, previous) =>
  switch getDisplayedChange(measure, current, previous) {
  | Some(0.0) => "no change"
  | Some(change) => `${change->formatSigned}${isRate(measure) ? " pp" : "%"}`
  | None => "new"
  }

let getChangeImpact = (measure, current, previous) =>
  switch getDisplayedChange(measure, current, previous) {
  | Some(0.0) | None => Neutral
  | Some(change) => change > 0.0 != isLowerBetter(measure) ? Favorable : Unfavorable
  }

let getImpactClasses = (impact: changeImpact) =>
  switch impact {
  | Favorable => ("text-nd_green-600", "bg-nd_green-50")
  | Unfavorable => ("text-nd_red-600", "bg-nd_red-50")
  | Neutral => ("text-nd_gray-500", "bg-nd_gray-50")
  }

let periodLabel = (startTime, endTime) => {
  let first = startTime->DayJs.getDayJsForString
  let last = (endTime->DayJs.getDayJsForString).subtract(1, "millisecond")
  if first.format("YYYY-MM-DD") == last.format("YYYY-MM-DD") {
    first.format("MMM D")
  } else if first.format("YYYY-MM") == last.format("YYYY-MM") {
    `${first.format("MMM D")}–${last.format("D")}`
  } else {
    `${first.format("MMM D")} – ${last.format("MMM D")}`
  }
}

let toIso = ms =>
  ms->Js.Date.fromFloat->Js.Date.toISOString->String.replaceRegExp(%re("/\.\d{3}Z$/"), "Z")

let getWindowDays = (startTime, endTime) => {
  let dayMs = 86400000.0
  let startMs = startTime->Js.Date.fromString->Js.Date.getTime
  let endMs = endTime->Js.Date.fromString->Js.Date.getTime
  let first = Math.floor(startMs /. dayMs) *. dayMs
  let count = Math.Int.max(1, Math.ceil((endMs -. first) /. dayMs)->Float.toInt)
  Array.fromInitializer(~length=count, index => toIso(first +. index->Int.toFloat *. dayMs))
}

let getDimensionValueLabel = (
  key: dimension,
  value,
  ~profileList: array<OMPSwitchTypes.ompListTypes>,
) =>
  switch (key, value) {
  | (_, "") => "Not recorded"
  | (#profile_id, _) =>
    profileList
    ->Array.find(profile => profile.id == value)
    ->mapOptionOrDefault(value, profile => profile.name)
  | (#status, _) => value->snakeToTitle
  | (#connector, _) => value->ConnectorUtils.getDisplayNameForConnector
  | _ => value
  }
