open LogicUtils
open ExplorerTypes
open ExplorerCatalog

let emptyResponses = {
  currentRows: [],
  previousRows: [],
  rateCurrent: [],
  ratePrevious: [],
}

let urlKey = name => `explore.${name}`

let isRate = measure =>
  switch measure {
  | SuccessRate | FailureRate | ThreeDsFailureRate | NotCompletedRate => true
  | Volume | Successful | Failed | ProcessedAmount | AvgTicket => false
  }

let isAmount = measure =>
  switch measure {
  | ProcessedAmount | AvgTicket => true
  | SuccessRate
  | FailureRate
  | ThreeDsFailureRate
  | NotCompletedRate
  | Volume
  | Successful
  | Failed => false
  }

let getDimensionValue = (dict, dimension: dimension) => dict->getString((dimension :> string), "")

let getOutcomesOfStatus = (source, status) =>
  switch source {
  | Intent =>
    intentStatuses
    ->Array.find(item => (item :> string) == status)
    ->Option.mapOr([], intentStatusOutcomes)
  | Attempt =>
    attemptStatuses
    ->Array.find(item => (item :> string) == status)
    ->Option.mapOr([], attemptStatusOutcomes)
  }

let sourceToString = source =>
  switch source {
  | Intent => "intent"
  | Attempt => "attempt"
  }

let sourceFromString = id =>
  switch id {
  | "attempt" => Attempt
  | _ => Intent
  }

let measureToString = measure =>
  switch measure {
  | SuccessRate => "success_rate"
  | FailureRate => "failure_rate"
  | Volume => "volume"
  | Successful => "successful"
  | Failed => "failed"
  | ThreeDsFailureRate => "three_ds_failure_rate"
  | NotCompletedRate => "not_completed_rate"
  | ProcessedAmount => "processed_amount"
  | AvgTicket => "avg_ticket"
  }

let measureFromString = id =>
  switch id {
  | "failure_rate" => FailureRate
  | "volume" => Volume
  | "successful" => Successful
  | "failed" => Failed
  | "three_ds_failure_rate" => ThreeDsFailureRate
  | "not_completed_rate" => NotCompletedRate
  | "processed_amount" => ProcessedAmount
  | "avg_ticket" => AvgTicket
  | _ => SuccessRate
  }

let formatPercentage = value => `${value->Float.toFixedWithPrecision(~digits=1)}%`

let formatSigned = value =>
  `${value > 0.0 ? "+" : ""}${value->Float.toFixedWithPrecision(~digits=1)}`

let formatDisplay = (measure, value, ~currency="") =>
  if isRate(measure) {
    value->formatPercentage
  } else if isAmount(measure) {
    let digits = currency->CurrencyUtils.getAmountPrecisionDigits
    `${currency} ${value->formatNumberWithCommas(~digits)}`
  } else {
    value->formatNumberWithCommas
  }

let formatChange = (measure, current, previous) =>
  switch previous {
  | Some(previousValue) if previousValue == current => "no change"
  | Some(previousValue) if isRate(measure) => `${(current -. previousValue)->formatSigned} pp`
  | Some(previousValue) =>
    getPercentageChange(current, previousValue)->Option.mapOr("new", change =>
      `${change->formatSigned}%`
    )
  | None => "new"
  }

let getChangeImpact = (measure, current, previous) =>
  switch previous {
  | Some(previousValue) if current != previousValue =>
    current > previousValue != isLowerBetter(measure) ? Favorable : Unfavorable
  | _ => Neutral
  }
