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
