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
