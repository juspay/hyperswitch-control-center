open LogicUtils
open DateRangePickerBinding
open DateRangePreset
open PresetsConfig

let toBlendPreset = (
  day: DateRangeUtils.customDateRange,
  ~disableFutureDates: bool,
): PresetsConfig.t => {
  switch day {
  | Today => fromPreset(today)
  | Yesterday => fromPreset(yesterday)
  | Tomorrow => fromPreset(tomorrow)
  | ThisMonth => fromPreset(thisMonth)
  | LastMonth => fromPreset(lastMonth)
  | LastSixMonths => {
      let now = Date.make()
      let sixMonthsAgo = Date.make()
      Date.setMonth(sixMonthsAgo, Date.getMonth(sixMonthsAgo) - 6)
      fromCustom({
        label: "Last 6 Months",
        startDate: sixMonthsAgo,
        endDate: now,
      })
    }
  | NextMonth => {
      let now = Date.make()
      let firstOfNextMonth = Date.makeWithYMD(
        ~year=Date.getFullYear(now),
        ~month=Date.getMonth(now) + 1,
        ~date=1,
      )
      let lastOfNextMonth = Date.makeWithYMD(
        ~year=Date.getFullYear(now),
        ~month=Date.getMonth(now) + 2,
        ~date=0,
      )
      fromCustom({
        label: "Next Month",
        startDate: firstOfNextMonth,
        endDate: lastOfNextMonth,
      })
    }
  | Hour(x) =>
    if disableFutureDates {
      if x === 0.5 {
        fromPreset(last30Minutes)
      } else if x === 1.0 {
        fromPreset(last1Hour)
      } else {
        let now = Date.make()
        let hoursAgo = Date.fromTime(Date.getTime(now) -. x *. 3600.0 *. 1000.0)
        fromCustom({
          label: `Last ${x->Float.toString->removeTrailingZero} Hours`,
          startDate: hoursAgo,
          endDate: now,
        })
      }
    } else {
      let now = Date.make()
      let hoursFromNow = Date.fromTime(Date.getTime(now) +. x *. 3600.0 *. 1000.0)
      fromCustom({
        label: `Next ${x->Float.toString->removeTrailingZero} Hours`,
        startDate: now,
        endDate: hoursFromNow,
      })
    }
  | Day(x) =>
    if x === 7.0 {
      fromPreset(last7Days)
    } else if x === 30.0 {
      fromPreset(last30Days)
    } else {
      let now = Date.make()
      let daysAgo = Date.fromTime(Date.getTime(now) -. x *. 86400.0 *. 1000.0)
      fromCustom({
        label: `Last ${x->Float.toString->removeTrailingZero} Days`,
        startDate: daysAgo,
        endDate: now,
      })
    }
  }
}

module BlendDateRangePicker = {
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
            startDate: start->Date.fromString,
            endDate: end->Date.fromString,
          }: dateRange
        ),
      )
    | _ => None
    }

    let handleChange = React.useCallback((range: dateRange) => {
      startInput.onChange(range.startDate->Date.toISOString->Identity.stringToFormReactEvent)
      endInput.onChange(range.endDate->Date.toISOString->Identity.stringToFormReactEvent)
    }, [startInput.onChange, endInput.onChange])

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

  <>
    <RenderIf condition={isBlendEnabled}>
      <BlendDateRangePicker
        startKey endKey showTime disable disablePastDates disableFutureDates predefinedDays
      />
    </RenderIf>
    <RenderIf condition={!isBlendEnabled}>
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
    </RenderIf>
  </>
}
