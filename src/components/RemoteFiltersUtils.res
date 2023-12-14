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

  let filterDict = Js.Dict.empty()
  switch filterJson->Js.Json.decodeObject {
  | Some(dict) => {
      // Hack for admin service config entity
      let allowedDefaultKeys = if dict->Js.Dict.get("sourceObject")->Js.Option.isSome {
        Js.Dict.keys(dict)
      } else {
        defaultKeysAllowed
      }
      // Hack for orders entity
      dict
      ->Js.Dict.entries
      ->Js.Array2.forEach(entry => {
        let (key, val) = entry
        if Js.Array2.includes(allowedDefaultKeys, key) {
          filterDict->Js.Dict.set(key, val)
        }
      })
    }

  | None => ()
  }

  unflattenDict
  ->Js.Dict.entries
  ->Js.Array2.forEach(entry => {
    let (key, val) = entry

    let parser = switch options->Js.Array2.find(option => {
      option.urlKey === key
    }) {
    | Some(selectedOption) => selectedOption.parser
    | None => x => x
    }

    filterDict->Js.Dict.set(key, parser(val))

    let val = switch urlKeyTypeDict->Js.Dict.entries->Array.find(((urlKey, _)) => key === urlKey) {
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
    filterDict->Js.Dict.set(key, val)
  })

  if filterDict->Js.Dict.keys->Js.Array2.length === 0 {
    filterJson
  } else {
    if dropdownSearchKeyValueNames->Js.Array2.length === 2 {
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
          let isformat = searchkeysDict !== Js.Dict.empty()
          let value = if isformat {
            let intSearchKeys = searchkeysDict->LogicUtils.getArrayFromDict("intSearchKeys", [])
            let arrSearchKeys = searchkeysDict->LogicUtils.getArrayFromDict("arrSearchKeys", [])
            if intSearchKeys->Js.Array2.includes(key->Js.Json.string) {
              value->LogicUtils.getFloatFromString(0.00)->Js.Json.number
            } else if arrSearchKeys->Js.Array2.includes(key->Js.Json.string) {
              value->Js.String2.split(",")->Js.Array2.map(str => str->Js.Json.string)->Js.Json.array
            } else {
              value->Js.Json.string
            }
          } else {
            value->Js.Json.string
          }
          filterDict->Js.Dict.set(key, value)
        }
      } else {
        let key =
          filterDict
          ->LogicUtils.getArrayFromDict(
            dropdownSearchKeyValueNames[0]->Belt.Option.getWithDefault(""),
            [],
          )
          ->Js.Array2.map(item => item->LogicUtils.getStringFromJson("")->LogicUtils.toCamelCase)
        let value =
          filterDict
          ->LogicUtils.getString(dropdownSearchKeyValueNames[1]->Belt.Option.getWithDefault(""), "")
          ->Js.String2.split(", ")
        value->Js.Array2.forEachi((value, indx) => {
          let key = key->Js.Array2.length > indx ? key[indx]->Belt.Option.getWithDefault("") : ""
          if value !== "" && key != "" {
            let isformat = searchkeysDict !== Js.Dict.empty()
            let value = if isformat {
              let intSearchKeys = searchkeysDict->LogicUtils.getArrayFromDict("intSearchKeys", [])
              let arrSearchKeys = searchkeysDict->LogicUtils.getArrayFromDict("arrSearchKeys", [])
              if intSearchKeys->Js.Array2.includes(key->Js.Json.string) {
                value->LogicUtils.getFloatFromString(0.00)->Js.Json.number
              } else if arrSearchKeys->Js.Array2.includes(key->Js.Json.string) {
                value
                ->Js.String2.split(",")
                ->Js.Array2.map(str => str->Js.Json.string)
                ->Js.Json.array
              } else {
                value->Js.Json.string
              }
            } else {
              value->Js.Json.string
            }
            filterDict->Js.Dict.set(key, value)
          }
        })
      }
    }
    if isEulerOrderEntity {
      let arr = if filterDict->Js.Dict.get("customerId")->Js.Option.isSome {
        [["date_created", "DESC"]->Js.Json.stringArray]
      } else {
        []
      }
      filterDict->Js.Dict.set("order", arr->Js.Json.array)
    }

    filterDict->Js.Json.object_
  }
}

