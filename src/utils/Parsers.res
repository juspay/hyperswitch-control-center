external strArrToJsonArr: array<Js.String.t> => array<Js.Json.t> = "%identity"
let numericParser = (. ~value, ~name as _) => {
  value
  ->Js.Json.decodeString
  ->Belt.Option.flatMap(Belt.Float.fromString)
  ->Belt.Option.getWithDefault(0.0)
  ->Js.Json.number
}

let numericNonZeroParser = (. ~value, ~name as _) => {
  let num =
    value
    ->Js.Json.decodeString
    ->Belt.Option.flatMap(Belt.Int.fromString)
    ->Belt.Option.getWithDefault(0)

  if num === 0 {
    Js.Json.null
  } else {
    num->Belt.Float.fromInt->Js.Json.number
  }
}

let otpParser = (. ~value, ~name as _) => {
  value
  ->Js.Json.decodeString
  ->Belt.Option.getWithDefault("")
  ->Js.String2.match_(%re("/[0-9]*/"))
  ->Belt.Option.getWithDefault([])
  ->Js.Array2.joinWith("")
  ->Js.Json.string
}

let alphaNumericCapitalParser = (. ~value, ~name as _) => {
  value
  ->Js.Json.decodeString
  ->Belt.Option.getWithDefault("")
  ->Js.String2.match_(%re(`/[A-Z0-9]+/g`))
  ->Belt.Option.getWithDefault([])
  ->Js.Array2.joinWith("")
  ->Js.Json.string
}

let capitalParser = (. ~value, ~name as _) => {
  value
  ->Js.Json.decodeString
  ->Belt.Option.getWithDefault("")
  ->Js.String2.match_(%re(`/[A-Z]+/g`))
  ->Belt.Option.getWithDefault([])
  ->Js.Array2.joinWith("")
  ->Js.Json.string
}

let getLimitCheckedValue = val => {
  let newValueFloat = LogicUtils.getFloatFromJson(val, 0.0)
  if newValueFloat > 1000000000000000.00 {
    newValueFloat->Belt.Float.toString->Js.String2.slice(~from=0, ~to_=15)->Js.Json.string
  } else {
    val
  }
}

let numericStrParser = (. ~value, ~name as _) => {
  let finalVal = getLimitCheckedValue(value)
  let num =
    finalVal
    ->Js.Json.decodeString
    ->Belt.Option.flatMap(Belt.Int.fromString)
    ->Belt.Option.getWithDefault(0)

  if num === 0 {
    ""->Js.Json.string
  } else {
    num->Belt.Int.toString->Js.Json.string
  }
}

let leadingSpaceStrParser = (. ~value, ~name as _) => {
  let str = value->Js.Json.decodeString->Belt.Option.getWithDefault("")
  str->Js.String2.replaceByRe(%re("/^[\s]+/"), "")->Js.Json.string
}

let removeSpaceParser = (. ~value, ~name as _) => {
  let str = value->Js.Json.decodeString->Belt.Option.getWithDefault("")
  str->Js.String2.replaceByRe(%re("/[\s]+/"), "")->Js.Json.string
}

let floatNumericStrParser = (. ~value, ~name as _) => {
  let finalVal = getLimitCheckedValue(value)
  let val = LogicUtils.getStringFromJson(finalVal, "0.0")

  let isFloat = Js.Float.isFinite(Js.Float.fromString(val))
  let sliceFloat = val->Js.String2.slice(~from=0, ~to_=Js.String.length(val) - 1)
  let isFloat2 = Js.Float.isFinite(Js.Float.fromString(sliceFloat))
  if !isFloat {
    isFloat2
      ? val->Js.String2.slice(~from=0, ~to_=Js.String.length(val) - 1)->Js.Json.string
      : "0.0"->Js.Json.string
  } else {
    finalVal
  }
}
let toUpperCaseParser = (. ~value, ~name as _) => {
  let str = value->Js.Json.decodeString->Belt.Option.getWithDefault("")
  str->Js.String2.toUpperCase->Js.Json.string
}
let customFloatNumericStrParserWithPrecision = precisionVal => {
  let floatNumericStrParserWithPrecision = (. ~value, ~name as _) => {
    let finalVal = getLimitCheckedValue(value)
    let val = LogicUtils.getStringFromJson(finalVal, "0.0")
    let indexOfDec = val->Js.String2.indexOf(".")

    let isFloat = Js.Float.isFinite(Js.Float.fromString(val))
    let sliceFloat = val->Js.String2.slice(~from=0, ~to_=Js.String.length(val) - 1)
    let isFloat2 = Js.Float.isFinite(Js.Float.fromString(sliceFloat))
    if !isFloat {
      isFloat2
        ? val->Js.String2.slice(~from=0, ~to_=Js.String.length(val) - 1)->Js.Json.string
        : "0.0"->Js.Json.string
    } else if indexOfDec > 0 {
      finalVal
      ->Js.Json.decodeString
      ->Belt.Option.getWithDefault("")
      ->Js.String.slice(~from=0, ~to_={indexOfDec + precisionVal})
      ->Js.Json.string
    } else {
      finalVal
    }
  }
  floatNumericStrParserWithPrecision
}

