let methodStr = (method: Fetch.requestMethod) => {
  switch method {
  | Get => "GET"
  | Head => "HEAD"
  | Post => "POST"
  | Put => "PUT"
  | Delete => "DELETE"
  | Connect => "CONNECT"
  | Options => "OPTIONS"
  | Trace => "TRACE"
  | Patch => "PATCH"
  | _ => ""
  }
}
let useUrlPrefix = () => {
  ""
}

let stripV4 = path => {
  switch path {
  | list{"v4", ...remaining} => remaining
  | _ => path
  }
}

// parse a string into json and return optional json
let safeParseOpt = st => {
  try {
    Some(JSON.parseExn(st))
  } catch {
  | _ => None
  }
}
// parse a string into json and return json with null default
let safeParse = st => {
  safeParseOpt(st)->Option.getOr(JSON.Encode.null)
}

type numericComparisionType =
  | LessThan(int, bool)
  | GreaterThan(int, bool)
  | EqualTo(array<int>)

type numericConditionCheck = {key: string, validRules: array<numericComparisionType>}
type conditionCheck = {key: string, vals: array<string>, not: bool}

type condition =
  | NoCondition
  | NumericCondition(numericConditionCheck)
  | ComparisionCheck(conditionCheck)

type rec logics = Return(array<(int, array<string>)>) | IfElse(array<logic>)
and logic = {
  condition: condition,
  logics: logics,
}

let getDictFromJsonObject = json => {
  switch json->JSON.Decode.object {
  | Some(dict) => dict
  | None => Dict.make()
  }
}

let convertMapObjectToDict = genericTypeMapVal => {
  open MapTypes
  let map = create(genericTypeMapVal)
  let mapIterator = map.entries(.)
  let dict = object.fromEntries(. mapIterator)->getDictFromJsonObject
  dict
}

let removeDuplicate = (arr: array<string>) => {
  arr->Array.filterWithIndex((item, i) => {
    arr->Array.indexOf(item) === i
  })
}

let sortBasedOnPriority = (sortArr: array<string>, priorityArr: array<string>) => {
  let finalPriorityArr = priorityArr->Array.filter(val => sortArr->Array.includes(val))
  let filteredArr = sortArr->Array.filter(item => !(finalPriorityArr->Array.includes(item)))
  finalPriorityArr->Array.concat(filteredArr)
}
let toCamelCase = str => {
  let strArr = str->String.replaceRegExp(%re("/[-_]+/g"), " ")->String.split(" ")
  strArr
  ->Array.mapWithIndex((item, i) => {
    let matchFn = (match, _, _, _, _, _) => {
      if i == 0 {
        match->String.toLocaleLowerCase
      } else {
        match->String.toLocaleUpperCase
      }
    }
    item->Js.String2.unsafeReplaceBy3(%re("/(?:^\w|[A-Z]|\b\w)/g"), matchFn)
  })
  ->Array.joinWith("")
}
let getNameFromEmail = email => {
  email
  ->String.split("@")
  ->Array.get(0)
  ->Option.getOr("")
  ->String.split(".")
  ->Array.map(name => {
    if name == "" {
      name
    } else {
      name->String.get(0)->Option.getOr("")->String.toUpperCase ++ name->String.sliceToEnd(~start=1)
    }
  })
  ->Array.joinWith(" ")
}

let getOptionString = (dict, key) => {
  dict->Dict.get(key)->Option.flatMap(JSON.Decode.string)
}

let getString = (dict, key, default) => {
  getOptionString(dict, key)->Option.getOr(default)
}

let getStringFromJson = (json: JSON.t, default) => {
  json->JSON.Decode.string->Option.getOr(default)
}

let getBoolFromJson = (json, defaultValue) => {
  json->JSON.Decode.bool->Option.getOr(defaultValue)
}

let getArrayFromJson = (json: JSON.t, default) => {
  json->JSON.Decode.array->Option.getOr(default)
}

