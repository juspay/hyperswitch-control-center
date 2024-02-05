type customDateRange =
  | Today
  | Tomorrow
  | Yesterday
  | ThisMonth
  | LastMonth
  | LastSixMonths
  | NextMonth
  | Hour(float)
  | Day(float)
let getDateString = (value, isoStringToCustomTimeZone: string => TimeZoneHook.dateTimeString) => {
  try {
    let {year, month, date} = isoStringToCustomTimeZone(value)
    `${year}-${month}-${date}`
  } catch {
  | _error => ""
  }
}
let getTimeString = (value, isoStringToCustomTimeZone: string => TimeZoneHook.dateTimeString) => {
  try {
    let {hour, minute} = isoStringToCustomTimeZone(value)
    `${hour}:${minute}:00`
  } catch {
  | _error => ""
  }
}
let getMins = (val: float) => {
  let mins = val *. 60.0

  mins->Float.toString
}
let getPredefinedStartAndEndDate = (
  todayDayJsObj: DayJs.dayJs,
  isoStringToCustomTimeZone: string => TimeZoneHook.dateTimeString,
  isoStringToCustomTimezoneInFloat: string => TimeZoneHook.dateTimeFloat,
  customTimezoneToISOString,
  value: customDateRange,
  disableFutureDates,
  disablePastDates,
  todayDate,
  todayTime,
) => {
  let lastMonth = todayDayJsObj.subtract(. 1, "month").endOf(. "month").toDate(.)
  let lastSixMonths = todayDayJsObj.toDate(.)
  let nextMonth = todayDayJsObj.add(. 1, "month").endOf(. "month").toDate(.)
  let yesterday = todayDayJsObj.subtract(. 1, "day").toDate(.)
  let tomorrow = todayDayJsObj.add(. 1, "day").toDate(.)
  let thisMonth = disableFutureDates
    ? todayDayJsObj.toDate(.)
    : todayDayJsObj.endOf(. "month").toDate(.)

  let customDate = switch value {
  | LastMonth => lastMonth
  | LastSixMonths => lastSixMonths
  | NextMonth => nextMonth
  | Yesterday => yesterday
  | Tomorrow => tomorrow
  | ThisMonth => thisMonth
  | _ => todayDayJsObj.toDate(.)
  }

  let daysInMonth =
    (customDate->DayJs.getDayJsForJsDate).endOf(. "month").toString(.)
    ->Date.fromString
    ->Js.Date.getDate
  let prevDate = (customDate->DayJs.getDayJsForJsDate).subtract(. 6, "month").toString(.)
  let daysInSixMonth = (customDate->DayJs.getDayJsForJsDate).diff(. prevDate, "day")->Int.toFloat
  let count = switch value {
  | Today => 1.0
  | Yesterday => 1.0
  | Tomorrow => 1.0
  | LastMonth => daysInMonth
  | LastSixMonths => daysInSixMonth
  | ThisMonth => customDate->Js.Date.getDate
  | NextMonth => daysInMonth
  | Day(val) => val
  | Hour(val) => val /. 24.0 +. 1.
  }

  let date =
    customTimezoneToISOString(
      String.make(customDate->Js.Date.getFullYear),
      String.make(customDate->Js.Date.getMonth +. 1.0),
      String.make(customDate->Js.Date.getDate),
      String.make(customDate->Js.Date.getHours),
      String.make(customDate->Js.Date.getMinutes),
      String.make(customDate->Js.Date.getSeconds),
    )->Date.fromString

  let todayInitial = date
  let today =
    todayInitial
    ->Date.toISOString
    ->isoStringToCustomTimezoneInFloat
    ->TimeZoneHook.dateTimeObjectToDate
  let msInADay = 24.0 *. 60.0 *. 60.0 *. 1000.0
  let durationSecs: float = (count -. 1.0) *. msInADay
  let dateBeforeDuration = today->Date.getTime->Js.Date.fromFloat
  let msInterval = disableFutureDates
    ? dateBeforeDuration->Date.getTime -. durationSecs
    : dateBeforeDuration->Date.getTime +. durationSecs
  let dateAfterDuration = msInterval->Js.Date.fromFloat

  let (finalStartDate, finalEndDate) = disableFutureDates
    ? (dateAfterDuration, dateBeforeDuration)
    : (dateBeforeDuration, dateAfterDuration)
  let startDate = getDateString(finalStartDate->Date.toString, isoStringToCustomTimeZone)
  let endDate = getDateString(finalEndDate->Date.toString, isoStringToCustomTimeZone)

  let endTime = {
    let eTime = switch value {
    | Hour(_) => getTimeString(finalEndDate->Date.toString, isoStringToCustomTimeZone)
    | _ => "23:59:59"
    }
    disableFutureDates && endDate == todayDate ? todayTime : eTime
  }
  let startTime = {
    let sTime = switch value {
    | Hour(_) => getTimeString(finalStartDate->Date.toString, isoStringToCustomTimeZone)
    | _ => "00:00:00"
    }
    !disableFutureDates && (value !== Today || disablePastDates) && startDate == todayDate
      ? todayTime
      : sTime
  }
  let stDate = startDate
  let enDate = endDate

  (stDate, enDate, startTime, endTime)
}
let datetext = (count, disableFutureDates) => {
  switch count {
  | Today => "Today"
  | Tomorrow => "Tomorrow"
  | Yesterday => "Yesterday"
  | ThisMonth => "This Month"
  | LastMonth => "Last Month"
  | LastSixMonths => "Last 6 Months"
  | NextMonth => "Next Month"
  | Hour(val) =>
    if val < 1.0 {
      disableFutureDates ? `Last ${getMins(val)} Mins` : `Next ${getMins(val)} Mins`
    } else if val === 1.0 {
      disableFutureDates ? `Last ${val->Float.toString} Hour` : `Next ${val->Float.toString} Hour`
    } else if disableFutureDates {
      `Last ${val->Float.toString} Hours`
    } else {
      `Next ${val->Float.toString} Hours`
    }
  | Day(val) =>
    disableFutureDates ? `Last ${val->Float.toString} Days` : `Next ${val->Float.toString} Days`
  }
}

let convertTimeStamp = (~isoStringToCustomTimeZone, timestamp, format) => {
  let convertedTimestamp = try {
    timestamp->isoStringToCustomTimeZone->TimeZoneHook.formattedDateTimeString(format)
  } catch {
  | _ => ""
  }
  convertedTimestamp
}

let changeTimeFormat = (~customTimezoneToISOString, ~date, ~time, ~format) => {
  let dateSplit = String.split(date, "T")
  let date = dateSplit[0]->Option.getOr("")->String.split("-")
  let dateDay = date[2]->Option.getOr("")
  let dateYear = date[0]->Option.getOr("")
  let dateMonth = date[1]->Option.getOr("")
  let timeSplit = String.split(time, ":")
  let timeHour = timeSplit->Array.get(0)->Option.getOr("00")
  let timeMinute = timeSplit->Array.get(1)->Option.getOr("00")
  let timeSecond = timeSplit->Array.get(2)->Option.getOr("00")
  let dateTimeCheck = customTimezoneToISOString(
    dateYear,
    dateMonth,
    dateDay,
    timeHour,
    timeMinute,
    timeSecond,
  )
  TimeZoneHook.formattedISOString(dateTimeCheck, format)
}
