open LogicUtils

let getMonthName = month => {
  switch month {
  | 0 => "Jan"
  | 1 => "Feb"
  | 2 => "Mar"
  | 3 => "Apr"
  | 4 => "May"
  | 5 => "Jun"
  | 6 => "Jul"
  | 7 => "Aug"
  | 8 => "Sep"
  | 9 => "Oct"
  | 10 => "Nov"
  | 11 => "Dec"
  | _ => ""
  }
}

let getCategoriesV2 = (data: array<JSON.t>, key: string) => {
  data->Array.map(item => {
    let value = item->getDictFromJsonObject->getString(key, "")

    if value->LogicUtils.isNonEmptyString && key == "time_bucket" {
      let dateObj = value->DayJs.getDayJsForString
      `${dateObj.month()->getMonthName} ${dateObj.format("DD")}`
    } else {
      value
    }
  })
}

let getCategories = (json: JSON.t, key: string): array<string> => {
  json
  ->getArrayFromJson([])
  ->Array.flatMap(item => {
    item
    ->getDictFromJsonObject
    ->getArrayFromDict("queryData", [])
    ->Array.map(item => {
      let value = item->getDictFromJsonObject->getString(key, "")

      if value->LogicUtils.isNonEmptyString && key == "time_bucket" {
        let dateObj = value->DayJs.getDayJsForString
        `${dateObj.month()->getMonthName} ${dateObj.format("DD")}`
      } else {
        value
      }
    })
  })
}

let getColor = index => {
  ["#1059C1B2", "#0EB025B2"]->Array.get(index)->Option.getOr("#1059C1B2")
}

let getLineGraphObj = (
  ~array: array<JSON.t>,
  ~key: string,
  ~name: string,
  ~color,
): LineGraphTypes.dataObj => {
  let data = array->Array.map(item => {
    item->getDictFromJsonObject->getInt(key, 0)
  })
  let dataObj: LineGraphTypes.dataObj = {
    showInLegend: false,
    name: `${name}`,
    data,
    color,
  }
  dataObj
}

let getBarGraphData = (json: JSON.t, key: string): BarGraphTypes.data => {
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
      color: "#7CC88F",
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
