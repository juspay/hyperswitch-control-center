let parseFilterString = queryString => {
  queryString
  ->Js.Global.decodeURI
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
