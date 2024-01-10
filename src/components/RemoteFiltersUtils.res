type urlKEyType = Boolean | Float | Int

let getFinalDict = (
  ~filterJson,
  ~filtersFromUrl,
  ~options: array<EntityType.optionType<'t>>,
  ~isEulerOrderEntity,
  ~dropdownSearchKeyValueNames,
  ~searchkeysDict,
  ~isSearchKeyArray,
  ~defaultKeysAllowed=["offset", "order", "orderType", "merchantId"],
  ~urlKeyTypeDict,
  (),
) => {
  let unflattenDict = filtersFromUrl->JsonFlattenUtils.unflattenObject

  let filterDict = Dict.make()
  switch filterJson->Js.Json.decodeObject {
  | Some(dict) => {
      // Hack for admin service config entity
      let allowedDefaultKeys = if dict->Dict.get("sourceObject")->Js.Option.isSome {
        Dict.keysToArray(dict)
      } else {
        defaultKeysAllowed
      }
      // Hack for orders entity
      dict
      ->Dict.toArray
      ->Array.forEach(entry => {
        let (key, val) = entry
        if Array.includes(allowedDefaultKeys, key) {
          filterDict->Dict.set(key, val)
        }
      })
    }

  | None => ()
  }

  unflattenDict
  ->Dict.toArray
  ->Array.forEach(entry => {
    let (key, val) = entry

    let parser = switch options->Array.find(option => {
      option.urlKey === key
    }) {
    | Some(selectedOption) => selectedOption.parser
    | None => x => x
    }

    filterDict->Dict.set(key, parser(val))

    let val = switch urlKeyTypeDict->Dict.toArray->Array.find(((urlKey, _)) => key === urlKey) {
    | Some((_, value)) =>
      let getExpectedType = ele => {
        switch value {
        | Boolean => ele->LogicUtils.getBoolFromString(false)->Js.Json.boolean
        | Float => ele->LogicUtils.getFloatFromString(0.)->Js.Json.number
        | Int => ele->LogicUtils.getIntFromString(0)->Int.toFloat->Js.Json.number
        }
      }
      switch val->Js.Json.classify {
      | JSONArray(stringValueArr) =>
        stringValueArr
        ->Array.map(ele => {
          getExpectedType(ele->Js.Json.decodeString->Option.getWithDefault(""))
        })
        ->Js.Json.array
      | JSONString(ele) => getExpectedType(ele)
      | _ => val
      }

    | None => val
    }
    filterDict->Dict.set(key, val)
  })

  if filterDict->Dict.keysToArray->Array.length === 0 {
    filterJson
  } else {
    if dropdownSearchKeyValueNames->Array.length === 2 {
      if !isSearchKeyArray {
        let key =
          filterDict
          ->LogicUtils.getString(dropdownSearchKeyValueNames[0]->Belt.Option.getWithDefault(""), "")
          ->LogicUtils.toCamelCase
        let value =
          filterDict->LogicUtils.getString(
            dropdownSearchKeyValueNames[1]->Belt.Option.getWithDefault(""),
            "",
          )
        if value !== "" {
          let isformat = searchkeysDict !== Dict.make()
          let value = if isformat {
            let intSearchKeys = searchkeysDict->LogicUtils.getArrayFromDict("intSearchKeys", [])
            let arrSearchKeys = searchkeysDict->LogicUtils.getArrayFromDict("arrSearchKeys", [])
            if intSearchKeys->Array.includes(key->Js.Json.string) {
              value->LogicUtils.getFloatFromString(0.00)->Js.Json.number
            } else if arrSearchKeys->Array.includes(key->Js.Json.string) {
              value->String.split(",")->Array.map(str => str->Js.Json.string)->Js.Json.array
            } else {
              value->Js.Json.string
            }
          } else {
            value->Js.Json.string
          }
          filterDict->Dict.set(key, value)
        }
      } else {
        let key =
          filterDict
          ->LogicUtils.getArrayFromDict(
            dropdownSearchKeyValueNames[0]->Belt.Option.getWithDefault(""),
            [],
          )
          ->Array.map(item => item->LogicUtils.getStringFromJson("")->LogicUtils.toCamelCase)
        let value =
          filterDict
          ->LogicUtils.getString(dropdownSearchKeyValueNames[1]->Belt.Option.getWithDefault(""), "")
          ->String.split(", ")
        value->Array.forEachWithIndex((value, indx) => {
          let key = key->Array.length > indx ? key[indx]->Belt.Option.getWithDefault("") : ""
          if value !== "" && key != "" {
            let isformat = searchkeysDict !== Dict.make()
            let value = if isformat {
              let intSearchKeys = searchkeysDict->LogicUtils.getArrayFromDict("intSearchKeys", [])
              let arrSearchKeys = searchkeysDict->LogicUtils.getArrayFromDict("arrSearchKeys", [])
              if intSearchKeys->Array.includes(key->Js.Json.string) {
                value->LogicUtils.getFloatFromString(0.00)->Js.Json.number
              } else if arrSearchKeys->Array.includes(key->Js.Json.string) {
                value->String.split(",")->Array.map(str => str->Js.Json.string)->Js.Json.array
              } else {
                value->Js.Json.string
              }
            } else {
              value->Js.Json.string
            }
            filterDict->Dict.set(key, value)
          }
        })
      }
    }
    if isEulerOrderEntity {
      let arr = if filterDict->Dict.get("customerId")->Js.Option.isSome {
        [["date_created", "DESC"]->Js.Json.stringArray]
      } else {
        []
      }
      filterDict->Dict.set("order", arr->Js.Json.array)
    }

    filterDict->Js.Json.object_
  }
}

