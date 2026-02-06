open AmountFilterTypes
open LogicUtils

let mapStringToamountFilterChild = key => {
  switch key {
  | "start_amount" => #start_amount
  | "end_amount" => #end_amount
  | "amount_option" => #amount_option
  | _ => #unknownchild
  }
}
let mapAmountFilterChildToString = key => {
  switch key {
  | #start_amount => "start_amount"
  | #end_amount => "end_amount"
  | #amount_option => "amount_option"
  | #unknownchild => "unknownchild"
  }
}
let mapStringToRange = val =>
  switch val {
  | "Greater than or Equal to" => GreaterThanOrEqualTo
  | "Less than or Equal to" => LessThanOrEqualTo
  | "Equal to" => EqualTo
  | "In Between" => InBetween
  | _ => UnknownRange(val)
  }

let mapRangeTypetoString = amountFilter => {
  switch amountFilter {
  | GreaterThanOrEqualTo => "Greater than or Equal to"
  | LessThanOrEqualTo => "Less than or Equal to"
  | EqualTo => "Equal to"
  | InBetween => "In Between"
  | UnknownRange(string) => string
  }
}

let stringRangetoTypeAmount = str =>
  switch str {
  | "GreaterThanOrEqualTo" => GreaterThanOrEqualTo
  | "LessThanOrEqualTo" => LessThanOrEqualTo
  | "EqualTo" => EqualTo
  | "InBetween" => InBetween
  | _ => UnknownRange(str)
  }

let amountFilterOptions: array<FilterSelectBox.dropdownOption> = [
  GreaterThanOrEqualTo,
  LessThanOrEqualTo,
  EqualTo,
  InBetween,
]->Array.map(option => {
  let label = option->mapRangeTypetoString
  {
    FilterSelectBox.label,
    value: label,
  }
})

let encodeFloatOrDefault = val =>
  (val->getFloatFromJson(0.0) *. 100.0)->Float.toFixed->getFloatFromString(0.0)->JSON.Encode.float

let validateAmount = dict => {
  let startAmountKey = dict->getFloat((#start_amount: amountFilterChild :> string), -1.0)
  let endAmountKey = dict->getFloat((#end_amount: amountFilterChild :> string), -1.0)
  let key = (#amount_option: amountFilterChild :> string)
  let amountOption = dict->getString(key, "")->stringRangetoTypeAmount
  switch amountOption {
  | GreaterThanOrEqualTo
  | EqualTo =>
    startAmountKey > 100000.0 || startAmountKey < 0.0
  | LessThanOrEqualTo => endAmountKey > 100000.0 || endAmountKey < 0.0
  | InBetween => endAmountKey <= startAmountKey
  | _ => false
  }
}

let createAmountQuery = (~dict) => {
  Js.log2("dict", dict)
  let hasAmountError = validateAmount(dict)
  let startAmount = dict->getvalFromDict("start_amount")
  let endAmount = dict->getvalFromDict("end_amount")
  let isAmountFilterUsed = startAmount->Option.isSome || endAmount->Option.isSome
  if !hasAmountError && isAmountFilterUsed {
    let encodeAmount = value => value->mapOptionOrDefault(JSON.Encode.null, encodeFloatOrDefault)
    dict->Dict.set(
      "amount_filter",
      [
        ("start_amount", startAmount->encodeAmount),
        ("end_amount", endAmount->encodeAmount),
      ]->getJsonFromArrayOfJson,
    )
  }
  dict
}

let startamountField = FormRenderer.makeFieldInfo(
  ~label="",
  ~name="start_amount",
  ~placeholder="0",
  ~customInput=InputFields.numericTextInput(~precision=2),
  ~type_="number",
)

let endAmountField = FormRenderer.makeFieldInfo(
  ~label="",
  ~name="end_amount",
  ~placeholder="0",
  ~customInput=InputFields.numericTextInput(~precision=2),
  ~type_="number",
)
