open LogicUtils

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
  switch filterJson->JSON.Decode.object {
  | Some(dict) => {
      // Hack for admin service config entity
      let allowedDefaultKeys = if dict->Dict.get("sourceObject")->Option.isSome {
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
        | Boolean => ele->getBoolFromString(false)->JSON.Encode.bool
        | Float => ele->getFloatFromString(0.)->JSON.Encode.float
        | Int => ele->getIntFromString(0)->Int.toFloat->JSON.Encode.float
        }
      }
      switch val->JSON.Classify.classify {
      | Array(stringValueArr) =>
        stringValueArr
        ->Array.map(ele => {
          getExpectedType(ele->JSON.Decode.string->Option.getOr(""))
        })
        ->JSON.Encode.array
      | String(ele) => getExpectedType(ele)
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
          filterDict->getString(dropdownSearchKeyValueNames[0]->Option.getOr(""), "")->toCamelCase
        let value = filterDict->getString(dropdownSearchKeyValueNames[1]->Option.getOr(""), "")
        if value->isNonEmptyString {
          let isformat = searchkeysDict !== Dict.make()
          let value = if isformat {
            let intSearchKeys = searchkeysDict->getArrayFromDict("intSearchKeys", [])
            let arrSearchKeys = searchkeysDict->getArrayFromDict("arrSearchKeys", [])
            if intSearchKeys->Array.includes(key->JSON.Encode.string) {
              value->getFloatFromString(0.00)->JSON.Encode.float
            } else if arrSearchKeys->Array.includes(key->JSON.Encode.string) {
              value->String.split(",")->Array.map(str => str->JSON.Encode.string)->JSON.Encode.array
            } else {
              value->JSON.Encode.string
            }
          } else {
            value->JSON.Encode.string
          }
          filterDict->Dict.set(key, value)
        }
      } else {
        let key =
          filterDict
          ->getArrayFromDict(dropdownSearchKeyValueNames[0]->Option.getOr(""), [])
          ->Array.map(item => item->getStringFromJson("")->toCamelCase)
        let value =
          filterDict
          ->getString(dropdownSearchKeyValueNames[1]->Option.getOr(""), "")
          ->String.split(", ")
        value->Array.forEachWithIndex((value, indx) => {
          let key = key->Array.length > indx ? key[indx]->Option.getOr("") : ""
          if value->isNonEmptyString && key->isNonEmptyString {
            let isformat = searchkeysDict !== Dict.make()
            let value = if isformat {
              let intSearchKeys = searchkeysDict->getArrayFromDict("intSearchKeys", [])
              let arrSearchKeys = searchkeysDict->getArrayFromDict("arrSearchKeys", [])
              if intSearchKeys->Array.includes(key->JSON.Encode.string) {
                value->getFloatFromString(0.00)->JSON.Encode.float
              } else if arrSearchKeys->Array.includes(key->JSON.Encode.string) {
                value
                ->String.split(",")
                ->Array.map(str => str->JSON.Encode.string)
                ->JSON.Encode.array
              } else {
                value->JSON.Encode.string
              }
            } else {
              value->JSON.Encode.string
            }
            filterDict->Dict.set(key, value)
          }
        })
      }
    }
    if isEulerOrderEntity {
      let arr = if filterDict->Dict.get("customerId")->Option.isSome {
        [["date_created", "DESC"]->getJsonFromArrayOfString]
      } else {
        []
      }
      filterDict->Dict.set("order", arr->JSON.Encode.array)
    }

    filterDict->JSON.Encode.object
  }
}

let getStrFromJson = (key, val) => {
  switch val->JSON.Classify.classify {
  | String(str) => str
  | Array(array) => array->Array.length > 0 ? `[${array->Array.joinWithUnsafe(",")}]` : ""
  | Number(num) => key === "offset" ? "0" : num->Float.toInt->Int.toString
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
  let searchParams = searchParams->stringReplaceAll("%20", " ")
  if String.length(searchParams) > 0 {
    let splitUrlArray = String.split(searchParams, "&")
    let entriesList = []
    let keyList = []
    let valueList = []

    splitUrlArray->Array.forEach(filterKeyVal => {
      let splitArray = String.split(filterKeyVal, "=")
      let keyStartIndex = String.lastIndexOf(splitArray[0]->Option.getOr(""), "-") + 1
      let key = String.sliceToEnd(splitArray[0]->Option.getOr(""), ~start=keyStartIndex)
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
  JSON.Encode.object(dict)
}

let getLocalFiltersData = (
  ~resArr: array<Nullable.t<'t>>,
  ~searchParams,
  ~initialFilters: array<EntityType.initialFilters<'t>>,
  ~dateRangeFilterDict: Dict.t<JSON.t>,
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
      let keyStartIndex = String.lastIndexOf(splitArray[0]->Option.getOr(""), `-`) + 1
      let key = String.sliceToEnd(splitArray[0]->Option.getOr(""), ~start=keyStartIndex)
      Array.push(keyList, key)->ignore
      Array.push(valueList, splitArray[1]->Option.getOr(""))->ignore
    })

    let dateRange = dateRangeFilterDict->getArrayFromDict("dateRange", [])
    let startKey =
      dateRange->Array.get(0)->Option.getOr(""->JSON.Encode.string)->getStringFromJson("")
    let endKey =
      dateRange->Array.get(1)->Option.getOr(""->JSON.Encode.string)->getStringFromJson("")

    let (keyList, valueList) = if (
      dateRangeFilterDict != Dict.make() &&
      startKey->isNonEmptyString &&
      endKey->isNonEmptyString &&
      keyList->Array.includes(startKey) &&
      keyList->Array.includes(endKey)
    ) {
      let start_Date = valueList[keyList->Array.indexOf(startKey)]->Option.getOr("")
      let end_Date = valueList[keyList->Array.indexOf(endKey)]->Option.getOr("")
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
              let value = valueList[idx]->Option.getOr("")
              if String.includes(value, "[") {
                let str = String.slice(~start=1, ~end=value->String.length - 1, value)
                let splitArray = String.split(str, ",")
                let jsonarr = splitArray->Array.map(val => JSON.Encode.string(val))
                res.contents = switch localFilter {
                | Some(localFilter) => localFilter(res.contents, JSON.Encode.array(jsonarr))
                | None => res.contents
                }
              } else {
                res.contents = switch localFilter {
                | Some(localFilter) => localFilter(res.contents, JSON.Encode.string(value))
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
            localFilter(res.contents, JSON.Encode.string(valueList[idx]->Option.getOr("")))
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
    if strValue->isNonEmptyString {
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
  switch defaultFilters->JSON.Decode.object {
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
    existingFilterUrl->isNonEmptyString && currentFilterUrl->isNonEmptyString
  ) {
    (
      `${existingFilterUrl}&${currentFilterUrl}`,
      Dict.fromArray(
        Array.concat(existingFilterDict->Dict.toArray, currentFilterDict->Dict.toArray),
      ),
    )
  } else if existingFilterUrl->isNonEmptyString {
    (existingFilterUrl, existingFilterDict)
  } else if currentFilterUrl->isNonEmptyString {
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
    let finalCompleteUrl = localSearchUrl->isNonEmptyString ? `${path}?${localSearchUrl}` : path
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
