@scope("Number") @val
external isInteger: float => bool = "isInteger"

let isEmptyString = str => str->String.length === 0

let isNonEmptyString = str => str->String.length > 0

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

let getDictFromJsonObject = json => {
  switch json->JSON.Decode.object {
  | Some(dict) => dict
  | None => Dict.make()
  }
}

let convertMapObjectToDict = (genericTypeMapVal: JSON.t) => {
  try {
    open MapTypes
    let map = create(genericTypeMapVal)
    let mapIterator = map.entries()
    let dict = object.fromEntries(mapIterator)->getDictFromJsonObject
    dict
  } catch {
  | _ => Dict.make()
  }
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

let toKebabCase = str => {
  let strArr = str->String.replaceRegExp(%re("/[-_]+/g"), " ")->String.split(" ")
  strArr
  ->Array.map(item => {
    item->String.toLocaleLowerCase
  })
  ->Array.joinWith("-")
}

let kebabToSnakeCase = str => {
  let strArr = str->String.replaceRegExp(%re("/[-_]+/g"), " ")->String.split(" ")
  strArr
  ->Array.map(item => {
    item->String.toLocaleLowerCase
  })
  ->Array.joinWith("_")
}

let getNameFromEmail = email => {
  email
  ->String.split("@")
  ->Array.get(0)
  ->Option.getOr("")
  ->String.split(".")
  ->Array.map(name => {
    if name->isEmptyString {
      name
    } else {
      name->String.get(0)->Option.getOr("")->String.toUpperCase ++ name->String.sliceToEnd(~start=1)
    }
  })
  ->Array.joinWith(" ")
}

let getOptionString = (dict, key) => {
  dict->Dict.get(key)->Option.flatMap(obj => obj->JSON.Decode.string)
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
  dict->Dict.get(key)->Option.flatMap(obj => obj->JSON.Decode.array)
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
  dict->Dict.get(key)->Option.flatMap(val => val->getOptionStrArrayFromJson)->Option.getOr(default)
}

let getOptionStrArrayFromDict = (dict, key) => {
  dict->Dict.get(key)->Option.flatMap(val => val->getOptionStrArrayFromJson)
}

let getNonEmptyString = str => {
  if str->isEmptyString {
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
  dict->Dict.get(key)->Option.flatMap(obj => obj->JSON.Decode.bool)
}

let getBool = (dict, key, default) => {
  getOptionBool(dict, key)->Option.getOr(default)
}

let getJsonObjectFromDict = (dict, key) => {
  dict->Dict.get(key)->Option.getOr(JSON.Encode.object(Dict.make()))
}

let getvalFromDict = (dict, key) => {
  dict->Dict.get(key)
}

let getBoolFromString = (boolString, default: bool) => {
  switch boolString->String.toLowerCase {
  | "true" => true
  | "false" => false
  | _ => default
  }
}
let getStringFromDictAsBool = (dict, key, default: bool) => {
  dict
  ->getOptionString(key)
  ->Option.mapOr(default, boolString => {
    getBoolFromString(boolString, default)
  })
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

let getIntStringFromJson = json => {
  switch json->JSON.Classify.classify {
  | Number(num) => num->Float.toInt->Int.toString->JSON.Encode.string
  | String(str) => str->JSON.Encode.string
  | _ => JSON.Encode.string("")
  }
}

let isUint8Array: 'a => bool = %raw("(val) => val instanceof Uint8Array")

let getUInt8ArrayFromJson = (json, default) => {
  switch JSON.Classify.classify(json) {
  | Object(obj) => isUint8Array(obj) ? Identity.anyTypeToUint8Array(obj) : default
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
  dict->Dict.get(key)->Option.flatMap(obj => obj->JSON.Decode.object)->Option.getOr(default)
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

let setDictNull = (dict, key, optionStr) => {
  switch optionStr {
  | Some(str) => dict->Dict.set(key, str->JSON.Encode.string)
  | None => dict->Dict.set(key, JSON.Encode.null)
  }
}
let setOptionString = (dict, key, optionStr) =>
  optionStr->Option.mapOr((), str => dict->Dict.set(key, str->JSON.Encode.string))

let setOptionJson = (dict, key, optionJson) =>
  optionJson->Option.mapOr((), json => dict->Dict.set(key, json))

let setOptionBool = (dict, key, optionInt) =>
  optionInt->Option.mapOr((), bool => dict->Dict.set(key, bool->JSON.Encode.bool))

let setOptionArray = (dict, key, optionArray) =>
  optionArray->Option.mapOr((), array => dict->Dict.set(key, array->JSON.Encode.array))

let setOptionDict = (dict, key, optionDictValue) =>
  optionDictValue->Option.mapOr((), value => dict->Dict.set(key, value->JSON.Encode.object))

let setOptionInt = (dict, key, optionInt) =>
  optionInt->Option.mapOr((), int => dict->Dict.set(key, int->JSON.Encode.int))

let mapOptionOrDefault = (t, defaultVal, func) => t->Option.mapOr(defaultVal, value => value->func)

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

let userNameToTitle = str =>
  str->String.split(".")->Array.map(capitalizeString)->Array.joinWith(" ")

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

let checkEmptyJson = json => {
  json == JSON.Encode.object(Dict.make())
}

let numericArraySortComperator = (a, b) => {
  if a < b {
    -1.
  } else if a > b {
    1.
  } else {
    0.
  }
}

let removeTrailingZero = (numeric_str: string) => {
  numeric_str->Float.fromString->Option.getOr(0.)->Float.toString
}

let isEmptyDict = dict => {
  dict->Dict.keysToArray->Array.length === 0
}

let isNullJson = val => {
  val == JSON.Encode.null || checkEmptyJson(val)
}

let stringReplaceAll = (str, old, new) => {
  str->String.split(old)->Array.joinWith(new)
}

let getUniqueArray = (arr: array<'t>) => {
  arr->Array.map(item => (item, ""))->Dict.fromArray->Dict.keysToArray
}

let getFirstLetterCaps = (str, ~splitBy="-") => {
  str
  ->String.toLowerCase
  ->String.split(splitBy)
  ->Array.map(capitalizeString)
  ->Array.joinWith(" ")
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

let convertNewLineSaperatedDataToArrayOfJson = text => {
  text
  ->String.split("\n")
  ->Array.filter(item => item->isNonEmptyString)
  ->Array.map(item => {
    item->safeParse
  })
}

let formatAmount = (amount, currency) => {
  let rec addCommas = str => {
    let len = String.length(str)
    if len <= 3 {
      str
    } else {
      let prefix = String.slice(~start=0, ~end=len - 3, str)
      let suffix = String.slice(~start=len - 3, ~end=len, str)
      addCommas(prefix) ++ "," ++ suffix
    }
  }

  `${currency} ${addCommas(amount->Int.toString)}`
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
  if data->isNonEmptyString {
    JSON.stringifyWithIndent(safeParse(data), 2)
  } else {
    data
  }
}

let getJsonFromDict = (dict, key) => {
  dict->Dict.get(key)->Option.getOr(Dict.make()->JSON.Encode.object)
}

let compareLogic = (firstValue, secondValue) => {
  let temp1 = firstValue
  let temp2 = secondValue
  if temp1 == temp2 {
    0.
  } else if temp1 > temp2 {
    -1.
  } else {
    1.
  }
}

let getJsonFromArrayOfJson = arr => arr->Dict.fromArray->JSON.Encode.object

let getTitle = name => {
  name
  ->String.toLowerCase
  ->String.split("_")
  ->Array.map(capitalizeString)
  ->Array.joinWith(" ")
}

// Regex to check if a string contains a substring
let regex = (positionToCheckFrom, searchString) => {
  let searchStringNew =
    searchString
    ->String.replaceRegExp(%re("/[<>\[\]';|?*\\]/g"), "")
    ->String.replaceRegExp(%re("/\(/g"), "\\(")
    ->String.replaceRegExp(%re("/\+/g"), "\\+")
    ->String.replaceRegExp(%re("/\)/g"), "\\)")
  RegExp.fromStringWithFlags(
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

let truncateFileNameWithEllipses = (~fileName, ~maxTextLength) => {
  let lastIndex = fileName->String.lastIndexOf(".")
  let beforeDotFileName = fileName->String.substring(~start=0, ~end=lastIndex)
  let afterDotFileType = fileName->String.substringToEnd(~start=lastIndex + 1)

  if beforeDotFileName->String.length + afterDotFileType->String.length + 1 <= maxTextLength {
    fileName
  } else {
    let truncatedText =
      beforeDotFileName->String.slice(~start=0, ~end=maxTextLength)->String.concat("...")
    truncatedText ++ "." ++ afterDotFileType
  }
}

let getDaysDiffForDates = (~startDate, ~endDate) => {
  let startDate = startDate->Date.fromTime
  let endDate = endDate->Date.fromTime
  let daysDiff = Math.abs(endDate->Date.getTime -. startDate->Date.getTime)
  let noOfmiliiseconds = 1000.0 *. 60.0 *. 60.0 *. 24.0

  Math.floor(daysDiff /. noOfmiliiseconds)
}

let getOptionalFromNullable = val => {
  val->Nullable.toOption
}

let getValFromNullableValue = (val, default) => {
  val->getOptionalFromNullable->Option.getOr(default)
}

let dateFormat = (timestamp, format) => (timestamp->DayJs.getDayJsForString).format(format)

let deleteNestedKeys = (dict: Dict.t<'a>, keys: array<string>) =>
  keys->Array.forEach(key => dict->Dict.delete(key))

let removeTrailingSlash = str => {
  if str->String.endsWith("/") {
    str->String.slice(~start=0, ~end=-1)
  } else {
    str
  }
}

let getMappedValueFromArrayOfJson = (array, itemToObjMapper) =>
  array->Belt.Array.keepMap(JSON.Decode.object)->Array.map(itemToObjMapper)

let uniqueObjectFromArrayOfObjects = (arr, keyExtractor) => {
  let uniqueDict = Dict.make()
  arr->Array.forEach(item => {
    let key = keyExtractor(item)
    Dict.set(uniqueDict, key, item)
  })
  Dict.valuesToArray(uniqueDict)
}

let randomString = (~length) => {
  let ranges = [(48.0, 57.0), (65.0, 90.0), (97.0, 122.0)] // 0-9 // A-Z // a-z

  let text =
    Array.make(~length, "")
    ->Array.map(_ => {
      let (min, max) =
        ranges
        ->Array.get(Js.Math.random_int(0, 3))
        ->Option.getOr((48.0, 57.0))
      let index = Math.floor(Math.random() *. (max -. min +. 1.0) +. min)->Int.fromFloat

      String.fromCharCode(index)
    })
    ->Array.joinWith("")

  text
}

let getStringFromNestedDict = (dict, key1, targetKey, defaultString) => {
  dict
  ->getDictfromDict(key1)
  ->getString(targetKey, defaultString)
}

let getDictFromNestedDict = (dict, dict1, dict2) => {
  dict
  ->getDictfromDict(dict1)
  ->getDictfromDict(dict2)
}

let getKeyValuePairsFromDict = dict => {
  dict
  ->Dict.toArray
  ->Array.map(((key, value)) => {
    let displayKey = key->snakeToTitle
    let displayValue = switch value->JSON.Classify.classify {
    | String(str) => str
    | Number(num) => num->Float.toString
    | Bool(bool) => bool->getStringFromBool->capitalizeString
    | _ => "N/A"
    }
    (displayKey, displayValue)
  })
}