let getStrFromJson = (key, val) => {
  switch val->Js.Json.classify {
  | JSONString(str) => str
  | JSONArray(array) => array->Array.length > 0 ? `[${array->Array.joinWith(",")}]` : ""
  | JSONNumber(num) => key === "offset" ? "0" : num->Belt.Float.toInt->string_of_int
  | _ => ""
  }
}

let getInitialValuesFromUrl = (
  ~searchParams,
  ~initialFilters: array<EntityType.initialFilters<'t>>,
  ~options: array<EntityType.optionType<'t>>=[],
  ~mandatoryRemoteKeys: array<string>=[],
  (),
) => {
  let initialFilters = initialFilters->Array.map(item => item.field)
  let dict = Dict.make()
  let searchParams = searchParams->LogicUtils.stringReplaceAll("%20", " ")
  if String.length(searchParams) > 0 {
    let splitUrlArray = String.split(searchParams, "&")
    let entriesList = []
    let keyList = []
    let valueList = []

    splitUrlArray->Array.forEach(filterKeyVal => {
      let splitArray = String.split(filterKeyVal, "=")
      let keyStartIndex = String.lastIndexOf(splitArray[0]->Belt.Option.getWithDefault(""), "-") + 1
      let key = String.sliceToEnd(
        splitArray[0]->Belt.Option.getWithDefault(""),
        ~start=keyStartIndex,
      )
      Array.push(keyList, key)->ignore
      splitArray->Js.Array2.shift->ignore
      let value = splitArray->Array.joinWith("=")
      Array.push(valueList, value)->ignore

      entriesList->Array.push((key, value))->ignore
    })
    entriesList->Array.forEach(entry => {
      let (key, value) = entry
      initialFilters->Array.forEach((filter: FormRenderer.fieldInfoType) => {
        filter.inputNames->Array.forEach(
          name => {
            if name === key {
              Dict.set(dict, key, value->UrlFetchUtils.getFilterValue)
            }
          },
        )
      })

      options->Array.forEach(option => {
        let fieldName = option.urlKey
        if fieldName === key {
          Dict.set(dict, key, value->UrlFetchUtils.getFilterValue)
        }
      })

      mandatoryRemoteKeys->Array.forEach(searchKey => {
        if searchKey === key {
          Dict.set(dict, key, value->UrlFetchUtils.getFilterValue)
        }
      })
    })
  }
  Js.Json.object_(dict)
}

