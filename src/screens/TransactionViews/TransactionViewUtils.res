open TransactionViewTypes

let paymentViewsArray: array<viewTypes> = [All, Succeeded, Failed, Dropoffs, Cancelled]

let getViewsDisplayName = (view: viewTypes) => {
  switch view {
  | All => "All"
  | Succeeded => "Succeeded"
  | Failed => "Failed"
  | Dropoffs => "Dropoffs"
  | Cancelled => "Cancelled"
  }
}

let getViewTypeFromString = view => {
  switch view {
  | "succeeded" => Succeeded
  | "cancelled" => Cancelled
  | "failed" => Failed
  | "requires_payment_method" => Dropoffs
  | _ => All
  }
}

let getAllViewsString = obj => {
  open LogicUtils
  obj
  ->getDictFromJsonObject
  ->getDictfromDict("status_with_count")
  ->Dict.keysToArray
  ->Array.joinWith(",")
}

let getViewsString = (view, obj) => {
  switch view {
  | All => getAllViewsString(obj)
  | Succeeded => "succeeded"
  | Failed => "failed"
  | Dropoffs => "requires_payment_method"
  | Cancelled => "cancelled"
  }
}

let getAllViewCount = obj => {
  open LogicUtils
  let countArray =
    obj
    ->getDictFromJsonObject
    ->getDictfromDict("status_with_count")
    ->Dict.valuesToArray
  countArray->Array.reduce(0, (acc, curr) =>
    (acc->Int.toFloat +. curr->getFloatFromJson(0.0))->Float.toInt
  )
}

let getViewCount = (view, obj) => {
  open LogicUtils
  switch view {
  | All => getAllViewCount(obj)
  | _ =>
    obj
    ->getDictFromJsonObject
    ->getDictfromDict("status_with_count")
    ->getInt(view->getViewsString(obj), 0)
  }
}
