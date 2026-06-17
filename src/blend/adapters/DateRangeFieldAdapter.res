open ReactFinalForm
open LogicUtils
open DateRangePickerAdapter
module BlendDateRangeField = {
  @react.component
  let make = (
    ~startKey: string,
    ~endKey: string,
    ~disable: bool,
    ~disablePastDates: bool,
    ~disableFutureDates: bool,
    ~predefinedDays: array<DateRangeUtils.customDateRange>,
    ~format: string,
    ~dateRangeLimit: option<int>,
    ~useDrawerOnMobile=true,
    ~skipQuickFiltersOnMobile=true,
    ~size=DateRangePickerBinding.Sm,
  ) => {
    let startInput = useField(startKey).input
    let endInput = useField(endKey).input
    let blendValue = switch (
      startInput.value->getStringFromJson("")->getNonEmptyString,
      endInput.value->getStringFromJson("")->getNonEmptyString,
    ) {
    | (Some(start), Some(end)) =>
      Some(
        (
          {
            startDate: start->Date.fromString,
            endDate: Some(end->Date.fromString),
          }: DateRangePickerBinding.dateRange
        ),
      )
    | _ => None
    }

    let handleChange = React.useCallback((range: DateRangePickerBinding.dateRange) => {
      let endDate = range.endDate->Option.getOr(range.startDate)
      startInput.onChange(
        formatIsoToFormat(range.startDate, format)->Identity.stringToFormReactEvent,
      )
      endInput.onChange(formatIsoToFormat(endDate, format)->Identity.stringToFormReactEvent)
    }, (startInput.onChange, endInput.onChange, format))

    let customPresets = predefinedDays->Array.map(day => toBlendPreset(day, ~disableFutureDates))

    let (minDate, maxDate) = getMinMaxDates(~dateRangeLimit, ~disableFutureDates, ~disablePastDates)

    <DateRangePickerBinding
      value=?blendValue
      onChange=handleChange
      showDateTimePicker=true
      isDisabled=disable
      disableFutureDates
      disablePastDates
      customPresets
      ?minDate
      ?maxDate
      useDrawerOnMobile
      skipQuickFiltersOnMobile
      size
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
  ~useDrawerOnMobile=true,
  ~skipQuickFiltersOnMobile=true,
  ~size=DateRangePickerBinding.Sm,
) => {
  let isBlendEnabled = BlendContext.useBlendEnabled()

  <>
    <RenderIf condition={isBlendEnabled}>
      <BlendDateRangeField
        startKey
        endKey
        disable
        disablePastDates
        disableFutureDates
        predefinedDays
        format
        dateRangeLimit
        useDrawerOnMobile
        skipQuickFiltersOnMobile
        size
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
