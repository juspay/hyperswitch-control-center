open LogicUtils

let getCategories = (json: JSON.t, key: string): array<string> => {
  json
  ->getArrayFromJson([])
  ->Array.flatMap(item => {
    item
    ->getDictFromJsonObject
    ->getArrayFromDict("queryData", [])
    ->Array.map(item => item->getDictFromJsonObject->getString(key, ""))
  })
}

let getColor = index => {
  ["#1059C1B2", "#0EB025B2"]->Array.get(index)->Option.getOr("#1059C1B2")
}

let getLineGraphData = (json: JSON.t, key: string): LineGraphTypes.data => {
  json
  ->getArrayFromJson([])
  ->Array.mapWithIndex((item, index) => {
    let data =
      item
      ->getDictFromJsonObject
      ->getArrayFromDict("queryData", [])
      ->Array.map(item => {
        item->getDictFromJsonObject->getInt(key, 0)
      })

    let dataObj: LineGraphTypes.dataObj = {
      showInLegend: false,
      name: `Series ${(index + 1)->Int.toString}`,
      data,
      color: index->getColor,
    }
    dataObj
  })
}

let getBarGraphData = (json: JSON.t, key: string, barColor: string): BarGraphTypes.data => {
  json
  ->getArrayFromJson([])
  ->Array.mapWithIndex((item, index) => {
    let data =
      item
      ->getDictFromJsonObject
      ->getArrayFromDict("queryData", [])
      ->Array.map(item => {
        item->getDictFromJsonObject->getInt(key, 0)
      })
    let dataObj: BarGraphTypes.dataObj = {
      showInLegend: false,
      name: `Series ${(index + 1)->Int.toString}`,
      data,
      color: barColor,
    }
    dataObj
  })
}

let modifyDataWithMissingPoints = (
  ~data,
  ~key,
  ~startDate,
  ~endDate,
  ~defaultValue: JSON.t,
  ~timeKey="time_bucket",
  ~granularity,
) => {
  data->Array.map(response => {
    let dict = response->getDictFromJsonObject->Dict.copy
    let queryData = dict->getArrayFromDict(key, [])
    let modifiedData = NewAnalyticsUtils.fillMissingDataPoints(
      ~data=queryData,
      ~startDate,
      ~endDate,
      ~timeKey,
      ~defaultValue,
      ~granularity,
    )
    dict->Dict.set(key, modifiedData->JSON.Encode.array)
    dict
  })
}
