open LogicUtils

// Escape the characters filter strings are split on, so values containing them stay intact
let encodeFilterValue = value =>
  value
  ->stringReplaceAll("%", "%25")
  ->stringReplaceAll(",", "%2C")
  ->stringReplaceAll("&", "%26")
  ->stringReplaceAll("=", "%3D")
  ->stringReplaceAll("#", "%23")

let decodeFilterValue = value =>
  value
  ->stringReplaceAll("%2C", ",")
  ->stringReplaceAll("%26", "&")
  ->stringReplaceAll("%3D", "=")
  ->stringReplaceAll("%23", "#")
  ->stringReplaceAll("%25", "%")

let getFilterArrayString = (array: array<JSON.t>) =>
  array
  ->Array.map(item =>
    item
    ->JSON.Decode.string
    ->mapOptionOrDefault([item]->Array.joinWithUnsafe(""), encodeFilterValue)
  )
  ->Array.joinWith(",")

let getFilterValue = value => {
  if String.includes(value, "[") {
    let str = String.slice(~start=1, ~end=value->String.length - 1, value)
    let splitArray = String.split(str, ",")
    let jsonarr = splitArray->Array.map(val => val->decodeFilterValue->JSON.Encode.string)
    JSON.Encode.array(jsonarr)
  } else {
    JSON.Encode.string(value)
  }
}
