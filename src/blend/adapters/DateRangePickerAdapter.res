open ReactFinalForm
open LogicUtils
open DateRangePickerBinding.DateRangePreset
open DateRangePickerBinding.PresetsConfig

let makeCustomPreset = (~id, ~label, ~startDate, ~endDate) =>
  fromCustom({
    id,
    label,
    getDateRange: () => {startDate, endDate: Some(endDate)},
  })

let toBlendPreset = (
  day: DateRangeUtils.customDateRange,
  ~disableFutureDates: bool,
): DateRangePickerBinding.PresetsConfig.t => {
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
      makeCustomPreset(
        ~id="last6Months",
        ~label="Last 6 months",
        ~startDate=sixMonthsAgo,
        ~endDate=now,
      )
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
      makeCustomPreset(
        ~id="nextMonth",
        ~label="Next month",
        ~startDate=firstOfNextMonth,
        ~endDate=lastOfNextMonth,
      )
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
        let label = `Last ${x->Float.toString->removeTrailingZero} hours`
        makeCustomPreset(
          ~id=`last_${x->Float.toString}_hours`,
          ~label,
          ~startDate=hoursAgo,
          ~endDate=now,
        )
      }
    } else {
      let now = Date.make()
      let hoursFromNow = Date.fromTime(Date.getTime(now) +. x *. 3600.0 *. 1000.0)
      let label = `Next ${x->Float.toString->removeTrailingZero} hours`
      makeCustomPreset(
        ~id=`next_${x->Float.toString}_hours`,
        ~label,
        ~startDate=now,
        ~endDate=hoursFromNow,
      )
    }
  | Day(x) =>
    if x === 7.0 {
      fromPreset(last7Days)
    } else if x === 30.0 {
      fromPreset(last30Days)
    } else {
      let now = Date.make()
      let daysAgo = (now->DayJs.getDayJsForJsDate).subtract(x->Float.toInt, "day").toDate()
      let label = `Last ${x->Float.toString->removeTrailingZero} days`
      makeCustomPreset(
        ~id=`last_${x->Float.toString}_days`,
        ~label,
        ~startDate=daysAgo,
        ~endDate=now,
      )
    }
  }
}

let formatIsoToFormat = (date: Date.t, format: string) =>
  date->Date.toISOString->TimeZoneHook.formattedISOString(format)

// Widest span a preset can cover, in days. Blend's maxRangeDays only guards the
// calendar grid, so presets beyond the limit must be filtered out ourselves.
let presetSpanDays = (day: DateRangeUtils.customDateRange) => {
  let now = Date.make()
  switch day {
  | Today | Yesterday | Tomorrow => 1.
  | ThisMonth => now->Date.getDate->Int.toFloat
  | LastMonth =>
    Date.makeWithYMD(~year=now->Date.getFullYear, ~month=now->Date.getMonth, ~date=0)
    ->Date.getDate
    ->Int.toFloat
  | NextMonth =>
    Date.makeWithYMD(~year=now->Date.getFullYear, ~month=now->Date.getMonth + 2, ~date=0)
    ->Date.getDate
    ->Int.toFloat
  | LastSixMonths => {
      let sixMonthsAgo = Date.make()
      Date.setMonth(sixMonthsAgo, Date.getMonth(sixMonthsAgo) - 6)
      (now->Date.getTime -. sixMonthsAgo->Date.getTime) /. 86400000.
    }
  | Hour(x) => x /. 24.
  | Day(x) => x
  }
}

let filterPresetsByLimit = (predefinedDays, dateRangeLimit) =>
  dateRangeLimit->mapOptionOrDefault(predefinedDays, limit =>
    predefinedDays->Array.filter(day => presetSpanDays(day) <= limit->Int.toFloat)
  )

let allowedRangeBounds = (allowedDateRange: option<Calendar.dateObj>) => {
  let toDate = s => s->getNonEmptyString->Option.map(Date.fromString)
  (
    allowedDateRange->Option.flatMap(r => r.startDate->toDate),
    allowedDateRange->Option.flatMap(r => r.endDate->toDate),
  )
}

module BlendDateRangePicker = {
  @react.component
  let make = (
    ~startKey: string,
    ~endKey: string,
    ~showTime=true,
    ~disable: bool,
    ~disablePastDates: bool,
    ~disableFutureDates: bool,
    ~predefinedDays: array<DateRangeUtils.customDateRange>,
    ~format: string,
    ~dateRangeLimit: option<int>,
    ~allowedDateRange: option<Calendar.dateObj>,
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

    let customPresets =
      predefinedDays
      ->filterPresetsByLimit(dateRangeLimit)
      ->Array.map(day => toBlendPreset(day, ~disableFutureDates))

    let (minDate, maxDate) = allowedRangeBounds(allowedDateRange)

    let formatConfig = showTime ? None : Some({DateRangePickerBinding.includeTime: false})

    <DateRangePickerBinding
      value=?blendValue
      onChange=handleChange
      showDateTimePicker=showTime
      isDisabled=disable
      disableFutureDates
      disablePastDates
      customPresets
      maxRangeDays=?dateRangeLimit
      ?minDate
      ?maxDate
      ?formatConfig
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
        startKey
        endKey
        showTime
        disable
        disablePastDates
        disableFutureDates
        predefinedDays
        format
        dateRangeLimit
        allowedDateRange
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