let getOptionalArrayFromDict = (dict, key) => {
  dict->Dict.get(key)->Option.flatMap(JSON.Decode.array)
}

let getArrayFromDict = (dict, key, default) => {
  dict->getOptionalArrayFromDict(key)->Option.getOr(default)
}

let getArrayDataFromJson = (json, itemToObjMapper) => {
  json
  ->JSON.Decode.array
  ->Option.getOr([])
  ->Belt.Array.keepMap(JSON.Decode.object)
  ->Array.map(itemToObjMapper)
}
let getStrArray = (dict, key) => {
  dict
  ->getOptionalArrayFromDict(key)
  ->Option.getOr([])
  ->Array.map(json => json->JSON.Decode.string->Option.getOr(""))
}

let getStrArrayFromJsonArray = jsonArr => {
  jsonArr->Belt.Array.keepMap(JSON.Decode.string)
}

let getStrArryFromJson = arr => {
  arr->JSON.Decode.array->Option.map(getStrArrayFromJsonArray)->Option.getOr([])
}

let getOptionStrArrayFromJson = json => {
  json->JSON.Decode.array->Option.map(getStrArrayFromJsonArray)
}

let getStrArrayFromDict = (dict, key, default) => {
  dict->Dict.get(key)->Option.flatMap(getOptionStrArrayFromJson)->Option.getOr(default)
}

let getOptionStrArrayFromDict = (dict, key) => {
  dict->Dict.get(key)->Option.flatMap(getOptionStrArrayFromJson)
}

let getNonEmptyString = str => {
  if str === "" {
    None
  } else {
    Some(str)
  }
}

let getNonEmptyArray = arr => {
  if arr->Array.length === 0 {
    None
  } else {
    Some(arr)
  }
}

let getOptionBool = (dict, key) => {
  dict->Dict.get(key)->Option.flatMap(JSON.Decode.bool)
}

let getBool = (dict, key, default) => {
  getOptionBool(dict, key)->Option.getOr(default)
}

let getJsonObjectFromDict = (dict, key) => {
  dict->Dict.get(key)->Option.getOr(JSON.Encode.object(Dict.make()))
}

let getBoolFromString = (boolString, default: bool) => {
  switch boolString->String.toLowerCase {
  | "true" => true
  | "false" => false
  | _ => default
  }
}
let getStringFromBool = boolValue => {
  switch boolValue {
  | true => "true"
  | false => "false"
  }
}
let getIntFromString = (str, default) => {
  switch str->Int.fromString {
  | Some(int) => int
  | None => default
  }
}
let getOptionIntFromString = str => {
  str->Int.fromString
}

let getOptionFloatFromString = str => {
  str->Float.fromString
}

let getFloatFromString = (str, default) => {
  switch str->Float.fromString {
  | Some(floatVal) => floatVal
  | None => default
  }
}

let getIntFromJson = (json, default) => {
  switch json->JSON.Classify.classify {
  | String(str) => getIntFromString(str, default)
  | Number(floatValue) => floatValue->Float.toInt
  | _ => default
  }
}
let getOptionIntFromJson = json => {
  switch json->JSON.Classify.classify {
  | String(str) => getOptionIntFromString(str)
  | Number(floatValue) => Some(floatValue->Float.toInt)
  | _ => None
  }
}
let getOptionFloatFromJson = json => {
  switch json->JSON.Classify.classify {
  | String(str) => getOptionFloatFromString(str)
  | Number(floatValue) => Some(floatValue)
  | _ => None
  }
}

let getFloatFromJson = (json, default) => {
  switch json->JSON.Classify.classify {
  | String(str) => getFloatFromString(str, default)
  | Number(floatValue) => floatValue
  | _ => default
  }
}

let getInt = (dict, key, default) => {
  switch Dict.get(dict, key) {
  | Some(value) => getIntFromJson(value, default)
  | None => default
  }
}
let getOptionInt = (dict, key) => {
  switch Dict.get(dict, key) {
  | Some(value) => getOptionIntFromJson(value)
  | None => None
  }
}

