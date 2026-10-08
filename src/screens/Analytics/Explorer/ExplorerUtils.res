open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerDescriptions

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

let getDimensionValue = (dict, dimension: dimension) => dict->getString((dimension :> string), "")

let getOutcomesOfStatus = (source: source, status) =>
  switch source {
  | #intent =>
    intentStatuses
    ->Array.find(item => (item :> string) == status)
    ->Option.mapOr([], intentStatusOutcomes)
  | #attempt =>
    attemptStatuses
    ->Array.find(item => (item :> string) == status)
    ->Option.mapOr([], attemptStatusOutcomes)
  }

let sourceFromString = id =>
  sources->Array.find(source => (source :> string) == id)->Option.getOr(#intent)

let measureFromString = (source, id) =>
  sourceConfig(source).measures
  ->Array.find(measure => (measure :> string) == id)
  ->Option.getOr(#success_rate)

let measureOptions = source =>
  sourceConfig(source).measures->Array.map((measure): MultiSelectBindings.selectMenuItemType => {
    label: measureLabel(source, measure),
    value: (measure :> string),
    subLabel: measureDefinition(source, measure),
  })

let metricCardMeasures = question => {
  let offered = sourceConfig(question.source).measures
  let headlineMeasures: array<measure> = [#success_rate, #volume, #successful, #failed]
  [question.measure]->Array.concat(
    headlineMeasures
    ->Array.filter(measure => measure != question.measure && offered->Array.includes(measure))
    ->Array.slice(~start=0, ~end=3),
  )
}

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
