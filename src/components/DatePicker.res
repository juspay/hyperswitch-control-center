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
  let dropdownRef = React.useRef(Js.Nullable.null)
  let (isExpanded, setIsExpanded) = React.useState(_ => false)
  let customTimezoneToISOString = TimeZoneHook.useCustomTimeZoneToIsoString()
  let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
  let (selectedDate, setSelectedDate) = React.useState(_ =>
    input.value
    ->LogicUtils.getStringFromJson("")
    ->DateRangePicker.getDateStringForValue(isoStringToCustomTimeZone)
  )
  let (date, setDate) = React.useState(_ => {
    if selectedDate !== "" {
      let date = String.split(selectedDate, "-")
      let dateDay = date->Belt.Array.get(2)->Belt.Option.getWithDefault("1")
      let dateMonth = date->Belt.Array.get(1)->Belt.Option.getWithDefault("1")
      let dateYear = date->Belt.Array.get(0)->Belt.Option.getWithDefault("1970")

      let timeSplit =
        switch input.value->Js.Json.decodeString {
        | Some(str) => str
        | None => ""
        }
        ->DateRangePicker.getTimeStringForValue(isoStringToCustomTimeZone)
        ->String.split(":")

      let timeHour = timeSplit->Belt.Array.get(0)->Belt.Option.getWithDefault(currentDateHourFormat)
      let timeMinute =
        timeSplit->Belt.Array.get(1)->Belt.Option.getWithDefault(currentDateMinuteFormat)
      let timeSecond =
        timeSplit->Belt.Array.get(2)->Belt.Option.getWithDefault(currentDateSecondsFormat)
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
    let currentDateDay = currentDateSplit->Belt.Array.get(2)->Belt.Option.getWithDefault("1")
    let currentDateYear = currentDateSplit->Belt.Array.get(0)->Belt.Option.getWithDefault("1970")
    let currentDateMonth = currentDateSplit->Belt.Array.get(1)->Belt.Option.getWithDefault("1")

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
    if input.value == ""->Js.Json.string {
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
    let startDateStr = if selectedDate === "" {
      "Select Date"
    } else if !showTime {
      selectedDate
    } else {
      let time = date->DateRangePicker.getTimeStringForValue(isoStringToCustomTimeZone)
      let splitTime = time->String.split(":")
      `${selectedDate} ${time === ""
          ? `${currentDateHourFormat}:${currentDateMinuteFormat}${showSeconds
                ? ":" ++ currentDateSecondsFormat
                : ""}`
          : splitTime->Belt.Array.get(0)->Belt.Option.getWithDefault("NA") ++
            ":" ++
            splitTime->Belt.Array.get(1)->Belt.Option.getWithDefault("NA") ++ (
              showSeconds
                ? ":" ++ splitTime->Belt.Array.get(2)->Belt.Option.getWithDefault("NA")
                : ""
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
  let fullLengthWidthClass = fullLength->Belt.Option.getWithDefault(false) ? "2xl:w-full" : ""

  let startTimeInput: ReactFinalForm.fieldRenderPropsInput = {
    name: "string",
    onBlur: _ev => (),
    onChange: timeValEv => {
      let timeVal = timeValEv->Identity.formReactEventToString
      if selectedDate !== "" {
        let todayDayJsObj = Js.Date.make()->Js.Date.toString->DayJs.getDayJsForString
        let todayTime = todayDayJsObj.format(. "HH:mm:ss")
        let todayDate = todayDayJsObj.format(. "YYYY-MM-DD")
        let timeVal = if disableFutureDates && selectedDate == todayDate && timeVal > todayTime {
          todayTime
        } else {
          timeVal
        }
        let date = String.split(selectedDate, "-")
        let dateDay = date->Belt.Array.get(2)->Belt.Option.getWithDefault("1")
        let dateMonth = date->Belt.Array.get(1)->Belt.Option.getWithDefault("1")
        let dateYear = date->Belt.Array.get(0)->Belt.Option.getWithDefault("1970")
        let timeSplit = String.split(timeVal, ":")
        let timeHour =
          timeSplit->Belt.Array.get(0)->Belt.Option.getWithDefault(currentDateHourFormat)
        let timeMinute =
          timeSplit->Belt.Array.get(1)->Belt.Option.getWithDefault(currentDateMinuteFormat)
        let timeSecond =
          timeSplit->Belt.Array.get(2)->Belt.Option.getWithDefault(currentDateSecondsFormat)
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
        time === ""
          ? `${currentDateHourFormat}:${currentDateMinuteFormat}:${currentDateSecondsFormat}`
          : time
      time->Js.Json.string
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
          <TimeInput input=startTimeInput isDisabled={selectedDate === ""} showSeconds />
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
