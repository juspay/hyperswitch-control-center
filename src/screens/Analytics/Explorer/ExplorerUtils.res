open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerDescriptions

let emptyResponses = {
  currentRows: [],
  previousRows: [],
  currentDaily: [],
  previousDaily: [],
  rateCurrent: [],
  ratePrevious: [],
  rateCurrentDaily: [],
  ratePreviousDaily: [],
  rateOverallCurrent: [],
  rateOverallPrevious: [],
}

let urlKey = name => `explore.${name}`
let filterPrefix = urlKey("f.")

let topGroupCount = 5
let maxBreakdownGroups = 12

let palette = ["#1C6DEA", "#E07A1F", "#11927E", "#8B5CF6", "#D6336C"]
let otherColor = "#99A0AE"
let previousColor = "#CACFD8"
let getGroupColor = index => palette->getValueFromArray(index, otherColor)

let successColor = "#11927E"
let failureColor = "#DD2B0E"
let waitingColor = "#E07A1F"

let getOutcomeColor = field =>
  switch field {
  | Success => successColor
  | Failed | AuthFailed => failureColor
  | Awaiting => waitingColor
  | Other | Total => otherColor
  }

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

let uniqueItems = arr =>
  arr->Array.filterWithIndex((item, index) => arr->Array.indexOf(item) == index)

let getOfferedDimensions = (source, ~backendDimensions: option<array<string>>) =>
  sourceConfig(source).dimensions->Array.filter(key =>
    backendDimensions->Option.mapOr(true, names => names->Array.includes((key :> string)))
  )

let getSplitDimensions = (measure, ~dimensions: array<dimension>) =>
  dimensions->Array.filter(key =>
    !((isRate(measure) || isAmount(measure)) && key == #status) &&
    !(isAmount(measure) && key == #currency)
  )

let findDimension = (dimensions: array<dimension>, id) =>
  dimensions->Array.find(key => (key :> string) == id)

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

let getRowDay = dict => dict->getString("time_bucket", "")->String.replace(" ", "T") ++ "Z"

let getRowKey = values => values->Array.joinWith("|")

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

let viewFromString = id => views->Array.find(view => (view :> string) == id)->Option.getOr(Trend)

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

let getChangeInWords = (measure, current, previous) => {
  let direction = current > previous ? "up" : "down"
  let size = value => Math.abs(value)->Float.toFixedWithPrecision(~digits=1)
  if isRate(measure) {
    let points = size(current -. previous)
    points == "0.0" ? "unchanged" : `${direction} ${points} percentage points`
  } else {
    switch getPercentageChange(current, previous) {
    | Some(change) => size(change) == "0.0" ? "unchanged" : `${direction} ${size(change)}%`
    | None => current == previous ? "unchanged" : `${direction} from nothing`
    }
  }
}

let getChangeImpact = (measure, current, previous) =>
  switch previous {
  | Some(previousValue) if current != previousValue =>
    current > previousValue != isLowerBetter(measure) ? Favorable : Unfavorable
  | _ => Neutral
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

let formatShortDate = iso =>
  (iso->String.slice(~start=0, ~end=10)->DayJs.getDayJsForString).format("MMM D")

let getWindowDays = (startTime, endTime) => {
  let dayMs = 86400000.0
  let startMs = startTime->Js.Date.fromString->Js.Date.getTime
  let endMs = endTime->Js.Date.fromString->Js.Date.getTime
  let first = Math.floor(startMs /. dayMs) *. dayMs
  let count = Math.Int.max(1, Math.ceil((endMs -. first) /. dayMs)->Float.toInt)
  Array.fromInitializer(~length=count, index => toIso(first +. index->Int.toFloat *. dayMs))
}

let getValuesLabel = (values, ~split: array<dimension>, ~labelFor) =>
  values
  ->Array.mapWithIndex((value, index) =>
    split->Array.get(index)->Option.mapOr(value, key => labelFor(key, value))
  )
  ->Array.joinWith(" · ")

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
    ->Option.mapOr(value, profile => profile.name)
  | (#status, _) => value->snakeToTitle
  | _ => value
  }

let measureOptions = source =>
  sourceConfig(source).measures->Array.map((measure): MultiSelectBindings.selectMenuItemType => {
    label: measureLabel(source, measure),
    value: measure->measureToString,
    subLabel: measureDefinition(source, measure),
  })

let dimensionOptions = (source, dimensions: array<dimension>) =>
  dimensions->Array.map((key): MultiSelectBindings.selectMenuItemType => {
    label: dimensionLabel(key),
    value: (key :> string),
    subLabel: dimensionDescription(source, key),
  })

let metricCardMeasures = question => {
  let offered = sourceConfig(question.source).measures
  [question.measure]->Array.concat(
    [SuccessRate, Volume, Successful, Failed]
    ->Array.filter(measure => measure != question.measure && offered->Array.includes(measure))
    ->Array.slice(~start=0, ~end=3),
  )
}
