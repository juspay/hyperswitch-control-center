open LogicUtils

let parseFilterString = queryString => {
  queryString
  ->decodeURI
  ->String.split("&")
  ->Belt.Array.keepMap(str => {
    let arr = str->String.split("=")
    let key = arr->Array.get(0)->Option.getOr("-")
    let val = arr->Array.sliceToEnd(~start=1)->Array.joinWith("=")
    key->isEmptyString || val->isEmptyString ? None : Some((key, val))
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
  let removeBrackets = value => {
    value->String.startsWith("[") && value->String.endsWith("]")
      ? value->String.slice(~start=1, ~end=-1)
      : value
  }

  let formatKeyValuePair = ((key, value)) => {
    value->isNonEmptyString
      ? {
          let formattedValue = removeBrackets(value)
          formattedValue->isNonEmptyString ? Some(`${key}=${formattedValue}`) : None
        }
      : None
  }

  dict
  ->Dict.toArray
  ->Array.filterMap(formatKeyValuePair)
  ->Array.joinWith("&")
}
