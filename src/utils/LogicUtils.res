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
let useDefaultArr = json => {
  React.useMemo1(() => {
    json
    ->Js.Json.decodeObject
    ->Belt.Option.flatMap(dict => dict->Js.Dict.get("default"))
    ->Belt.Option.flatMap(Js.Json.decodeArray)
    ->Belt.Option.getWithDefault([])
    ->Belt.Array.keepMap(Js.Json.decodeString)
  }, [json])
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

type time = {day: string, start: string, end: string}

let getDictFromJsonObject = json => {
  switch json->Js.Json.decodeObject {
  | Some(dict) => dict
  | None => Js.Dict.empty()
  }
}

let removeDuplicate = (arr: array<string>) => {
  arr->Js.Array2.filteri((item, i) => {
    arr->Js.Array2.indexOf(item) === i
  })
}

let sortBasedOnPriority = (sortArr: array<string>, priorityArr: array<string>) => {
  let finalPriorityArr = priorityArr->Js.Array2.filter(val => sortArr->Js.Array2.includes(val))
  let filteredArr = sortArr->Js.Array2.filter(item => !(finalPriorityArr->Js.Array2.includes(item)))
  finalPriorityArr->Js.Array2.concat(filteredArr)
}
let toCamelCase = str => {
  let strArr = str->Js.String2.replaceByRe(%re("/[-_]+/g"), " ")->Js.String2.split(" ")
  strArr
  ->Js.Array2.mapi((item, i) => {
    let matchFn = (match, _, _, _, _, _) => {
      if i == 0 {
        match->Js.String2.toLocaleLowerCase
      } else {
        match->Js.String2.toLocaleUpperCase
      }
    }
    item->Js.String2.unsafeReplaceBy3(%re("/(?:^\w|[A-Z]|\b\w)/g"), matchFn)
  })
  ->Js.Array2.joinWith("")
}
let getNameFromEmail = email => {
  email
  ->Js.String2.split("@")
  ->Js.Array2.unsafe_get(0)
  ->Js.String2.split(".")
  ->Js.Array2.map(name => {
    if name == "" {
      name
    } else {
      name->Js.String2.get(0)->Js.String2.toUpperCase ++ name->Js.String2.sliceToEnd(~from=1)
    }
  })
  ->Js.Array2.joinWith(" ")
}

let useValidateEmail = str => {
  !Js.Re.test_(
    %re(`/^(([^<>()[\]\.,;:\s@"]+(\.[^<>()[\]\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/`),
    str->Js.String.trim,
  )
}

let doSetState = (value, setter) => {
  setter(_ => value)
}

let getOptionString = (dict, key) => {
  dict->Js.Dict.get(key)->Belt.Option.flatMap(Js.Json.decodeString)
}

let getString = (dict, key, default) => {
  getOptionString(dict, key)->Belt.Option.getWithDefault(default)
}

let getStrVal = (~default="", dict, key) => {
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
  dict->Js.Dict.get(key)->Belt.Option.flatMap(Js.Json.decodeArray)
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
  ->Js.Array2.map(itemToObjMapper)
}
let getStrArray = (dict, key) => {
  dict
  ->getOptionalArrayFromDict(key)
  ->Belt.Option.getWithDefault([])
  ->Belt.Array.map(json => json->Js.Json.decodeString->Belt.Option.getWithDefault(""))
}
let getBoolArray = (dict, key, default) => {
  dict
  ->getOptionalArrayFromDict(key)
  ->Belt.Option.getWithDefault([])
  ->Belt.Array.map(json => json->Js.Json.decodeBoolean->Belt.Option.getWithDefault(default))
}

let getStrArrayFromJsonArray = jsonArr => {
  jsonArr->Belt.Array.keepMap(Js.Json.decodeString)
}
let getIntArrayFromJsonArray = jsonArr => {
  jsonArr->Belt.Array.keepMap(Js.Json.decodeNumber)->Js.Array2.map(Belt.Float.toInt)
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

let getOptionIntArrayFromJson = json => {
  json->Js.Json.decodeArray->Belt.Option.map(getIntArrayFromJsonArray)
}
let getStrArrayFromDict = (dict, key, default) => {
  dict
  ->Js.Dict.get(key)
  ->Belt.Option.flatMap(getOptionStrArrayFromJson)
  ->Belt.Option.getWithDefault(default)
}

let getOptionStrArrayFromDict = (dict, key) => {
  dict->Js.Dict.get(key)->Belt.Option.flatMap(getOptionStrArrayFromJson)
}

let getOptionIntArrayFromDict = (dict, key) => {
  dict->Js.Dict.get(key)->Belt.Option.flatMap(getOptionIntArrayFromJson)
}

let getNonEmptyString = str => {
  if str === "" {
    None
  } else {
    Some(str)
  }
}

let getNonEmptyArray = arr => {
  if arr->Js.Array2.length === 0 {
    None
  } else {
    Some(arr)
  }
}

let getReturnArray = (dict, key) => {
  switch Js.Dict.get(dict, key) {
  | Some(value) =>
    switch value->Js.Json.decodeArray {
    | Some(jsonArr) => jsonArr->Js.Array2.reduce((acc, jsonItem) => {
        switch jsonItem->Js.Json.decodeArray {
        | Some(percentTuple) =>
          if percentTuple->Js.Array2.length === 2 {
            let percent = switch Js.Json.decodeNumber(
              percentTuple[0]->Belt.Option.getWithDefault(Js.Json.null),
            ) {
            | Some(num) => num->Belt.Float.toInt
            | None => 0
            }

            let priorityArr = switch percentTuple[1]
            ->Belt.Option.getWithDefault(Js.Json.null)
            ->getOptionStrArrayFromJson {
            | Some(x) => x
            | None => []
            }

            let _ = Js.Array2.push(acc, (percent, priorityArr))
          }
        | None => ()
        }
        acc
      }, [])->Some
    | None => None
    }
  | None => None
  }
}

let getOptionBool = (dict, key) => {
  dict->Js.Dict.get(key)->Belt.Option.flatMap(Js.Json.decodeBoolean)
}

let getBool = (dict, key, default) => {
  getOptionBool(dict, key)->Belt.Option.getWithDefault(default)
}

let getJsonObjectFromDict = (dict, key) => {
  dict->Js.Dict.get(key)->Belt.Option.getWithDefault(Js.Json.object_(Js.Dict.empty()))
}

let getBoolFromString = (boolString, default: bool) => {
  switch boolString->Js.String2.toLowerCase {
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

let getFloatFromOptionString = (str: option<string>, default) => {
  str->Belt.Option.getWithDefault("")->Belt.Float.fromString->Belt.Option.getWithDefault(default)
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
  switch Js.Dict.get(dict, key) {
  | Some(value) => getIntFromJson(value, default)
  | None => default
  }
}
let getOptionInt = (dict, key) => {
  switch Js.Dict.get(dict, key) {
  | Some(value) => getOptionIntFromJson(value)
  | None => None
  }
}

let getOptionFloat = (dict, key) => {
  switch Js.Dict.get(dict, key) {
  | Some(value) => getOptionFloatFromJson(value)
  | None => None
  }
}

let getFloat = (dict, key, default) => {
  dict
  ->Js.Dict.get(key)
  ->Belt.Option.map(json => getFloatFromJson(json, default))
  ->Belt.Option.getWithDefault(default)
}

let getObj = (dict, key, default) => {
  dict
  ->Js.Dict.get(key)
  ->Belt.Option.flatMap(Js.Json.decodeObject)
  ->Belt.Option.getWithDefault(default)
}

let getTime = (dict, key) => {
  switch dict->Js.Dict.get(key) {
  | Some(json) => {
      let timeStr = getStringFromJson(json, "")
      let (from, day) =
        timeStr->Js.String2.length > 11 ? (4, Js.String.slice(~from=0, ~to_=3, timeStr)) : (0, "")
      let time = timeStr->Js.String2.split("-")->Js.Array2.map(t => Js.String.sliceToEnd(~from, t))

      if time->Js.Array2.length !== 2 {
        {day, start: "00:00", end: "00:00"}
      } else {
        {
          day,
          start: time[0]->Belt.Option.getWithDefault("00:00"),
          end: time[1]->Belt.Option.getWithDefault("00:00"),
        }
      }
    }

  | None => {day: "", start: "", end: ""}
  }
}

let convertStringToFile = (~contentType="", str) => {
  [str->Webapi__Blob.stringToBlobPart]->Webapi__File.makeWithOptions(
    "",
    Webapi__File.makeFilePropertyBag(~_type=contentType, ()),
  )
}

let convertToMin = time => {
  let t =
    time
    ->Js.String2.split(":")
    ->Js.Array2.map(t => t->Belt.Int.fromString->Belt.Option.getWithDefault(0))
  t->Js.Array2.length === 2
    ? t[0]->Belt.Option.getWithDefault(0) * 60 + t[1]->Belt.Option.getWithDefault(0)
    : 0
}

let parseCondition = condJson => {
  switch condJson->Js.Json.decodeObject {
  | Some(condDict) => {
      let not = getBool(condDict, "not", false)
      switch getOptionString(condDict, "key") {
      | Some(key) =>
        switch getOptionStrArrayFromDict(condDict, "vals") {
        | Some(vals) => Some(ComparisionCheck({key, not, vals}))
        | None => None
        }
      | None => None
      }
    }

  | None => None
  }
}

let rec parseLogicsJsonArr = logicsJson => {
  switch logicsJson->Js.Json.decodeArray {
  | Some(logicsArr) => logicsArr->Js.Array2.reduce((acc, logicJson) => {
      switch logicJson->Js.Json.decodeObject {
      | Some(logicObj) => {
          let condition = switch Js.Dict.get(logicObj, "cond") {
          | Some(condJson) =>
            switch condJson->parseCondition {
            | Some(condition) => condition
            | None => NoCondition
            }

          | None => NoCondition
          }
          switch Js.Dict.get(logicObj, "logics") {
          | Some(logicsJson) => {
              let subLogics = logicsJson->parseLogicsJsonArr
              let logic = {
                condition,
                logics: subLogics,
              }
              let _ = Js.Array2.push(acc, logic)
            }

          | None => ()
          }

          switch getReturnArray(logicObj, "return") {
          | Some(returnArr) => {
              let logic = {
                condition,
                logics: Return(returnArr),
              }
              let _ = Js.Array2.push(acc, logic)
            }

          | None => ()
          }
        }

      | None => ()
      }
      acc
    }, [])->IfElse
  | None => Return([])
  }
}

let useLogics = json => {
  React.useMemo1(() => {
    switch json->Js.Json.decodeObject {
    | Some(obj) =>
      switch Js.Dict.get(obj, "logics") {
      | Some(logicsJson) => logicsJson->parseLogicsJsonArr
      | None => Return([])
      }
    | None => Return([])
    }
  }, [json])
}

let paddingChar = "\t"

let rec printLogics = (logics, defaultArr, indentLevel) => {
  let padding = Belt.Array.make(indentLevel, paddingChar)->Js.Array.joinWith("", _)
  let isEmpty = switch logics {
  | Return(strArr) => strArr->Js.Array2.length === 0
  | IfElse(logicsArr) => logicsArr->Js.Array2.length === 0
  }

  if isEmpty {
    `${padding}//`
  } else {
    switch logics {
    | Return(returArr) => {
        let (overallPercent, code) = returArr->Js.Array.reducei((acc, info, i) => {
          let (totalSoFar, codeSoFar) = acc
          let (percent, strArr) = info

          let newTotal = totalSoFar + percent
          let percentStr = newTotal->string_of_int
          let newArr = strArr->Js.Array2.map(x => `"${x}"`)->Js.Array2.joinWith(", ")

          let prefix = if i === 0 {
            `${padding}if`
          } else {
            ` else if`
          }
          let predicate = if newTotal === 100 {
            ` else`
          } else {
            `${prefix} (percent <= ${percentStr})`
          }

          let newCode =
            codeSoFar ++
            `${predicate} {\n` ++
            `${padding}${paddingChar}priorities = [${newArr}]\n` ++
            `${padding}}`

          (totalSoFar + percent, newCode)
        }, (0, ""), _)

        if overallPercent < 100 {
          let strArr = defaultArr
          let newArr = strArr->Js.Array2.map(x => `"${x}"`)->Js.Array2.joinWith(", ")
          let newCode =
            code ++
            ` else {\n` ++
            `${padding}${paddingChar}priorities = [${newArr}]\n` ++
            `${padding}}`
          newCode
        } else {
          code
        }
      }

    | IfElse(logicsArr) =>
      logicsArr
      ->Js.Array2.mapi((logic, i) => {
        let conditionStr = switch logic.condition {
        | NoCondition => ""
        | NumericCondition(numericComparisionType) => {
            let key = numericComparisionType.key
            let validRules = numericComparisionType.validRules

            validRules
            ->Js.Array2.map(rule =>
              switch rule {
              | LessThan(num, inclusive) => {
                  let op = inclusive ? "<=" : "<"
                  `${key} ${op} ${num->string_of_int}`
                }

              | GreaterThan(num, inclusive) => {
                  let op = inclusive ? ">=" : ">"
                  `${key} ${op} ${num->string_of_int}`
                }

              | EqualTo(nums) => {
                  let numsStr = nums->Js.Array2.map(string_of_int)->Js.Array2.joinWith(", ")
                  `[${numsStr}].contains(${key})`
                }
              }
            )
            ->Js.Array2.joinWith("\n")
          }

        | ComparisionCheck(conditionCheck) => {
            let key = conditionCheck.key
            let vals = conditionCheck.vals
            let _not = conditionCheck.not

            if vals->Js.Array2.length === 1 {
              `${key} == "${vals[0]->Belt.Option.getWithDefault("")}"`
            } else {
              let valsArrStr = vals->Js.Array2.map(x => `"${x}"`)->Js.Array2.joinWith(", ")
              `[${valsArrStr}].contains(${key})`
            }
          }
        }

        let ifType = if i === 0 {
          `${padding}if`
        } else {
          " else if"
        }

        let start = switch logic.condition {
        | NoCondition => " else"
        | NumericCondition(_numericComparisionType) => `${ifType} (${conditionStr})`
        | ComparisionCheck(_conditionCheck) => `${ifType} (${conditionStr})`
        }

        let blockContent = printLogics(logic.logics, defaultArr, indentLevel + 1)

        `${start} {
${blockContent}
${padding}}`
      })
      ->Js.Array2.joinWith("")
    }
  }
}

let printableStrArray = strArray => {
  strArray->Js.Array2.map(Js.Json.string)->Js.Json.array->Js.Json.stringify
}

let getCode = (defaultArr, logics) => {
  `
def priorities = ${defaultArr->printableStrArray}
def randomPercent = System.currentTimeMillis() % 100
  

${printLogics(logics, defaultArr, 0)}

setGatewayPriority(priorities)
  
  `
}

let rec getLogicArrJson = (logicArr: array<logic>) => {
  logicArr
  ->Js.Array2.map(logic => {
    let dict = Js.Dict.empty()
    switch logic.condition {
    | NoCondition => ()
    | NumericCondition(numericCond) => {
        let condDict = Js.Dict.empty()
        Js.Dict.set(condDict, "key", numericCond.key->Js.Json.string)
        Js.Dict.set(
          condDict,
          "vals",
          numericCond.validRules
          ->Js.Array2.map(rule => {
            switch rule {
            | LessThan(int, bool) =>
              [
                (bool ? "lte" : "lt")->Js.Json.string,
                int->Belt.Float.fromInt->Js.Json.number,
              ]->Js.Json.array
            | GreaterThan(int, bool) =>
              [
                (bool ? "gte" : "gt")->Js.Json.string,
                int->Belt.Float.fromInt->Js.Json.number,
              ]->Js.Json.array
            | EqualTo(nums) =>
              {
                let arr = ["eq"->Js.Json.string]
                nums->Js.Array2.forEach(
                  num => {
                    let _ = Js.Array2.push(arr, num->Belt.Float.fromInt->Js.Json.number)
                  },
                )
                arr
              }->Js.Json.array
            }
          })
          ->Js.Json.array,
        )

        Js.Dict.set(dict, "cond", condDict->Js.Json.object_)
      }

    | ComparisionCheck(cond) => {
        let condDict = Js.Dict.empty()
        Js.Dict.set(condDict, "key", cond.key->Js.Json.string)
        Js.Dict.set(condDict, "vals", cond.vals->Js.Array2.map(Js.Json.string)->Js.Json.array)
        Js.Dict.set(condDict, "not", cond.not->Js.Json.boolean)

        Js.Dict.set(dict, "cond", condDict->Js.Json.object_)
      }
    }
    switch logic.logics {
    | Return(returnArr) => {
        let returnArrJson =
          returnArr
          ->Js.Array2.map(tuple => {
            let (percent, strArr) = tuple

            Js.Json.array([
              percent->Belt.Float.fromInt->Js.Json.number,
              strArr->Js.Array2.map(Js.Json.string)->Js.Json.array,
            ])
          })
          ->Js.Json.array

        Js.Dict.set(dict, "return", returnArrJson)
      }

    | IfElse(subLogicArr) => Js.Dict.set(dict, "logics", subLogicArr->getLogicArrJson)
    }
    dict->Js.Json.object_
  })
  ->Js.Json.array
}

let getJson = (logics: logics, defaultPriorities) => {
  let logicsJson = switch logics {
  | Return(_arr) => Js.Json.string("return statement")
  | IfElse(arr) => arr->getLogicArrJson
  }

  let dict = Js.Dict.empty()
  Js.Dict.set(dict, "default", defaultPriorities->Js.Array2.map(Js.Json.string)->Js.Json.array)
  Js.Dict.set(dict, "logics", logicsJson)
  dict->Js.Json.object_
}

@set external setCookie: (DOMUtils.document, string) => unit = "cookie"
@get external getCookie: DOMUtils.document => Js.Nullable.t<string> = "cookie"

let getCookieVal = key => {
  switch getCookie(DOMUtils.document)->Js.Nullable.toOption {
  | Some(str) => {
      let cookieInfoDict =
        str
        ->Js.String2.split(";")
        ->Js.Array2.map(segment => {
          let arr = segment->Js.String2.split("=")
          let key = arr->Belt.Array.get(0)->Belt.Option.getWithDefault("")->Js.String2.trim
          let value = arr->Belt.Array.get(1)->Belt.Option.getWithDefault("")->Js.String2.trim
          (key, value)
        })
        ->Js.Dict.fromArray

      cookieInfoDict->Js.Dict.get(key)->Belt.Option.getWithDefault("")
    }

  | None => ""
  }
}

let setCookieVal = cookie => {
  setCookie(DOMUtils.document, cookie)
}

let getDictFromUrlSearchParams = searchParams => {
  open Belt.Array
  searchParams
  ->Js.String2.split("&")
  ->keepMap(getNonEmptyString)
  ->keepMap(keyVal => {
    let splitArray = Js.String2.split(keyVal, "=")

    switch (splitArray->get(0), splitArray->get(1)) {
    | (Some(key), Some(val)) => Some(key, val)
    | _ => None
    }
  })
  ->Js.Dict.fromArray
}
let setOptionString = (dict, key, optionStr) =>
  optionStr->Belt.Option.mapWithDefault((), str => dict->Js.Dict.set(key, str->Js.Json.string))

let setOptionFloat = (dict, key, optionFloat) =>
  optionFloat->Belt.Option.mapWithDefault((), float =>
    dict->Js.Dict.set(key, float->Js.Json.number)
  )

let setOptionInt = (dict, key, optionInt) =>
  optionInt->Belt.Option.mapWithDefault((), int =>
    dict->Js.Dict.set(key, int->Belt.Float.fromInt->Js.Json.number)
  )

let setOptionBool = (dict, key, optionInt) =>
  optionInt->Belt.Option.mapWithDefault((), bool => dict->Js.Dict.set(key, bool->Js.Json.boolean))

let setOptionArray = (dict, key, optionArray) =>
  optionArray->Belt.Option.mapWithDefault((), array => dict->Js.Dict.set(key, array->Js.Json.array))

let setOptionDict = (dict, key, optionDictValue) =>
  optionDictValue->Belt.Option.mapWithDefault((), value =>
    dict->Js.Dict.set(key, value->Js.Json.object_)
  )

let getJsonFromStringOption = optionStr =>
  optionStr->Belt.Option.mapWithDefault(Js.Json.null, Js.Json.string)

let getJsonFromFloatOption = optionFloat =>
  optionFloat->Belt.Option.mapWithDefault(Js.Json.null, Js.Json.number)

let getJsonFromIntOption = optionInt =>
  optionInt->Belt.Option.mapWithDefault(Js.Json.null, v => v->Belt.Float.fromInt->Js.Json.number)

let capitalizeString = str => {
  Js.String2.toUpperCase(Js.String2.charAt(str, 0)) ++ Js.String2.substringToEnd(str, ~from=1)
}

let snakeToCamel = str => {
  str
  ->Js.String2.split("_")
  ->Js.Array2.mapi((x, i) => i == 0 ? x : capitalizeString(x))
  ->Js.Array2.joinWith("")
}

let camelToSnake = str => {
  str
  ->capitalizeString
  ->Js.String2.replaceByRe(%re("/([a-z0-9A-Z])([A-Z])/g"), "$1_$2")
  ->Js.String2.toLowerCase
}

let camelCaseToTitle = str => {
  str->capitalizeString->Js.String2.replaceByRe(%re("/([a-z0-9A-Z])([A-Z])/g"), "$1 $2")
}

let isContainingStringLowercase = (text, searchStr) => {
  text->Js.String2.toLowerCase->Js.String2.includes(searchStr->Js.String2.toLowerCase)
}

let snakeToTitle = str => {
  str
  ->Js.String2.split("_")
  ->Js.Array2.map(x => {
    let first = x->Js.String2.charAt(0)->Js.String2.toUpperCase
    let second = x->Js.String2.substringToEnd(~from=1)
    first ++ second
  })
  ->Js.Array2.joinWith(" ")
}

let urlToTitle = str => {
  str
  ->Js.String2.split("-")
  ->Js.Array2.map(x => {
    let firstLetter = x->Js.String2.charAt(0)->Js.String2.toUpperCase
    let restLetters = x->Js.String2.substringToEnd(~from=1)
    `${firstLetter}${restLetters}`
  })
  ->Js.Array2.joinWith(" ")
}

let titleToSnake = str => {
  str->Js.String2.split(" ")->Js.Array2.map(Js.String2.toLowerCase)->Js.Array2.joinWith("_")
}

let getOptionalDictFromDict = (dict, key) => {
  switch dict->Js.Dict.get(key) {
  | Some(json) =>
    switch json->Js.Json.decodeObject {
    | Some(dict) => Some(dict)
    | None => None
    }
  | None => None
  }
}

let getIntFromString = (str, default) => {
  str->Belt.Int.fromString->Belt.Option.getWithDefault(default)
}

let getIntFromOptionString = (optionStr, default) => {
  switch optionStr {
  | Some(str) => str->getIntFromString(default)
  | None => default
  }
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
      `${Js.String2.make(years)}Y `
    } else {
      ""
    }
    let month_disp = if months > 0 {
      `${Js.String2.make(months)}M `
    } else {
      ""
    }
    let day_disp = if days > 0 {
      `${Js.String2.make(days)}D `
    } else {
      ""
    }
    let hr_disp = if hours > 0 {
      `${Js.String2.make(hours)}H `
    } else {
      ""
    }
    let min_disp = if minutes > 0 {
      `${Js.String2.make(minutes)}M `
    } else {
      ""
    }
    let sec_disp = if seconds > 0 {
      `${Js.String2.make(seconds)}S `
    } else {
      ""
    }
    let millisec_disp = if (
      (labelValue < 1.0 ||
        (includeMilliseconds->Belt.Option.getWithDefault(false) && labelValue < 60.0)) &&
        labelValue > 0.0
    ) {
      `${Js.String2.make(mod((labelValue *. 1000.0)->Belt.Int.fromFloat, 1000))}MS`
    } else {
      ""
    }

    if days > 0 {
      year_disp ++ month_disp ++ day_disp
    } else {
      year_disp ++ month_disp ++ day_disp ++ hr_disp ++ min_disp ++ sec_disp ++ millisec_disp
    }
  } else {
    "0"
  }
}

let checkEmptyJson = json => {
  json == Js.Json.object_(Js.Dict.empty())
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

//agnostic of case
let alphabeticalSortFn = (e1, e2) => {
  let e1 = e1->Js.String2.toLowerCase
  let e2 = e2->Js.String2.toLowerCase
  if e1 > e2 {
    1
  } else if e1 < e2 {
    -1
  } else {
    0
  }
}

let getHostnameQueryFromURL = url => {
  let arr = url->Js.String2.split("?")
  let queryDict = arr->Belt.Array.get(1)->Belt.Option.getWithDefault("")->getDictFromUrlSearchParams
  (arr[0]->Belt.Option.getWithDefault(""), queryDict)
}

let makeURLFromHostnameQuery = (host, queryDict) => {
  let query =
    queryDict->Js.Dict.entries->Js.Array2.map(((k, v)) => `${k}=${v}`)->Js.Array2.joinWith("&")
  `${host}?${query}`
}

let isEmptyDict = dict => {
  dict->Js.Dict.keys->Js.Array2.length === 0
}
let stringReplaceAll = (str, old, new) => {
  str->Js.String2.split(old)->Js.Array2.joinWith(new)
}

let getNullFloat = (dict, key) => {
  switch Js.Dict.get(dict, key) {
  | Some(value) =>
    switch value->Js.Json.decodeString {
    | Some(val) => val->Belt.Float.fromString->Js.Nullable.fromOption
    | None =>
      switch value->Js.Json.decodeNumber {
      | Some(val) => val->Js.Nullable.return
      | None => Js.Nullable.null
      }
    }
  | None => Js.Nullable.null
  }
}

let getUniqueArray = (arr: array<'t>) => {
  arr->Js.Array2.map(item => (item, ""))->Js.Dict.fromArray->Js.Dict.keys
}

let getFirstLetterCaps = (str, ~splitBy="-", ()) => {
  str
  ->Js.String2.toLowerCase
  ->Js.String2.split(splitBy)
  ->Js.Array2.map(capitalizeString)
  ->Js.Array2.joinWith(" ")
}

let getDictfromDict = (dict, key) => {
  dict->getJsonObjectFromDict(key)->getDictFromJsonObject
}

let checkLeapYear = year => (mod(year, 4) === 0 && mod(year, 100) !== 0) || mod(year, 400) === 0

let safeDivision = (~numerator: float, ~denominator: float) => {
  denominator > 0. ? numerator /. denominator : 0.
}

let getValueFromArr = (arr, index, default) =>
  arr->Belt.Array.get(index)->Belt.Option.getWithDefault(default)

let isEqualStringArr = (arr1, arr2) => {
  let arr1 = arr1->getUniqueArray
  let arr2 = arr2->getUniqueArray
  let lengthEqual = arr1->Js.Array2.length === arr2->Js.Array2.length
  let isContainsAll = arr1->Js.Array2.reduce((acc, str) => {
    arr2->Js.Array2.includes(str) && acc
  }, true)
  lengthEqual && isContainsAll
}

let getDefaultNumberFormat = () => {
  open CurrencyFormatUtils
  USD
}

let indianShortNum = labelValue => {
  shortNum(~labelValue, ~numberFormat=getDefaultNumberFormat(), ())
}

let getNumberString = (
  ~prefix="",
  ~suffix="",
  ~showDecimal=false,
  ~toShortNum=false,
  ~numberFormat="INR",
  ~digits=2,
  value,
) => {
  if toShortNum {
    `${prefix}${shortNum(~labelValue=value, ~numberFormat=getDefaultNumberFormat(), ())}${suffix}`
  } else {
    let valueSplitArr = Js.Float.toFixedWithPrecision(value, ~digits)->Js.String2.split(".")

    let decimalValue =
      valueSplitArr
      ->Belt.Array.get(1)
      ->Belt.Option.getWithDefault("0")
      ->Belt.Int.fromString
      ->Belt.Option.getWithDefault(0)
    let decimal = if valueSplitArr->Js.Array2.length > 1 && decimalValue !== 0 {
      `.${valueSplitArr[1]->Belt.Option.getWithDefault("")}`
    } else {
      ""
    }
    let receivedValue = value->Js.Math.floor_float->Belt.Float.toString
    let formattedvalue = if numberFormat === "INR" {
      receivedValue->Js.String2.replaceByRe(%re("/(\d)(?=(?:(\d\d)+(\d)(?!\d))+(?!\d))/g"), "$1,")
    } else {
      receivedValue->Js.String2.replaceByRe(%re("/(\d)(?=(\d{3})+(?!\d))/g"), "$1,")
    }
    `${prefix}${formattedvalue}${showDecimal ? decimal : ""}${suffix}`
  }
}

let convertNewLineSaperatedDataToArrayOfJson = text => {
  text
  ->Js.String2.split("\n")
  ->Js.Array2.filter(item => item !== "")
  ->Js.Array2.map(item => {
    item->safeParse
  })
}

let getObjectArrayFromJson = json => {
  json->getArrayFromJson([])->Js.Array2.map(getDictFromJsonObject)
}

let getListHead = (~default="", list) => {
  list->Belt.List.head->Belt.Option.getWithDefault(default)
}

/*
metrics arr: the array which need to be merged i.e 
[
  [
    {
      "order_status": "1",
      "time": "2023-07-24 00:00:00"
    },
    {
      "order_status": "3330",
      "time": "2023-07-25 00:00:00"
    },
  
  ],
  [
    {
      "p2p_clicked": "1",
      "time": "2023-07-24 00:00:00"
    },
    {
      "p2p_clicked": "3330",
      "time": "2023-07-25 00:00:00"
    },
  ]
]

dictKey: key on which we wanted to merge i.e in the above case it will be time

output will be :

[
  {
    "order_status": "1",
    "time": "2023-07-24 00:00:00",
    "p2p_clicked": "1"
  },
  {
    "order_status": "3330",
    "time": "2023-07-25 00:00:00",
    "p2p_clicked": "3330"
  }
]


*/
let dataMerge = (~dataArr: array<array<Js.Json.t>>, ~dictKey: array<string>) => {
  let finalData = Js.Dict.empty()
  dataArr->Js.Array2.forEach(jsonArr => {
    jsonArr->Js.Array2.forEach(jsonObj => {
      let dict = jsonObj->getDictFromJsonObject
      let dictKey =
        dictKey
        ->Js.Array2.map(
          ele => {
            dict->getString(ele, "")
          },
        )
        ->Js.Array2.joinWith("-")
      let existingData = finalData->getObj(dictKey, Js.Dict.empty())->Js.Dict.entries
      let data = dict->Js.Dict.entries

      finalData->Js.Dict.set(
        dictKey,
        existingData->Js.Array2.concat(data)->Js.Dict.fromArray->Js.Json.object_,
      )
    })
  })

  finalData->Js.Dict.values
}

let sumOfArrInt = (arr: array<int>) => {
  arr->Belt.Array.reduce(0, (acc, value) => acc + value)
}

let sumOfArrFloat = (arr: array<float>) => {
  arr->Belt.Array.reduce(0., (acc, value) => acc +. value)
}

let getJsonFromStr = data => {
  if data !== "" {
    Js.Json.stringifyWithSpace(safeParse(data), 2)
  } else {
    data
  }
}

let compareStr = (str1, str2) => {
  str1->Js.String2.toLowerCase->Js.String2.includes(str2->Js.String2.toLowerCase)
}

//Extract Exn to Dict
external toExnJson: exn => Js.Json.t = "%identity"

let exnToDict = exn => {
  exn->toExnJson->getDictFromJsonObject
}

let getJsonDict = val => {
  val->Belt.Option.getWithDefault(Js.Dict.empty()->Js.Json.object_)
}

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

let getJsonFromArrayOfJson = arr => arr->Js.Dict.fromArray->Js.Json.object_
let getNonEmptyStrFromOptionStr = (str, defaultValue) => {
  switch str {
  | Some(val) => val->Js.String2.trim !== "" ? val : defaultValue
  | None => defaultValue
  }
}

let getTitle = name => {
  name
  ->Js.String2.toLowerCase
  ->Js.String2.split("_")
  ->Js.Array2.map(capitalizeString)
  ->Js.Array2.joinWith(" ")
}
