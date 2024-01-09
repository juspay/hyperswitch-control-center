let useErroryValueResetter = (
  input: ReactFinalForm.fieldRenderPropsInput,
  isoStringToCustomTimeZone,
) => {
  React.useEffect1(() => {
    let isErroryTimeValue = value => {
      try {
        let _checkEnd = value->Js.Json.decodeString->Belt.Option.map(isoStringToCustomTimeZone)
        false
      } catch {
      | _error => true
      }
    }
    if input.value->isErroryTimeValue {
      input.onChange(""->Identity.stringToFormReactEvent)
    }

    None
  }, [input.value])
}

let getDateStringForValue = (
  value,
  isoStringToCustomTimeZone: string => TimeZoneHook.dateTimeString,
) => {
  switch value->Js.Json.decodeString {
  | Some(a) =>
    if a === "" {
      ""
    } else {
      try {
        let check = TimeZoneHook.formattedISOString(a, "YYYY-MM-DDTHH:mm:ss.SSS[Z]")
        let {year, month, date} = isoStringToCustomTimeZone(check)
        `${year}-${month}-${date}`
      } catch {
      | _error => ""
      }
    }
  | None => ""
  }
}

type duration = Minute | Hour | Day

let options = [
  (5, Minute),
  (15, Minute),
  (30, Minute),
  (1, Hour),
  (3, Hour),
  (6, Hour),
  (12, Hour),
  (24, Hour),
  (2, Day),
  (5, Day),
  (7, Day),
  (30, Day),
]

module PredefinedCustomRange = {
  let optionClass = "px-4 py-2 flex items-center justify-between hover:bg-jp-gray-100 dark:hover:bg-jp-gray-800 cursor-pointer text-sm"

