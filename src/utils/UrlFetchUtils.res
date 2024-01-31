let getFilterValue = value => {
  if String.includes(value, "[") {
    let str = String.slice(~start=1, ~end=value->String.length - 1, value)
    let splitArray = String.split(str, ",")
    let jsonarr = splitArray->Array.map(val => JSON.Encode.string(val))
    JSON.Encode.array(jsonarr)
  } else {
    JSON.Encode.string(value)
  }
}
