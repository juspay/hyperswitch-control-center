open TransactionViewTypes

let paymentViewsArray: array<viewTypes> = [All, Succeeded, Failed, Dropoffs, Cancelled]

let refundViewsArray: array<viewTypes> = [All, Succeeded, Failed, Pending]

let disputeViewsArray: array<viewTypes> = [All, Succeeded, Failed, Pending]

let payoutViewsArray: array<viewTypes> = [All, Succeeded, Failed, Cancelled, Expired, Reversed]

let getCustomFilterKey = entity =>
  switch entity {
  | Orders => "status"
  | Refunds => "refund_status"
  | Disputes => "dispute_status"
  | Payouts => "status"
  }

let getViewsDisplayName = (view: viewTypes) => {
  switch view {
  | All => "All"
  | Succeeded => "Succeeded"
  | Failed => "Failed"
  | Dropoffs => "Dropoffs"
  | Cancelled => "Cancelled"
  | Pending => "Pending"
  | Expired => "Expired"
  | Reversed => "Reversed"
  | _ => ""
  }
}

let getViewTypeFromString = (view, entity) => {
  switch entity {
  | Orders =>
    switch view {
    | "succeeded" => Succeeded
    | "cancelled" => Cancelled
    | "failed" => Failed
    | "requires_payment_method" => Dropoffs
    | "pending" => Pending
    | _ => All
    }
  | Refunds =>
    switch view {
    | "success" => Succeeded
    | "failure" => Failed
    | "pending" => Pending
    | _ => All
    }
  | Disputes =>
    switch view {
    | "dispute_won" => Succeeded
    | "dispute_lost" => Failed
    | "dispute_opened" => Pending
    | _ => All
    }
  | Payouts =>
    switch view {
    | "success" => Succeeded
    | "failed" => Failed
    | "cancelled" => Cancelled
    | "expired" => Expired
    | "reversed" => Reversed
    | _ => All
    }
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

let getViewsString = (view, obj, entity) => {
  switch entity {
  | Orders =>
    switch view {
    | All => getAllViewsString(obj)
    | Succeeded => "succeeded"
    | Failed => "failed"
    | Dropoffs => "requires_payment_method"
    | Cancelled => "cancelled"
    | Pending => "pending"
    | _ => ""
    }
  | Refunds =>
    switch view {
    | All => getAllViewsString(obj)
    | Succeeded => "success"
    | Failed => "failure"
    | Pending => "pending"
    | _ => ""
    }
  | Disputes =>
    switch view {
    | All => getAllViewsString(obj)
    | Succeeded => "dispute_won"
    | Failed => "dispute_lost"
    | Pending => "dispute_opened"
    | _ => ""
    }
  | Payouts =>
    switch view {
    | All => getAllViewsString(obj)
    | Succeeded => "success"
    | Failed => "failed"
    | Cancelled => "cancelled"
    | Expired => "expired"
    | Reversed => "reversed"
    | _ => ""
    }
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

let getViewCount = (view, obj, entity) => {
  open LogicUtils
  switch view {
  | All => getAllViewCount(obj)
  | _ =>
    obj
    ->getDictFromJsonObject
    ->getDictfromDict("status_with_count")
    ->getInt(view->getViewsString(obj, entity), 0)
  }
}
