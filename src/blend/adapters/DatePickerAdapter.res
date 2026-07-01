module BlendDatePicker = {
  @react.component
  let make = (
    ~input: ReactFinalForm.fieldRenderPropsInput,
    ~isDisabled: bool,
    ~disablePastDates: bool,
    ~disableFutureDates: bool,
    ~format: string,
    ~showTime: bool,
    ~currentDateHourFormat: string,
    ~currentDateMinuteFormat: string,
    ~currentDateSecondsFormat: string,
  ) => {
    open ReactFinalForm
    open LogicUtils
    open Date
    open TimeZoneHook
    let customTimezoneToISOString = useCustomTimeZoneToIsoString()

    let blendValue =
      input.value
      ->getStringFromJson("")
      ->getNonEmptyString
      ->Option.map(str => {
        let date = str->fromString
        ({startDate: date, endDate: None}: DateRangePickerBinding.dateRange)
      })

    let handleChange = React.useCallback((range: DateRangePickerBinding.dateRange) => {
      let date = range.startDate
      let year = date->getFullYear->Int.toString
      let month = (date->getMonth + 1)->Int.toString
      let day = date->getDate->Int.toString
      let (hours, minutes, seconds) = showTime
        ? (
            date->getHours->Int.toString,
            date->getMinutes->Int.toString,
            date->getSeconds->Int.toString,
          )
        : (currentDateHourFormat, currentDateMinuteFormat, currentDateSecondsFormat)
      let isoString = customTimezoneToISOString(year, month, day, hours, minutes, seconds)
      input.onChange(isoString->formattedISOString(format)->Identity.stringToFormReactEvent)
    }, (
      input.onChange,
      format,
      showTime,
      customTimezoneToISOString,
      currentDateHourFormat,
      currentDateMinuteFormat,
      currentDateSecondsFormat,
    ))

    <DateRangePickerBinding
      value=?blendValue
      onChange=handleChange
      isDisabled
      disableFutureDates
      disablePastDates
      isSingleDatePicker=true
      allowSingleDateSelection=true
      showPresets=false
      showDateTimePicker=showTime
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
      <BlendDatePicker
        input
        isDisabled
        disablePastDates
        disableFutureDates
        format
        showTime
        currentDateHourFormat
        currentDateMinuteFormat
        currentDateSecondsFormat
      />
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
