let numericArrayStringFormat = (. ~value, ~name as _) => {
  LogicUtils.getArrayFromJson(value, [])->Js.Array2.joinWith(",")->Js.Json.string
}
let upperCaseFormat = (. ~value, ~name as _) => {
  value->LogicUtils.getStringFromJson("")->Js.String2.toUpperCase->Js.Json.string
}
let lowerCaseFormat = (. ~value, ~name as _) => {
  value->LogicUtils.getStringFromJson("")->Js.String2.toLowerCase->Js.Json.string
}
let numericArrayStrArrayFormat = (. ~value, ~name as _) => {
  let val = switch Js.Json.decodeArray(value) {
  | Some(arr) => arr->Js.Array2.reduce((acc, jsonItem) => {
      switch jsonItem->Js.Json.decodeNumber {
      | Some(num) => {
          let _ = acc->Js.Array2.push(num->Belt.Float.toString->Js.Json.string)
        }

      | None => ()
      }
      acc
    }, [])

  | _ => []
  }

  val->Js.Json.array
}

let numericStrFormat = (. ~value, ~name as _) => {
  value->Js.Json.decodeNumber->Belt.Option.getWithDefault(0.0)->Belt.Float.toString->Js.Json.string
}

let strArrayFormat = (. ~value, ~name as _) => {
  let strVal = value->Js.Json.decodeString->Belt.Option.getWithDefault("")

  let arr =
    strVal
    ->Js.String2.split(",")
    ->Js.Array2.map(Js.String2.trim)
    ->Belt.Array.keepMap(LogicUtils.getNonEmptyString)

  arr->Js.Json.stringArray
}
let trimString = (. ~value, ~name as _) => {
  value->LogicUtils.getStringFromJson("")->Js.String2.trim->Js.Json.string
}
