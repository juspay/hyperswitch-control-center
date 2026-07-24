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
  ) => {
    let startInput = useField(startKey).input
    let endInput = useField(endKey).input
    let showToast = ToastAdapter.useShowToast()
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
      let (endDate, limitMessage) = clampEndDate(
        ~dateRangeLimit,
        ~startDate=range.startDate,
        ~endDate=range.endDate->Option.getOr(range.startDate),
      )
      startInput.onChange(
        formatIsoToFormat(range.startDate, format)->Identity.stringToFormReactEvent,
      )
      endInput.onChange(formatIsoToFormat(endDate, format)->Identity.stringToFormReactEvent)
      switch limitMessage {
      | Some(message) => showToast(~message, ~toastType=ToastState.ToastError)
      | None => ()
      }
    }, (startInput.onChange, endInput.onChange, format, dateRangeLimit, showToast))

    let customPresets = predefinedDays->Array.map(day => toBlendPreset(day, ~disableFutureDates))

    <DateRangePickerBinding
      value=?blendValue
      onChange=handleChange
      showDateTimePicker=true
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
        startKey
        endKey
        disable
        disablePastDates
        disableFutureDates
        predefinedDays
        format
        dateRangeLimit
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
