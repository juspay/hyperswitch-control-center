open LogicUtils

let useStateForInput = (input: ReactFinalForm.fieldRenderPropsInput) => {
  React.useMemo(() => {
    let val = input.value->JSON.Decode.string->Option.getOr("")
    let onChange = fn => {
      let newVal = fn(val)
      input.onChange(newVal->Identity.stringToFormReactEvent)
    }
    (val, onChange)
  }, [input])
}

let toBlendPreset = (
  day: DateRangeUtils.customDateRange,
  ~disableFutureDates: bool,
): DateRangePickerBinding.PresetsConfig.t => {
  switch day {
  | Today =>
    DateRangePickerBinding.PresetsConfig.fromPreset(DateRangePickerBinding.DateRangePreset.today)
  | Yesterday =>
    DateRangePickerBinding.PresetsConfig.fromPreset(
      DateRangePickerBinding.DateRangePreset.yesterday,
    )
  | Tomorrow =>
    DateRangePickerBinding.PresetsConfig.fromPreset(DateRangePickerBinding.DateRangePreset.tomorrow)
  | ThisMonth =>
    DateRangePickerBinding.PresetsConfig.fromPreset(
      DateRangePickerBinding.DateRangePreset.thisMonth,
    )
  | LastMonth =>
    DateRangePickerBinding.PresetsConfig.fromPreset(
      DateRangePickerBinding.DateRangePreset.lastMonth,
    )
  | LastSixMonths => {
      let now = Js.Date.make()
      let sixMonthsAgo = Js.Date.make()
      let _ = Js.Date.setMonth(sixMonthsAgo, Js.Date.getMonth(sixMonthsAgo) -. 6.0)
      DateRangePickerBinding.PresetsConfig.fromCustom({
        label: "Last 6 Months",
        startDate: sixMonthsAgo,
        endDate: now,
      })
    }
  | NextMonth => {
      let now = Js.Date.make()
      let firstOfNextMonth = Js.Date.makeWithYMD(
        ~year=Js.Date.getFullYear(now),
        ~month=Js.Date.getMonth(now) +. 1.0,
        ~date=1.0,
        (),
      )
      let lastOfNextMonth = Js.Date.makeWithYMD(
        ~year=Js.Date.getFullYear(now),
        ~month=Js.Date.getMonth(now) +. 2.0,
        ~date=0.0,
        (),
      )
      DateRangePickerBinding.PresetsConfig.fromCustom({
        label: "Next Month",
        startDate: firstOfNextMonth,
        endDate: lastOfNextMonth,
      })
    }
  | Hour(x) =>
    if disableFutureDates {
      if x === 0.5 {
        DateRangePickerBinding.PresetsConfig.fromPreset(
          DateRangePickerBinding.DateRangePreset.last30Minutes,
        )
      } else if x === 1.0 {
        DateRangePickerBinding.PresetsConfig.fromPreset(
          DateRangePickerBinding.DateRangePreset.last1Hour,
        )
      } else {
        let now = Js.Date.make()
        let hoursAgo = Js.Date.fromFloat(Js.Date.getTime(now) -. x *. 3600.0 *. 1000.0)
        DateRangePickerBinding.PresetsConfig.fromCustom({
          label: `Last ${Float.toString(x)} Hours`,
          startDate: hoursAgo,
          endDate: now,
        })
      }
    } else {
      let now = Js.Date.make()
      let hoursFromNow = Js.Date.fromFloat(Js.Date.getTime(now) +. x *. 3600.0 *. 1000.0)
      DateRangePickerBinding.PresetsConfig.fromCustom({
        label: `Next ${Float.toString(x)} Hours`,
        startDate: now,
        endDate: hoursFromNow,
      })
    }
  | Day(x) =>
    if x === 7.0 {
      DateRangePickerBinding.PresetsConfig.fromPreset(
        DateRangePickerBinding.DateRangePreset.last7Days,
      )
    } else if x === 30.0 {
      DateRangePickerBinding.PresetsConfig.fromPreset(
        DateRangePickerBinding.DateRangePreset.last30Days,
      )
    } else {
      let now = Js.Date.make()
      let daysAgo = Js.Date.fromFloat(Js.Date.getTime(now) -. x *. 86400.0 *. 1000.0)
      DateRangePickerBinding.PresetsConfig.fromCustom({
        label: `Last ${Float.toString(x)} Days`,
        startDate: daysAgo,
        endDate: now,
      })
    }
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
  ~customButtonStyle=?,
  ~buttonText="",
  ~textStyle=?,
  ~standardTimeToday=false,
  ~removeConversion=false,
  ~isTooltipVisible=true,
) => {
  let isBlendEnabled = BlendContext.useBlendEnabled()

  // Hoist hooks above conditional to satisfy React rules
  let startInput = ReactFinalForm.useField(startKey).input
  let endInput = ReactFinalForm.useField(endKey).input
  let (startDateVal, setStartDateVal) = useStateForInput(startInput)
  let (endDateVal, setEndDateVal) = useStateForInput(endInput)

  if isBlendEnabled {
    let blendValue: option<DateRangePickerBinding.dateRange> = if (
      startDateVal->isNonEmptyString && endDateVal->isNonEmptyString
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

    let customPresets = predefinedDays->Array.map(day => toBlendPreset(day, ~disableFutureDates))

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
    <DateRangePicker
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
      ?customButtonStyle
      buttonText
      ?textStyle
      standardTimeToday
      removeConversion
      isTooltipVisible
    />
  }
}