  @react.component
  let make = (
    ~processDate,
    ~changeStartDate: (
      ~hour: string=?,
      ~min: string=?,
      ~sec: string=?,
      ~ele: Js.String2.t,
      unit,
    ) => unit,
    ~changeEndDate: (
      ~hour: string=?,
      ~min: string=?,
      ~sec: string=?,
      ~ele: Js.String2.t,
      unit,
    ) => unit,
    ~setCalendarVisibility,
  ) => {
    let setStartDateToToday = startDate => {
      changeStartDate(~ele=startDate->processDate, ())
      changeEndDate(~ele=Js.Date.make()->processDate, ())
    }
    <>
      <div
        className=optionClass
        onClick={_ => {
          let currentDate = Js.Date.make()->processDate
          changeStartDate(~ele=currentDate, ())
          changeEndDate(~ele=currentDate, ())
          setCalendarVisibility(_ => false)
        }}>
        {React.string("Today so far")}
      </div>
      <div
        className=optionClass
        onClick={_ => {
          let currentDate = Js.Date.make()
          let gapISO =
            Js.Date.make()
            ->Js.Date.setDate(currentDate->Js.Date.getDate -. 1.0)
            ->Js.Date.fromFloat
            ->processDate

          changeStartDate(~ele=gapISO, ())
          changeEndDate(~ele=gapISO, ())
          setCalendarVisibility(_ => false)
        }}>
        {React.string("Yesterday")}
      </div>
      <div
        className=optionClass
        onClick={_ => {
          let currentDate = Js.Date.make()
          let gapISO =
            Js.Date.make()
            ->Js.Date.setDate(currentDate->Js.Date.getDate -. 2.0)
            ->Js.Date.fromFloat
            ->processDate

          changeStartDate(~ele=gapISO, ())
          changeEndDate(~ele=gapISO, ())
          setCalendarVisibility(_ => false)
        }}>
        {React.string("Day Before Yesterday")}
      </div>
      <div
        className=optionClass
        onClick={_ => {
          let prevMonday = Js.Date.make()
          let newVar = prevMonday->Js.Date.getDay->Belt.Float.toInt + 6

          prevMonday
          ->Js.Date.setDate(
            (prevMonday->Js.Date.getDate->Belt.Float.toInt - mod(newVar, 7))->Belt.Int.toFloat,
          )
          ->ignore

          prevMonday->setStartDateToToday

          setCalendarVisibility(_ => false)
        }}>
        {React.string("This week so far")}
      </div>
      <div
        className=optionClass
        onClick={_ => {
          let prevMonday = Js.Date.make()
          let newVar = prevMonday->Js.Date.getDay->Belt.Float.toInt + 6

          prevMonday
          ->Js.Date.setDate(
            (prevMonday->Js.Date.getDate->Belt.Float.toInt - mod(newVar, 7))->Belt.Int.toFloat,
          )
          ->ignore

          let mondayOfLastWeek =
            prevMonday->Js.Date.setDate(prevMonday->Js.Date.getDate -. 7.0)->Js.Date.fromFloat

          let sundayOfLastWeek =
            prevMonday->Js.Date.setDate(mondayOfLastWeek->Js.Date.getDate +. 6.0)->Js.Date.fromFloat

          changeStartDate(~ele=mondayOfLastWeek->processDate, ())
          changeEndDate(~ele=sundayOfLastWeek->processDate, ())
          setCalendarVisibility(_ => false)
        }}>
        {React.string("Last Week")}
      </div>
      <div
        className=optionClass
        onClick={_ => {
          Js.Date.make()->Js.Date.setDate(1.0)->Js.Date.fromFloat->setStartDateToToday

          setCalendarVisibility(_ => false)
        }}>
        {React.string("This month so far")}
      </div>
      <div
        className=optionClass
        onClick={_ => {
          let now = Js.Date.make()
          let prevMonthLastDate =
            Js.Date.makeWithYMD(
              ~year=now->Js.Date.getFullYear,
              ~month=now->Js.Date.getMonth,
              ~date=0.0,
              (),
            )->processDate
          let prevMonthFirstDate =
            Js.Date.makeWithYMD(
              ~year=now->Js.Date.getFullYear -. (now->Js.Date.getMonth > 0.0 ? 0.0 : 1.0),
              ~month=mod(now->Js.Date.getMonth->Belt.Float.toInt - 1 + 12, 12)->Belt.Int.toFloat,
              ~date=1.0,
              (),
            )->processDate

          changeStartDate(~ele=prevMonthFirstDate, ())
          changeEndDate(~ele=prevMonthLastDate, ())

          setCalendarVisibility(_ => false)
        }}>
        {React.string("Last Month")}
      </div>
    </>
  }
}

module LastOptions = {
  @react.component
  let make = (~selectLastMin) => {
    <>
      <label className="p-2 pt-4"> {"Last..."->React.string} </label>
      <div className="flex gap-2 flex-wrap p-2">
        {options
        ->Array.mapWithIndex((option, i) => {
          let (val, durationType) = option
          let valStr = val->Belt.Int.toString

          let durationStrOrig = switch durationType {
          | Minute => "minute"
          | Hour => "hour"
          | Day => "day"
          }
          let durationStr = if val === 1 {
            durationStrOrig
          } else {
            `${durationStrOrig}s`
          }
          <div
            key={Belt.Int.toString(i)}
            className="p-2 w-20 border border-jp-gray-400 dark:border-jp-gray-800 dark:hover:border-jp-gray-500 dark:hover:text-white hover:border-jp-gray-800 hover:text-jp-gray-800 cursor-pointer hover:text-jp-gray-500"
            onClick={_ => selectLastMin(val, durationType)}>
            {`${valStr} ${durationStr}`->React.string}
          </div>
        })
        ->React.array}
      </div>
    </>
  }
}

//------------------ Main Component

