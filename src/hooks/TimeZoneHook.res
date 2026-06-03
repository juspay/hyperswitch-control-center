type dateTimeString = {
  year: string,
  month: string,
  date: string,
  hour: string,
  minute: string,
  second: string,
}
type dateTimeFloat = {
  year: float,
  month: float,
  date: float,
  hour: float,
  minute: float,
  second: float,
}

let formatter = str => {
  let strLen = str->String.length
  strLen == 0 ? "00" : strLen == 1 ? `0${str}` : str
}

let dateTimeObjectToDate = (dateTimeObject: dateTimeFloat) => {
  Js.Date.makeWithYMDHMS(
    ~year=dateTimeObject.year,
    ~month=dateTimeObject.month -. 1.0,
    ~date=dateTimeObject.date,
    ~hours=dateTimeObject.hour,
    ~minutes=dateTimeObject.minute,
    ~seconds=dateTimeObject.second,
    (),
  )
}

let stringToFloat = element => {
  switch Float.fromString(element) {
  | Some(a) => a
  | _ => 0.0
  }
}

let dateTimeStringToDateTimeFloat = (dateTime: dateTimeString) => {
  {
    year: dateTime.year->stringToFloat,
    month: dateTime.month->stringToFloat,
    date: dateTime.date->stringToFloat,
    hour: dateTime.hour->stringToFloat,
    minute: dateTime.minute->stringToFloat,
    second: dateTime.second->stringToFloat,
  }
}

let formattedDateTimeFloat = (dateTime: dateTimeFloat, format: string) => {
  (dateTime->dateTimeObjectToDate->Date.toString->DayJs.getDayJsForString).format(format)
}

let formattedDateTimeString = (dateTime: dateTimeString, format: string) => {
  formattedDateTimeFloat(dateTime->dateTimeStringToDateTimeFloat, format)
}

let formattedISOString = (dateTimeIsoString: string, format: string) => {
  // 2021-08-29T18:30:00.000Z
  let tempTimeDateString = dateTimeIsoString->String.replace("Z", "")
  let tempTimeDate = tempTimeDateString->String.split("T")
  let time = tempTimeDate[1]
  let date = tempTimeDate[0]
  let dateComponents = date->Option.getOr("")->String.split("-")
  let timeComponents = time->Option.getOr("")->String.split(":")
  let dateTimeObject: dateTimeFloat = {
    year: dateComponents[0]->Option.getOr("")->stringToFloat,
    month: dateComponents[1]->Option.getOr("")->stringToFloat,
    date: dateComponents[2]->Option.getOr("")->stringToFloat,
    hour: timeComponents[0]->Option.getOr("")->stringToFloat,
    minute: timeComponents[1]->Option.getOr("")->stringToFloat,
    second: timeComponents[2]->Option.getOr("")->stringToFloat,
  }
  formattedDateTimeFloat(dateTimeObject, format)
}

let en_USStringToDateTimeObject = dateTimeIsoString => {
  let tempTimeDateString = dateTimeIsoString->String.replace(",", "")

  let tempTimeDate =
    tempTimeDateString->Js.String2.splitByRe(%re("/\s/"))->Array.map(val => val->Option.getOr(""))

  let time = tempTimeDate[1]
  let date = tempTimeDate[0]
  let dateComponents = date->Option.getOr("")->String.split("/")
  let timeComponents = time->Option.getOr("")->String.split(":")
  let tempHour = switch Float.fromString(timeComponents[0]->Option.getOr("")) {
  | Some(a) => a
  | _ => 0.0
  }
  let fullTempHour =
    tempTimeDate[2]->Option.getOr("") === "AM"
      ? tempHour === 12.0 ? 0.0 : tempHour
      : tempHour < 12.0
      ? tempHour +. 12.0
      : tempHour
  let hourInString = Float.toString(fullTempHour)
  let dateTimeObject: dateTimeString = {
    year: formatter(dateComponents[2]->Option.getOr("")),
    month: formatter(dateComponents[0]->Option.getOr("")),
    date: formatter(dateComponents[1]->Option.getOr("")),
    hour: formatter(hourInString),
    minute: formatter(timeComponents[1]->Option.getOr("")),
    second: formatter(timeComponents[2]->Option.getOr("")),
  }
  dateTimeObject
}

