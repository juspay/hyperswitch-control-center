open DateRangeUtils

module CompareOption = {
  @react.component
  let make = (~value: compareOption, ~comparison, ~startDateVal, ~endDateVal, ~onClick) => {
    let previousPeriod = React.useMemo(() => {
      let (startDate, endDate) = getComparisionTimePeriod(
        ~startDate=startDateVal,
        ~endDate=endDateVal,
      )
      let format = "MMM DD, YYYY"
      let startDateStr = getFormattedDate(startDate, format)
      let endDateStr = getFormattedDate(endDate, format)
      `${startDateStr} - ${endDateStr}`
    }, [comparison])
    <div
      onClick={_ => onClick(value)}
      className={`text-center md:text-start min-w-max bg-white w-full   hover:bg-jp-gray-100 hover:bg-opacity-75 cursor-pointer mx-2 rounded-md p-2 text-sm font-medium text-grey-900 `}>
      {switch value {
      | No_Comparison => "No Comparison"->React.string
      | Previous_Period =>
        <div>
          {"Previous Period : "->React.string}
          <span className="opacity-70"> {{previousPeriod}->React.string} </span>
        </div>
      | Custom => "Custom Range"->React.string
      }}
    </div>
  }
}

module ButtonRightIcon = {
  open LogicUtils
  @react.component
  let make = (
    ~startDateVal,
    ~endDateVal,
    ~setStartDateVal,
    ~setEndDateVal,
    ~disable,
    ~isDropdownOpen,
    ~removeFilterOption,
    ~resetToInitalValues,
  ) => {
    let buttonIcon = isDropdownOpen ? "angle-up" : "angle-down"

    let removeApplyFilter = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      resetToInitalValues()
      setStartDateVal(_ => "")
      setEndDateVal(_ => "")
    }

    <div className="flex flex-row gap-2">
      <Icon className={getStrokeColor(disable, isDropdownOpen)} name=buttonIcon size=14 />
      <RenderIf
        condition={removeFilterOption &&
        startDateVal->isNonEmptyString &&
        endDateVal->isNonEmptyString}>
        <Icon name="crossicon" size=16 onClick=removeApplyFilter />
      </RenderIf>
    </div>
  }
}

module DateSelectorButton = {
  open LogicUtils
  @react.component
  let make = (
    ~startDateVal,
    ~endDateVal,
    ~setStartDateVal,
    ~setEndDateVal,
    ~disable,
    ~isDropdownOpen,
    ~removeFilterOption,
    ~resetToInitalValues,
    ~showTime,
    ~buttonText,
    ~showSeconds,
    ~predefinedOptionSelected,
    ~disableFutureDates,
    ~onClick,
    ~buttonType,
    ~textStyle,
    ~iconBorderColor,
    ~customButtonStyle,
    ~enableToolTip=true,
    ~showLeftIcon=true,
    ~isCompare=false,
    ~comparison,
  ) => {
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
    let isMobileView = MatchMedia.useMobileChecker()
    let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()

    let startDateStr = formatDateString(
      ~dateVal=startDateVal,
      ~buttonText,
      ~defaultLabel="[From-Date]",
      ~isoStringToCustomTimeZone,
    )
    let endDateStr = formatDateString(
      ~dateVal=endDateVal,
      ~buttonText,
      ~defaultLabel="[To-Date]",
      ~isoStringToCustomTimeZone,
    )

    let startTimeStr = formatTimeString(
      ~timeVal=startDateVal->getTimeStringForValue(isoStringToCustomTimeZone),
      ~defaultTime="00:00:00",
      ~showSeconds,
    )

    let endTimeStr = formatTimeString(
      ~timeVal=endDateVal->getTimeStringForValue(isoStringToCustomTimeZone),
      ~defaultTime="23:59:59",
      ~showSeconds,
    )

    let tooltipText = {
      switch (startDateVal->isEmptyString, endDateVal->isEmptyString, showTime) {
      | (true, true, _) => `Select Date ${showTime ? "and Time" : ""}`
      | (false, true, true) => `${startDateStr} ${startTimeStr} - Now`
      | (false, false, true) => `${startDateStr} ${startTimeStr} - ${endDateStr} ${endTimeStr}`
      | (false, false, false) =>
        `${startDateStr} ${startDateStr === buttonText ? "" : "-"} ${endDateStr}`
      | _ => ""
      }
    }

    let formatText = text => isMobileView ? "" : text

    let buttonText =
      getButtonText(
        ~predefinedOptionSelected,
        ~disableFutureDates,
        ~startDateVal,
        ~endDateVal,
        ~buttonText,
        ~isoStringToCustomTimeZone,
        ~comparison,
      )->formatText

    let leftIcon = if isCompare {
      let text = buttonText === "No Comparison" ? "" : "Compare: "
      Button.CustomIcon(<span className="font-medium text-sm"> {text->React.string} </span>)
    } else if showLeftIcon {
      Button.CustomIcon(<Icon name="calendar-filter" size=22 />)
    } else {
      Button.NoIcon
    }

    let rightIcon = {
      Button.CustomIcon(
        <ButtonRightIcon
          startDateVal
          endDateVal
          setStartDateVal
          setEndDateVal
          disable
          isDropdownOpen
          removeFilterOption
          resetToInitalValues
        />,
      )
    }

    let textStyle = switch textStyle {
    | Some(value) => value
    | None => isCompare ? textColor.primaryNormal : ""
    }

    let button =
      <Button
        text={buttonText}
        leftIcon
        rightIcon
        buttonSize=XSmall
        isDropdownOpen
        onClick
        iconBorderColor
        customButtonStyle
        buttonState={disable ? Disabled : Normal}
        ?buttonType
        textStyle
      />

    if enableToolTip {
      <ToolTip
        description={tooltipText}
        toolTipFor={button}
        justifyClass="justify-end"
        toolTipPosition={Top}
      />
    } else {
      button
    }
  }
}
