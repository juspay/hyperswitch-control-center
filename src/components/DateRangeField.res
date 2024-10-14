open DateRangeUtils
open DateRangeFieldHelper

module Base = {
  @react.component
  let make = (
    ~startDateVal: string,
    ~setStartDateVal: (string => string) => unit,
    ~endDateVal: string,
    ~setEndDateVal: (string => string) => unit,
    ~seconStartDateVal: string,
    ~setSeconStartDateVal: (string => string) => unit,
    ~seconEndDateVal: string,
    ~setSeconEndDateVal: (string => string) => unit,
    ~showTime=false,
    ~disable=false,
    ~disablePastDates=true,
    ~disableFutureDates=false,
    ~predefinedDays=[],
    ~enableComparision=false,
    ~compareOptions=[],
    ~format="YYYY-MM-DDTHH:mm:ss.SSS[Z]",
    ~numMonths=1,
    ~disableApply=true,
    ~removeFilterOption=false,
    ~dateRangeLimit=?,
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
  ) => {
    open LogicUtils
    let (isCustomSelectedPrimary, setIsCustomSelectedPrimary) = React.useState(_ =>
      predefinedDays->Array.length === 0
    )
    let (isCustomSelectedSecondary, setIsCustomSelectedSecondary) = React.useState(_ =>
      compareOptions->Array.length === 0
    )

    let formatDateTime = showSeconds ? "MMM DD, YYYY HH:mm:ss" : "MMM DD, YYYY HH:mm"
    let (showOption, setShowOption) = React.useState(_ => false)
    let customTimezoneToISOString = TimeZoneHook.useCustomTimeZoneToIsoString()
    let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
    let isoStringToCustomTimezoneInFloat = TimeZoneHook.useIsoStringToCustomTimeZoneInFloat()
    let (clickedDates, setClickedDates) = React.useState(_ => [])
    let (localStartDate, setLocalStartDate) = React.useState(_ => startDateVal)
    let (localEndDate, setLocalEndDate) = React.useState(_ => endDateVal)
    let (localStartSecondaryDate, setLocalStartSecondaryDate) = React.useState(_ =>
      seconStartDateVal
    )
    let (localEndSecondaryDate, setLocalEndSecondaryDate) = React.useState(_ => seconEndDateVal)
    let (isDropdownExpandedPrimary, setIsDropdownExpandedPrimary) = React.useState(_ => false)
    let (calendarVisibilityPrimary, setCalendarVisibilityPrimary) = React.useState(_ => false)
    let (isDropdownExpandedSecondary, setIsDropdownExpandedSecondary) = React.useState(_ => false)
    let (calendarVisibilitySecondary, setCalendarVisibilitySecondary) = React.useState(_ => false)
    let isMobileView = MatchMedia.useMobileChecker()
    let isFilterSection = React.useContext(TableFilterSectionContext.filterSectionContext)

    let dropdownPosition =
      isFilterSection && !isMobileView && isCustomSelectedPrimary ? "right-0" : ""
    let customStyleForBtn = "rounded-lg bg-white"
    let timeVisibilityClass = showTime ? "block" : "hidden"

    let todayDayJsObj = React.useMemo(() => {
      Date.make()->Date.toString->DayJs.getDayJsForString
    }, [isDropdownExpandedPrimary])

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
      None
    }, [startDateVal, endDateVal])

    React.useEffect(() => {
      switch dateRangeLimit {
      | Some(maxLen) => {
          let diff = getStartEndDiff(localStartDate, localEndDate)
          let maxDiffInMillis = (maxLen->Int.toFloat *. 24. *. 60. *. 60. -. 1.) *. 1000.
          if diff > maxDiffInMillis {
            resetStartEndInput(~setStartDate=setLocalStartDate, ~setEndDate=setLocalEndDate)
          }
        }

      | None => ()
      }
      None
    }, [localStartDate, localEndDate])

    let dateRangeRef = React.useRef(Nullable.null)
    let dropdownRef = React.useRef(Nullable.null)

    useErroryValueResetter(startDateVal, setStartDateVal)
    useErroryValueResetter(endDateVal, setEndDateVal)
    useErroryValueResetter(seconStartDateVal, setSeconStartDateVal)
    useErroryValueResetter(seconEndDateVal, setSeconEndDateVal)

    let startDate = localStartDate->getDateStringForValue(isoStringToCustomTimeZone)
    let endDate = localEndDate->getDateStringForValue(isoStringToCustomTimeZone)
    let seconStartDate = localStartDate->getDateStringForValue(isoStringToCustomTimeZone)
    let seconEndDate = localEndDate->getDateStringForValue(isoStringToCustomTimeZone)

    let isDropdownExpandedActualPrimary = isDropdownExpandedPrimary && calendarVisibilityPrimary
    let isDropdownExpandedActualSecondary =
      isDropdownExpandedSecondary && calendarVisibilitySecondary

    let saveDates = () => {
      if localStartDate->isNonEmptyString && localEndDate->isNonEmptyString {
        setStartDateVal(_ => localStartDate)
        setEndDateVal(_ => localEndDate)
      }
      if (
        enableComparision &&
        localStartSecondaryDate->isNonEmptyString &&
        localEndSecondaryDate->isNonEmptyString
      ) {
        setSeconStartDateVal(_ => localStartSecondaryDate)
        setSeconEndDateVal(_ => localEndSecondaryDate)
      }
    }
    let resetToInitalValues = () => {
      setLocalStartDate(_ => startDateVal)
      setLocalEndDate(_ => endDateVal)
      setLocalStartSecondaryDate(_ => seconStartDateVal)
      setLocalEndSecondaryDate(_ => seconEndDateVal)
    }

    OutsideClick.useOutsideClick(
      ~refs=ArrayOfRef([dateRangeRef, dropdownRef]),
      ~isActive=isDropdownExpandedPrimary || calendarVisibilityPrimary,
      ~callback=() => {
        setIsDropdownExpandedPrimary(_ => false)
        setCalendarVisibilityPrimary(p => !p)
        if isDropdownExpandedActualPrimary && isCustomSelectedPrimary {
          resetToInitalValues()
        }
      },
    )

    let changeSecondaryEndDate = (date, isFromCustomInput, time) => {
      if disableApply {
        setIsDropdownExpandedSecondary(_ => false)
      }

      if localEndSecondaryDate == date && isFromCustomInput {
        setSeconEndDateVal(_ => "")
      } else {
        let endDateSplit = String.split(date, "-")
        let endDateYear = endDateSplit->getValueFromArray(0, "")
        let endDateMonth = endDateSplit->getValueFromArray(1, "")
        let endDateDate = endDateSplit->getValueFromArray(2, "")

        let splitTime = switch time {
        | Some(val) => val
        | None =>
          if disableFutureDates && date == todayDate {
            todayTime
          } else {
            initialEndTime
          }
        }

        let timeSplit = String.split(splitTime, ":")
        let timeHour = timeSplit->getValueFromArray(0, "00")
        let timeMinute = timeSplit->getValueFromArray(1, "00")
        let timeSecond = timeSplit->getValueFromArray(2, "00")
        let endDateTimeCheck = customTimezoneToISOString(
          endDateYear,
          endDateMonth,
          endDateDate,
          timeHour,
          timeMinute,
          timeSecond,
        )
        setLocalEndSecondaryDate(_ => TimeZoneHook.formattedISOString(endDateTimeCheck, format))
      }
    }

    let changeEndDate = (ele, isFromCustomInput, time) => {
      if disableApply {
        setIsDropdownExpandedPrimary(_ => false)
      }
      if localEndDate == ele && isFromCustomInput {
        setEndDateVal(_ => "")
      } else {
        let endDateSplit = String.split(ele, "-")
        let endDateDate = endDateSplit->getValueFromArray(2, "")
        let endDateYear = endDateSplit->getValueFromArray(0, "")
        let endDateMonth = endDateSplit->getValueFromArray(1, "")

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
        let timeHour = timeSplit->getValueFromArray(0, "00")
        let timeMinute = timeSplit->getValueFromArray(1, "00")
        let timeSecond = timeSplit->getValueFromArray(2, "00")
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

    let changeSecondaryStartDate = (date, isFromCustomInput, time) => {
      let setDate = str => {
        let startDateSplit = String.split(str, "-")
        let startDateYear = startDateSplit->getValueFromArray(0, "")
        let startDateMonth = startDateSplit->getValueFromArray(1, "")
        let startDateDay = startDateSplit->getValueFromArray(2, "")

        let splitTime = switch time {
        | Some(val) => val
        | None =>
          if !disableFutureDates && date == todayDate && !standardTimeToday {
            todayTime
          } else {
            initialStartTime
          }
        }

        let timeSplit = String.split(splitTime, ":")
        let timeHour = timeSplit->getValueFromArray(0, "00")
        let timeMinute = timeSplit->getValueFromArray(1, "00")
        let timeSecond = timeSplit->getValueFromArray(2, "00")
        let startDateTimeCheck = customTimezoneToISOString(
          startDateYear,
          startDateMonth,
          startDateDay,
          timeHour,
          timeMinute,
          timeSecond,
        )

        setLocalStartSecondaryDate(_ => TimeZoneHook.formattedISOString(startDateTimeCheck, format))
      }
      let resetStartDate = () => {
        resetStartEndInput(
          ~setStartDate=setLocalStartSecondaryDate,
          ~setEndDate=setLocalEndSecondaryDate,
        )
        setDate(date)
      }

      let isStartDateNonEmpty = seconStartDate->isNonEmptyString
      let isEndDateNonEmpty = seconEndDate->isNonEmptyString
      let isEndDateEmpty = seconEndDate->isEmptyString

      if isStartDateNonEmpty && seconStartDate == date && isFromCustomInput {
        changeSecondaryEndDate(date, isFromCustomInput, None)
      } else if isStartDateNonEmpty && seconStartDate > date && isFromCustomInput {
        resetStartDate()
      } else if isEndDateNonEmpty && seconStartDate == date && isFromCustomInput {
        resetStartDate()
      } else if (
        date > seconStartDate &&
        date < seconEndDate &&
        isStartDateNonEmpty &&
        isEndDateNonEmpty &&
        isFromCustomInput
      ) {
        resetStartDate()
      } else if (
        isStartDateNonEmpty && isEndDateNonEmpty && date > seconEndDate && isFromCustomInput
      ) {
        resetStartDate()
      } else {
        ()
      }

      if !isFromCustomInput || seconStartDate->isEmptyString {
        setDate(date)
      }

      if (
        (isStartDateNonEmpty && isEndDateEmpty && !isFromCustomInput) ||
          (isStartDateNonEmpty &&
          isEndDateEmpty &&
          isStartBeforeEndDate(seconStartDate, date) &&
          isFromCustomInput)
      ) {
        changeSecondaryEndDate(date, isFromCustomInput, None)
      }
    }

    let changeStartDate = (ele, isFromCustomInput, time) => {
      let setDate = str => {
        let startDateSplit = String.split(str, "-")
        let startDateDay = startDateSplit->getValueFromArray(2, "")
        let startDateYear = startDateSplit->getValueFromArray(0, "")
        let startDateMonth = startDateSplit->getValueFromArray(1, "")
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
        let timeHour = timeSplit->getValueFromArray(0, "00")
        let timeMinute = timeSplit->getValueFromArray(1, "00")
        let timeSecond = timeSplit->getValueFromArray(2, "00")
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
        resetStartEndInput(~setStartDate=setLocalStartDate, ~setEndDate=setLocalEndDate)
        setDate(ele)
      }

      let isStartDateNonEmpty = startDate->isNonEmptyString
      let isEndDateNonEmpty = endDate->isNonEmptyString
      let isEndDateEmpty = endDate->isEmptyString

      if isStartDateNonEmpty && startDate == ele && isFromCustomInput {
        changeEndDate(ele, isFromCustomInput, None)
      } else if isStartDateNonEmpty && startDate > ele && isFromCustomInput {
        resetStartDate()
      } else if isEndDateNonEmpty && startDate == ele && isFromCustomInput {
        resetStartDate()
      } else if (
        ele > startDate &&
        ele < endDate &&
        isStartDateNonEmpty &&
        isEndDateNonEmpty &&
        isFromCustomInput
      ) {
        resetStartDate()
      } else if isStartDateNonEmpty && isEndDateNonEmpty && ele > endDate && isFromCustomInput {
        resetStartDate()
      } else {
        ()
      }

      if !isFromCustomInput || startDate->isEmptyString {
        setDate(ele)
      }

      if (
        (isStartDateNonEmpty && isEndDateEmpty && !isFromCustomInput) ||
          (isStartDateNonEmpty &&
          isEndDateEmpty &&
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
      setCalendarVisibilityPrimary(p => !p)
      setIsDropdownExpandedPrimary(_ => false)
      saveDates()
    }

    let cancelButton = _ => {
      resetToInitalValues()
      setCalendarVisibilityPrimary(p => !p)
      setIsDropdownExpandedPrimary(_ => false)
    }

    let formatDate = date =>
      date->isNonEmptyString
        ? getFormattedDate(date->getDateStringForValue(isoStringToCustomTimeZone), "YYYY-MM-DD")
        : ""

    let selectedStartDate = formatDate(localStartDate)
    let selectedEndDate = formatDate(localEndDate)

    let setDateTime = (~date, ~time, setLocalDate) => {
      if date->isNonEmptyString {
        let timestamp = changeTimeFormat(~date, ~time, ~customTimezoneToISOString, ~format)
        setLocalDate(_ => timestamp)
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
            setDateTime(~date=startDate, ~time=todayTime, setLocalStartDate)
          } else if (
            disableFutureDates && selectedStartDate == selectedEndDate && startTimeVal > endTime
          ) {
            ()
          } else {
            setDateTime(~date=startDate, ~time=startTimeVal, setLocalStartDate)
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
            setDateTime(~date=startDate, ~time=todayTime, setLocalEndDate)
          } else if (
            disableFutureDates && selectedStartDate == selectedEndDate && endTimeVal < startTime
          ) {
            ()
          } else {
            setDateTime(~date=endDate, ~time=endTimeVal, setLocalEndDate)
          }
        }
      },
      onFocus: _ => (),
      value: localEndDate->getTimeStringForValue(isoStringToCustomTimeZone)->JSON.Encode.string,
      checked: false,
    }

    let handlePredefinedOptionClick = (value, disableFutureDates) => {
      setIsCustomSelectedPrimary(_ => false)
      setCalendarVisibilityPrimary(_ => false)
      setIsDropdownExpandedPrimary(_ => false)
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

      resetStartEndInput(~setStartDate=setLocalStartDate, ~setEndDate=setLocalEndDate)

      setDateTime(~date=startDate, ~time=stTime, setLocalStartDate)
      setDateTime(~date=endDate, ~time=enTime, setLocalEndDate)
      changeStartDate(stDate, false, Some(stTime))
      changeEndDate(enDate, false, Some(enTime))
    }

    let handleCompareOptionClick = value => {
      switch value {
      | Custom => {
          setCalendarVisibilitySecondary(_ => true)
          setIsCustomSelectedSecondary(_ => true)
        }
      | _ => {
          setIsCustomSelectedSecondary(_ => false)
          setCalendarVisibilitySecondary(_ => false)
          setIsDropdownExpandedSecondary(_ => false)
          setShowOption(_ => false)

          let (startDate, endDate) = getComparisionTimePeriod(
            ~startDate=startDateVal,
            ~endDate=endDateVal,
          )

          resetStartEndInput(
            ~setStartDate=setLocalStartSecondaryDate,
            ~setEndDate=setLocalEndSecondaryDate,
          )

          let stDate = getFormattedDate(startDate, "YYYY-MM-DD")
          let edDate = getFormattedDate(endDate, "YYYY-MM-DD")
          let stTime = getFormattedDate(startDate, "HH:MM:00")
          let endTime = getFormattedDate(endDate, "HH:MM:00")

          setDateTime(~date=stDate, ~time=stTime, setLocalStartSecondaryDate)
          setDateTime(~date=edDate, ~time=endTime, setLocalEndSecondaryDate)

          changeSecondaryStartDate(stDate, false, Some("00:00:00"))
          changeSecondaryEndDate(edDate, false, Some(endTime))
        }
      }
    }

    let handleDropdownClick = dropDownType => {
      switch dropDownType {
      | PrimaryDateRange => {
          setIsDropdownExpandedSecondary(_ => false)
          setCalendarVisibilitySecondary(_ => false)
          toggleDropdown(
            ~isDropdownExpanded=isDropdownExpandedPrimary,
            ~setIsDropdownExpanded=setIsDropdownExpandedPrimary,
            ~calendarVisibility=calendarVisibilityPrimary,
            ~setCalendarVisibility=setCalendarVisibilityPrimary,
            ~predefinedOptionsLength=predefinedDays->Array.length,
            ~isCustomSelected=isCustomSelectedPrimary,
            ~setShowOption,
          )
        }
      | CompareDateRange => {
          setIsDropdownExpandedPrimary(_ => false)
          setCalendarVisibilityPrimary(_ => false)
          toggleDropdown(
            ~isDropdownExpanded=isDropdownExpandedSecondary,
            ~setIsDropdownExpanded=setIsDropdownExpandedSecondary,
            ~calendarVisibility=calendarVisibilitySecondary,
            ~setCalendarVisibility=setCalendarVisibilitySecondary,
            ~predefinedOptionsLength=compareOptions->Array.length,
            ~isCustomSelected=isCustomSelectedPrimary,
            ~setShowOption,
          )
        }
      }
    }

    React.useEffect(() => {
      let shouldSaveDates =
        startDate->isNonEmptyString &&
        endDate->isNonEmptyString &&
        localStartDate->isNonEmptyString &&
        localEndDate->isNonEmptyString &&
        (disableApply || !isCustomSelectedPrimary)

      if shouldSaveDates {
        saveDates()
      }

      if disableApply {
        setShowOption(_ => false)
      }
      None
    }, (startDate, endDate, localStartDate, localEndDate))

    let filteredPredefinedDays = switch dateRangeLimit {
    | Some(limit) =>
      let maxDiff = (limit->Float.fromInt *. 24. *. 60. *. 60. -. 1.) *. 1000.
      predefinedDays->Array.filter(item =>
        getDiffForPredefined(
          item,
          isoStringToCustomTimeZone,
          isoStringToCustomTimezoneInFloat,
          customTimezoneToISOString,
          disableFutureDates,
          disablePastDates,
        ) <=
        maxDiff
      )
    | None => predefinedDays
    }

    let isPrimaryPredefinedOptionSelected = getIsPredefinedOptionSelected(
      predefinedDays,
      startDateVal,
      endDateVal,
      isoStringToCustomTimeZone,
      isoStringToCustomTimezoneInFloat,
      customTimezoneToISOString,
      disableFutureDates,
      disablePastDates,
    )

    let isSecondaryPredefinedOptionSelected = getIsPredefinedOptionSelected(
      predefinedDays,
      seconStartDateVal,
      seconEndDateVal,
      isoStringToCustomTimeZone,
      isoStringToCustomTimezoneInFloat,
      customTimezoneToISOString,
      disableFutureDates,
      disablePastDates,
    )

    let dropDownElement = dropDownType =>
      <div className={"flex md:flex-row flex-col w-full py-2"}>
        {switch dropDownType {
        | PrimaryDateRange =>
          <RenderIf condition={predefinedDays->Array.length > 0 && showOption}>
            <AddDataAttributes attributes=[("data-date-picker-predifined", "predefined-options")]>
              <div className="flex flex-wrap gap-1 md:flex-col">
                {
                  let customBg = isPrimaryPredefinedOptionSelected->getCustomeRangeBg

                  filteredPredefinedDays
                  ->Array.mapWithIndex((value, i) => {
                    <div
                      key={i->Int.toString}
                      className="w-1/3 md:w-full md:min-w-max text-center md:text-start">
                      <PredefinedOption
                        predefinedOptionSelected=isPrimaryPredefinedOptionSelected
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
                      />
                    </div>
                  })
                  ->Array.concat([
                    <div
                      className={`text-center md:text-start min-w-max bg-white dark:bg-jp-gray-lightgray_background w-1/3   hover:bg-jp-gray-100 hover:bg-opacity-75 dark:hover:bg-jp-gray-850 dark:hover:bg-opacity-100 cursor-pointer mx-2 rounded-md p-2 text-sm font-medium text-grey-900 ${customBg}`}
                      onClick={_ => {
                        setCalendarVisibilityPrimary(_ => true)
                        setIsCustomSelectedPrimary(_ => true)
                      }}>
                      {React.string("Custom Range")}
                    </div>,
                  ])
                  ->React.array
                }
              </div>
            </AddDataAttributes>
          </RenderIf>
        | CompareDateRange =>
          <RenderIf condition={compareOptions->Array.length > 0 && showOption}>
            <AddDataAttributes attributes=[("data-date-picker-predifined", "predefined-options")]>
              <div className="flex flex-wrap gap-1 md:flex-col">
                {compareOptions
                ->Array.mapWithIndex((value, i) => {
                  <div
                    key={i->Int.toString} className="w-full md:min-w-max text-center md:text-start">
                    <CompareOption value startDateVal endDateVal onClick=handleCompareOptionClick />
                  </div>
                })
                ->React.array}
              </div>
            </AddDataAttributes>
          </RenderIf>
        }}
        <AddDataAttributes attributes=[("data-date-picker-section", "date-picker-calendar")]>
          <div
            className={(calendarVisibilityPrimary && isCustomSelectedPrimary) ||
              (calendarVisibilitySecondary && isCustomSelectedSecondary)
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
              calendarContaierStyle="md:mx-3 md:my-1 border-0 md:border"
              ?allowedDateRange
            />
            <div
              className={`${timeVisibilityClass} w-full flex flex-row md:gap-4 p-3 justify-around md:justify-start dark:text-gray-400 text-gray-700 `}>
              <TimeInput input=startTimeInput showSeconds label="From" />
              <TimeInput input=endTimeInput showSeconds label="To" />
            </div>
            <RenderIf condition={!disableApply}>
              <div
                id="neglectTopbarTheme"
                className="flex flex-row flex-wrap gap-3 bg-white dark:bg-jp-gray-lightgray_background px-3 mt-3 mb-1 align-center justify-end ">
                <Button
                  text="Cancel"
                  customButtonStyle="rounded-lg"
                  buttonType=Secondary
                  buttonState=Normal
                  buttonSize=XSmall
                  onClick={cancelButton}
                />
                <Button
                  text="Apply"
                  customButtonStyle="rounded-lg"
                  buttonType=Primary
                  buttonState={endDate->isEmptyString ? Disabled : Normal}
                  buttonSize=XSmall
                  onClick={handleApply}
                />
              </div>
            </RenderIf>
          </div>
        </AddDataAttributes>
      </div>

    let dropDownClass = `absolute ${dropdownPosition} z-20 max-h-min max-w-min overflow-auto bg-white dark:bg-jp-gray-950 rounded-lg shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none mt-2 right-0`

    <div className="flex gap-2">
      <div ref={dateRangeRef->ReactDOM.Ref.domRef} className="daterangSelection relative">
        <DateSelectorButton
          startDateVal
          endDateVal
          setStartDateVal
          setEndDateVal
          disable
          isDropdownOpen=isDropdownExpandedActualPrimary
          removeFilterOption
          resetToInitalValues
          showTime
          buttonText
          showSeconds
          predefinedOptionSelected=isPrimaryPredefinedOptionSelected
          disableFutureDates
          onClick={_ => handleDropdownClick(PrimaryDateRange)}
          buttonType
          textStyle
          iconBorderColor=customborderCSS
          customButtonStyle=customStyleForBtn
          enableToolTip=true
          showLeftIcon=true
        />
        <RenderIf condition={isDropdownExpandedActualPrimary}>
          <div ref={dropdownRef->ReactDOM.Ref.domRef} className=dropDownClass>
            {dropDownElement(PrimaryDateRange)}
          </div>
        </RenderIf>
      </div>
      <RenderIf condition={enableComparision}>
        <div className="daterangSelection relative">
          <DateSelectorButton
            startDateVal=seconStartDateVal
            endDateVal=seconEndDateVal
            setStartDateVal=setSeconStartDateVal
            setEndDateVal=setSeconEndDateVal
            disable
            isDropdownOpen=isDropdownExpandedActualSecondary
            removeFilterOption
            resetToInitalValues
            showTime
            buttonText
            showSeconds
            predefinedOptionSelected=isSecondaryPredefinedOptionSelected
            disableFutureDates
            onClick={_ => handleDropdownClick(CompareDateRange)}
            buttonType
            textStyle
            iconBorderColor=customborderCSS
            customButtonStyle=customStyleForBtn
            enableToolTip=false
            showLeftIcon=false
            isCompare=true
          />
          <RenderIf condition={isDropdownExpandedActualSecondary}>
            <div ref={dropdownRef->ReactDOM.Ref.domRef} className=dropDownClass>
              {dropDownElement(CompareDateRange)}
            </div>
          </RenderIf>
        </div>
      </RenderIf>
    </div>
  }
}

@react.component
let make = (
  ~startKey: string,
  ~endKey: string,
  ~seconStartKey: string="seconStartKey",
  ~seconEndKey: string="seconEndKey",
  ~showTime=false,
  ~disable=false,
  ~disablePastDates=true,
  ~disableFutureDates=false,
  ~predefinedDays=[],
  ~compareOptions=[],
  ~enableComparision=false,
  ~format="YYYY-MM-DDTHH:mm:ss.SSS[Z]",
  ~numMonths=1,
  ~disableApply=true,
  ~removeFilterOption=false,
  ~dateRangeLimit=?,
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
) => {
  // primary
  let startInput = ReactFinalForm.useField(startKey).input
  let endInput = ReactFinalForm.useField(endKey).input
  let (startDateVal, setStartDateVal) = useStateForInput(startInput)
  let (endDateVal, setEndDateVal) = useStateForInput(endInput)
  // secondary
  let seconStartInput = ReactFinalForm.useField(seconStartKey).input
  let seconEndInput = ReactFinalForm.useField(seconEndKey).input
  let (seconStartDateVal, setSeconStartDateVal) = useStateForInput(seconStartInput)
  let (seconEndDateVal, setSeconEndDateVal) = useStateForInput(seconEndInput)

  <Base
    startDateVal
    setStartDateVal
    endDateVal
    setEndDateVal
    seconStartDateVal
    setSeconStartDateVal
    seconEndDateVal
    setSeconEndDateVal
    showTime
    disable
    disablePastDates
    disableFutureDates
    predefinedDays
    enableComparision
    compareOptions
    format
    numMonths
    disableApply
    removeFilterOption
    ?dateRangeLimit
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
  />
}