let getOptionFloat = (dict, key) => {
  switch Dict.get(dict, key) {
  | Some(value) => getOptionFloatFromJson(value)
  | None => None
  }
}

let getFloat = (dict, key, default) => {
  dict->Dict.get(key)->Option.map(json => getFloatFromJson(json, default))->Option.getOr(default)
}

let getObj = (dict, key, default) => {
  dict->Dict.get(key)->Option.flatMap(JSON.Decode.object)->Option.getOr(default)
}

let getDictFromUrlSearchParams = searchParams => {
  searchParams
  ->String.split("&")
  ->Belt.Array.keepMap(getNonEmptyString)
  ->Belt.Array.keepMap(keyVal => {
    let splitArray = String.split(keyVal, "=")

    switch (splitArray->Array.get(0), splitArray->Array.get(1)) {
    | (Some(key), Some(val)) => Some(key, val)
    | _ => None
    }
  })
  ->Dict.fromArray
}
let setOptionString = (dict, key, optionStr) =>
  optionStr->Option.mapOr((), str => dict->Dict.set(key, str->JSON.Encode.string))

let setOptionBool = (dict, key, optionInt) =>
  optionInt->Option.mapOr((), bool => dict->Dict.set(key, bool->JSON.Encode.bool))

let setOptionArray = (dict, key, optionArray) =>
  optionArray->Option.mapOr((), array => dict->Dict.set(key, array->JSON.Encode.array))

let setOptionDict = (dict, key, optionDictValue) =>
  optionDictValue->Option.mapOr((), value => dict->Dict.set(key, value->JSON.Encode.object))

let capitalizeString = str => {
  String.toUpperCase(String.charAt(str, 0)) ++ Js.String2.substringToEnd(str, ~from=1)
}

let snakeToCamel = str => {
  str
  ->String.split("_")
  ->Array.mapWithIndex((x, i) => i == 0 ? x : capitalizeString(x))
  ->Array.joinWith("")
}

let camelToSnake = str => {
  str
  ->capitalizeString
  ->String.replaceRegExp(%re("/([a-z0-9A-Z])([A-Z])/g"), "$1_$2")
  ->String.toLowerCase
}

let camelCaseToTitle = str => {
  str->capitalizeString->String.replaceRegExp(%re("/([a-z0-9A-Z])([A-Z])/g"), "$1 $2")
}

let isContainingStringLowercase = (text, searchStr) => {
  text->String.toLowerCase->String.includes(searchStr->String.toLowerCase)
}

let snakeToTitle = str => {
  str
  ->String.split("_")
  ->Array.map(x => {
    let first = x->String.charAt(0)->String.toUpperCase
    let second = x->Js.String2.substringToEnd(~from=1)
    first ++ second
  })
  ->Array.joinWith(" ")
}

let titleToSnake = str => {
  str->String.split(" ")->Array.map(String.toLowerCase)->Array.joinWith("_")
}

let getIntFromString = (str, default) => {
  str->Int.fromString->Option.getOr(default)
}

let removeTrailingZero = (numeric_str: string) => {
  numeric_str->Float.fromString->Option.getOr(0.)->Float.toString
}