let getLocalFiltersData = (
  ~resArr: Js.Array2.t<Js.Nullable.t<'t>>,
  ~searchParams,
  ~initialFilters: array<EntityType.initialFilters<'t>>,
  ~dateRangeFilterDict: Dict.t<Js.Json.t>,
  ~options: array<EntityType.optionType<'t>>,
  (),
) => {
  let res = ref(resArr)
  if String.length(searchParams) > 0 {
    let splitUrlArray = String.split(searchParams, "&")
    let keyList = []
    let valueList = []
    splitUrlArray->Array.forEach(filterKeyVal => {
      let splitArray = String.split(filterKeyVal, "=")
      let keyStartIndex = String.lastIndexOf(splitArray[0]->Belt.Option.getWithDefault(""), `-`) + 1
      let key = String.sliceToEnd(
        splitArray[0]->Belt.Option.getWithDefault(""),
        ~start=keyStartIndex,
      )
      Array.push(keyList, key)->ignore
      Array.push(valueList, splitArray[1]->Belt.Option.getWithDefault(""))->ignore
    })

    let dateRange = dateRangeFilterDict->LogicUtils.getArrayFromDict("dateRange", [])
    let startKey =
      dateRange
      ->Belt.Array.get(0)
      ->Belt.Option.getWithDefault(""->Js.Json.string)
      ->LogicUtils.getStringFromJson("")
    let endKey =
      dateRange
      ->Belt.Array.get(1)
      ->Belt.Option.getWithDefault(""->Js.Json.string)
      ->LogicUtils.getStringFromJson("")

    let (keyList, valueList) = if (
      dateRangeFilterDict != Dict.make() &&
      startKey != "" &&
      endKey != "" &&
      keyList->Array.includes(startKey) &&
      keyList->Array.includes(endKey)
    ) {
      let start_Date = valueList[keyList->Array.indexOf(startKey)]->Belt.Option.getWithDefault("")
      let end_Date = valueList[keyList->Array.indexOf(endKey)]->Belt.Option.getWithDefault("")
      let keyList = keyList->Array.filter(item => item != startKey && item != endKey)
      let valueList = valueList->Array.filter(item => item != start_Date && item != end_Date)
      keyList->Array.push(startKey)->ignore
      valueList->Array.push(`${start_Date}&${end_Date}`)->ignore
      (keyList, valueList)
    } else {
      (keyList, valueList)
    }

    keyList->Array.forEachWithIndex((key, idx) => {
      initialFilters->Array.forEach(filter => {
        let field: FormRenderer.fieldInfoType = filter.field
        let localFilter = filter.localFilter
        field.inputNames->Array.forEach(
          name => {
            if name === key {
              let value = valueList[idx]->Belt.Option.getWithDefault("")
              if String.includes(value, "[") {
                let str = String.slice(~start=1, ~end=value->String.length - 1, value)
                let splitArray = String.split(str, ",")
                let jsonarr = splitArray->Array.map(val => Js.Json.string(val))
                res.contents = switch localFilter {
                | Some(localFilter) => localFilter(res.contents, Js.Json.array(jsonarr))
                | None => res.contents
                }
              } else {
                res.contents = switch localFilter {
                | Some(localFilter) => localFilter(res.contents, Js.Json.string(value))
                | None => res.contents
                }
              }
            }
          },
        )
      })

      options->Array.forEach(option => {
        let fieldName = option.urlKey
        let localFilter = option.localFilter
        if fieldName === key {
          res.contents = switch localFilter {
          | Some(localFilter) =>
            localFilter(
              res.contents,
              Js.Json.string(valueList[idx]->Belt.Option.getWithDefault("")),
            )
          | None => res.contents
          }
        }
      })
    })
  }
  res.contents
}

let generateUrlFromDict = (~dict, ~options: array<EntityType.optionType<'t>>, tableName) => {
  dict
  ->Dict.toArray
  ->Belt.Array.keepMap(entry => {
    let (key, val) = entry

    let strValue = getStrFromJson(key, val)
    if strValue !== "" {
      let requiredOption = options->Array.find(option => option.urlKey === key)
      switch requiredOption {
      | Some(option) => {
          let finalVal = option.parser(val)
          Dict.set(dict, key, finalVal)
        }

      | None => Dict.set(dict, key, val)
      }
      let finalKey = switch tableName {
      | Some(val) => val->String.concat(`-${key}`)
      | None => key
      }
      Some(`${finalKey}=${strValue}`)
    } else {
      None
    }
  })
  ->Array.joinWith("&")
}

let applyFilters = (
  ~currentFilterDict,
  ~defaultFilters,
  ~setOffset,
  ~path,
  ~existingFilterDict,
  ~options,
  ~ignoreUrlUpdate=false,
  ~setLocalSearchFilters=?,
  ~tableName,
  ~updateUrlWith=?,
  (),
) => {
  let dict = Dict.make()

  let currentFilterUrl = generateUrlFromDict(~dict=currentFilterDict, ~options, tableName)

  let existingFilterUrl = generateUrlFromDict(~dict=existingFilterDict, ~options, tableName)
  switch defaultFilters->Js.Json.decodeObject {
  | Some(originalDict) =>
    originalDict
    ->Dict.toArray
    ->Array.forEach(entry => {
      let (key, value) = entry
      Dict.set(dict, key, value)
    })
  | None => ()
  }
  switch setOffset {
  | Some(fn) => fn(_ => 0)
  | None => ()
  }

  let (localSearchUrl, localSearchDict) = if (
    existingFilterUrl->String.length > 0 && currentFilterUrl->String.length > 0
  ) {
    (
      `${existingFilterUrl}&${currentFilterUrl}`,
      Dict.fromArray(
        Array.concat(existingFilterDict->Dict.toArray, currentFilterDict->Dict.toArray),
      ),
    )
  } else if existingFilterUrl->String.length > 0 {
    (existingFilterUrl, existingFilterDict)
  } else if currentFilterUrl->String.length > 0 {
    (currentFilterUrl, currentFilterDict)
  } else {
    ("", Dict.make())
  }

  if ignoreUrlUpdate {
    switch setLocalSearchFilters {
    | Some(fn) => fn(_ => localSearchUrl)
    | _ => ()
    }
  } else {
    let finalCompleteUrl = localSearchUrl->String.length > 0 ? `${path}?${localSearchUrl}` : path
    switch updateUrlWith {
    | Some(fn) =>
      fn(
        localSearchDict
        ->Dict.toArray
        ->Array.map(item => {
          let (key, value) = item
          (key, getStrFromJson(key, value))
        })
        ->Dict.fromArray,
      )
    | None => RescriptReactRouter.push(finalCompleteUrl)
    }
  }
}
