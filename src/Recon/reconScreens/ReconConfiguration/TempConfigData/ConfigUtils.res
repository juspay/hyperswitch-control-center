let getTodayDate = () => {
  let currentDate = Date.getTime(Date.make())
  let date = Js.Date.fromFloat(currentDate)->Date.toISOString
  date->TimeZoneHook.formattedISOString("YYYY-MM-DDTHH:mm:ss[Z]")->String.slice(~start=0, ~end=10)
}

let getTomorrowDate = () => {
  let currentDate = Date.getTime(Date.make())
  let tomorrowDateMilliseconds = currentDate +. 86400000.0
  let tomorrowDate = Js.Date.fromFloat(tomorrowDateMilliseconds)->Date.toISOString
  tomorrowDate
  ->TimeZoneHook.formattedISOString("YYYY-MM-DDTHH:mm:ss[Z]")
  ->String.slice(~start=0, ~end=10)
}
