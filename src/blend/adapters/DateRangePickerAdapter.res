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

let clampEndDate = (~dateRangeLimit, ~startDate, ~endDate) =>
  dateRangeLimit->mapOptionOrDefault((endDate, None), days => {
    let maxEndDate = (startDate->DayJs.getDayJsForJsDate).add(days, "day").toDate()
    endDate->Date.getTime > maxEndDate->Date.getTime
      ? (maxEndDate, Some(`Date range should not exceed ${days->Int.toString} days`))
      : (endDate, None)
  })

module BlendDateRangePicker = {
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
      limitMessage->Option.forEach(message => showToast(~message, ~toastType=ToastState.ToastError))
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
        disable
        disablePastDates
        disableFutureDates
        predefinedDays
        format
        dateRangeLimit
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
