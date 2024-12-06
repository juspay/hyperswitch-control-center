open AmountFilterTypes
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
let validateAmount = dict => {
  open LogicUtils
  let sAmntK = dict->getFloat((#start_amount: AmountFilterTypes.amountFilterChild :> string), -1.0)
  let eAmtK = dict->getFloat((#end_amount: AmountFilterTypes.amountFilterChild :> string), -1.0)
  let key = (#amount_option: AmountFilterTypes.amountFilterChild :> string)
  let amountOption = dict->getString(key, "")->AmountFilterTypes.stringRangetoTypeAmount
  Js.log(amountOption)
  let haserror = switch amountOption {
  | GreaterThanOrEqualTo
  | EqualTo =>
    sAmntK > 100000.0 || sAmntK < 0.0
  | LessThanOrEqualTo => eAmtK > 100000.0 || eAmtK < 0.0
  | InBetween => eAmtK <= sAmntK
  | _ => false
  }
  Js.log2("haserror", haserror)
  haserror
}
