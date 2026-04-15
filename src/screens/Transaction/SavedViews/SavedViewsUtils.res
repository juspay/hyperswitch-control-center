let maxViews = 5

let entityToKey = entity =>
  switch entity {
  | "payment_views" => "PaymentViews"
  | "refund_views" => "RefundViews"
  | "dispute_views" => "DisputeViews"
  | "payout_views" => "PayoutViews"
  | _ => "PaymentViews"
  }

let truncateName = (~maxLen=20, name) =>
  name->String.length > maxLen ? name->String.slice(~start=0, ~end=maxLen) ++ "..." : name

let jsonValueToString = jsonValue => {
  switch jsonValue->JSON.Classify.classify {
  | String(s) => s
  | Number(n) => n->Float.toString
  | Bool(b) => b ? "true" : "false"
  | Array(arr) => {
      let strArr = arr->LogicUtils.getStrArrayFromJsonArray
      let sortedStrArr = strArr->Array.toSorted((a, b) => String.compare(a, b))
      "[" ++ sortedStrArr->Array.joinWith(",") ++ "]"
    }
  | Null => ""
  | _ => ""
  }
}

// Read a filter value as a string regardless of whether it is stored as
// a string, a number, or a single-element array (as react-final-form sometimes does).
let stringFromFilterValue = (dict, key) => {
  switch dict->Dict.get(key) {
  | Some(json) =>
    switch json->JSON.Classify.classify {
    | String(s) => s
    | Number(n) => n->Float.toString
    | Array(arr) =>
      switch arr->Array.get(0) {
      | Some(ele) =>
        switch ele->JSON.Classify.classify {
        | String(s) => s
        | Number(n) => n->Float.toString
        | _ => ""
        }
      | None => ""
      }
    | _ => ""
    }
  | None => ""
  }
}

// Collapses amount_option / start_amount / end_amount into a nested amount_filter
// object on `filtersDict` in place. AmountFilter stores amount_option via an
// identity cast of the variant, so the value in form state is the constructor
// name ("InBetween", "GreaterThanOrEqualTo", ...). Parse with stringRangetoTypeAmount.
let foldAmountOption = filtersDict => {
  let amountOption = filtersDict->stringFromFilterValue("amount_option")
  if amountOption->LogicUtils.isNonEmptyString {
    let startAmountStr = filtersDict->stringFromFilterValue("start_amount")
    let endAmountStr = filtersDict->stringFromFilterValue("end_amount")
    filtersDict->Dict.delete("start_amount")
    filtersDict->Dict.delete("end_amount")

    let amountFilterDict = Dict.make()
    let setIfSome = (key, str) =>
      switch Float.fromString(str) {
      | Some(num) => amountFilterDict->Dict.set(key, num->JSON.Encode.float)
      | None => ()
      }

    switch amountOption->AmountFilterUtils.stringRangetoTypeAmount {
    | GreaterThanOrEqualTo => setIfSome("start_amount", startAmountStr)
    | LessThanOrEqualTo => setIfSome("end_amount", endAmountStr)
    | EqualTo =>
      setIfSome("start_amount", startAmountStr)
      setIfSome("end_amount", startAmountStr)
    | InBetween =>
      setIfSome("start_amount", startAmountStr)
      setIfSome("end_amount", endAmountStr)
    | UnknownRange(_) =>
      // Unrecognized option — drop it rather than persist garbage.
      filtersDict->Dict.delete("amount_option")
    }

    if amountFilterDict->Dict.keysToArray->Array.length > 0 {
      filtersDict->Dict.set("amount_filter", amountFilterDict->JSON.Encode.object)
    }
  }
}

let flattenToDict = (dictToSet, key, value) => {
  let rec processValue = (k, v) => {
    switch v->JSON.Classify.classify {
    | Null => ()
    | _ if ["limit", "offset"]->Array.includes(k) => ()
    | Object(objDict) =>
      objDict
      ->Dict.toArray
      ->Array.forEach(innerItem => {
        let (innerKey, innerValue) = innerItem
        processValue(innerKey, innerValue)
      })
    | _ =>
      let strVal = jsonValueToString(v)
      if strVal->LogicUtils.isNonEmptyString {
        dictToSet->Dict.set(k, strVal)
      }
    }
  }
  processValue(key, value)
}