let shortNum = (
  ~labelValue: float,
  ~numberFormat: CurrencyFormatUtils.currencyFormat,
  ~presision: int=2,
  (),
) => {
  open CurrencyFormatUtils
  let value = Math.abs(labelValue)

  switch numberFormat {
  | IND =>
    switch value {
    | v if v >= 1.0e+7 =>
      `${Js.Float.toFixedWithPrecision(v /. 1.0e+7, ~digits=presision)->removeTrailingZero}Cr`
    | v if v >= 1.0e+5 =>
      `${Js.Float.toFixedWithPrecision(v /. 1.0e+5, ~digits=presision)->removeTrailingZero}L`
    | v if v >= 1.0e+3 =>
      `${Js.Float.toFixedWithPrecision(v /. 1.0e+3, ~digits=presision)->removeTrailingZero}K`
    | _ => Js.Float.toFixedWithPrecision(labelValue, ~digits=presision)->removeTrailingZero
    }
  | USD | DefaultConvert =>
    switch value {
    | v if v >= 1.0e+9 =>
      `${Js.Float.toFixedWithPrecision(v /. 1.0e+9, ~digits=presision)->removeTrailingZero}B`
    | v if v >= 1.0e+6 =>
      `${Js.Float.toFixedWithPrecision(v /. 1.0e+6, ~digits=presision)->removeTrailingZero}M`
    | v if v >= 1.0e+3 =>
      `${Js.Float.toFixedWithPrecision(v /. 1.0e+3, ~digits=presision)->removeTrailingZero}K`
    | _ => Js.Float.toFixedWithPrecision(labelValue, ~digits=presision)->removeTrailingZero
    }
  }
}

let latencyShortNum = (~labelValue: float, ~includeMilliseconds=?, ()) => {
  if labelValue !== 0.0 {
    let value = Int.fromFloat(labelValue)
    let value_days = value / 86400
    let years = value_days / 365
    let months = mod(value_days, 365) / 30
    let days = mod(mod(value_days, 365), 30)
    let hours = value / 3600
    let minutes = mod(value, 3600) / 60
    let seconds = mod(mod(value, 3600), 60)

    let year_disp = if years >= 1 {
      `${String.make(years)}Y `
    } else {
      ""
    }
    let month_disp = if months > 0 {
      `${String.make(months)}M `
    } else {
      ""
    }
    let day_disp = if days > 0 {
      `${String.make(days)}D `
    } else {
      ""
    }
    let hr_disp = if hours > 0 {
      `${String.make(hours)}H `
    } else {
      ""
    }
    let min_disp = if minutes > 0 {
      `${String.make(minutes)}M `
    } else {
      ""
    }
    let millisec_disp = if (
      (labelValue < 1.0 || (includeMilliseconds->Option.getOr(false) && labelValue < 60.0)) &&
        labelValue > 0.0
    ) {
      `.${String.make(mod((labelValue *. 1000.0)->Int.fromFloat, 1000))}`
    } else {
      ""
    }
    let sec_disp = if seconds > 0 {
      `${String.make(seconds)}${millisec_disp}S `
    } else {
      ""
    }

    if days > 0 {
      year_disp ++ month_disp ++ day_disp
    } else {
      year_disp ++ month_disp ++ day_disp ++ hr_disp ++ min_disp ++ sec_disp
    }
  } else {
    "0"
  }
}

let checkEmptyJson = json => {
  json == JSON.Encode.object(Dict.make())
}

let numericArraySortComperator = (a, b) => {
  if a < b {
    -1
  } else if a > b {
    1
  } else {
    0
  }
}

let isEmptyDict = dict => {
  dict->Dict.keysToArray->Array.length === 0
}

let isEmptyString = str => str->String.length === 0

let isNonEmptyString = str => str->String.length > 0

let stringReplaceAll = (str, old, new) => {
  str->String.split(old)->Array.joinWith(new)
}

let getUniqueArray = (arr: array<'t>) => {
  arr->Array.map(item => (item, ""))->Dict.fromArray->Dict.keysToArray
}

let getFirstLetterCaps = (str, ~splitBy="-", ()) => {
  str->String.toLowerCase->String.split(splitBy)->Array.map(capitalizeString)->Array.joinWith(" ")
}

let getDictfromDict = (dict, key) => {
  dict->getJsonObjectFromDict(key)->getDictFromJsonObject
}

let checkLeapYear = year => (mod(year, 4) === 0 && mod(year, 100) !== 0) || mod(year, 400) === 0

let getValueFromArray = (arr, index, default) => arr->Array.get(index)->Option.getOr(default)

