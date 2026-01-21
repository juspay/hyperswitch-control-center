let parseFilterString = queryString => {
  queryString
  ->decodeURI
  ->String.split("&")
  ->Belt.Array.keepMap(str => {
    let arr = str->String.split("=")
    let key = arr->Array.get(0)->Option.getOr("-")
    let val = arr->Array.sliceToEnd(~start=1)->Array.joinWith("=")
    key->LogicUtils.isEmptyString || val->LogicUtils.isEmptyString ? None : Some((key, val))
  })
  ->Dict.fromArray
}

let parseFilterDict = dict => {
  dict
  ->Dict.toArray
  ->Array.map(item => {
    let (key, value) = item
    `${key}=${value}`
  })
  ->Array.joinWith("&")
}

let parseFilterDictV2 = dict => {
  dict
  ->Dict.toArray
  ->Array.filterMap(((key, value)) => {
    value->LogicUtils.isNonEmptyString
      ? {
          let formattedValue =
            value->String.startsWith("[") && value->String.endsWith("]")
              ? value->String.slice(~start=1, ~end=-1)
              : value
          formattedValue->LogicUtils.isNonEmptyString ? Some(`${key}=${formattedValue}`) : None
        }
      : None
  })
  ->Array.joinWith("&")
}
