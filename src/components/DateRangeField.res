let defaultCellHighlighter = (_): Calendar.highlighter => {
  {
    highlightSelf: false,
    highlightLeft: false,
    highlightRight: false,
  }
}

let useErroryValueResetter = (value: string, setValue: (string => string) => unit) => {
  React.useEffect(() => {
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
  }, [])
}

let isStartBeforeEndDate = (start, end) => {
  let getDate = date => {
    let datevalue = Js.Date.makeWithYMD(
      ~year=Js.Float.fromString(date[0]->Option.getOr("")),
      ~month=Js.Float.fromString(
        String.make(Js.Float.fromString(date[1]->Option.getOr("")) -. 1.0),
      ),
      ~date=Js.Float.fromString(date[2]->Option.getOr("")),
      (),
    )
    datevalue
  }
  let startDate = getDate(String.split(start, "-"))
  let endDate = getDate(String.split(end, "-"))
  startDate < endDate
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
    open DateRangeUtils
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
    let dateRangeDropdownVal = datetext(value, disableFutureDates)
    <ToolTip
      tooltipWidthClass="w-fit"
      tooltipForWidthClass="!block w-full"
      description={isTooltipVisible ? `${startDate} - ${endDate}` : ""}
      toolTipFor={<AddDataAttributes
        attributes=[("data-daterange-dropdown-value", dateRangeDropdownVal)]>
        <div>
          <div
            className={`${optionBG} mx-2 rounded-md p-2 hover:bg-jp-gray-100 hover:bg-opacity-75 dark:hover:bg-jp-gray-850 dark:hover:bg-opacity-100  cursor-pointer text-sm font-medium text-grey-900`}
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
    ~buttonText="",
    ~allowedDateRange=?,
    ~textStyle=?,
    ~standardTimeToday=false,
    ~removeConversion=false,
    ~customborderCSS="",
    ~isTooltipVisible=true,
    ~events=?,
    ~customButtonStyle="",
  ) => {
    open DateRangeUtils
    open LogicUtils
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

    let (isDropdownExpanded, setIsDropdownExpanded) = React.useState(_ => false)
    let (calendarVisibility, setCalendarVisibility) = React.useState(_ => false)
    let isMobileView = MatchMedia.useMobileChecker()
    let isFilterSection = React.useContext(TableFilterSectionContext.filterSectionContext)

    let dropdownPosition = isFilterSection && !isMobileView && isCustomSelected ? "right-0" : ""

    let todayDayJsObj = React.useMemo(() => {
      Date.make()->Date.toString->DayJs.getDayJsForString
    }, [isDropdownExpanded])

    let currentTime = todayDayJsObj.format("HH:mm")
    let todayDate = todayDayJsObj.format("YYYY-MM-DD")
    let todayTime = React.useMemo(() => {
      todayDayJsObj.format("HH:mm:ss")
    }, [currentTime])

    let initialStartTime = disableFutureDates || selectStandardTime ? "00:00:00" : "23:59:59"
    let initialEndTime = disableFutureDates || selectStandardTime ? "23:59:59" : "00:00:00"
    React.useEffect(() => {
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
    let handleEvent = React.useCallback(() => {
      switch events {
      | Some(fn) => fn()
      | _ => ()
      }
    }, [events])

    React.useEffect(() => {
      switch dateRangeLimit {
      | Some(maxLen) => {
          let diff = getStartEndDiff(localStartDate, localEndDate)
          if diff > (maxLen->Int.toFloat *. 24. *. 60. *. 60. -. 1.) *. 1000. {
            resetStartEndInput()
          }
        }

      | None => ()
      }
      None
    }, (localStartDate, localEndDate))

    React.useEffect(() => {
      if isDropdownExpanded == true {
        handleEvent()
      }

      None
    }, [isDropdownExpanded])

    let dateRangeRef = React.useRef(Nullable.null)
    let dropdownRef = React.useRef(Nullable.null)

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
      if localStartDate->isNonEmptyString && localEndDate->isNonEmptyString {
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
    )

    let changeEndDate = (ele, isFromCustomInput, time) => {
      if disableApply {
        setIsDropdownExpanded(_ => false)
      }
      if localEndDate == ele && isFromCustomInput {
        setEndDateVal(_ => "")
      } else {
        let endDateSplit = String.split(ele, "-")
        let endDateDate = endDateSplit[2]->Option.getOr("")
        let endDateYear = endDateSplit[0]->Option.getOr("")
        let endDateMonth = endDateSplit[1]->Option.getOr("")
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
        let timeHour = timeSplit->Array.get(0)->Option.getOr("00")
        let timeMinute = timeSplit->Array.get(1)->Option.getOr("00")
        let timeSecond = timeSplit->Array.get(2)->Option.getOr("00")
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
        let startDateDay = startDateSplit[2]->Option.getOr("")
        let startDateYear = startDateSplit[0]->Option.getOr("")
        let startDateMonth = startDateSplit[1]->Option.getOr("")
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
        let timeHour = timeSplit->Array.get(0)->Option.getOr("00")
        let timeMinute = timeSplit->Array.get(1)->Option.getOr("00")
        let timeSecond = timeSplit->Array.get(2)->Option.getOr("00")
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
      if startDate->isNonEmptyString && startDate == ele && isFromCustomInput {
        changeEndDate(ele, isFromCustomInput, None)
      } else if startDate->isNonEmptyString && startDate > ele && isFromCustomInput {
        resetStartDate()
      } else if endDate->isNonEmptyString && startDate == ele && isFromCustomInput {
        resetStartDate()
      } else if (
        ele > startDate &&
        ele < endDate &&
        startDate->isNonEmptyString &&
        endDate->isNonEmptyString &&
        isFromCustomInput
      ) {
        resetStartDate()
      } else if (
        startDate->isNonEmptyString &&
        endDate->isNonEmptyString &&
        ele > endDate &&
        isFromCustomInput
      ) {
        resetStartDate()
      } else {
        ()
      }

      if !isFromCustomInput || startDate->isEmptyString {
        setDate(ele)
      }

      if (
        (startDate->isNonEmptyString && endDate->isEmptyString && !isFromCustomInput) ||
          (startDate->isNonEmptyString &&
          endDate->isEmptyString &&
          isStartBeforeEndDate(startDate, ele) &&
          isFromCustomInput)
      ) {
        changeEndDate(ele, isFromCustomInput, None)
      }
    }

    let onDateClick = str => {
      let data = switch Array.find(clickedDates, x => x == str) {
      | Some(_d) => Belt.Array.keep(clickedDates, x => x != str)
      | None => Array.concat(clickedDates, [str])
      }
      let dat = data->Array.map(x => x)
      setClickedDates(_ => dat)
      changeStartDate(str, true, None)
    }

    let handleApply = _ => {
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

    let selectedStartDate = if localStartDate->isNonEmptyString {
      getFormattedDate(
        localStartDate->getDateStringForValue(isoStringToCustomTimeZone),
        "YYYY-MM-DD",
      )
    } else {
      ""
    }
    let selectedEndDate = if localEndDate->isNonEmptyString {
      getFormattedDate(localEndDate->getDateStringForValue(isoStringToCustomTimeZone), "YYYY-MM-DD")
    } else {
      ""
    }
    let setStartDate = (~date, ~time) => {
      if date->isNonEmptyString {
        let timestamp = changeTimeFormat(~date, ~time, ~customTimezoneToISOString, ~format)
        setLocalStartDate(_ => timestamp)
      }
    }
    let setEndDate = (~date, ~time) => {
      if date->isNonEmptyString {
        let timestamp = changeTimeFormat(~date, ~time, ~customTimezoneToISOString, ~format)
        setLocalEndDate(_ => timestamp)
      }
    }
    let startTimeInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ => (),
      onChange: timeValEv => {
        let startTimeVal = timeValEv->Identity.formReactEventToString
        let endTime = localEndDate->getTimeStringForValue(isoStringToCustomTimeZone)

        if localStartDate->isNonEmptyString {
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
      onFocus: _ => (),
      value: localStartDate->getTimeStringForValue(isoStringToCustomTimeZone)->JSON.Encode.string,
      checked: false,
    }
    let endTimeInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ => (),
      onChange: timeValEv => {
        let endTimeVal = timeValEv->Identity.formReactEventToString
        let startTime = localStartDate->getTimeStringForValue(isoStringToCustomTimeZone)
        if localEndDate->isNonEmptyString {
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
      onFocus: _ => (),
      value: localEndDate->getTimeStringForValue(isoStringToCustomTimeZone)->JSON.Encode.string,
      checked: false,
    }

    let startDateStr =
      startDateVal->isNonEmptyString
        ? getFormattedDate(
            startDateVal->getDateStringForValue(isoStringToCustomTimeZone),
            "MMM DD, YYYY",
          )
        : buttonText->isNonEmptyString
        ? buttonText
        : "[From-Date]"
    let endDateStr =
      endDateVal->isNonEmptyString
        ? getFormattedDate(
            endDateVal->getDateStringForValue(isoStringToCustomTimeZone),
            "MMM DD, YYYY",
          )
        : buttonText->isNonEmptyString
        ? ""
        : "[To-Date]"
    let startTimeStr =
      startDateVal->isNonEmptyString
        ? startDateVal->getTimeStringForValue(isoStringToCustomTimeZone)
        : "00:00:00"
    let endTimeStr =
      startDateVal->isNonEmptyString
        ? endDateVal->getTimeStringForValue(isoStringToCustomTimeZone)
        : "23:59:59"

    let endTimeStr = {
      let timeArr = endTimeStr->String.split(":")
      let endTimeTxt = `${timeArr[0]->Option.getOr("00")}:${timeArr[1]->Option.getOr("00")}`
      showSeconds ? `${endTimeTxt}:${timeArr[2]->Option.getOr("00")}` : endTimeTxt
    }
    let startTimeStr = {
      let timeArr = startTimeStr->String.split(":")
      let startTimeTxt = `${timeArr[0]->Option.getOr("00")}:${timeArr[1]->Option.getOr("00")}`
      showSeconds ? `${startTimeTxt}:${timeArr[2]->Option.getOr("00")}` : startTimeTxt
    }

    let tooltipText = {
      startDateVal->isEmptyString && endDateVal->isEmptyString
        ? `Select Date ${showTime ? "and Time" : ""}`
        : showTime
        ? `${startDateStr} ${startTimeStr} - ${endDateStr} ${endTimeStr}`
        : endDateVal->isEmptyString
        ? `${startDateStr} - Now`
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

    React.useEffect(() => {
      if startDate->isNonEmptyString && endDate->isNonEmptyString {
        if (
          localStartDate->isNonEmptyString &&
          localEndDate->isNonEmptyString &&
          (disableApply || !isCustomSelected)
        ) {
          saveDates()
        }

        if disableApply {
          setShowOption(_ => false)
        }
      }
      None
    }, (startDate, endDate, localStartDate, localEndDate))

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

    let getPredefinedValues = predefinedDay => {
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
      (startTimestamp, endTimestamp)
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

      let (startTimestamp, endTimestamp) = getPredefinedValues(item)

      let prestartDate = convertTimeStamp(
        ~isoStringToCustomTimeZone,
        startTimestamp,
        "YYYY-MM-DDTHH:mm:00[Z]",
      )
      let preendDate = convertTimeStamp(
        ~isoStringToCustomTimeZone,
        endTimestamp,
        "YYYY-MM-DDTHH:mm:00[Z]",
      )

      startDate == prestartDate && endDate == preendDate
    })

    let buttonText = switch predefinedOptionSelected {
    | Some(value) => DateRangeUtils.datetext(value, disableFutureDates)
    | None =>
      startDateVal->isEmptyString && endDateVal->isEmptyString
        ? `Select Date`
        : endDateVal->isEmptyString
        ? `${startDateStr} - Now`
        : `${startDateStr} ${startDateStr === buttonText ? "" : "-"} ${endDateStr}`
    }

    let filteredPredefinedDays = {
      switch dateRangeLimit {
      | Some(limit) =>
        predefinedDays->Array.filter(item => {
          getDiffForPredefined(item) <= (limit->Float.fromInt *. 24. *. 60. *. 60. -. 1.) *. 1000.
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
        {if removeFilterOption && startDateVal->isNonEmptyString && endDateVal->isNonEmptyString {
          <Icon name="crossicon" size=16 onClick=removeApplyFilter />
        } else {
          React.null
        }}
      </div>
    }

    let calendarElement =
      <div className={`flex flex-col tablet:flex-row w-full py-2`}>
        {if predefinedDays->Array.length > 0 && showOption {
          <AddDataAttributes attributes=[("data-date-picker-predifined", "predefined-options")]>
            <div className="flex flex-wrap gap-1 md:flex-col">
              {filteredPredefinedDays
              ->Array.mapWithIndex((value, i) => {
                <div
                  key={i->Int.toString}
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
              <AddDataAttributes attributes=[("data-daterange-dropdown-value", "Custom Range")]>
                <div
                  className={`text-center md:text-start min-w-max bg-white dark:bg-jp-gray-lightgray_background w-full hover:bg-jp-gray-100 hover:bg-opacity-75 dark:hover:bg-jp-gray-850 dark:hover:bg-opacity-100 cursor-pointer mx-2 rounded-md p-2 text-sm font-medium text-grey-900 ${customeRangeBg}}`}
                  onClick={_ => {
                    setCalendarVisibility(_ => true)
                    setIsCustomSelected(_ => true)
                  }}>
                  {React.string("Custom Range")}
                </div>
              </AddDataAttributes>
            </div>
          </AddDataAttributes>
        } else {
          React.null
        }}
        <AddDataAttributes attributes=[("data-date-picker-section", "date-picker-calendar")]>
          <div
            className={calendarVisibility && isCustomSelected
              ? "w-full tablet:w-auto h-auto"
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
              calendarContaierStyle="md:mx-2 md:my-1 border-0 md:border"
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
                className="flex flex-row flex-wrap gap-3 bg-white dark:bg-jp-gray-lightgray_background px-3 mt-3 mb-1 align-center justify-end ">
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
                  buttonState={endDate->LogicUtils.isEmptyString ? Disabled : Normal}
                  buttonSize=Small
                  onClick={handleApply}
                />
              </div>
            }}
          </div>
        </AddDataAttributes>
      </div>
    open HeadlessUI
    <>
      <div className={"md:relative daterangSelection"}>
        <AddDataAttributes
          attributes=[
            ("data-date-picker", `dateRangePicker${isFilterSection ? "-Filter" : ""}`),
            ("data-date-picker-start-date", `${startDateStr} ${startTimeStr}`),
            ("data-date-picker-end-date", `${endDateStr} ${endTimeStr}`),
          ]>
          <div ref={dateRangeRef->ReactDOM.Ref.domRef}>
            <ToolTip
              description={tooltipText}
              toolTipFor={<Button
                dataTestId="date-range-selector"
                text={isMobileView && textHideInMobileView ? "" : buttonText}
                leftIcon={CustomIcon(<Icon name="calendar-filter" size=22 />)}
                rightIcon={CustomIcon(iconElement)}
                buttonSize=Large
                isDropdownOpen=isDropdownExpandedActual
                onClick={_ => handleDropdownClick()}
                iconBorderColor={customborderCSS}
                customButtonStyle
                buttonState={disable ? Disabled : Normal}
                ?buttonType
                ?textStyle
              />}
              justifyClass="justify-end"
              toolTipPosition={Top}
            />
          </div>
        </AddDataAttributes>
        {if isDropdownExpandedActual {
          if isMobileView {
            <BottomModal headerText={buttonText} onCloseClick={cancelButton}>
              calendarElement
            </BottomModal>
          } else {
            <Transition
              \"as"="span"
              enter="transition ease-out duration-100"
              enterFrom="transform opacity-0 scale-95"
              enterTo="transform opacity-100 scale-100"
              leave="transition ease-in duration-75"
              leaveFrom="transform opacity-100 scale-100"
              show={isDropdownExpandedActual}
              leaveTo="transform opacity-0 scale-95">
              <div
                ref={dropdownRef->ReactDOM.Ref.domRef}
                className={`${dropdownVisibilityClass} absolute ${dropdownPosition} z-20 max-h-30-rem tablet:max-h-min max-w-min overflow-auto bg-white dark:bg-jp-gray-950 rounded-lg shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none mt-2 right-0`}>
                calendarElement
              </div>
            </Transition>
          }
        } else {
          React.null
        }}
      </div>
    </>
  }
}

let useStateForInput = (input: ReactFinalForm.fieldRenderPropsInput) => {
  React.useMemo(() => {
    let val = input.value->JSON.Decode.string->Option.getOr("")
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
  ~buttonText="",
  ~textStyle=?,
  ~standardTimeToday=false,
  ~removeConversion=false,
  ~isTooltipVisible=true,
  ~events=?,
  ~customButtonStyle="",
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
    buttonText
    ?allowedDateRange
    ?textStyle
    standardTimeToday
    removeConversion
    isTooltipVisible
    ?events
    customButtonStyle
  />
}
