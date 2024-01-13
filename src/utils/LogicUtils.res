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
    Js.Json.parseExn(st)->Some
  } catch {
  | _e => None
  }
}
// parse a string into json and return json with null default
let safeParse = st => {
  safeParseOpt(st)->Belt.Option.getWithDefault(Js.Json.null)
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
  switch json->Js.Json.decodeObject {
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
  ->Belt.Array.get(0)
  ->Belt.Option.getWithDefault("")
  ->String.split(".")
  ->Array.map(name => {
    if name == "" {
      name
    } else {
      name->String.get(0)->Option.getWithDefault("")->String.toUpperCase ++
        name->String.sliceToEnd(~start=1)
    }
  })
  ->Array.joinWith(" ")
}

let getOptionString = (dict, key) => {
  dict->Dict.get(key)->Belt.Option.flatMap(Js.Json.decodeString)
}

let getString = (dict, key, default) => {
  getOptionString(dict, key)->Belt.Option.getWithDefault(default)
}

let getStringFromJson = (json: Js.Json.t, default) => {
  json->Js.Json.decodeString->Belt.Option.getWithDefault(default)
}

let getBoolFromJson = (json, defaultValue) => {
  json->Js.Json.decodeBoolean->Belt.Option.getWithDefault(defaultValue)
}

let getArrayFromJson = (json: Js.Json.t, default) => {
  json->Js.Json.decodeArray->Belt.Option.getWithDefault(default)
}

let getOptionalArrayFromDict = (dict, key) => {
  dict->Dict.get(key)->Belt.Option.flatMap(Js.Json.decodeArray)
}

let getArrayFromDict = (dict, key, default) => {
  dict->getOptionalArrayFromDict(key)->Belt.Option.getWithDefault(default)
}

let getArrayDataFromJson = (json, itemToObjMapper) => {
  open Belt.Option

  json
  ->Js.Json.decodeArray
  ->getWithDefault([])
  ->Belt.Array.keepMap(Js.Json.decodeObject)
  ->Array.map(itemToObjMapper)
}
let getStrArray = (dict, key) => {
  dict
  ->getOptionalArrayFromDict(key)
  ->Belt.Option.getWithDefault([])
  ->Belt.Array.map(json => json->Js.Json.decodeString->Belt.Option.getWithDefault(""))
}

let getStrArrayFromJsonArray = jsonArr => {
  jsonArr->Belt.Array.keepMap(Js.Json.decodeString)
}

let getStrArryFromJson = arr => {
  arr
  ->Js.Json.decodeArray
  ->Belt.Option.map(getStrArrayFromJsonArray)
  ->Belt.Option.getWithDefault([])
}

let getOptionStrArrayFromJson = json => {
  json->Js.Json.decodeArray->Belt.Option.map(getStrArrayFromJsonArray)
}

let getStrArrayFromDict = (dict, key, default) => {
  dict
  ->Dict.get(key)
  ->Belt.Option.flatMap(getOptionStrArrayFromJson)
  ->Belt.Option.getWithDefault(default)
}

let getOptionStrArrayFromDict = (dict, key) => {
  dict->Dict.get(key)->Belt.Option.flatMap(getOptionStrArrayFromJson)
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
  dict->Dict.get(key)->Belt.Option.flatMap(Js.Json.decodeBoolean)
}

let getBool = (dict, key, default) => {
  getOptionBool(dict, key)->Belt.Option.getWithDefault(default)
}

let getJsonObjectFromDict = (dict, key) => {
  dict->Dict.get(key)->Belt.Option.getWithDefault(Js.Json.object_(Dict.make()))
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
  switch str->Belt.Int.fromString {
  | Some(int) => int
  | None => default
  }
}
let getOptionIntFromString = str => {
  str->Belt.Int.fromString
}

let getOptionFloatFromString = str => {
  str->Belt.Float.fromString
}

let getFloatFromString = (str, default) => {
  switch str->Belt.Float.fromString {
  | Some(floatVal) => floatVal
  | None => default
  }
}

let getIntFromJson = (json, default) => {
  switch json->Js.Json.classify {
  | JSONString(str) => getIntFromString(str, default)
  | JSONNumber(floatValue) => floatValue->Belt.Float.toInt
  | _ => default
  }
}
let getOptionIntFromJson = json => {
  switch json->Js.Json.classify {
  | JSONString(str) => getOptionIntFromString(str)
  | JSONNumber(floatValue) => Some(floatValue->Belt.Float.toInt)
  | _ => None
  }
}
let getOptionFloatFromJson = json => {
  switch json->Js.Json.classify {
  | JSONString(str) => getOptionFloatFromString(str)
  | JSONNumber(floatValue) => Some(floatValue)
  | _ => None
  }
}

let getFloatFromJson = (json, default) => {
  switch json->Js.Json.classify {
  | JSONString(str) => getFloatFromString(str, default)
  | JSONNumber(floatValue) => floatValue
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
  dict
  ->Dict.get(key)
  ->Belt.Option.map(json => getFloatFromJson(json, default))
  ->Belt.Option.getWithDefault(default)
}

let getObj = (dict, key, default) => {
  dict
  ->Dict.get(key)
  ->Belt.Option.flatMap(Js.Json.decodeObject)
  ->Belt.Option.getWithDefault(default)
}

let getDictFromUrlSearchParams = searchParams => {
  open Belt.Array
  searchParams
  ->String.split("&")
  ->keepMap(getNonEmptyString)
  ->keepMap(keyVal => {
    let splitArray = String.split(keyVal, "=")

    switch (splitArray->get(0), splitArray->get(1)) {
    | (Some(key), Some(val)) => Some(key, val)
    | _ => None
    }
  })
  ->Dict.fromArray
}
let setOptionString = (dict, key, optionStr) =>
  optionStr->Belt.Option.mapWithDefault((), str => dict->Dict.set(key, str->Js.Json.string))

let setOptionBool = (dict, key, optionInt) =>
  optionInt->Belt.Option.mapWithDefault((), bool => dict->Dict.set(key, bool->Js.Json.boolean))

let setOptionArray = (dict, key, optionArray) =>
  optionArray->Belt.Option.mapWithDefault((), array => dict->Dict.set(key, array->Js.Json.array))

let setOptionDict = (dict, key, optionDictValue) =>
  optionDictValue->Belt.Option.mapWithDefault((), value =>
    dict->Dict.set(key, value->Js.Json.object_)
  )

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
  str->Belt.Int.fromString->Belt.Option.getWithDefault(default)
}

let removeTrailingZero = (numeric_str: string) => {
  numeric_str->Belt.Float.fromString->Belt.Option.getWithDefault(0.)->Belt.Float.toString
}

let shortNum = (
  ~labelValue: float,
  ~numberFormat: CurrencyFormatUtils.currencyFormat,
  ~presision: int=2,
  (),
) => {
  open CurrencyFormatUtils
  let value = Js.Math.abs_float(labelValue)

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
    let value = Belt.Int.fromFloat(labelValue)
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
      (labelValue < 1.0 ||
        (includeMilliseconds->Belt.Option.getWithDefault(false) && labelValue < 60.0)) &&
        labelValue > 0.0
    ) {
      `.${String.make(mod((labelValue *. 1000.0)->Belt.Int.fromFloat, 1000))}`
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
  json == Js.Json.object_(Dict.make())
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

let getValueFromArray = (arr, index, default) =>
  arr->Belt.Array.get(index)->Belt.Option.getWithDefault(default)

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
  list->Belt.List.head->Belt.Option.getWithDefault(default)
}

let dataMerge = (~dataArr: array<array<Js.Json.t>>, ~dictKey: array<string>) => {
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
        existingData->Array.concat(data)->Dict.fromArray->Js.Json.object_,
      )
    })
  })

  finalData->Dict.valuesToArray
}

let getJsonFromStr = data => {
  if data !== "" {
    Js.Json.stringifyWithSpace(safeParse(data), 2)
  } else {
    data
  }
}

//Extract Exn to Dict
external toExnJson: exn => Js.Json.t = "%identity"

let compareLogic = (firstValue, secondValue) => {
  let (temp1, _) = firstValue
  let (temp2, _) = secondValue
  if temp1 == temp2 {
    0
  } else if temp1 > temp2 {
    -1
  } else {
    1
  }
}

let getJsonFromArrayOfJson = arr => arr->Dict.fromArray->Js.Json.object_

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
  | None => Js.String2.match_(itemToCheck, regex("_", searchText))->Belt.Option.isSome
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
