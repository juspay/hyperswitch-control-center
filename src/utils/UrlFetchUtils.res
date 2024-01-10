let getFilterValue = value => {
  if String.includes(value, "[") {
    let str = String.slice(~start=1, ~end=value->String.length - 1, value)
    let splitArray = String.split(str, ",")
    let jsonarr = splitArray->Array.map(val => Js.Json.string(val))
    Js.Json.array(jsonarr)
  } else {
    Js.Json.string(value)
  }
}
