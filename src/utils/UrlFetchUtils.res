let getFilterValue = value => {
  if Js.String2.includes(value, "[") {
    let str = Js.String2.slice(~from=1, ~to_=value->Js.String2.length - 1, value)
    let splitArray = Js.String2.split(str, ",")
    let jsonarr = splitArray->Js.Array2.map(val => Js.Json.string(val))
    Js.Json.array(jsonarr)
  } else {
    Js.Json.string(value)
  }
}