let getStrFromJson = (key, val) => {
  switch val->Js.Json.classify {
  | JSONString(str) => str
  | JSONArray(array) => array->Js.Array2.length > 0 ? `[${array->Js.Array2.joinWith(",")}]` : ""
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
  let initialFilters = initialFilters->Js.Array2.map(item => item.field)
  let dict = Js.Dict.empty()
  let searchParams = searchParams->LogicUtils.stringReplaceAll("%20", " ")
  if Js.String.length(searchParams) > 0 {
    let splitUrlArray = Js.String2.split(searchParams, "&")
    let entriesList = []
    let keyList = []
    let valueList = []

    splitUrlArray->Js.Array2.forEach(filterKeyVal => {
      let splitArray = Js.String2.split(filterKeyVal, "=")
      let keyStartIndex =
        Js.String2.lastIndexOf(splitArray[0]->Belt.Option.getWithDefault(""), "-") + 1
      let key = Js.String2.sliceToEnd(
        splitArray[0]->Belt.Option.getWithDefault(""),
        ~from=keyStartIndex,
      )
      Js.Array2.push(keyList, key)->ignore
      splitArray->Js.Array2.shift->ignore
      let value = splitArray->Js.Array2.joinWith("=")
      Js.Array2.push(valueList, value)->ignore

      entriesList->Js.Array2.push((key, value))->ignore
    })
    entriesList->Js.Array2.forEach(entry => {
      let (key, value) = entry
      initialFilters->Js.Array2.forEach((filter: FormRenderer.fieldInfoType) => {
        filter.inputNames->Js.Array2.forEach(
          name => {
            if name === key {
              Js.Dict.set(dict, key, value->UrlFetchUtils.getFilterValue)
            }
          },
        )
      })

      options->Js.Array2.forEach(option => {
        let fieldName = option.urlKey
        if fieldName === key {
          Js.Dict.set(dict, key, value->UrlFetchUtils.getFilterValue)
        }
      })

      mandatoryRemoteKeys->Js.Array2.forEach(searchKey => {
        if searchKey === key {
          Js.Dict.set(dict, key, value->UrlFetchUtils.getFilterValue)
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
  ~dateRangeFilterDict: Js.Dict.t<Js.Json.t>,
  ~options: array<EntityType.optionType<'t>>,
  (),
) => {
  let res = ref(resArr)
  if Js.String2.length(searchParams) > 0 {
    let splitUrlArray = Js.String2.split(searchParams, "&")
    let keyList = []
    let valueList = []
    splitUrlArray->Js.Array2.forEach(filterKeyVal => {
      let splitArray = Js.String2.split(filterKeyVal, "=")
      let keyStartIndex =
        Js.String2.lastIndexOf(splitArray[0]->Belt.Option.getWithDefault(""), `-`) + 1
      let key = Js.String2.sliceToEnd(
        splitArray[0]->Belt.Option.getWithDefault(""),
        ~from=keyStartIndex,
      )
      Js.Array2.push(keyList, key)->ignore
      Js.Array2.push(valueList, splitArray[1]->Belt.Option.getWithDefault(""))->ignore
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
      dateRangeFilterDict != Js.Dict.empty() &&
      startKey != "" &&
      endKey != "" &&
      keyList->Js.Array2.includes(startKey) &&
      keyList->Js.Array2.includes(endKey)
    ) {
      let start_Date =
        valueList[keyList->Js.Array2.indexOf(startKey)]->Belt.Option.getWithDefault("")
      let end_Date = valueList[keyList->Js.Array2.indexOf(endKey)]->Belt.Option.getWithDefault("")
      let keyList = keyList->Js.Array2.filter(item => item != startKey && item != endKey)
      let valueList = valueList->Js.Array2.filter(item => item != start_Date && item != end_Date)
      keyList->Js.Array2.push(startKey)->ignore
      valueList->Js.Array2.push(`${start_Date}&${end_Date}`)->ignore
      (keyList, valueList)
    } else {
      (keyList, valueList)
    }

    keyList->Js.Array2.forEachi((key, idx) => {
      initialFilters->Js.Array2.forEach(filter => {
        let field: FormRenderer.fieldInfoType = filter.field
        let localFilter = filter.localFilter
        field.inputNames->Js.Array2.forEach(
          name => {
            if name === key {
              let value = valueList[idx]->Belt.Option.getWithDefault("")
              if Js.String2.includes(value, "[") {
                let str = Js.String2.slice(~from=1, ~to_=value->Js.String2.length - 1, value)
                let splitArray = Js.String2.split(str, ",")
                let jsonarr = splitArray->Js.Array2.map(val => Js.Json.string(val))
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

      options->Js.Array2.forEach(option => {
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
  ->Js.Dict.entries
  ->Belt.Array.keepMap(entry => {
    let (key, val) = entry

    let strValue = getStrFromJson(key, val)
    if strValue !== "" {
      let requiredOption = options->Js.Array2.find(option => option.urlKey === key)
      switch requiredOption {
      | Some(option) => {
          let finalVal = option.parser(val)
          Js.Dict.set(dict, key, finalVal)
        }

      | None => Js.Dict.set(dict, key, val)
      }
      let finalKey = switch tableName {
      | Some(val) => val->Js.String2.concat(`-${key}`)
      | None => key
      }
      Some(`${finalKey}=${strValue}`)
    } else {
      None
    }
  })
  ->Js.Array2.joinWith("&")
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
  let dict = Js.Dict.empty()

  let currentFilterUrl = generateUrlFromDict(~dict=currentFilterDict, ~options, tableName)

  let existingFilterUrl = generateUrlFromDict(~dict=existingFilterDict, ~options, tableName)
  switch defaultFilters->Js.Json.decodeObject {
  | Some(originalDict) =>
    originalDict
    ->Js.Dict.entries
    ->Js.Array2.forEach(entry => {
      let (key, value) = entry
      Js.Dict.set(dict, key, value)
    })
  | None => ()
  }
  switch setOffset {
  | Some(fn) => fn(_ => 0)
  | None => ()
  }

  let (localSearchUrl, localSearchDict) = if (
    existingFilterUrl->Js.String2.length > 0 && currentFilterUrl->Js.String2.length > 0
  ) {
    (
      `${existingFilterUrl}&${currentFilterUrl}`,
      Js.Dict.fromArray(
        Js.Array2.concat(existingFilterDict->Js.Dict.entries, currentFilterDict->Js.Dict.entries),
      ),
    )
  } else if existingFilterUrl->Js.String2.length > 0 {
    (existingFilterUrl, existingFilterDict)
  } else if currentFilterUrl->Js.String2.length > 0 {
    (currentFilterUrl, currentFilterDict)
  } else {
    ("", Js.Dict.empty())
  }

  if ignoreUrlUpdate {
    switch setLocalSearchFilters {
    | Some(fn) => fn(_ => localSearchUrl)
    | _ => ()
    }
  } else {
    let finalCompleteUrl =
      localSearchUrl->Js.String2.length > 0 ? `${path}?${localSearchUrl}` : path
    switch updateUrlWith {
    | Some(fn) =>
      fn(
        localSearchDict
        ->Js.Dict.entries
        ->Js.Array2.map(item => {
          let (key, value) = item
          (key, getStrFromJson(key, value))
        })
        ->Js.Dict.fromArray,
      )
    | None => RescriptReactRouter.push(finalCompleteUrl)
    }
  }
}
