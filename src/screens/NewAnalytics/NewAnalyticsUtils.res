open LogicUtils

let getGranularityGap = option => {
  switch option {
  | "G_ONEHOUR" => 60
  | "G_THIRTYMIN" => 30
  | "G_FIFTEENMIN" => 15
  | "G_ONEDAY" | _ => 1440
  }
}

let getFormat = (~granularity) => {
  if (
    granularity == (#G_THIRTYMIN: NewAnalyticsTypes.granularity :> string) ||
    granularity == (#G_FIFTEENMIN: NewAnalyticsTypes.granularity :> string) ||
    granularity == (#G_ONEDAY: NewAnalyticsTypes.granularity :> string)
  ) {
    "YYYY-MM-DD HH:mm:ss"
  } else {
    "YYYY-MM-DD HH:00:00"
  }
}

let formatTime = (
  itemDict,
  granularityEnabled: bool,
  granularity: string,
  isoStringToCustomTimeZone: string => TimeZoneHook.dateTimeString,
  dataKey,
  timeKey: string,
) => {
  if granularityEnabled && granularity != (#G_ONEDAY: NewAnalyticsTypes.granularity :> string) {
    let rangeObj = itemDict->getObj(dataKey, Dict.make())
    let time = rangeObj->getString(timeKey, "")
    let {year, month, date, hour, minute} = isoStringToCustomTimeZone(time)

    let baseTime = `${year}-${month}-${date} ${hour}:${minute}`->DayJs.getDayJsForString
    let format = getFormat(~granularity)
    baseTime.format(format)
  } else {
    itemDict->getString(timeKey, "")
  }
}

let extractTimeDict = (
  ~data: array<JSON.t>,
  ~dataKey: string,
  ~granularityEnabled: bool,
  ~granularity: string,
  ~isoStringToCustomTimeZone: string => TimeZoneHook.dateTimeString,
  ~timeKey: string,
) => {
  let dataDict = Dict.make()
  data->Array.forEach(item => {
    let itemDict = item->getDictFromJsonObject

    let time = formatTime(
      itemDict,
      granularityEnabled,
      granularity,
      isoStringToCustomTimeZone,
      dataKey,
      timeKey,
    )
    let newItem = item->getDictFromJsonObject
    // update the time bucket in the dict
    newItem->Dict.set("time_bucket", time->JSON.Encode.string)

    dataDict->Dict.set(time, newItem->JSON.Encode.object)
  })
  dataDict
}

let fillForMissingTimeRange = (
  ~existingTimeDict,
  ~timeKey: string,
  ~defaultValue: JSON.t,
  ~startDate,
  ~endDate,
  ~granularity,
) => {
  let startingPoint = startDate->DayJs.getDayJsForString
  let startingPoint = startingPoint.format("YYYY-MM-DD HH:00:00")->DayJs.getDayJsForString
  let endingPoint = endDate->DayJs.getDayJsForString
  let gap = "minute"
  let devider = granularity->getGranularityGap
  let limit =
    (endingPoint.diff(startingPoint.toString(), gap)->Int.toFloat /. devider->Int.toFloat)
    ->Math.floor
    ->Float.toInt
  let format = getFormat(~granularity)
  let dataPoints = Dict.make()
  let _ = Belt.Array.range(0, limit)->Array.map(x => {
    let newDict = defaultValue->getDictFromJsonObject->Dict.copy
    let timeVal = startingPoint.add(x * devider, gap).format(format)

    switch existingTimeDict->Dict.get(timeVal) {
    | Some(val) => {
        newDict->Dict.set(timeKey, timeVal->JSON.Encode.string)
        dataPoints->Dict.set(timeVal, val)
      }
    | None => {
        newDict->Dict.set(timeKey, timeVal->JSON.Encode.string)
        dataPoints->Dict.set(timeVal, newDict->JSON.Encode.object)
      }
    }
  })

  dataPoints
}
