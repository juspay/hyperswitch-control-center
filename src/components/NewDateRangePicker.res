open DateTimeUtils

let defaultCellHighlighter = (_): NewCalendar.highlighter => {
  {
    highlightSelf: false,
    highlightLeft: false,
    highlightRight: false,
  }
}

let useErroryValueResetter = (
  value: string,
  setValue: (string => string) => unit,
  isoStringToCustomTimeZone,
) => {
  React.useEffect1(() => {
    let isErroryTimeValue = value => {
      try {
        let _ = value->isoStringToCustomTimeZone
        false
      } catch {
      | _error => true
      }
    }
    if value->isErroryTimeValue {
      setValue(_ => "")
    }

    None
  }, [setValue])
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
  ) => {
    let selectedClass = if predefinedOptionSelected === Some(value) {
      "bg-jp-2-light-gray-100 text-jp-2-light-primary-600"
    } else {
      "desktop:bg-white hover:bg-jp-2-light-gray-100 text-jp-2-light-gray-1300"
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
      description={`${startDate} - ${endDate}`}
      toolTipFor={<AddDataAttributes
        attributes=[("data-daterange-dropdown-value", dateRangeDropdownVal)]>
        <div
          className={`${selectedClass} rounded-lg px-3 md:py-2 py-3 cursor-pointer text-fs-14 font-medium dark:text-gray-400`}
          onClick=handleClick>
          {React.string(dateRangeDropdownVal)}
        </div>
      </AddDataAttributes>}
      toolTipPosition=Right
      contentAlign=Left
    />
  }
}

