open AmountFilterTypes
open LogicUtils
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
  let sAmntK = dict->getFloat((#start_amount: AmountFilterTypes.amountFilterChild :> string), -1.0)
  let eAmtK = dict->getFloat((#end_amount: AmountFilterTypes.amountFilterChild :> string), -1.0)
  let key = (#amount_option: AmountFilterTypes.amountFilterChild :> string)
  let amountOption = dict->getString(key, "")->AmountFilterTypes.stringRangetoTypeAmount
  let haserror = switch amountOption {
  | GreaterThanOrEqualTo
  | EqualTo =>
    sAmntK > 100000.0 || sAmntK < 0.0
  | LessThanOrEqualTo => eAmtK > 100000.0 || eAmtK < 0.0
  | InBetween => eAmtK <= sAmntK
  | _ => false
  }
  haserror
}
let createAmountQuery = (~dict) => {
  let hasAmountError = validateAmount(dict)
  if !hasAmountError {
    let encodeAmount = value => value->mapOptionOrDefault(JSON.Encode.null, encodeFloatOrDefault)
    dict->Dict.set(
      "amount_filter",
      [
        ("start_amount", dict->getvalFromDict("start_amount")->encodeAmount),
        ("end_amount", dict->getvalFromDict("end_amount")->encodeAmount),
      ]->getJsonFromArrayOfJson,
    )
  }
  dict
}
