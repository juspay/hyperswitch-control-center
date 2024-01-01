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
  let strLen = str->Js.String2.length
  strLen == 0 ? "00" : strLen == 1 ? `0${str}` : str
}

let dateTimeObjectToString = (dateTimeObject: dateTimeString) => {
  `${dateTimeObject.year}-${dateTimeObject.month}-${dateTimeObject.date}T${dateTimeObject.hour}:${dateTimeObject.minute}:${dateTimeObject.second}Z`
}

let getUnixFormat = dateStr => {
  let date = Js.Date.fromString(dateStr)
  Js.Math.floor_int(Js.Date.getTime(date) /. 1000.0)->Js.Int.toString
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
  switch Belt.Float.fromString(element) {
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
  (dateTime->dateTimeObjectToDate->Js.Date.toString->DayJs.getDayJsForString).format(. format)
}

let formattedDateTimeString = (dateTime: dateTimeString, format: string) => {
  formattedDateTimeFloat(dateTime->dateTimeStringToDateTimeFloat, format)
}

let formattedISOString = (dateTimeIsoString: string, format: string) => {
  // 2021-08-29T18:30:00.000Z
  let tempTimeDateString = dateTimeIsoString->Js.String2.replace("Z", "")
  let tempTimeDate = tempTimeDateString->Js.String2.split("T")
  let time = tempTimeDate[1]
  let date = tempTimeDate[0]
  let dateComponents = date->Belt.Option.getWithDefault("")->Js.String2.split("-")
  let timeComponents = time->Belt.Option.getWithDefault("")->Js.String2.split(":")
  let dateTimeObject: dateTimeFloat = {
    year: dateComponents[0]->Belt.Option.getWithDefault("")->stringToFloat,
    month: dateComponents[1]->Belt.Option.getWithDefault("")->stringToFloat,
    date: dateComponents[2]->Belt.Option.getWithDefault("")->stringToFloat,
    hour: timeComponents[0]->Belt.Option.getWithDefault("")->stringToFloat,
    minute: timeComponents[1]->Belt.Option.getWithDefault("")->stringToFloat,
    second: timeComponents[2]->Belt.Option.getWithDefault("")->stringToFloat,
  }
  formattedDateTimeFloat(dateTimeObject, format)
}

let en_USStringToDateTimeObject = dateTimeIsoString => {
  let tempTimeDateString = dateTimeIsoString->Js.String2.replace(",", "")

  let tempTimeDate =
    tempTimeDateString
    ->Js.String2.splitByRe(%re("/\s/"))
    ->Js.Array2.map(val => val->Belt.Option.getWithDefault(""))

  let time = tempTimeDate[1]
  let date = tempTimeDate[0]
  let dateComponents = date->Belt.Option.getWithDefault("")->Js.String2.split("/")
  let timeComponents = time->Belt.Option.getWithDefault("")->Js.String2.split(":")
  let tempHour = switch Belt.Float.fromString(timeComponents[0]->Belt.Option.getWithDefault("")) {
  | Some(a) => a
  | _ => 0.0
  }
  let fullTempHour =
    tempTimeDate[2]->Belt.Option.getWithDefault("") === "AM"
      ? tempHour === 12.0 ? 0.0 : tempHour
      : tempHour < 12.0
      ? tempHour +. 12.0
      : tempHour
  let hourInString = Belt.Float.toString(fullTempHour)
  let dateTimeObject: dateTimeString = {
    year: formatter(dateComponents[2]->Belt.Option.getWithDefault("")),
    month: formatter(dateComponents[0]->Belt.Option.getWithDefault("")),
    date: formatter(dateComponents[1]->Belt.Option.getWithDefault("")),
    hour: formatter(hourInString),
    minute: formatter(timeComponents[1]->Belt.Option.getWithDefault("")),
    second: formatter(timeComponents[2]->Belt.Option.getWithDefault("")),
  }
  dateTimeObject
}

type timeZoneObject = {timeZone: string}
@send external toLocaleString: (Js.Date.t, string, timeZoneObject) => string = "toLocaleString"
let convertTimeZone = (date, timezoneString) => {
  let localTimeString = Js.Date.fromString(date)
  localTimeString
  ->toLocaleString("en-US", {timeZone: timezoneString})
  ->Js.String2.replaceByRe(%re("/\s/g"), " ")
}

let useCustomTimeZoneToIsoString = () => {
  let (zone, _setZone) = React.useContext(UserTimeZoneProvider.userTimeContext)

  let customTimezoneToISOString = React.useCallback1(
    (year, month, day, hours, minutes, seconds) => {
      let selectedTimeZoneData = TimeZoneData.getTimeZoneData(zone)
      let timeZoneData = selectedTimeZoneData
      let timezone = timeZoneData.offset

      let monthString = Js.String2.length(month) == 1 ? `0${month}` : month
      let dayString = Js.String2.length(day) == 1 ? `0${day}` : day
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
      let newFormedDate = Js.Date.fromString(fullTimeManagedString)
      let isoFormattedDate = Js.Date.toISOString(newFormedDate)
      isoFormattedDate
    },
    [zone],
  )
  customTimezoneToISOString
}

let useIsoStringToCustomTimeZone = () => {
  let (zone, _setZone) = React.useContext(UserTimeZoneProvider.userTimeContext)

  let isoStringToCustomTimezone = React.useCallback1(isoString => {
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

  let isoStringToCustomTimezoneInFloat = React.useCallback1(isoString => {
    let selectedTimeZoneData = TimeZoneData.getTimeZoneData(zone)
    let selectedTimeZoneAlias = selectedTimeZoneData.region
    let timezoneConvertedString = convertTimeZone(isoString, selectedTimeZoneAlias)
    let customDateTimeString: dateTimeString = en_USStringToDateTimeObject(timezoneConvertedString)
    let customDateTime = dateTimeStringToDateTimeFloat(customDateTimeString)
    customDateTime
  }, [zone])
  isoStringToCustomTimezoneInFloat
}

let timeStrToMicroSec = str => {
  let arr = str->Js.String2.split(" ")
  if arr->Js.Array2.length > 1 {
    let time =
      arr[0]->Belt.Option.getWithDefault("00")->Belt.Int.fromString->Belt.Option.getWithDefault(0)
    let ms = arr[1]->Belt.Option.getWithDefault("") === "min" ? time * 60000 : time * 1000
    ms->Belt.Int.toString
  } else {
    str
  }
}

let getTimeFromString = str => {
  str
  ->Js.String2.split("T")
  ->Belt.Array.get(1)
  ->Belt.Option.mapWithDefault("00:00", Js.String2.slice(~from=0, ~to_=5))
}

let getDateFromString = str => {
  str->Js.String2.split("T")->Belt.Array.get(0)->Belt.Option.getWithDefault("2022-01-01")
}

let getDiffOfDatesFromToday = (~isAbs=true, toDate) => {
  let toDate = Js.Date.fromString(toDate)->Js.Date.getTime
  let today = Js.Date.now()
  ((isAbs ? Js.Math.abs_float(toDate -. today) : toDate -. today) /. 1000. /. 60. /. 60. /. 24.)
  ->Js.Math.round
  ->Belt.Float.toInt
}
let getDiffBetweenDates = (toDate, fromDate, isAbs) => {
  let toDate = Js.Date.fromString(toDate)->Js.Date.getTime
  let fromDate = Js.Date.fromString(fromDate)->Js.Date.getTime
  ((isAbs ? Js.Math.abs_float(toDate -. fromDate) : toDate -. fromDate) /.
  1000. /.
  60. /.
  60. /. 24.)
  ->Js.Math.round
  ->Belt.Float.toInt
}
let incrementByDays = (date, days) => {
  let date = Js.Date.fromString(date)->Js.Date.getTime
  date +. days *. 1000. *. 60. *. 60. *. 24.
}
