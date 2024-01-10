type timeZoneObject = {timeZone: string}
@send external toLocaleString: (Js.Date.t, string, timeZoneObject) => string = "toLocaleString"

type dateTime = {
  year: float,
  month: float,
  date: float,
  hour: float,
  minute: float,
  second: float,
}

let timezoneOffset = Dict.fromArray([("IST", "+05:30"), ("GMT", "+00:00")])
let timezoneLocation = Dict.fromArray([("IST", "Asia/Kolkata"), ("GMT", "UTC")])

let formatter = str => {
  String.length(str) == 0 ? "00" : String.length(str) == 1 ? `0${str}` : str
}

let convertTimeZone = (date, timezoneString) => {
  let localTimeString = Js.Date.fromString(date)
  toLocaleString(localTimeString, "en-US", {timeZone: timezoneString})
}

let isoStringToCustomTimezone = isoString => {
  let timezone = "IST"

  let timezoneString = switch Dict.get(timezoneLocation, timezone) {
  | Some(d) => d
  | None => "Asia/Kolkata"
  }

  let timezoneConvertedString = convertTimeZone(isoString, timezoneString)
  let timezoneConverted = Js.Date.fromString(timezoneConvertedString)
  let timeZoneYear = Js.Date.getFullYear(timezoneConverted)
  let timeZoneMonth = Js.Date.getMonth(timezoneConverted)
  let timeZoneDate = Js.Date.getDate(timezoneConverted)
  let timeZoneHour = Js.Date.getHours(timezoneConverted)
  let timeZoneMinute = Js.Date.getMinutes(timezoneConverted)
  let timeZoneSecond = Js.Date.getSeconds(timezoneConverted)
  let customDateTime: dateTime = {
    year: timeZoneYear,
    month: timeZoneMonth,
    date: timeZoneDate,
    hour: timeZoneHour,
    minute: timeZoneMinute,
    second: timeZoneSecond,
  }
  customDateTime
}
