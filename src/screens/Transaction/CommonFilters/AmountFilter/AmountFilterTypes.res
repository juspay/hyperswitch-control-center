type amountFilter =
  | GreaterThanOrEqualTo
  | LessThanOrEqualTo
  | EqualTo
  | InBetween
  | UnknownRange(string)

type amountFilterChild = [
  | #start_amount
  | #end_amount
  | #amount_option
  | #unknownchild
]

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
