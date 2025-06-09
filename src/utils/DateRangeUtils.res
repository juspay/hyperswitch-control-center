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
type compareOption =
  | No_Comparison
  | Previous_Period
  | Custom
@unboxed
type comparison =
  | EnableComparison
  | DisableComparison

let comparisonMapprer = val => {
  switch val {
  | "EnableComparison" => EnableComparison
  | "DisableComparison" => DisableComparison
  | _ => DisableComparison
  }
}

let compareOptionToString = (option: compareOption) =>
  switch option {
  | No_Comparison => "No_Comparison"
  | Previous_Period => "Previous_Period"
  | Custom => "Custom"
  }

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
  let lastMonth = todayDayJsObj.subtract(1, "month").endOf("month").toDate()
  let lastSixMonths = todayDayJsObj.toDate()
  let nextMonth = todayDayJsObj.add(1, "month").endOf("month").toDate()
  let yesterday = todayDayJsObj.subtract(1, "day").toDate()
  let tomorrow = todayDayJsObj.add(1, "day").toDate()
  let thisMonth = disableFutureDates
    ? todayDayJsObj.toDate()
    : todayDayJsObj.endOf("month").toDate()

  let customDate = switch value {
  | LastMonth => lastMonth
  | LastSixMonths => lastSixMonths
  | NextMonth => nextMonth
  | Yesterday => yesterday
  | Tomorrow => tomorrow
  | ThisMonth => thisMonth
  | _ => todayDayJsObj.toDate()
  }

  let daysInMonth =
    (customDate->DayJs.getDayJsForJsDate).endOf("month").toString()
    ->Date.fromString
    ->Js.Date.getDate
  let prevDate = (customDate->DayJs.getDayJsForJsDate).subtract(6, "month").toString()
  let daysInSixMonth = (customDate->DayJs.getDayJsForJsDate).diff(prevDate, "day")->Int.toFloat
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

let getTimeStringForValue = (
  value,
  isoStringToCustomTimeZone: string => TimeZoneHook.dateTimeString,
) => {
  if value->LogicUtils.isEmptyString {
    ""
  } else {
    try {
      let check = TimeZoneHook.formattedISOString(value, "YYYY-MM-DDTHH:mm:ss.SSS[Z]")
      let {hour, minute, second} = isoStringToCustomTimeZone(check)
      `${hour}:${minute}:${second}`
    } catch {
    | _error => ""
    }
  }
}

let formatTimeString = (~timeVal, ~defaultTime, ~showSeconds) => {
  open LogicUtils
  if timeVal->isNonEmptyString {
    let timeArr = timeVal->String.split(":")
    let timeTxt = `${timeArr->getValueFromArray(0, "00")}:${timeArr->getValueFromArray(1, "00")}`
    showSeconds ? `${timeTxt}:${timeArr->getValueFromArray(2, "00")}` : timeTxt
  } else {
    defaultTime
  }
}

let getFormattedDate = (date, format) => {
  date->Date.fromString->Date.toISOString->TimeZoneHook.formattedISOString(format)
}

let getDateStringForValue = (
  value,
  isoStringToCustomTimeZone: string => TimeZoneHook.dateTimeString,
) => {
  if value->LogicUtils.isEmptyString {
    ""
  } else {
    try {
      let check = TimeZoneHook.formattedISOString(value, "YYYY-MM-DDTHH:mm:ss.SSS[Z]")
      let {year, month, date} = isoStringToCustomTimeZone(check)
      `${year}-${month}-${date}`
    } catch {
    | _error => ""
    }
  }
}

let formatDateString = (~dateVal, ~buttonText, ~defaultLabel, ~isoStringToCustomTimeZone) => {
  open LogicUtils
  if dateVal->isNonEmptyString {
    getFormattedDate(dateVal->getDateStringForValue(isoStringToCustomTimeZone), "MMM DD, YYYY")
  } else if buttonText->isNonEmptyString {
    buttonText
  } else {
    defaultLabel
  }
}