type timeZoneObject = {timeZone: string}
@send external toLocaleString: (Date.t, string, timeZoneObject) => string = "toLocaleString"
let convertTimeZone = (date, timezoneString) => {
  let localTimeString = Date.fromString(date)
  localTimeString
  ->toLocaleString("en-US", {timeZone: timezoneString})
  ->String.replaceRegExp(%re("/\s/g"), " ")
}

let useCustomTimeZoneToIsoString = () => {
  let (zone, _setZone) = React.useContext(UserTimeZoneProvider.userTimeContext)

  let customTimezoneToISOString = React.useCallback((year, month, day, hours, minutes, seconds) => {
    let selectedTimeZoneData = TimeZoneData.getTimeZoneData(zone)
    let timeZoneData = selectedTimeZoneData
    let timezone = timeZoneData.offset

    let monthString = String.length(month) == 1 ? `0${month}` : month
    let dayString = String.length(day) == 1 ? `0${day}` : day
    let hoursString = formatter(hours)
    let minutesString = formatter(minutes)

    let secondsString = formatter(seconds)

    let fullTimeManagedString =
      year ++
      "-" ++
      monthString ++
      "-" ++
      dayString ++
      "T" ++
      hoursString ++
      ":" ++
      minutesString ++
      ":" ++
      secondsString ++
      timezone
    let newFormedDate = Date.fromString(fullTimeManagedString)
    let isoFormattedDate = Date.toISOString(newFormedDate)
    isoFormattedDate
  }, [zone])
  customTimezoneToISOString
}

let useIsoStringToCustomTimeZone = () => {
  let (zone, _setZone) = React.useContext(UserTimeZoneProvider.userTimeContext)

  let isoStringToCustomTimezone = React.useCallback(isoString => {
    let selectedTimeZoneData = TimeZoneData.getTimeZoneData(zone)
    let selectedTimeZoneAlias = selectedTimeZoneData.region
    let timezoneConvertedString = convertTimeZone(isoString, selectedTimeZoneAlias)
    let customDateTime: dateTimeString = en_USStringToDateTimeObject(timezoneConvertedString)
    customDateTime
  }, [zone])
  isoStringToCustomTimezone
}

let useIsoStringToCustomTimeZoneInFloat = () => {
  let (zone, _setZone) = React.useContext(UserTimeZoneProvider.userTimeContext)

  let isoStringToCustomTimezoneInFloat = React.useCallback(isoString => {
    let selectedTimeZoneData = TimeZoneData.getTimeZoneData(zone)
    let selectedTimeZoneAlias = selectedTimeZoneData.region
    let timezoneConvertedString = convertTimeZone(isoString, selectedTimeZoneAlias)
    let customDateTimeString: dateTimeString = en_USStringToDateTimeObject(timezoneConvertedString)
    let customDateTime = dateTimeStringToDateTimeFloat(customDateTimeString)
    customDateTime
  }, [zone])
  isoStringToCustomTimezoneInFloat
}

let useGetTimeInCustomTimeZone = () => {
  let (zone, _setZone) = React.useContext(UserTimeZoneProvider.userTimeContext)

  React.useCallback((format, ~includeTimeZone=false) => {
    let nowIso = Js.Date.make()->Js.Date.toISOString
    let selectedTimeZoneData = TimeZoneData.getTimeZoneData(zone)
    let selectedTimeZoneAlias = selectedTimeZoneData.region
    let selectedTimeZoneTitle = selectedTimeZoneData.title
    let timezoneConvertedString = convertTimeZone(nowIso, selectedTimeZoneAlias)
    let customDateTimeString: dateTimeString = en_USStringToDateTimeObject(timezoneConvertedString)
    let formattedDate = formattedDateTimeString(customDateTimeString, format)
    includeTimeZone ? `${formattedDate} ${selectedTimeZoneTitle}` : formattedDate
  }, [zone])
}