let arrayParser = (. ~value, ~name as _) => {
  let val = LogicUtils.getStringFromJson(value, "")

  val->Js.String2.split(",")->Js.Array2.filter(x => x !== "")->Js.Json.stringArray
}
let arrayParser2 = (. ~value, ~name as _) => {
  let val = LogicUtils.getStringFromJson(value, "")
  val->Js.String2.split(",")->Js.Json.stringArray
}
let numericArrayParser = (. ~value, ~name as _) => {
  let valArr = switch Js.Json.classify(value) {
  | JSONString(a) => a->Js.String2.split(",")
  | JSONArray(arr) => arr->Js.Array2.reduce((acc, jsonItem) => {
      switch jsonItem->Js.Json.decodeString {
      | Some(str) => acc->Js.Array2.push(str)->ignore
      | None => ()
      }
      acc
    }, [])
  | _ => []
  }

  valArr->Js.Array2.reduce((acc, str) => {
    switch str->Belt.Float.fromString {
    | Some(a) => acc->Js.Array2.push(a->Js.Json.number)->ignore
    | None => ()
    }
    acc
  }, [])->Js.Json.array
}

let arrOfObjToArrOfObjValue = (. ~value, ~name as _) => {
  let jsonArr = switch value->Js.Json.decodeArray {
  | Some(dict_arr) => dict_arr->Js.Array2.reduce((acc, item) => {
      switch Js.Json.decodeObject(item) {
      | Some(obj) => {
          let val = Js.Dict.values(obj)
          let strval = LogicUtils.getStringFromJson(
            val[0]->Belt.Option.getWithDefault(Js.Json.null),
            "",
          )

          if strval != "" {
            acc->Js.Array2.push(val[0]->Belt.Option.getWithDefault(Js.Json.null))->ignore
          }
          acc
        }

      | None => acc
      }
    }, [])
  | None => []
  }
  jsonArr->Js.Json.array
}

let arrayStrParser = (. ~value, ~name as _) => {
  let x =
    value
    ->Js.Json.decodeArray
    ->Belt.Option.getWithDefault([])
    ->Belt.Array.keepMap(Js.Json.decodeString)

  x->Js.Array2.joinWith(", ")->Js.Json.string
}

let strFromArrayParser = (. ~value, ~name as _) => {
  value
  ->LogicUtils.getArrayFromJson([])
  ->LogicUtils.getStrArrayFromJsonArray
  ->Js.Array2.joinWith(",")
  ->Js.Json.string
}
let moneyFormat = (. ~value, ~name as _) => {
  let value = value->LogicUtils.getStringFromJson("")->Js.String2.replaceByRe(%re("/[^0-9.,]/"), "")
  let moneyArr = value->Js.String2.split(".")
  let newFormat = if moneyArr->Js.Array2.length > 0 {
    moneyArr[0]
    ->Belt.Option.getWithDefault("")
    ->LogicUtils.stringReplaceAll(",", "")
    ->Js.String2.replaceByRe(%re("/\b0+/g"), "")
    ->Js.String2.replaceByRe(%re("/(\d)(?=(?:(\d\d)+(\d)(?!\d))+(?!\d))/g"), "$1,")
  } else {
    ""
  }
  if moneyArr->Js.Array2.length > 1 {
    ({newFormat == "" ? "0" : newFormat} ++
    "." ++
    moneyArr[1]
    ->Belt.Option.getWithDefault("")
    ->LogicUtils.stringReplaceAll(",", "")
    ->Js.String.slice(~from=0, ~to_=2))->Js.Json.string
  } else {
    newFormat->Js.Json.string
  }
}
let moneyFormatForiegn = (. ~value, ~name as _) => {
  let value = value->LogicUtils.getStringFromJson("")->Js.String2.replaceByRe(%re("/[^0-9.,]/"), "")
  let moneyArr = value->Js.String2.split(".")
  let newFormat = if moneyArr->Js.Array2.length > 0 {
    moneyArr[0]
    ->Belt.Option.getWithDefault("")
    ->LogicUtils.stringReplaceAll(",", "")
    ->Js.String2.replaceByRe(%re("/\b0+/g"), "")
    ->Js.String2.replaceByRe(%re("/(\d)(?=(\d{3})+(?!\d))/g"), "$1,")
  } else {
    ""
  }
  if moneyArr->Js.Array2.length > 1 {
    ({newFormat == "" ? "0" : newFormat} ++
    "." ++
    moneyArr[1]
    ->Belt.Option.getWithDefault("")
    ->LogicUtils.stringReplaceAll(",", "")
    ->Js.String.slice(~from=0, ~to_=2))->Js.Json.string
  } else {
    newFormat->Js.Json.string
  }
}