@react.component
let make = (
  ~input: array<ReactFinalForm.fieldRenderPropsInput>,
  ~showTime=false,
  ~disablePastDates=true,
  ~disableFutureDates=false,
  ~format="YYYY-MM-DDTHH:mm:ss.SSS[Z]",
) => {
  let startInput = input[0]->Belt.Option.getWithDefault(ReactFinalForm.makeFakeInput())
  let endInput = input[1]->Belt.Option.getWithDefault(ReactFinalForm.makeFakeInput())
  let (startTime, setStartTime) = React.useState(_ => "00:00:00")
  let (endTime, setEndTime) = React.useState(_ => "23:59:59")
  let (isDropdownExpanded, setIsDropdownExpanded) = React.useState(_ => false)
  let (calendarVisibility, setCalendarVisibility) = React.useState(_ => false)
  let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
  let customTimezoneToISOString = TimeZoneHook.useCustomTimeZoneToIsoString()

  let dateRangeRef = React.useRef(Js.Nullable.null)
  let dropdownRef = React.useRef(Js.Nullable.null)

  OutsideClick.useOutsideClick(
    ~refs=ArrayOfRef([dateRangeRef, dropdownRef]),
    ~isActive=isDropdownExpanded || calendarVisibility,
    ~callback=() => {
      setIsDropdownExpanded(_ => false)
    },
    (),
  )

  useErroryValueResetter(startInput, isoStringToCustomTimeZone)
  useErroryValueResetter(endInput, isoStringToCustomTimeZone)

  let dropdownVisibilityClass = if isDropdownExpanded {
    "inline-block"
  } else {
    "hidden"
  }

  let buttonIcon = if isDropdownExpanded {
    "angle-up"
  } else {
    "angle-down"
  }

  let changeCalendarVisibility = _ev => {
    setCalendarVisibility(p => !p)
  }

  let stInp = startInput.value->getDateStringForValue(isoStringToCustomTimeZone)
  let startDate = if stInp !== "" {
    stInp
  } else {
    Js.Date.now()
    ->Js.Date.fromFloat
    ->Js.Date.toISOString
    ->InfraDateRangeCustomSelection.getDateString(isoStringToCustomTimeZone)
  }

  let enInp = endInput.value->getDateStringForValue(isoStringToCustomTimeZone)
  let endDate = if enInp !== "" {
    enInp
  } else {
    Js.Date.now()
    ->Js.Date.fromFloat
    ->Js.Date.toISOString
    ->InfraDateRangeCustomSelection.getDateString(isoStringToCustomTimeZone)
  }

  let changeStartDate = (~hour="00", ~min="00", ~sec="00", ~ele, ()) => {
    let startDateSplit = String.split(ele, "-")
    let startDateDay = startDateSplit[2]->Belt.Option.getWithDefault("")
    let startDateYear = startDateSplit[0]->Belt.Option.getWithDefault("")
    let startDateMonth = startDateSplit[1]->Belt.Option.getWithDefault("")
    let startDateTimeCheck = customTimezoneToISOString(
      startDateYear,
      startDateMonth,
      startDateDay,
      hour,
      min,
      sec,
    )
    setStartTime(_ => `${hour}:${min}:${sec}`)
    startInput.onChange(
      TimeZoneHook.formattedISOString(startDateTimeCheck, format)->Identity.stringToFormReactEvent,
    )
  }

  let changeEndDate = (~hour="23", ~min="59", ~sec="59", ~ele, ()) => {
    setIsDropdownExpanded(_ => false)
    let endDateSplit = String.split(ele, "-")
    let endDateDate = endDateSplit[2]->Belt.Option.getWithDefault("")
    let endDateYear = endDateSplit[0]->Belt.Option.getWithDefault("")
    let endDateMonth = endDateSplit[1]->Belt.Option.getWithDefault("")
    let endDateTimeCheck = customTimezoneToISOString(
      endDateYear,
      endDateMonth,
      endDateDate,
      hour,
      min,
      sec,
    )
    setEndTime(_ => `${hour}:${min}:${sec}`)
    endInput.onChange(
      TimeZoneHook.formattedISOString(endDateTimeCheck, format)->Identity.stringToFormReactEvent,
    )
  }

  let processDate = x => {
    x->Js.Date.toISOString->InfraDateRangeCustomSelection.getDateString(isoStringToCustomTimeZone)
  }

  let getFormattedDate = date => {
    date->Js.Date.fromString->Js.Date.toISOString->TimeZoneHook.formattedISOString("YYYY-MM-DD")
  }

  let buttonText = {
    let startDateStr = startDate !== "" ? getFormattedDate(startDate) : "[From-Date]"
    let endDateStr = endDate !== "" ? getFormattedDate(endDate) : "[To-Date]"

    if showTime {
      `${startDateStr}, ${startTime} \u279F ${endDateStr}, ${endTime}`
    } else {
      `${startDateStr} \u279F ${endDateStr}`
    }
  }

  let selectLastMin = (val, durationType) => {
    let currentTime = Js.Date.make()

    let setGapDuration = switch durationType {
    | Minute => Js.Date.setMinutes
    | Hour => Js.Date.setHours
    | Day => Js.Date.setDate
    }

    let getCurrentDuration = switch durationType {
    | Minute => currentTime->Js.Date.getMinutes
    | Hour => currentTime->Js.Date.getHours
    | Day => currentTime->Js.Date.getDate
    }

    let gapISO =
      Js.Date.make()->setGapDuration(getCurrentDuration -. val->Belt.Int.toFloat)->Js.Date.fromFloat

    let currentDate = currentTime->processDate
    let gapDate = gapISO->processDate

    if durationType === Day {
      changeStartDate(~ele=gapDate, ())
      changeEndDate(~ele=currentDate, ())
    } else {
      let {hour: gapHour, minute: gapMinute, second: gapSecond} =
        gapISO->Js.Date.toISOString->isoStringToCustomTimeZone
      changeStartDate(~ele=gapDate, ~hour=gapHour, ~min=gapMinute, ~sec=gapSecond, ())

      let {
        hour: currentHour,
        minute: currentMinute,
        second: currentSecond,
      } = isoStringToCustomTimeZone(currentTime->Js.Date.toISOString)
      changeEndDate(~ele=currentDate, ~hour=currentHour, ~min=currentMinute, ~sec=currentSecond, ())
    }
  }

  <>
    <div className="relative">
      <span ref={dateRangeRef->ReactDOM.Ref.domRef}>
        <Button
          text=buttonText
          leftIcon={FontAwesome("calendar")}
          rightIcon={FontAwesome(buttonIcon)}
          onClick={_ => setIsDropdownExpanded(prev => !prev)}
        />
      </span>
      {isDropdownExpanded
        ? <div
            ref={dropdownRef->ReactDOM.Ref.domRef}
            className={`${dropdownVisibilityClass} absolute z-20`}>
            <div>
              <div className="flex pt-3">
                <div
                  className="m-0 w-80 bg-white dark:bg-jp-gray-950 dark:border-jp-gray-950 dark:text-jp-gray-text_darktheme dark:text-opacity-50 border border-jp-gray-100 shadow-md h-full text-jp-gray-700">
                  <LastOptions selectLastMin />
                  <div>
                    <ul>
                      <PredefinedCustomRange
                        processDate changeStartDate changeEndDate setCalendarVisibility
                      />
                      <div
                        className="px-4 py-2 flex items-center justify-between hover:bg-jp-gray-100 dark:hover:bg-jp-gray-800 cursor-pointer text-sm"
                        onClick={_ => setCalendarVisibility(_ => true)}>
                        {React.string("Custom Input")}
                        <Icon name="angle-right" size=16 />
                      </div>
                    </ul>
                  </div>
                </div>
                {calendarVisibility
                  ? <InfraDateRangeCustomSelection
                      setIsDropdownExpanded
                      disableFutureDates
                      disablePastDates
                      showTime
                      changeCalendarVisibility
                      startDate
                      endDate
                      changeStartDate
                      changeEndDate
                    />
                  : React.null}
              </div>
            </div>
          </div>
        : React.null}
    </div>
  </>
}
