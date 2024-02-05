open DayJs
open DateRangeUtils
let useConstructQueryOnBasisOfOpt = () => {
  let customTimezoneToISOString = TimeZoneHook.useCustomTimeZoneToIsoString()
  let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
  let isoStringToCustomTimezoneInFloat = TimeZoneHook.useIsoStringToCustomTimeZoneInFloat()
  let todayDayJsObj = Date.make()->Date.toString->getDayJsForString

  let todayDate = todayDayJsObj.format(. "YYYY-MM-DD")
  let todayTime = todayDayJsObj.format(. "HH:mm:ss")
  (~queryString, ~disableFutureDates, ~disablePastDates, ~startKey, ~endKey, ~optKey) => {
    if queryString->String.includes(optKey) {
      try {
        let arrQuery = queryString->String.split("&")
        let tempArr = arrQuery->Array.filter(x => x->String.includes(optKey))
        let tempArr = tempArr[0]->Option.getOr("")->String.split("=")
        let optVal = tempArr[1]->Option.getOr("")

        let customrange: customDateRange = switch optVal {
        | "today" => Today
        | "yesterday" => Yesterday
        | "tomorrow" => Tomorrow
        | "last_month" => LastMonth
        | "this_month" => ThisMonth
        | "next_month" => NextMonth
        | st => {
            let arr = st->String.split("_")
            let _ = arr[0]->Option.getOr("") == "next"
            let anchor = arr[2]->Option.getOr("")
            let val = arr[1]->Option.getOr("")
            switch anchor {
            | "days" => Day(val->Float.fromString->Option.getOr(0.0))
            | "hours" => Hour(val->Float.fromString->Option.getOr(0.0))
            | "mins" => Hour(val->Float.fromString->Option.getOr(0.0) /. 60.0)
            | _ => Today
            }
          }
        }
        let (stDate, enDate, stTime, enTime) = getPredefinedStartAndEndDate(
          todayDayJsObj,
          isoStringToCustomTimeZone,
          isoStringToCustomTimezoneInFloat,
          customTimezoneToISOString,
          customrange,
          disableFutureDates,
          disablePastDates,
          todayDate,
          todayTime,
        )
        let stTimeStamp = changeTimeFormat(
          ~date=stDate,
          ~time=stTime,
          ~customTimezoneToISOString,
          ~format="YYYY-MM-DDTHH:mm:ss.SSS[Z]",
        )
        let enTimeStamp = changeTimeFormat(
          ~date=enDate,
          ~time=enTime,
          ~customTimezoneToISOString,
          ~format="YYYY-MM-DDTHH:mm:ss.SSS[Z]",
        )
        let updatedArr = arrQuery->Array.map(x =>
          if x->String.includes(startKey) {
            `${startKey}=${stTimeStamp}`
          } else if x->String.includes(endKey) {
            `${endKey}=${enTimeStamp}`
          } else {
            x
          }
        )
        updatedArr->Array.joinWith("&")
      } catch {
      | _error => queryString
      }
    } else {
      queryString
    }
  }
}
