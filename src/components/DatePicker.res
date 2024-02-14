@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~isDisabled=false,
  ~disablePastDates=true,
  ~disableFutureDates=false,
  ~format="YYYY-MM-DDTHH:mm:ss",
  ~customButtonStyle="",
  ~newThemeCustomButtonStyle="",
  ~leftIcon=?,
  ~rightIcon=?,
  ~buttonType=?,
  ~buttonSize=?,
  ~customDisabledFutureDays=0.0,
  ~currentDateHourFormat="00",
  ~currentDateMinuteFormat="00",
  ~currentDateSecondsFormat="00",
  ~calendarContaierStyle=?,
  ~showTime=false,
  ~showSeconds=true,
  ~fullLength=?,
) => {
  open LogicUtils
  let dropdownRef = React.useRef(Nullable.null)
  let (isExpanded, setIsExpanded) = React.useState(_ => false)
  let customTimezoneToISOString = TimeZoneHook.useCustomTimeZoneToIsoString()
  let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
  let (selectedDate, setSelectedDate) = React.useState(_ =>
    input.value
    ->getStringFromJson("")
    ->DateRangePicker.getDateStringForValue(isoStringToCustomTimeZone)
  )
  let (date, setDate) = React.useState(_ => {
    if selectedDate->isNonEmptyString {
      let date = String.split(selectedDate, "-")
      let dateDay = date->Array.get(2)->Option.getOr("1")
      let dateMonth = date->Array.get(1)->Option.getOr("1")
      let dateYear = date->Array.get(0)->Option.getOr("1970")

      let timeSplit =
        switch input.value->JSON.Decode.string {
        | Some(str) => str
        | None => ""
        }
        ->DateRangePicker.getTimeStringForValue(isoStringToCustomTimeZone)
        ->String.split(":")

      let timeHour = timeSplit->Array.get(0)->Option.getOr(currentDateHourFormat)
      let timeMinute = timeSplit->Array.get(1)->Option.getOr(currentDateMinuteFormat)
      let timeSecond = timeSplit->Array.get(2)->Option.getOr(currentDateSecondsFormat)
      let dateTimeCheck = customTimezoneToISOString(
        dateYear,
        dateMonth,
        dateDay,
        timeHour,
        timeMinute,
        timeSecond,
      )
      let timestamp = TimeZoneHook.formattedISOString(dateTimeCheck, format)
      timestamp
    } else {
      ""
    }
  })

  let dropdownVisibilityClass = if isExpanded {
    "inline-block z-100"
  } else {
    "hidden"
  }

  let onDateClick = str => {
    showTime ? () : setIsExpanded(p => !p)

    setSelectedDate(_ => str)

    let currentDateSplit = String.split(str, "-")
    let currentDateDay = currentDateSplit->Array.get(2)->Option.getOr("1")
    let currentDateYear = currentDateSplit->Array.get(0)->Option.getOr("1970")
    let currentDateMonth = currentDateSplit->Array.get(1)->Option.getOr("1")

    let currentDateTimeCheck = customTimezoneToISOString(
      currentDateYear,
      currentDateMonth,
      currentDateDay,
      currentDateHourFormat,
      currentDateMinuteFormat,
      currentDateSecondsFormat,
    )
    setDate(_ => currentDateTimeCheck)
    input.onChange(currentDateTimeCheck->Identity.stringToFormReactEvent)
  }
  React.useEffect1(() => {
    if input.value == ""->JSON.Encode.string {
      setSelectedDate(_ => "")
    }
    None
  }, [input.value])

  let defaultCellHighlighter = currDate => {
    let highlighter: Calendar.highlighter = {
      highlightSelf: currDate === selectedDate,
      highlightLeft: false,
      highlightRight: false,
    }
    highlighter
  }
  OutsideClick.useOutsideClick(
    ~refs=ArrayOfRef([dropdownRef]),
    ~isActive=isExpanded,
    ~callback=() => {
      setIsExpanded(p => !p)
    },
    (),
  )
  let changeVisibility = _ev => {
    if !isDisabled {
      setIsExpanded(p => !p)
    }
  }

  let buttonText = {
    let startDateStr = if selectedDate->isEmptyString {
      "Select Date"
    } else if !showTime {
      selectedDate
    } else {
      let time = date->DateRangePicker.getTimeStringForValue(isoStringToCustomTimeZone)
      let splitTime = time->String.split(":")
      `${selectedDate} ${time->isEmptyString
          ? `${currentDateHourFormat}:${currentDateMinuteFormat}${showSeconds
                ? ":" ++ currentDateSecondsFormat
                : ""}`
          : splitTime->Array.get(0)->Option.getOr("NA") ++
            ":" ++
            splitTime->Array.get(1)->Option.getOr("NA") ++ (
              showSeconds ? ":" ++ splitTime->Array.get(2)->Option.getOr("NA") : ""
            )}`
    }
    startDateStr
  }

  let buttonIcon = if isExpanded {
    "angle-up"
  } else {
    "angle-down"
  }

  let rightIcon: Button.iconType = switch rightIcon {
  | Some(icon) => icon
  | None => FontAwesome(buttonIcon)
  }

  let leftIcon: Button.iconType = switch leftIcon {
  | Some(icon) => icon
  | None => FontAwesome("calendar")
  }
  let fullLengthWidthClass = fullLength->Option.getOr(false) ? "2xl:w-full" : ""

  let startTimeInput: ReactFinalForm.fieldRenderPropsInput = {
    name: "string",
    onBlur: _ev => (),
    onChange: timeValEv => {
      let timeVal = timeValEv->Identity.formReactEventToString
      if selectedDate->isNonEmptyString {
        let todayDayJsObj = Date.make()->Date.toString->DayJs.getDayJsForString
        let todayTime = todayDayJsObj.format(. "HH:mm:ss")
        let todayDate = todayDayJsObj.format(. "YYYY-MM-DD")
        let timeVal = if disableFutureDates && selectedDate == todayDate && timeVal > todayTime {
          todayTime
        } else {
          timeVal
        }
        let date = String.split(selectedDate, "-")
        let dateDay = date->Array.get(2)->Option.getOr("1")
        let dateMonth = date->Array.get(1)->Option.getOr("1")
        let dateYear = date->Array.get(0)->Option.getOr("1970")
        let timeSplit = String.split(timeVal, ":")
        let timeHour = timeSplit->Array.get(0)->Option.getOr(currentDateHourFormat)
        let timeMinute = timeSplit->Array.get(1)->Option.getOr(currentDateMinuteFormat)
        let timeSecond = timeSplit->Array.get(2)->Option.getOr(currentDateSecondsFormat)
        let dateTimeCheck = customTimezoneToISOString(
          dateYear,
          dateMonth,
          dateDay,
          timeHour,
          timeMinute,
          timeSecond,
        )
        let timestamp = TimeZoneHook.formattedISOString(dateTimeCheck, format)
        setDate(_ => timestamp)
        input.onChange(timestamp->Table.dateFormat(format)->Identity.stringToFormReactEvent)
      }
    },
    onFocus: _ev => (),
    value: {
      let time = date->DateRangePicker.getTimeStringForValue(isoStringToCustomTimeZone)
      let time =
        time->isEmptyString
          ? `${currentDateHourFormat}:${currentDateMinuteFormat}:${currentDateSecondsFormat}`
          : time
      time->JSON.Encode.string
    },
    checked: false,
  }
  let styleClass = showTime
    ? " flex-col bg-white dark:bg-jp-gray-lightgray_background border-jp-gray-500 dark:border-jp-gray-960 p-4 rounded border"
    : "flex-row"
  let isMobileView = MatchMedia.useMobileChecker()

  let calendarElement =
    <>
      <CalendarList
        count=1
        cellHighlighter=defaultCellHighlighter
        onDateClick
        disablePastDates
        disableFutureDates
        customDisabledFutureDays
        ?calendarContaierStyle
      />
      {if showTime {
        <div className={`w-fit dark:text-gray-400 text-gray-700 `}>
          <TimeInput input=startTimeInput isDisabled={selectedDate->isEmptyString} showSeconds />
        </div>
      } else {
        React.null
      }}
    </>

  <div ref={dropdownRef->ReactDOM.Ref.domRef} className="md:relative">
    <Button
      text=buttonText
      customButtonStyle
      ?buttonType
      ?buttonSize
      buttonState={isDisabled ? Disabled : Normal}
      leftIcon
      rightIcon
      onClick={changeVisibility}
      ?fullLength
    />
    <div className=dropdownVisibilityClass>
      {if isMobileView {
        <BottomModal headerText={buttonText} onCloseClick={changeVisibility}>
          calendarElement
        </BottomModal>
      } else {
        <div className={`absolute flex w-max z-10  ${fullLengthWidthClass} ${styleClass}`}>
          calendarElement
        </div>
      }}
    </div>
  </div>
}
