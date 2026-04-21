open LogicUtils

module BlendDateRangeField = {
  @react.component
  let make = (
    ~startKey: string,
    ~endKey: string,
    ~showTime: bool,
    ~disable: bool,
    ~disablePastDates: bool,
    ~disableFutureDates: bool,
    ~predefinedDays: array<DateRangeUtils.customDateRange>,
  ) => {
    let startInput = ReactFinalForm.useField(startKey).input
    let endInput = ReactFinalForm.useField(endKey).input
    let blendValue = switch (
      startInput.value->JSON.Decode.string->Option.flatMap(getNonEmptyString),
      endInput.value->JSON.Decode.string->Option.flatMap(getNonEmptyString),
    ) {
    | (Some(start), Some(end)) =>
      Some(
        (
          {
            startDate: start->Js.Date.fromString,
            endDate: end->Js.Date.fromString,
          }: DateRangePickerBinding.dateRange
        ),
      )
    | _ => None
    }

    let handleChange = React.useCallback((range: DateRangePickerBinding.dateRange) => {
      startInput.onChange(range.startDate->Js.Date.toISOString->Identity.stringToFormReactEvent)
      endInput.onChange(range.endDate->Js.Date.toISOString->Identity.stringToFormReactEvent)
    }, [startInput.onChange, endInput.onChange])

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
  }
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
  let isBlendEnabled = BlendContext.useBlendEnabled()

  <>
    <RenderIf condition={isBlendEnabled}>
      <BlendDateRangeField
        startKey endKey showTime disable disablePastDates disableFutureDates predefinedDays
      />
    </RenderIf>
    <RenderIf condition={!isBlendEnabled}>
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
    </RenderIf>
  </>
}
