open LogicUtils
open ExplorerTypes
open ExplorerCatalog

let emptyResponses = {
  currentRows: [],
  previousRows: [],
}

let urlKey = (key: selectionKey) => `explore.${(key :> string)}`

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

let getRowKey = values => values->Array.joinWith("|")

let sourceFromString = id =>
  sources->Array.find(source => (source :> string) == id)->Option.getOr(#intent)

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
  | _ => value
  }