let isEqualStringArr = (arr1, arr2) => {
  let arr1 = arr1->getUniqueArray
  let arr2 = arr2->getUniqueArray
  let lengthEqual = arr1->Array.length === arr2->Array.length
  let isContainsAll = arr1->Array.reduce(true, (acc, str) => {
    arr2->Array.includes(str) && acc
  })
  lengthEqual && isContainsAll
}

let getDefaultNumberFormat = () => {
  open CurrencyFormatUtils
  USD
}

let indianShortNum = labelValue => {
  shortNum(~labelValue, ~numberFormat=getDefaultNumberFormat(), ())
}

let convertNewLineSaperatedDataToArrayOfJson = text => {
  text
  ->String.split("\n")
  ->Array.filter(item => item !== "")
  ->Array.map(item => {
    item->safeParse
  })
}

let getObjectArrayFromJson = json => {
  json->getArrayFromJson([])->Array.map(getDictFromJsonObject)
}

let getListHead = (~default="", list) => {
  list->List.head->Option.getOr(default)
}

let dataMerge = (~dataArr: array<array<JSON.t>>, ~dictKey: array<string>) => {
  let finalData = Dict.make()
  dataArr->Array.forEach(jsonArr => {
    jsonArr->Array.forEach(jsonObj => {
      let dict = jsonObj->getDictFromJsonObject
      let dictKey =
        dictKey
        ->Array.map(
          ele => {
            dict->getString(ele, "")
          },
        )
        ->Array.joinWith("-")
      let existingData = finalData->getObj(dictKey, Dict.make())->Dict.toArray
      let data = dict->Dict.toArray

      finalData->Dict.set(
        dictKey,
        existingData->Array.concat(data)->Dict.fromArray->JSON.Encode.object,
      )
    })
  })

  finalData->Dict.valuesToArray
}

let getJsonFromStr = data => {
  if data !== "" {
    JSON.stringifyWithIndent(safeParse(data), 2)
  } else {
    data
  }
}

let compareLogic = (firstValue, secondValue) => {
  let temp1 = firstValue
  let temp2 = secondValue
  if temp1 == temp2 {
    0
  } else if temp1 > temp2 {
    -1
  } else {
    1
  }
}

let getJsonFromArrayOfJson = arr => arr->Dict.fromArray->JSON.Encode.object

let getTitle = name => {
  name->String.toLowerCase->String.split("_")->Array.map(capitalizeString)->Array.joinWith(" ")
}

// Regex to check if a string contains a substring
let regex = (positionToCheckFrom, searchString) => {
  let searchStringNew =
    searchString
    ->String.replaceRegExp(%re("/[<>\[\]';|?*\\]/g"), "")
    ->String.replaceRegExp(%re("/\(/g"), "\\(")
    ->String.replaceRegExp(%re("/\+/g"), "\\+")
    ->String.replaceRegExp(%re("/\)/g"), "\\)")
  Js.Re.fromStringWithFlags(
    "(.*)(" ++ positionToCheckFrom ++ "" ++ searchStringNew ++ ")(.*)",
    ~flags="i",
  )
}

let checkStringStartsWithSubstring = (~itemToCheck, ~searchText) => {
  let isMatch = switch Js.String2.match_(itemToCheck, regex("\\b", searchText)) {
  | Some(_) => true
  | None => Js.String2.match_(itemToCheck, regex("_", searchText))->Option.isSome
  }
  isMatch && searchText->String.length > 0
}

let listOfMatchedText = (text, searchText) => {
  switch Js.String2.match_(text, regex("\\b", searchText)) {
  | Some(r) => r->Array.sliceToEnd(~start=1)->Belt.Array.keepMap(x => x)
  | None =>
    switch Js.String2.match_(text, regex("_", searchText)) {
    | Some(a) => a->Array.sliceToEnd(~start=1)->Belt.Array.keepMap(x => x)
    | None => [text]
    }
  }
}

let getJsonFromArrayOfString = arr => {
  arr->Array.map(ele => ele->JSON.Encode.string)->JSON.Encode.array
}
