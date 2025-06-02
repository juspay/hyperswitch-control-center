open LogicUtils
open AnalyticsTypes

let getTopLevelFilterFromDict = (filterValueDict, moduleName) => {
  filterValueDict
  ->Dict.toArray
  ->Belt.Array.keepMap(item => {
    let (key, value) = item
    let keyArr = key->String.split(".")
    let prefix = keyArr->Array.get(0)->Option.getOr("")
    if prefix === moduleName && prefix->LogicUtils.isNonEmptyString {
      None
    } else {
      Some((prefix, value))
    }
  })
  ->Dict.fromArray
}

let getTopFiltersToSearchParam = (getTopLevelFilter, allFilterKeys) => {
  let filterSearchParam =
    getTopLevelFilter
    ->Dict.toArray
    ->Belt.Array.keepMap(entry => {
      let (key, value) = entry
      if allFilterKeys->Array.includes(key) {
        switch value->JSON.Classify.classify {
        | String(str) => `${key}=${str}`->Some
        | Number(num) => `${key}=${num->String.make}`->Some
        | Array(arr) => `${key}=[${arr->String.make}]`->Some
        | _ => None
        }
      } else {
        None
      }
    })
    ->Array.joinWith("&")

  filterSearchParam
}

let getFilterValueFromUrl = (getTopLevelFilter, filterKeys) => {
  getTopLevelFilter
  ->Dict.toArray
  ->Belt.Array.keepMap(entries => {
    let (key, value) = entries
    filterKeys->Array.includes(key) ? Some((key, value)) : None
  })
  ->Dict.fromArray
  ->JSON.Encode.object
  ->Some
}

let parseData = json => {
  let data = json->getDictFromJsonObject
  let value = data->getJsonObjectFromDict("queryData")->getArrayFromJson([])
  value
}

let generateIDFromKeys = (keys, dict) => {
  keys
  ->Option.getOr([])
  ->Array.map(key => {
    dict->Dict.get(key)
  })
  ->Array.joinWithUnsafe("")
}

let getUpdatedData = (data, weeklyData, cols, activeTab, getTable) => {
  let dataArr = data->parseData
  let weeklyArr = weeklyData->parseData

  dataArr
  ->Array.map(item => {
    let dataDict = item->getDictFromJsonObject
    let dataKey = activeTab->generateIDFromKeys(dataDict)

    weeklyArr->Array.forEach(newItem => {
      let weekklyDataDict = newItem->getDictFromJsonObject
      let weekklyDataKey = activeTab->generateIDFromKeys(weekklyDataDict)

      if dataKey === weekklyDataKey {
        cols->Array.forEach(
          obj => {
            switch weekklyDataDict->Dict.get(obj.refKey) {
            | Some(val) => dataDict->Dict.set(obj.newKey, val)
            | _ => ()
            }
          },
        )
      }
    })
    dataDict->JSON.Encode.object
  })
  ->JSON.Encode.array
  ->getTable
  ->Array.map(Nullable.make)
}

let getNewDefaultCols = (activeTab, defaultColumns, allColumns, getHeadingFn) => {
  activeTab
  ->Option.getOr([])
  ->Belt.Array.keepMap(item => {
    defaultColumns
    ->Belt.Array.keepMap(columnItem => {
      let val = columnItem->getHeadingFn
      val.key === item ? Some(columnItem) : None
    })
    ->Array.get(0)
  })
  ->Array.concat(allColumns)
}

let getNewAllCols = (defaultColumns, activeTab, allColumns, getHeadingFn) => {
  defaultColumns
  ->Belt.Array.keepMap(item => {
    let val = item->getHeadingFn
    activeTab->Option.getOr([])->Array.includes(val.key) ? Some(item) : None
  })
  ->Array.concat(allColumns)
}

let tableBorderClass = "border-collapse border border-jp-gray-940 border-solid border-2 rounded-md border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30 mt-7"