type calendarTab = {title: string}
module CalendarTabs = {
  @react.component
  let make = (~setSelectedTab, ~isDateSelected=true) => {
    let routeTabs: array<calendarTab> = [
      {
        title: "Date Selection",
      },
      {
        title: "Time Selection",
      },
    ]

    let deafultTab: Tabs.tab = {
      title: "",
      renderContent: () => React.null,
    }

    let tabs = routeTabs->Array.map((routeTab): Tabs.tab => {
      {title: routeTab.title, renderContent: () => React.null}
    })
    let isDisabled =
      (tabs->Belt.Array.get(1)->Belt.Option.getWithDefault(deafultTab)).title == "Time Selection" &&
        !isDateSelected
    let disabledTab = ["Time Selection"]
    <div className="w-full">
      <Tabs
        tabs
        initialIndex=0
        tabContainerClass="!justify-between !mx-6 !pr-0 !mt-4"
        disabledTab
        disableIndicationArrow=true
        tabBottomShadow=""
        renderedTabClassName="!pb-4"
        isDisabled
        showRedDot=true
        visitedTabs=["Date Selection", "Time Selection"]
        onTitleClick={i => {
          switch routeTabs->Belt.Array.get(i) {
          | Some(routeTab) =>
            if !(disabledTab->Array.includes(routeTab.title) && isDisabled) {
              setSelectedTab(_ => routeTab.title)
            }
          | None => ()
          }
        }}
      />
    </div>
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
    ~customButtonStyle=?,
  ) => {
    open DateRangeUtils
    let (isCustomSelected, setIsCustomSelected) = React.useState(_ =>
      predefinedDays->Array.length === 0
    )
    let (selectedTab, setSelectedTab) = React.useState(_ => "Date Selection")
    let formatDateTime = showSeconds ? "MMM DD, YYYY HH:mm:ss" : "MMM DD, YYYY HH:mm"
    let (showOption, setShowOption) = React.useState(_ => false)
    let customTimezoneToISOString = TimeZoneHook.useCustomTimeZoneToIsoString()
    let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
    let isoStringToCustomTimezoneInFloat = TimeZoneHook.useIsoStringToCustomTimeZoneInFloat()

    let (clickedDates, setClickedDates) = React.useState(_ => [])

    let (localStartDate, setLocalStartDate) = React.useState(_ => startDateVal)
    let (localEndDate, setLocalEndDate) = React.useState(_ => endDateVal)
    let (_localOpt, setLocalOpt) = React.useState(_ => "")
    let (_showMsg, setShowMsg) = React.useState(_ => false)

    let (isDropdownExpanded, setIsDropdownExpanded) = React.useState(_ => false)
    let (calendarVisibility, setCalendarVisibility) = React.useState(_ => false)
    let isMobileView = MatchMedia.useMobileChecker()
    let isFilterSection = React.useContext(TableFilterSectionContext.filterSectionContext)

    let dropdownPosition =
      isFilterSection && !isMobileView && !showTime && isCustomSelected ? "right-0" : ""

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

    useErroryValueResetter(startDateVal, setStartDateVal, isoStringToCustomTimeZone)
    useErroryValueResetter(endDateVal, setEndDateVal, isoStringToCustomTimeZone)

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

    let changeEndDate = (ele, isFromCustomInput, time) => {
      if disableApply {
        setIsDropdownExpanded(_ => false)
      }
      if localEndDate == ele && isFromCustomInput {
        setEndDateVal(_ => "")
      } else {
        let endDateSplit = String.split(ele, "-")
        let endDateDate = endDateSplit->Belt.Array.get(2)->Belt.Option.getWithDefault("")
        let endDateYear = endDateSplit->Belt.Array.get(0)->Belt.Option.getWithDefault("")
        let endDateMonth = endDateSplit->Belt.Array.get(1)->Belt.Option.getWithDefault("")
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
    let changeStartDate = (ele, isFromCustomInput, isSetEndDate, time) => {
      let setDate = str => {
        let startDateSplit = String.split(str, "-")
        let startDateDay = startDateSplit->Belt.Array.get(2)->Belt.Option.getWithDefault("")
        let startDateYear = startDateSplit->Belt.Array.get(0)->Belt.Option.getWithDefault("")
        let startDateMonth = startDateSplit->Belt.Array.get(1)->Belt.Option.getWithDefault("")
        let splitTime = switch time {
        | Some(val) => val
        | None =>
          if !disableFutureDates && ele == todayDate {
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
        startDate != "" &&
        endDate != "" &&
        isFromCustomInput &&
        ((ele > startDate && ele < endDate) || ele > endDate)
      ) {
        resetStartDate()
      }

      if !isFromCustomInput || startDate == "" {
        setDate(ele)
      }

      if (
        ((startDate != "" && endDate == "" && !isFromCustomInput) ||
          (startDate != "" &&
          endDate == "" &&
          isStartBeforeEndDate(startDate, ele) &&
          isFromCustomInput)) && isSetEndDate
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
      changeStartDate(str, true, true, None)
    }

    let handleApply = _ev => {
      setShowOption(_ => false)
      setSelectedTab(_ => "Date Selection")
      setCalendarVisibility(p => !p)
      setIsDropdownExpanded(_ => false)
      saveDates()
    }

    let cancelButton = _ => {
      resetToInitalValues()
      setCalendarVisibility(p => !p)
      setSelectedTab(_ => "Date Selection")
      setIsDropdownExpanded(_ => false)
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

    let startDateStr =
      startDateVal !== ""
        ? getFormattedDate(
            startDateVal->getDateStringForValue(isoStringToCustomTimeZone),
            "MMM DD, YYYY",
          )
        : "[From-Date]"
    let endDateStr =
      endDateVal !== ""
        ? getFormattedDate(
            endDateVal->getDateStringForValue(isoStringToCustomTimeZone),
            "MMM DD, YYYY",
          )
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
      showTime
        ? `${startDateStr} ${startTimeStr} - ${endDateStr} ${endTimeStr}`
        : `${startDateStr} - ${endDateStr}`
    }

    let buttonIcon = if isDropdownExpanded {
      "chevron-up"
    } else {
      "chevron-down"
    }

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
      changeStartDate(stDate, false, true, Some(stTime))
      changeEndDate(enDate, false, Some(enTime))
    }

    let handleDropdownClick = () => {
      if predefinedDays->Array.length > 0 {
        if calendarVisibility {
          setCalendarVisibility(_ => false)
          setIsCustomSelected(_ => false)
          setShowOption(_ => !isDropdownExpanded)
          setIsDropdownExpanded(_ => !isDropdownExpanded)
          setShowOption(_ => !isCustomSelected)
        } else {
          setIsDropdownExpanded(_ => true)
          setIsCustomSelected(_ => false)
          setShowOption(_ => true)
          setCalendarVisibility(_ => true)
        }
      } else {
        setIsDropdownExpanded(_p => !isDropdownExpanded)
        setCalendarVisibility(_ => !isDropdownExpanded)
      }
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

    let customStyle = ""

    let btnStyle = customButtonStyle->Belt.Option.getWithDefault("")

    let customStyleForBtn = btnStyle->String.length > 0 ? btnStyle : customStyle

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

    let removeApplyFilter = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      resetToInitalValues()
      setStartDateVal(_ => "")
      setEndDateVal(_ => "")
    }

    let iconElement = {
      <div className="flex flex-row gap-2">
        <Icon name=buttonIcon size=20 />
        {if removeFilterOption && startDateVal !== "" && endDateVal !== "" {
          <Icon name="crossicon" size=16 onClick=removeApplyFilter />
        } else {
          React.null
        }}
      </div>
    }

    let isDateSelected = startDate != "" && endDate != ""

    let calendarElement =
      <div className={`flex flex-col w-full items-center overflow-visible`}>
        {if predefinedDays->Array.length > 0 && showOption && !isCustomSelected {
          <AddDataAttributes attributes=[("data-date-picker-predifined", "predefined-options")]>
            <div className="flex flex-wrap md:flex-col md:p-1 overflow-hidden">
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
                  />
                </div>
              })
              ->React.array}
              <div
                className="w-1/3 md:w-full md:min-w-max text-center md:text-start rounded-lg px-3 md:py-2 py-3 cursor-pointer text-fs-14 font-medium text-jp-2-light-gray-1300 dark:text-gray-400 desktop:bg-white dark:bg-jp-gray-lightgray_background hover:bg-jp-2-light-gray-100"
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
        {showTime && calendarVisibility && isCustomSelected
          ? <CalendarTabs setSelectedTab isDateSelected />
          : React.null}
        <AddDataAttributes attributes=[("data-date-picker-section", "date-picker-calendar")]>
          <div
            className={calendarVisibility && isCustomSelected
              ? "w-auto md:w-[328px] h-auto"
              : "hidden"}>
            {if selectedTab == "Date Selection" {
              <NewCalendarList
                count=numMonths
                cellHighlighter=defaultCellHighlighter
                startDate
                endDate
                showTime
                onDateClick
                changeEndDate
                changeStartDate
                disablePastDates
                disableFutureDates
                ?dateRangeLimit
                setShowMsg
                calendarContaierStyle=""
              />
            } else {
              <NewCalendarTimeInput
                startDate
                endDate
                localStartDate
                disableFutureDates
                todayDate
                todayTime
                localEndDate
                getTimeStringForValue
                isoStringToCustomTimeZone
                setStartDate
                setEndDate
                startTimeStr
                endTimeStr
              />
            }}
            {if disableApply {
              React.null
            } else {
              <div
                id="neglectTopbarTheme"
                className="flex flex-row  bg-white dark:bg-jp-gray-lightgray_background p-3 align-center gap-3 border-t rounded-b-lg">
                <Button
                  text="Cancel"
                  buttonType=Secondary
                  buttonState=Normal
                  buttonSize=Small
                  customButtonStyle="w-full shadow-jp-2-xs"
                  onClick={cancelButton}
                />
                <Button
                  text="Apply"
                  buttonType=Primary
                  buttonState={endDate == "" ? Disabled : Normal}
                  buttonSize=Small
                  customButtonStyle="w-full"
                  onClick={handleApply}
                />
              </div>
            }}
          </div>
        </AddDataAttributes>
      </div>

    <>
      <div className="md:relative daterangSelection">
        <AddDataAttributes
          attributes=[
            ("data-date-picker", `dateRangePicker${isFilterSection ? "-Filter" : ""}`),
            ("data-date-picker-start-date", `${startDateStr} ${startTimeStr}`),
            ("data-date-picker-end-date", `${endDateStr} ${endTimeStr}`),
          ]>
          <div ref={dateRangeRef->ReactDOM.Ref.domRef}>
            <Button
              text={isMobileView && textHideInMobileView ? "" : buttonText}
              leftIcon={FontAwesome("new-calendar")}
              rightIcon={CustomIcon(iconElement)}
              buttonSize=Small
              isDropdownOpen=isDropdownExpandedActual
              onClick={_ => handleDropdownClick()}
              customButtonStyle=customStyleForBtn
              buttonState={disable ? Disabled : Normal}
              buttonType=Dropdown
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
              className={`${dropdownVisibilityClass} mt-2 ${dropdownPosition} absolute z-20 bg-white shadow-jp-2-sm max-h-min max-w-min overflow-auto border border-jp-2-light-gray-400 rounded-lg overflow-visible`}>
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
  ~selectStandardTime=false,
  ~customButtonStyle=?,
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
  />
}
