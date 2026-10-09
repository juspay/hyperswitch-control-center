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
  _isoStringToCustomTimeZone: string => TimeZoneHook.dateTimeString,
  isoStringToCustomTimezoneInFloat: string => TimeZoneHook.dateTimeFloat,
  _customTimezoneToISOString,
  value: customDateRange,
  disableFutureDates,
  disablePastDates,
  _todayDate,
  _todayTime,
) => {
  // Calendar arithmetic uses selected-zone wall time, without converting it a second time.
  let now = todayDayJsObj.toDate()
  let today =
    now
    ->Date.toISOString
    ->isoStringToCustomTimezoneInFloat
    ->TimeZoneHook.dateTimeObjectToDate
    ->DayJs.getDayJsForJsDate
  let todayDate = today.format("YYYY-MM-DD")
  let todayTime = today.format("HH:mm:ss")
  let (start, end) = switch value {
  | Today => (today, today)
  | Yesterday => {
      let day = today.subtract(1, "day")
      (day, day)
    }
  | Tomorrow => {
      let day = today.add(1, "day")
      (day, day)
    }
  | ThisMonth => (today.date(1), disableFutureDates ? today : today.endOf("month"))
  | LastMonth => {
      let month = today.subtract(1, "month")
      (month.date(1), month.endOf("month"))
    }
  | NextMonth => {
      let month = today.add(1, "month")
      (month.date(1), month.endOf("month"))
    }
  | LastSixMonths => (today.subtract(6, "month"), today)
  | Day(val) =>
    disableFutureDates
      ? (today.subtract(val->Float.toInt - 1, "day"), today)
      : (today, today.add(val->Float.toInt - 1, "day"))
  | Hour(val) => {
      // Hour presets are elapsed time, including across daylight-saving transitions.
      let duration = val *. 3600000.
      let other = Date.fromTime(Date.getTime(now) +. (disableFutureDates ? -.duration : duration))
      let other =
        other
        ->Date.toISOString
        ->isoStringToCustomTimezoneInFloat
        ->TimeZoneHook.dateTimeObjectToDate
        ->DayJs.getDayJsForJsDate
      disableFutureDates ? (other, today) : (today, other)
    }
  }
  let startDate = start.format("YYYY-MM-DD")
  let endDate = end.format("YYYY-MM-DD")

  let endTime = {
    let eTime = switch value {
    | Hour(_) => end.format("HH:mm:ss")
    | _ => "23:59:59"
    }
    disableFutureDates && endDate == todayDate ? todayTime : eTime
  }
  let startTime = {
    let sTime = switch value {
    | Hour(_) => start.format("HH:mm:ss")
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

let getComparisonTimePeriod = (~startDate, ~endDate) => {
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
