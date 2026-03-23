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
  let isBlendEnabled = React.useContext(BlendContext.blendEnabledContext)

  // Hoist hooks above conditional to satisfy React rules
  let startInput = ReactFinalForm.useField(startKey).input
  let endInput = ReactFinalForm.useField(endKey).input
  let (startDateVal, setStartDateVal) = DateRangePickerAdapter.useStateForInput(startInput)
  let (endDateVal, setEndDateVal) = DateRangePickerAdapter.useStateForInput(endInput)

  if isBlendEnabled {
    let blendValue: option<DateRangePickerBinding.dateRange> = if (
      startDateVal->LogicUtils.isNonEmptyString && endDateVal->LogicUtils.isNonEmptyString
    ) {
      Some({
        startDate: Js.Date.fromString(startDateVal),
        endDate: Js.Date.fromString(endDateVal),
      })
    } else {
      None
    }

    let handleChange = (range: DateRangePickerBinding.dateRange) => {
      setStartDateVal(_ => Js.Date.toISOString(range.startDate))
      setEndDateVal(_ => Js.Date.toISOString(range.endDate))
    }

    let customPresets =
      predefinedDays->Array.map(day =>
        DateRangePickerAdapter.toBlendPreset(day, ~disableFutureDates)
      )

    <DateRangePickerBinding
      value=?blendValue
      onChange=handleChange
      showDateTimePicker=showTime
      isDisabled=disable
      disableFutureDates
      disablePastDates
      customPresets
    />
  } else {
    <DateRangeField
      startKey
      endKey
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
      ?allowedDateRange
      selectStandardTime
      buttonText
      ?textStyle
      standardTimeToday
      removeConversion
      isTooltipVisible
      ?events
      customButtonStyle
    />
  }
}