let getButtonText = (
  ~predefinedOptionSelected,
  ~disableFutureDates,
  ~startDateVal,
  ~endDateVal,
  ~buttonText,
  ~isoStringToCustomTimeZone,
  ~comparison,
) => {
  open LogicUtils

  let startDateStr = formatDateString(
    ~dateVal=startDateVal,
    ~buttonText,
    ~defaultLabel="[From-Date]",
    ~isoStringToCustomTimeZone,
  )

  let endDateStr = formatDateString(
    ~dateVal=endDateVal,
    ~buttonText,
    ~defaultLabel="[To-Date]",
    ~isoStringToCustomTimeZone,
  )

  switch comparison->comparisonMapprer {
  | DisableComparison => `No Comparison`
  | EnableComparison =>
    switch predefinedOptionSelected {
    | Some(value) => datetext(value, disableFutureDates)
    | None =>
      switch (startDateVal->isEmptyString, endDateVal->isEmptyString) {
      | (true, true) => `No Comparison`
      | (true, false) => `${endDateStr}` // When start date is empty, show only end date
      | (false, true) => `${startDateStr} - Now` // When end date is empty, show start date and "Now"
      | (false, false) =>
        let separator = startDateStr === buttonText ? "" : "-"
        `${startDateStr} ${separator} ${endDateStr}`
      }
    }
  }
}

let getStrokeColor = (disable, isDropdownExpandedActualPrimary) =>
  if disable {
    "text-nd_gray-400"
  } else if isDropdownExpandedActualPrimary {
    "stroke-jp-2-light-gray-1700"
  } else {
    "stroke-jp-2-light-gray-1100"
  }

let getComparisionTimePeriod = (~startDate, ~endDate) => {
  let startingPoint = startDate->DayJs.getDayJsForString
  let endingPoint = endDate->DayJs.getDayJsForString
  let gap = endingPoint.diff(startingPoint.toString(), "millisecond") // diff between points

  let startTimeValue = startingPoint.subtract(gap, "millisecond").toDate()->Date.toISOString
  let endTimeVal = startingPoint.subtract(1, "millisecond").toDate()->Date.toISOString

  (startTimeValue, endTimeVal)
}

let resetStartEndInput = (~setStartDate, ~setEndDate) => {
  setStartDate(_ => "")
  setEndDate(_ => "")
}

let getStartEndDiff = (startDate, endDate) => {
  let diffTime = Math.abs(
    endDate->Date.fromString->Date.getTime -. startDate->Date.fromString->Date.getTime,
  )
  diffTime
}

let getDiffForPredefined = (
  predefinedDay,
  isoStringToCustomTimeZone,
  isoStringToCustomTimezoneInFloat,
  customTimezoneToISOString,
  disableFutureDates,
  disablePastDates,
) => {
  let todayDayJsObj = Date.make()->Date.toString->DayJs.getDayJsForString
  let todayDate = todayDayJsObj.format("YYYY-MM-DD")
  let todayTime = todayDayJsObj.format("HH:mm:ss")
  let format = "YYYY-MM-DDTHH:mm:00[Z]"

  let (stDate, enDate, stTime, enTime) = getPredefinedStartAndEndDate(
    todayDayJsObj,
    isoStringToCustomTimeZone,
    isoStringToCustomTimezoneInFloat,
    customTimezoneToISOString,
    predefinedDay,
    disableFutureDates,
    disablePastDates,
    todayDate,
    todayTime,
  )

  let startTimestamp = changeTimeFormat(
    ~date=stDate,
    ~time=stTime,
    ~customTimezoneToISOString,
    ~format,
  )
  let endTimestamp = changeTimeFormat(
    ~date=enDate,
    ~time=enTime,
    ~customTimezoneToISOString,
    ~format,
  )

  getStartEndDiff(startTimestamp, endTimestamp)
}

let getIsPredefinedOptionSelected = (
  predefinedDays,
  startDateVal,
  endDateVal,
  isoStringToCustomTimeZone,
  isoStringToCustomTimezoneInFloat,
  customTimezoneToISOString,
  disableFutureDates,
  disablePastDates,
) => {
  let format = "YYYY-MM-DDTHH:mm:00[Z]"
  predefinedDays->Array.find(item => {
    let startDate = convertTimeStamp(~isoStringToCustomTimeZone, startDateVal, format)
    let endDate = convertTimeStamp(~isoStringToCustomTimeZone, endDateVal, format)
    let difference = getStartEndDiff(startDate, endDate)
    getDiffForPredefined(
      item,
      isoStringToCustomTimeZone,
      isoStringToCustomTimezoneInFloat,
      customTimezoneToISOString,
      disableFutureDates,
      disablePastDates,
    ) === difference
  })
}

let getGapBetweenRange = (~startDate, ~endDate) => {
  let startingPoint = startDate->DayJs.getDayJsForString
  let endingPoint = endDate->DayJs.getDayJsForString
  endingPoint.diff(startingPoint.toString(), "day") // diff between points
}
