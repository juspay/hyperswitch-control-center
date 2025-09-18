open LogicUtils
open NewAnalyticsTypes

let redColor = "#BA3535"
let blue = "#1059C1B2"
let green = "#0EB025B2"
let barGreenColor = "#7CC88F"
let sankyBlue = "#E4EFFF"
let sankyRed = "#F7E0E0"
let sankyLightBlue = "#91B7EE"
let sankyLightRed = "#EC6262"
let coralRed = "#FF6B6B"
let turquoise = "#4ECDC4"
let skyBlue = "#45B7D1"
let mintGreen = "#96CEB4"
let lightYellow = "#FFEAA7"
let plum = "#DDA0DD"
let seafoam = "#98D8C8"
let goldenYellow = "#F7DC6F"
let lightPurple = "#BB8FCE"
let lightBlue = "#85C1E9"
let peach = "#F8C471"
let lightGreen = "#82E0AA"
let salmon = "#F1948A"
let powderBlue = "#AED6F1"
let lavender = "#D7BDE2"

let getGranularityLabel = option => {
  switch option {
  | #G_ONEDAY => "Day-wise"
  | #G_ONEHOUR => "Hour-wise"
  | #G_THIRTYMIN => "30min-wise"
  | #G_FIFTEENMIN => "15min-wise"
  }
}

let defaulGranularity = {
  label: #G_ONEDAY->getGranularityLabel,
  value: (#G_ONEDAY: NewAnalyticsTypes.granularity :> string),
}

let getGranularityOptions = (~startTime, ~endTime) => {
  let startingPoint = startTime->DayJs.getDayJsForString
  let endingPoint = endTime->DayJs.getDayJsForString
  let gap = endingPoint.diff(startingPoint.toString(), "hour") // diff between points

  let options = if gap < 1 {
    [#G_THIRTYMIN, #G_FIFTEENMIN]
  } else if gap < 24 {
    [#G_ONEHOUR, #G_THIRTYMIN, #G_FIFTEENMIN]
  } else if gap < 168 {
    [#G_ONEDAY, #G_ONEHOUR]
  } else {
    [#G_ONEDAY]
  }

  options->Array.map(option => {
    label: option->getGranularityLabel,
    value: (option: NewAnalyticsTypes.granularity :> string),
  })
}

let getDefaultGranularity = (~startTime, ~endTime, ~granularity) => {
  let options = getGranularityOptions(~startTime, ~endTime)
  if granularity {
    options->Array.get(options->Array.length - 1)->Option.getOr(defaulGranularity)
  } else {
    defaulGranularity
  }
}

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
      granularity == (#G_FIFTEENMIN: NewAnalyticsTypes.granularity :> string)
  ) {
    "YYYY-MM-DD HH:mm:ss"
  } else if granularity == (#G_ONEDAY: NewAnalyticsTypes.granularity :> string) {
    "YYYY-MM-DD 00:00:00"
  } else {
    // granularity at hour wise
    "YYYY-MM-DD HH:00:00"
  }
}

let formatTimeString = time => {
  let hour =
    time->String.split(":")->Array.get(0)->Option.getOr("00")->Int.fromString->Option.getOr(0)
  let mimute =
    time->String.split(":")->Array.get(1)->Option.getOr("00")->Int.fromString->Option.getOr(0)

  let newHour = Int.mod(hour, 12)
  let newHour = newHour == 0 ? 12 : newHour

  let period = hour >= 12 ? "PM" : "AM"

  if mimute > 0 {
    `${newHour->Int.toString}:${mimute->Int.toString} ${period}`
  } else {
    `${newHour->Int.toString} ${period}`
  }
}

let formatTime = (
  ~itemDict,
  ~granularityEnabled: bool,
  ~granularity: string,
  ~isoStringToCustomTimeZone: string => TimeZoneHook.dateTimeString,
  ~timeKey,
) => {
  if granularityEnabled {
    let rangeObj = itemDict->getObj("time_range", Dict.make())
    let time = rangeObj->getString("start_time", "")
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
  ~granularityEnabled: bool,
  ~granularity: string,
  ~isoStringToCustomTimeZone: string => TimeZoneHook.dateTimeString,
  ~timeKey,
) => {
  let dataDict = Dict.make()
  data->Array.forEach(item => {
    let itemDict = item->getDictFromJsonObject
    let time = formatTime(
      ~itemDict,
      ~granularityEnabled,
      ~granularity,
      ~isoStringToCustomTimeZone,
      ~timeKey,
    )
    let newItem = item->getDictFromJsonObject
    // update the time bucket in the dict
    newItem->Dict.set(timeKey, time->JSON.Encode.string)
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
let sortQueryDataByDate = query => {
  query->Array.sort((a, b) => {
    let valueA = a->getDictFromJsonObject->getString("time_bucket", "")
    let valueB = b->getDictFromJsonObject->getString("time_bucket", "")
    compareLogic(valueB, valueA)
  })
  query
}

let getColor = index => {
  [
    blue,
    green,
    coralRed,
    turquoise,
    skyBlue,
    mintGreen,
    lightYellow,
    plum,
    seafoam,
    goldenYellow,
    lightPurple,
    lightBlue,
    peach,
    lightGreen,
    salmon,
    powderBlue,
    lavender,
  ]
  ->Array.get(index)
  ->Option.getOr(blue)
}

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

let checkTimePresent = (options, key) => {
  options->Array.reduce(false, (flag, item) => {
    let value = item->getDictFromJsonObject->getString(key, "NA")
    if value->isNonEmptyString && key == "time_bucket" {
      let dateObj = value->DayJs.getDayJsForString
      dateObj.format("HH") != "00" || flag
    } else {
      false
    }
  })
}

let getAmountValue = (data, ~id) => {
  switch data->getOptionFloat(id) {
  | Some(value) => value /. 100.0
  | _ => 0.0
  }
}

let getLineGraphObj = (
  ~array: array<JSON.t>,
  ~key: string,
  ~name: string,
  ~color,
  ~isAmount=false,
): LineGraphTypes.dataObj => {
  let data = array->Array.map(item => {
    let dict = item->getDictFromJsonObject
    if isAmount {
      dict->getAmountValue(~id=key)
    } else {
      dict->getFloat(key, 0.0)
    }
  })
  let dataObj: LineGraphTypes.dataObj = {
    showInLegend: true,
    name,
    data,
    color,
  }
  dataObj
}

let formatDateValue = (value: string, ~includeYear=false) => {
  let dateObj = value->DayJs.getDayJsForString

  if includeYear {
    `${dateObj.month()->getMonthName} ${dateObj.format("DD")} ${dateObj.year()->Int.toString} `
  } else {
    `${dateObj.month()->getMonthName} ${dateObj.format("DD")}`
  }
}
let getLabelName = (~key, ~index, ~points) => {
  let getDateObject = (array, index) => {
    array
    ->getValueFromArray(index, Dict.make()->JSON.Encode.object)
    ->getDictFromJsonObject
    ->getString(key, "")
  }

  if key === "time_bucket" {
    let pointsArray = points->getArrayFromJson([])
    let startPoint = pointsArray->getDateObject(0)
    let endPoint = pointsArray->getDateObject(pointsArray->Array.length - 1)

    let startDate = startPoint->formatDateValue
    let endDate = endPoint->formatDateValue
    `${startDate} - ${endDate}`
  } else {
    `Series ${(index + 1)->Int.toString}`
  }
}
