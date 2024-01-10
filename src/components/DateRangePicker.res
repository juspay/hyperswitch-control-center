let defaultCellHighlighter = (_): Calendar.highlighter => {
  {
    highlightSelf: false,
    highlightLeft: false,
    highlightRight: false,
  }
}

let useErroryValueResetter = (value: string, setValue: (string => string) => unit) => {
  React.useEffect0(() => {
    let isErroryTimeValue = _ => {
      try {
        false
      } catch {
      | _error => true
      }
    }
    if value->isErroryTimeValue {
      setValue(_ => "")
    }

    None
  })
}

let getDateStringForValue = (
  value,
  isoStringToCustomTimeZone: string => TimeZoneHook.dateTimeString,
) => {
  if value === "" {
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

let getTimeStringForValue = (
  value,
  isoStringToCustomTimeZone: string => TimeZoneHook.dateTimeString,
) => {
  if value === "" {
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

let getFormattedDate = (date, format) => {
  date->Js.Date.fromString->Js.Date.toISOString->TimeZoneHook.formattedISOString(format)
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

let getStartEndDiff = (startDate, endDate) => {
  let diffTime = Js.Math.abs_float(
    endDate->Js.Date.fromString->Js.Date.getTime -. startDate->Js.Date.fromString->Js.Date.getTime,
  )
  diffTime
}

module PredefinedOption = {
  @react.component
  let make = (
    ~predefinedOptionSelected,
    ~value,
    ~onClick,
    ~disableFutureDates,
    ~disablePastDates,
    ~todayDayJsObj,
    ~isoStringToCustomTimeZone,
    ~isoStringToCustomTimezoneInFloat,
    ~customTimezoneToISOString,
    ~todayDate,
    ~todayTime,
    ~formatDateTime,
    ~isTooltipVisible=true,
  ) => {
    let optionBG = if predefinedOptionSelected === Some(value) {
      "bg-blue-100 dark:bg-jp-gray-850 py-2"
    } else {
      "bg-transparent md:bg-white md:dark:bg-jp-gray-lightgray_background py-2"
    }

    let (stDate, enDate, stTime, enTime) = DateRangeUtils.getPredefinedStartAndEndDate(
      todayDayJsObj,
      isoStringToCustomTimeZone,
      isoStringToCustomTimezoneInFloat,
      customTimezoneToISOString,
      value,
      disableFutureDates,
      disablePastDates,
      todayDate,
      todayTime,
    )

    let startDate = getFormattedDate(`${stDate}T${stTime}Z`, formatDateTime)
    let endDate = getFormattedDate(`${enDate}T${enTime}Z`, formatDateTime)
    let handleClick = _value => {
      onClick(value, disableFutureDates)
    }
    let dateRangeDropdownVal = DateRangeUtils.datetext(value, disableFutureDates)
    <ToolTip
      tooltipWidthClass="w-fit"
      tooltipForWidthClass="!block w-full"
      description={isTooltipVisible ? `${startDate} - ${endDate}` : ""}
      toolTipFor={<AddDataAttributes
        attributes=[("data-daterange-dropdown-value", dateRangeDropdownVal)]>
        <div>
          <div
            className={`${optionBG} px-4 py-2 hover:bg-jp-gray-100 hover:bg-opacity-75 dark:hover:bg-jp-gray-850 dark:hover:bg-opacity-100  cursor-pointer text-sm text-gray-500 dark:text-gray-400`}
            onClick=handleClick>
            {React.string(dateRangeDropdownVal)}
          </div>
        </div>
      </AddDataAttributes>}
      toolTipPosition=Right
      contentAlign=Left
    />
  }
}

module Base = {
  @react.component
  let make = (
    ~startDateVal: string,
    ~setStartDateVal: (string => string) => unit,
    ~endDateVal: string,
    ~setEndDateVal: (string => string) => unit,
    ~showTime=false,
    ~disable=false,
    ~disablePastDates=true,
    ~disableFutureDates=false,
    ~predefinedDays=[],
    ~format="YYYY-MM-DDTHH:mm:ss.SSS[Z]",
    ~numMonths=1,
    ~disableApply=true,
    ~removeFilterOption=false,
    ~dateRangeLimit=?,
    ~optFieldKey as _=?,
    ~textHideInMobileView=true,
    ~showSeconds=true,
    ~hideDate=false,
    ~selectStandardTime=false,
    ~buttonType=?,
    ~customButtonStyle=?,
    ~buttonText="",
    ~allowedDateRange=?,
    ~textStyle=?,
    ~standardTimeToday=false,
    ~removeConversion=false,
    ~customborderCSS="",
    ~isTooltipVisible=true,
  ) => {
    open DateRangeUtils
    let (isCustomSelected, setIsCustomSelected) = React.useState(_ =>
      predefinedDays->Array.length === 0
    )
    let formatDateTime = showSeconds ? "MMM DD, YYYY HH:mm:ss" : "MMM DD, YYYY HH:mm"
    let (showOption, setShowOption) = React.useState(_ => false)
    let customTimezoneToISOString = TimeZoneHook.useCustomTimeZoneToIsoString()
    let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
    let isoStringToCustomTimezoneInFloat = TimeZoneHook.useIsoStringToCustomTimeZoneInFloat()

    let (clickedDates, setClickedDates) = React.useState(_ => [])

    let (localStartDate, setLocalStartDate) = React.useState(_ => startDateVal)
    let (localEndDate, setLocalEndDate) = React.useState(_ => endDateVal)
    let (_localOpt, setLocalOpt) = React.useState(_ => "")
    let (showMsg, setShowMsg) = React.useState(_ => false)

    let (isDropdownExpanded, setIsDropdownExpanded) = React.useState(_ => false)
    let (calendarVisibility, setCalendarVisibility) = React.useState(_ => false)
    let isMobileView = MatchMedia.useMobileChecker()
    let isFilterSection = React.useContext(TableFilterSectionContext.filterSectionContext)

    let dropdownPosition = isFilterSection && !isMobileView && isCustomSelected ? "right-0" : ""

    let todayDayJsObj = React.useMemo1(() => {
      Js.Date.make()->Js.Date.toString->DayJs.getDayJsForString
    }, [isDropdownExpanded])

    let currentTime = todayDayJsObj.format(. "HH:mm")
    let todayDate = todayDayJsObj.format(. "YYYY-MM-DD")
    let todayTime = React.useMemo1(() => {
      todayDayJsObj.format(. "HH:mm:ss")
    }, [currentTime])

    let initialStartTime = disableFutureDates || selectStandardTime ? "00:00:00" : "23:59:59"
    let initialEndTime = disableFutureDates || selectStandardTime ? "23:59:59" : "00:00:00"
    React.useEffect2(() => {
      setLocalStartDate(_ => startDateVal)
      setLocalEndDate(_ => endDateVal)
      setLocalOpt(_ => "")
      None
    }, (startDateVal, endDateVal))

    let resetStartEndInput = () => {
      setLocalStartDate(_ => "")
      setLocalEndDate(_ => "")
      setLocalOpt(_ => "")
    }

    React.useEffect2(() => {
      switch dateRangeLimit {
      | Some(maxLen) => {
          let diff = getStartEndDiff(localStartDate, localEndDate)
          if diff > (maxLen->Belt.Int.toFloat *. 24. *. 60. *. 60. -. 1.) *. 1000. {
            setShowMsg(_ => true)
            resetStartEndInput()
          }
        }

      | None => ()
      }
      None
    }, (localStartDate, localEndDate))

    let dateRangeRef = React.useRef(Js.Nullable.null)
    let dropdownRef = React.useRef(Js.Nullable.null)

    useErroryValueResetter(startDateVal, setStartDateVal)
    useErroryValueResetter(endDateVal, setEndDateVal)

    let startDate = localStartDate->getDateStringForValue(isoStringToCustomTimeZone)
    let endDate = localEndDate->getDateStringForValue(isoStringToCustomTimeZone)

    let isDropdownExpandedActual = isDropdownExpanded && calendarVisibility

    let dropdownVisibilityClass = if isDropdownExpandedActual {
      "inline-block"
    } else {
      "hidden"
    }
    let saveDates = () => {
      if localStartDate !== "" && localEndDate !== "" {
        setStartDateVal(_ => localStartDate)
        setEndDateVal(_ => localEndDate)
      }
    }
    let resetToInitalValues = () => {
      setLocalStartDate(_ => startDateVal)
      setLocalEndDate(_ => endDateVal)
      setLocalOpt(_ => "")
    }

    OutsideClick.useOutsideClick(
      ~refs=ArrayOfRef([dateRangeRef, dropdownRef]),
      ~isActive=isDropdownExpanded || calendarVisibility,
      ~callback=() => {
        setIsDropdownExpanded(_ => false)
        setCalendarVisibility(p => !p)
        if isDropdownExpandedActual && isCustomSelected {
          resetToInitalValues()
        }
      },
      (),
    )

    let changeEndDate = (ele, isFromCustomInput, time) => {
      if disableApply {
        setIsDropdownExpanded(_ => false)
      }
      if localEndDate == ele && isFromCustomInput {
        setEndDateVal(_ => "")
      } else {
        let endDateSplit = String.split(ele, "-")
        let endDateDate = endDateSplit[2]->Belt.Option.getWithDefault("")
        let endDateYear = endDateSplit[0]->Belt.Option.getWithDefault("")
        let endDateMonth = endDateSplit[1]->Belt.Option.getWithDefault("")
        let splitTime = switch time {
        | Some(val) => val
        | None =>
          if disableFutureDates && ele == todayDate {
            todayTime
          } else {
            initialEndTime
          }
        }

        let timeSplit = String.split(splitTime, ":")
        let timeHour = timeSplit->Belt.Array.get(0)->Belt.Option.getWithDefault("00")
        let timeMinute = timeSplit->Belt.Array.get(1)->Belt.Option.getWithDefault("00")
        let timeSecond = timeSplit->Belt.Array.get(2)->Belt.Option.getWithDefault("00")
        let endDateTimeCheck = customTimezoneToISOString(
          endDateYear,
          endDateMonth,
          endDateDate,
          timeHour,
          timeMinute,
          timeSecond,
        )
        setLocalEndDate(_ => TimeZoneHook.formattedISOString(endDateTimeCheck, format))
      }
    }
    let changeStartDate = (ele, isFromCustomInput, time) => {
      let setDate = str => {
        let startDateSplit = String.split(str, "-")
        let startDateDay = startDateSplit[2]->Belt.Option.getWithDefault("")
        let startDateYear = startDateSplit[0]->Belt.Option.getWithDefault("")
        let startDateMonth = startDateSplit[1]->Belt.Option.getWithDefault("")
        let splitTime = switch time {
        | Some(val) => val
        | None =>
          if !disableFutureDates && ele == todayDate && !standardTimeToday {
            todayTime
          } else {
            initialStartTime
          }
        }
        let timeSplit = String.split(splitTime, ":")
        let timeHour = timeSplit->Belt.Array.get(0)->Belt.Option.getWithDefault("00")
        let timeMinute = timeSplit->Belt.Array.get(1)->Belt.Option.getWithDefault("00")
        let timeSecond = timeSplit->Belt.Array.get(2)->Belt.Option.getWithDefault("00")
        let startDateTimeCheck = customTimezoneToISOString(
          startDateYear,
          startDateMonth,
          startDateDay,
          timeHour,
          timeMinute,
          timeSecond,
        )

        setLocalStartDate(_ => TimeZoneHook.formattedISOString(startDateTimeCheck, format))
      }
      let resetStartDate = () => {
        resetStartEndInput()
        setDate(ele)
      }
      if startDate != "" && startDate == ele && isFromCustomInput {
        changeEndDate(ele, isFromCustomInput, None)
      } else if startDate != "" && startDate > ele && isFromCustomInput {
        resetStartDate()
      } else if endDate != "" && startDate == ele && isFromCustomInput {
        resetStartDate()
      } else if (
        ele > startDate && ele < endDate && startDate != "" && endDate != "" && isFromCustomInput
      ) {
        resetStartDate()
      } else if startDate != "" && endDate != "" && ele > endDate && isFromCustomInput {
        resetStartDate()
      } else {
        ()
      }

      if !isFromCustomInput || startDate == "" {
        setDate(ele)
      }

      if (
        (startDate != "" && endDate == "" && !isFromCustomInput) ||
          (startDate != "" &&
          endDate == "" &&
          isStartBeforeEndDate(startDate, ele) &&
          isFromCustomInput)
      ) {
        changeEndDate(ele, isFromCustomInput, None)
      }
    }

    let onDateClick = str => {
      let data = switch Belt.Array.getBy(clickedDates, x => x == str) {
      | Some(_d) => Belt.Array.keep(clickedDates, x => x != str)
      | None => Belt.Array.concat(clickedDates, [str])
      }
      let dat = data->Array.map(x => x)
      setClickedDates(_ => dat)
      changeStartDate(str, true, None)
    }

    let handleApply = _ev => {
      setShowOption(_ => false)
      setCalendarVisibility(p => !p)
      setIsDropdownExpanded(_ => false)
      saveDates()
    }

    let cancelButton = _ => {
      resetToInitalValues()
      setCalendarVisibility(p => !p)
      setIsDropdownExpanded(_ => false)
    }

    let selectedStartDate = if localStartDate != "" {
      getFormattedDate(
        localStartDate->getDateStringForValue(isoStringToCustomTimeZone),
        "YYYY-MM-DD",
      )
    } else {
      ""
    }
    let selectedEndDate = if localEndDate != "" {
      getFormattedDate(localEndDate->getDateStringForValue(isoStringToCustomTimeZone), "YYYY-MM-DD")
    } else {
      ""
    }
    let setStartDate = (~date, ~time) => {
      if date != "" {
        let timestamp = changeTimeFormat(~date, ~time, ~customTimezoneToISOString, ~format)
        setLocalStartDate(_ => timestamp)
      }
    }
    let setEndDate = (~date, ~time) => {
      if date != "" {
        let timestamp = changeTimeFormat(~date, ~time, ~customTimezoneToISOString, ~format)
        setLocalEndDate(_ => timestamp)
      }
    }
    let startTimeInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ev => (),
      onChange: timeValEv => {
        let startTimeVal = timeValEv->Identity.formReactEventToString
        let endTime = localEndDate->getTimeStringForValue(isoStringToCustomTimeZone)

        if localStartDate !== "" {
          if disableFutureDates && selectedStartDate == todayDate && startTimeVal > todayTime {
            setStartDate(~date=startDate, ~time=todayTime)
          } else if (
            disableFutureDates && selectedStartDate == selectedEndDate && startTimeVal > endTime
          ) {
            ()
          } else {
            setStartDate(~date=startDate, ~time=startTimeVal)
          }
        }
      },
      onFocus: _ev => (),
      value: localStartDate->getTimeStringForValue(isoStringToCustomTimeZone)->Js.Json.string,
      checked: false,
    }
    let endTimeInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ev => (),
      onChange: timeValEv => {
        let endTimeVal = timeValEv->Identity.formReactEventToString
        let startTime = localStartDate->getTimeStringForValue(isoStringToCustomTimeZone)
        if localEndDate !== "" {
          if disableFutureDates && selectedEndDate == todayDate && endTimeVal > todayTime {
            setEndDate(~date=startDate, ~time=todayTime)
          } else if (
            disableFutureDates && selectedStartDate == selectedEndDate && endTimeVal < startTime
          ) {
            ()
          } else {
            setEndDate(~date=endDate, ~time=endTimeVal)
          }
        }
      },
      onFocus: _ev => (),
      value: localEndDate->getTimeStringForValue(isoStringToCustomTimeZone)->Js.Json.string,
      checked: false,
    }

    let startDateStr =
      startDateVal !== ""
        ? getFormattedDate(
            startDateVal->getDateStringForValue(isoStringToCustomTimeZone),
            "MMM DD, YYYY",
          )
        : buttonText != ""
        ? buttonText
        : "[From-Date]"
    let endDateStr =
      endDateVal !== ""
        ? getFormattedDate(
            endDateVal->getDateStringForValue(isoStringToCustomTimeZone),
            "MMM DD, YYYY",
          )
        : buttonText != ""
        ? ""
        : "[To-Date]"
    let startTimeStr =
      startDateVal !== ""
        ? startDateVal->getTimeStringForValue(isoStringToCustomTimeZone)
        : "00:00:00"
    let endTimeStr =
      startDateVal !== ""
        ? endDateVal->getTimeStringForValue(isoStringToCustomTimeZone)
        : "23:59:59"

    let endTimeStr = {
      let timeArr = endTimeStr->String.split(":")
      let endTimeTxt = `${timeArr[0]->Belt.Option.getWithDefault(
          "00",
        )}:${timeArr[1]->Belt.Option.getWithDefault("00")}`
      showSeconds ? `${endTimeTxt}:${timeArr[2]->Belt.Option.getWithDefault("00")}` : endTimeTxt
    }
    let startTimeStr = {
      let timeArr = startTimeStr->String.split(":")
      let startTimeTxt = `${timeArr[0]->Belt.Option.getWithDefault(
          "00",
        )}:${timeArr[1]->Belt.Option.getWithDefault("00")}`
      showSeconds ? `${startTimeTxt}:${timeArr[2]->Belt.Option.getWithDefault("00")}` : startTimeTxt
    }

    let buttonText = {
      startDateVal->String.length === 0 && endDateVal->String.length === 0
        ? `Select Date ${showTime ? "and Time" : ""}`
        : showTime
        ? `${startDateStr} ${startTimeStr} - ${endDateStr} ${endTimeStr}`
        : `${startDateStr} ${startDateStr === buttonText ? "" : "-"} ${endDateStr}`
    }

    let buttonIcon = isDropdownExpanded ? "angle-up" : "angle-down"

    let handlePredefinedOptionClick = (value, disableFutureDates) => {
      setIsCustomSelected(_ => false)
      setCalendarVisibility(_ => false)
      setIsDropdownExpanded(_ => false)
      setShowOption(_ => false)
      let (stDate, enDate, stTime, enTime) = DateRangeUtils.getPredefinedStartAndEndDate(
        todayDayJsObj,
        isoStringToCustomTimeZone,
        isoStringToCustomTimezoneInFloat,
        customTimezoneToISOString,
        value,
        disableFutureDates,
        disablePastDates,
        todayDate,
        todayTime,
      )

      resetStartEndInput()

      setStartDate(~date=startDate, ~time=stTime)
      setEndDate(~date=endDate, ~time=enTime)
      setLocalOpt(_ =>
        DateRangeUtils.datetext(value, disableFutureDates)
        ->String.toLowerCase
        ->String.split(" ")
        ->Array.joinWith("_")
      )
      changeStartDate(stDate, false, Some(stTime))
      changeEndDate(enDate, false, Some(enTime))
    }

    let handleDropdownClick = () => {
      if predefinedDays->Array.length > 0 {
        if calendarVisibility {
          setCalendarVisibility(_ => false)
          setShowOption(_ => !isDropdownExpanded)
          setIsDropdownExpanded(_ => !isDropdownExpanded)
          setShowOption(_ => !isCustomSelected)
        } else {
          setIsDropdownExpanded(_ => true)
          setShowOption(_ => true)
          setCalendarVisibility(_ => true)
        }
      } else {
        setIsDropdownExpanded(_p => !isDropdownExpanded)
        setCalendarVisibility(_ => !isDropdownExpanded)
      }
    }

    let displayStartDate = convertTimeStamp(
      ~isoStringToCustomTimeZone,
      localStartDate,
      formatDateTime,
    )
    let modifiedStartDate = if removeConversion {
      (displayStartDate->DayJs.getDayJsForString).subtract(. 330, "minute").format(.
        "YYYY-MM-DDTHH:mm:ss[Z]",
      )
    } else {
      displayStartDate
    }

    let displayEndDate = convertTimeStamp(~isoStringToCustomTimeZone, localEndDate, formatDateTime)

    let modifiedEndDate = if removeConversion {
      (displayEndDate->DayJs.getDayJsForString).subtract(. 330, "minute").format(.
        "YYYY-MM-DDTHH:mm:ss[Z]",
      )
    } else {
      displayEndDate
    }

    React.useEffect4(() => {
      if startDate !== "" && endDate !== "" {
        if localStartDate !== "" && localEndDate !== "" && (disableApply || !isCustomSelected) {
          saveDates()
        }

        if disableApply {
          setShowOption(_ => false)
        }
      }
      None
    }, (startDate, endDate, localStartDate, localEndDate))

    let btnStyle = customButtonStyle->Belt.Option.getWithDefault("")

    let customStyleForBtn = btnStyle->String.length > 0 ? btnStyle : ""

    let timeVisibilityClass = showTime ? "block" : "hidden"

    let getDiffForPredefined = predefinedDay => {
      let (stDate, enDate, stTime, enTime) = DateRangeUtils.getPredefinedStartAndEndDate(
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
        ~format="YYYY-MM-DDTHH:mm:00[Z]",
      )
      let endTimestamp = changeTimeFormat(
        ~date=enDate,
        ~time=enTime,
        ~customTimezoneToISOString,
        ~format="YYYY-MM-DDTHH:mm:00[Z]",
      )
      getStartEndDiff(startTimestamp, endTimestamp)
    }

    let predefinedOptionSelected = predefinedDays->Array.find(item => {
      let startDate = convertTimeStamp(
        ~isoStringToCustomTimeZone,
        startDateVal,
        "YYYY-MM-DDTHH:mm:00[Z]",
      )
      let endDate = convertTimeStamp(
        ~isoStringToCustomTimeZone,
        endDateVal,
        "YYYY-MM-DDTHH:mm:00[Z]",
      )
      let difference = getStartEndDiff(startDate, endDate)
      getDiffForPredefined(item) === difference
    })

    let filteredPredefinedDays = {
      switch dateRangeLimit {
      | Some(limit) =>
        predefinedDays->Array.filter(item => {
          getDiffForPredefined(item) <=
          (limit->Belt.Float.fromInt *. 24. *. 60. *. 60. -. 1.) *. 1000.
        })
      | None => predefinedDays
      }
    }

    let customeRangeBg = switch predefinedOptionSelected {
    | Some(_) => "bg-white dark:bg-jp-gray-lightgray_background"
    | None => "bg-jp-gray-100 dark:bg-jp-gray-850"
    }

    let removeApplyFilter = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      resetToInitalValues()
      setStartDateVal(_ => "")
      setEndDateVal(_ => "")
    }

    let buttonType: option<Button.buttonType> = buttonType
    let calendarIcon = "calendar"
    let arrowIconSize = 14
    let strokeColor = if disable {
      "stroke-jp-2-light-gray-600"
    } else if isDropdownExpandedActual {
      "stroke-jp-2-light-gray-1700"
    } else {
      "stroke-jp-2-light-gray-1100"
    }

    let iconElement = {
      <div className="flex flex-row gap-2">
        <Icon className=strokeColor name=buttonIcon size=arrowIconSize />
        {if removeFilterOption && startDateVal !== "" && endDateVal !== "" {
          <Icon name="crossicon" size=16 onClick=removeApplyFilter />
        } else {
          React.null
        }}
      </div>
    }

    let calendarElement =
      <div className={`flex md:flex-row flex-col w-full`}>
        {if predefinedDays->Array.length > 0 && showOption {
          <AddDataAttributes attributes=[("data-date-picker-predifined", "predefined-options")]>
            <div className="flex flex-wrap md:flex-col">
              {filteredPredefinedDays
              ->Array.mapWithIndex((value, i) => {
                <div
                  key={i->string_of_int}
                  className="w-1/3 md:w-full md:min-w-max text-center md:text-start">
                  <PredefinedOption
                    predefinedOptionSelected
                    value
                    onClick=handlePredefinedOptionClick
                    disableFutureDates
                    disablePastDates
                    todayDayJsObj
                    isoStringToCustomTimeZone
                    isoStringToCustomTimezoneInFloat
                    customTimezoneToISOString
                    todayDate
                    todayTime
                    formatDateTime
                    isTooltipVisible
                  />
                </div>
              })
              ->React.array}
              <div
                className={`text-center md:text-start min-w-max bg-white dark:bg-jp-gray-lightgray_background w-1/3 px-4 py-2  hover:bg-jp-gray-100 hover:bg-opacity-75 dark:hover:bg-jp-gray-850 dark:hover:bg-opacity-100 cursor-pointer text-sm text-gray-500 dark:text-gray-400 ${customeRangeBg}}`}
                onClick={_ => {
                  setCalendarVisibility(_ => true)
                  setIsCustomSelected(_ => true)
                }}>
                {React.string("Custom Range")}
              </div>
            </div>
          </AddDataAttributes>
        } else {
          React.null
        }}
        <AddDataAttributes attributes=[("data-date-picker-section", "date-picker-calendar")]>
          <div
            className={calendarVisibility && isCustomSelected
              ? "w-auto md:w-max h-auto"
              : "hidden"}>
            <CalendarList
              count=numMonths
              cellHighlighter=defaultCellHighlighter
              startDate
              endDate
              onDateClick
              disablePastDates
              disableFutureDates
              ?dateRangeLimit
              setShowMsg
              calendarContaierStyle="md:m-3 border-0 md:border"
              ?allowedDateRange
            />
            <div
              className={`${timeVisibilityClass} w-full flex flex-row md:gap-4 p-3 justify-around md:justify-start dark:text-gray-400 text-gray-700 `}>
              <TimeInput input=startTimeInput showSeconds label="From" />
              <TimeInput input=endTimeInput showSeconds label="To" />
            </div>
            {if disableApply {
              React.null
            } else {
              <div
                id="neglectTopbarTheme"
                className="flex flex-row flex-wrap gap-4 bg-white dark:bg-jp-gray-lightgray_background p-3 align-center justify-end ">
                <div
                  className="text-gray-700 font-fira-code dark:text-gray-400 flex-wrap font-medium self-center text-sm">
                  {if displayStartDate != "" && displayEndDate != "" && !disableApply && !hideDate {
                    <div className="flex flex-col">
                      <AddDataAttributes attributes=[("data-date-range-start", displayStartDate)]>
                        <div> {React.string(modifiedStartDate)} </div>
                      </AddDataAttributes>
                      <AddDataAttributes attributes=[("data-date-range-end", displayEndDate)]>
                        <div> {React.string(modifiedEndDate)} </div>
                      </AddDataAttributes>
                    </div>
                  } else if showMsg {
                    let msg = `Date Range should not exceed ${dateRangeLimit
                      ->Belt.Option.getWithDefault(0)
                      ->Belt.Int.toString} days`
                    <span className="w-full flex flex-row items-center mr-0 text-red-500">
                      <FormErrorIcon />
                      {React.string(msg)}
                    </span>
                  } else {
                    React.null
                  }}
                </div>
                <Button
                  text="Cancel"
                  buttonType=Secondary
                  buttonState=Normal
                  buttonSize=Small
                  onClick={cancelButton}
                />
                <Button
                  text="Apply"
                  buttonType=Primary
                  buttonState={endDate == "" ? Disabled : Normal}
                  buttonSize=Small
                  onClick={handleApply}
                />
              </div>
            }}
          </div>
        </AddDataAttributes>
      </div>

    <>
      <div className={"md:relative daterangSelection"}>
        <AddDataAttributes
          attributes=[
            ("data-date-picker", `dateRangePicker${isFilterSection ? "-Filter" : ""}`),
            ("data-date-picker-start-date", `${startDateStr} ${startTimeStr}`),
            ("data-date-picker-end-date", `${endDateStr} ${endTimeStr}`),
          ]>
          <div ref={dateRangeRef->ReactDOM.Ref.domRef}>
            <Button
              text={isMobileView && textHideInMobileView ? "" : buttonText}
              leftIcon={FontAwesome(calendarIcon)}
              rightIcon={CustomIcon(iconElement)}
              buttonSize=Small
              isDropdownOpen=isDropdownExpandedActual
              onClick={_ => handleDropdownClick()}
              iconBorderColor={customborderCSS}
              customButtonStyle={customStyleForBtn}
              buttonState={disable ? Disabled : Normal}
              ?buttonType
              ?textStyle
            />
          </div>
        </AddDataAttributes>
        {if isDropdownExpandedActual {
          if isMobileView {
            <BottomModal headerText={buttonText} onCloseClick={cancelButton}>
              calendarElement
            </BottomModal>
          } else {
            <div
              ref={dropdownRef->ReactDOM.Ref.domRef}
              className={`${dropdownVisibilityClass} absolute ${dropdownPosition} z-20 bg-white dark:bg-jp-gray-lightgray_background rounded border-jp-gray-500 dark:border-jp-gray-960 shadow-md dark:shadow-sm dark:shadow-gray-700 max-h-min max-w-min overflow-auto`}>
              calendarElement
            </div>
          }
        } else {
          React.null
        }}
      </div>
    </>
  }
}

let useStateForInput = (input: ReactFinalForm.fieldRenderPropsInput) => {
  React.useMemo1(() => {
    let val = input.value->Js.Json.decodeString->Belt.Option.getWithDefault("")
    let onChange = fn => {
      let newVal = fn(val)
      input.onChange(newVal->Identity.stringToFormReactEvent)
    }

    (val, onChange)
  }, [input])
}

@react.component
let make = (
  ~startKey: string,
  ~endKey: string,
  ~showTime=false,
  ~disable=false,
  ~disablePastDates=true,
  ~disableFutureDates=false,
  ~predefinedDays=[],
  ~format="YYYY-MM-DDTHH:mm:ss.SSS[Z]",
  ~numMonths=1,
  ~disableApply=true,
  ~removeFilterOption=false,
  ~dateRangeLimit=?,
  ~optFieldKey=?,
  ~textHideInMobileView=true,
  ~showSeconds=true,
  ~hideDate=false,
  ~allowedDateRange=?,
  ~selectStandardTime=false,
  ~customButtonStyle=?,
  ~buttonText="",
  ~textStyle=?,
  ~standardTimeToday=false,
  ~removeConversion=false,
  ~isTooltipVisible=true,
) => {
  let startInput = ReactFinalForm.useField(startKey).input
  let endInput = ReactFinalForm.useField(endKey).input
  let (startDateVal, setStartDateVal) = useStateForInput(startInput)
  let (endDateVal, setEndDateVal) = useStateForInput(endInput)

  <Base
    startDateVal
    setStartDateVal
    endDateVal
    setEndDateVal
    showTime
    disable
    disablePastDates
    disableFutureDates
    predefinedDays
    format
    numMonths
    disableApply
    removeFilterOption
    ?dateRangeLimit
    ?optFieldKey
    textHideInMobileView
    showSeconds
    hideDate
    selectStandardTime
    ?customButtonStyle
    buttonText
    ?allowedDateRange
    ?textStyle
    standardTimeToday
    removeConversion
    isTooltipVisible
  />
}
