type days = Sunday | Monday | Tuesday | Wednesday | Thrusday | Friday | Saturday

let daysArr = [Sunday, Monday, Tuesday, Wednesday, Thrusday, Friday, Saturday]

let dayMapper = (days: days) => {
  switch days {
  | Sunday => "Sunday"
  | Monday => "Monday"
  | Tuesday => "Tuesda"
  | Wednesday => "Wednesday"
  | Thrusday => "Thrusday"
  | Friday => "Friday"
  | Saturday => "Saturday"
  }
}
let cloneDate = date => date->Js.Date.getTime->Js.Date.fromFloat
let makeStartOfDayDate = date => {
  let date = Js.Date.setHoursMSMs(
    cloneDate(date),
    ~hours=0.,
    ~minutes=0.,
    ~seconds=0.,
    ~milliseconds=0.,
    (),
  )

  Js.Date.fromFloat(date)
}
let getStartOfWeek = (dayJs: Js.Date.t, startOfday: days) => {
  let day = Js.Date.getDay(dayJs)
  let startWeekDay = daysArr->Array.indexOf(startOfday)->Belt.Int.toFloat
  let diff = (day < startWeekDay ? 7. : 0.) +. day -. startWeekDay
  Js.Date.setDate(cloneDate(dayJs), Js.Date.getDate(dayJs) -. diff)
  ->Js.Date.fromFloat
  ->makeStartOfDayDate
  ->DayJs.getDayJsForJsDate
}

let utcToIST = timeStr => {
  let isEU = false
  let updatedHour = Js.Date.getHours(timeStr) +. 5.0
  let updatedMin = Js.Date.getMinutes(timeStr) +. 30.0

  let istTime = Js.Date.setHoursM(timeStr, ~hours=updatedHour, ~minutes=updatedMin, ())
  if isEU {
    timeStr->Js.Date.toISOString
  } else {
    Js.Date.fromFloat(istTime)->Js.Date.toISOString
  }
}

let utcToISTDate = timeStr => {
  let isEU = false
  let updatedHour = Js.Date.getHours(timeStr) +. 5.0
  let updatedMin = Js.Date.getMinutes(timeStr) +. 30.0

  let istTime = Js.Date.setHoursM(timeStr, ~hours=updatedHour, ~minutes=updatedMin, ())
  if isEU {
    timeStr
  } else {
    Js.Date.fromFloat(istTime)
  }
}

let parseAsFloat = (dateStr: string) => {
  let date = (dateStr->DayJs.getDayJsForString).toDate(.)
  Js.Date.makeWithYMDHMS(
    ~year=date->Js.Date.getFullYear,
    ~month=date->Js.Date.getMonth,
    ~date=date->Js.Date.getDate,
    ~hours=date->Js.Date.getHours,
    ~minutes=date->Js.Date.getMinutes,
    ~seconds=date->Js.Date.getSeconds,
    (),
  )->Js.Date.valueOf
}

let toUtc = (datetime: Js.Date.t) => {
  let offset = Js.Date.getTimezoneOffset(Js.Date.now()->Js.Date.fromFloat)->Belt.Int.fromFloat
  (datetime->DayJs.getDayJsForJsDate).add(. offset, "minute").toDate(.)
}

let getStartEndDiff = (startDate, endDate) => {
  let diffTime = Js.Math.abs_float(
    endDate->Js.Date.fromString->Js.Date.getTime -. startDate->Js.Date.fromString->Js.Date.getTime,
  )
  diffTime
}

let isStartBeforeEndDate = (start, end) => {
  let getDate = date => {
    let datevalue = Js.Date.makeWithYMD(
      ~year=Js.Float.fromString(date[0]->Belt.Option.getWithDefault("")),
      ~month=Js.Float.fromString(
        String.make(Js.Float.fromString(date[1]->Belt.Option.getWithDefault("")) -. 1.0),
      ),
      ~date=Js.Float.fromString(date[2]->Belt.Option.getWithDefault("")),
      (),
    )
    datevalue
  }
  let startDate = getDate(String.split(start, "-"))
  let endDate = getDate(String.split(end, "-"))
  startDate < endDate
}

let getFormattedDate = (date, format) => {
  date->Js.Date.fromString->Js.Date.toISOString->TimeZoneHook.formattedISOString(format)
}
type month = Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec

let months = [Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec]

let timeOptions = [
  "12:00 am",
  "12:15 am",
  "12:30 am",
  "12:45 am",
  "1:00 am",
  "1:15 am",
  "1:30 am",
  "1:45 am",
  "2:00 am",
  "2:15 am",
  "2:30 am",
  "2:45 am",
  "3:00 am",
  "3:15 am",
  "3:30 am",
  "3:45 am",
  "4:00 am",
  "4:15 am",
  "4:30 am",
  "4:45 am",
  "5:00 am",
  "5:15 am",
  "5:30 am",
  "5:45 am",
  "6:00 am",
  "6:15 am",
  "6:30 am",
  "6:45 am",
  "7:00 am",
  "7:15 am",
  "7:30 am",
  "7:45 am",
  "8:00 am",
  "8:15 am",
  "8:30 am",
  "8:45 am",
  "9:00 am",
  "9:15 am",
  "9:30 am",
  "9:45 am",
  "10:00 am",
  "10:15 am",
  "10:30 am",
  "10:45 am",
  "11:00 am",
  "11:15 am",
  "11:30 am",
  "11:45 am",
  "12:00 pm",
  "12:15 pm",
  "12:30 pm",
  "12:45 pm",
  "1:00 pm",
  "1:15 pm",
  "1:30 pm",
  "1:45 pm",
  "2:00 pm",
  "2:15 pm",
  "2:30 pm",
  "2:45 pm",
  "3:00 pm",
  "3:15 pm",
  "3:30 pm",
  "3:45 pm",
  "4:00 pm",
  "4:15 pm",
  "4:30 pm",
  "4:45 pm",
  "5:00 pm",
  "5:15 pm",
  "5:30 pm",
  "5:45 pm",
  "6:00 pm",
  "6:15 pm",
  "6:30 pm",
  "6:45 pm",
  "7:00 pm",
  "7:15 pm",
  "7:30 pm",
  "7:45 pm",
  "8:00 pm",
  "8:15 pm",
  "8:30 pm",
  "8:45 pm",
  "9:00 pm",
  "9:15 pm",
  "9:30 pm",
  "9:45 pm",
  "10:00 pm",
  "10:15 pm",
  "10:30 pm",
  "10:45 pm",
  "11:00 pm",
  "11:15 pm",
  "11:30 pm",
  "11:45 pm",
]
