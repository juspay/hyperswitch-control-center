let parseFilterString = queryString => {
  queryString
  ->Js.Global.decodeURI
  ->Js.String2.split("&")
  ->Belt.Array.keepMap(str => {
    let arr = str->Js.String2.split("=")
    let key = arr->Belt.Array.get(0)->Belt.Option.getWithDefault("-")
    let val = arr->Belt.Array.sliceToEnd(1)->Js.Array2.joinWith("=")
    key === "" || val === "" ? None : Some((key, val))
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
