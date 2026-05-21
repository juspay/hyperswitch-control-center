open ReactFinalForm
open LogicUtils

module BlendDatePicker = {
  @react.component
  let make = (
    ~input: ReactFinalForm.fieldRenderPropsInput,
    ~isDisabled: bool,
    ~disablePastDates: bool,
    ~disableFutureDates: bool,
    ~format: string,
  ) => {
    let blendValue =
      input.value
      ->getStringFromJson("")
      ->getNonEmptyString
      ->Option.map(str => {
        let date = str->Date.fromString
        ({startDate: date, endDate: None}: DateRangePickerBinding.dateRange)
      })

    let handleChange = React.useCallback((range: DateRangePickerBinding.dateRange) => {
      input.onChange(
        DateRangePickerAdapter.formatIsoToFormat(
          range.startDate,
          format,
        )->Identity.stringToFormReactEvent,
      )
    }, (input.onChange, format))

    <DateRangePickerBinding
      value=?blendValue
      onChange=handleChange
      isDisabled
      disableFutureDates
      disablePastDates
      isSingleDatePicker=true
      allowSingleDateSelection=true
      showPresets=false
    />
  }
}

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
  ~calendarContainerStyle=?,
  ~showTime=false,
  ~showSeconds=true,
  ~fullLength=?,
) => {
  let isBlendEnabled = BlendContext.useBlendEnabled()

  <>
    <RenderIf condition={isBlendEnabled}>
      <BlendDatePicker input isDisabled disablePastDates disableFutureDates format />
    </RenderIf>
    <RenderIf condition={!isBlendEnabled}>
      <DatePicker
        input
        isDisabled
        disablePastDates
        disableFutureDates
        format
        customButtonStyle
        newThemeCustomButtonStyle
        ?leftIcon
        ?rightIcon
        ?buttonType
        ?buttonSize
        customDisabledFutureDays
        currentDateHourFormat
        currentDateMinuteFormat
        currentDateSecondsFormat
        ?calendarContainerStyle
        showTime
        showSeconds
        ?fullLength
      />
    </RenderIf>
  </>
}
