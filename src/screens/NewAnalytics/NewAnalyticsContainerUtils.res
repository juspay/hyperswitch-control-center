open NewAnalyticsTypes

let getPageIndex = (url: RescriptReactRouter.url) => {
  switch url.path->HSwitchUtils.urlPath {
  | list{"new-analytics", "smart-retry"} => 1
  | list{"new-analytics", "refund"} => 2
  | list{"new-analytics", "payment"} | _ => 0
  }
}

let getPageFromIndex = index => {
  switch index {
  | 1 => NewAnalyticsSmartRetry
  | 2 => NewAnalyticsRefund
  | 0 | _ => NewAnalyticsPayment
  }
}

let renderValueInp = () => (_fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
  React.null
}

let compareToInput = (~comparisonKey) => {
  FormRenderer.makeMultiInputFieldInfoOld(
    ~label="",
    ~comboCustomInput=renderValueInp(),
    ~inputFields=[
      FormRenderer.makeInputFieldInfo(~name=`${comparisonKey}`),
      FormRenderer.makeInputFieldInfo(~name=`extraKey`),
    ],
    (),
  )
}

let (
  startTimeFilterKey,
  endTimeFilterKey,
  smartRetryKey,
  compareToStartTimeKey,
  compareToEndTimeKey,
  comparisonKey,
) = (
  "startTime",
  "endTime",
  "is_smart_retry_enabled",
  "compareToStartTime",
  "compareToEndTime",
  "comparison",
)

let initialFixedFilterFields = (~compareWithStartTime, ~compareWithEndTime, ~events=?) => {
  let events = switch events {
  | Some(fn) => fn
  | _ => () => ()
  }
  let newArr = [
    (
      {
        localFilter: None,
        field: FormRenderer.makeMultiInputFieldInfo(
          ~label="",
          ~comboCustomInput=InputFields.filterDateRangeField(
            ~startKey=startTimeFilterKey,
            ~endKey=endTimeFilterKey,
            ~format="YYYY-MM-DDTHH:mm:ss[Z]",
            ~showTime=true,
            ~disablePastDates={false},
            ~disableFutureDates={true},
            ~predefinedDays=[
              Hour(0.5),
              Hour(1.0),
              Hour(2.0),
              Today,
              Yesterday,
              Day(2.0),
              Day(7.0),
              Day(30.0),
              ThisMonth,
              LastMonth,
            ],
            ~numMonths=2,
            ~disableApply=false,
            ~dateRangeLimit=180,
            ~events,
          ),
          ~inputFields=[],
          ~isRequired=false,
        ),
      }: EntityType.initialFilters<'t>
    ),
    (
      {
        localFilter: None,
        field: FormRenderer.makeMultiInputFieldInfo(
          ~label="",
          ~comboCustomInput=InputFields.filterCompareDateRangeField(
            ~startKey=compareToStartTimeKey,
            ~endKey=compareToEndTimeKey,
            ~comparisonKey,
            ~format="YYYY-MM-DDTHH:mm:ss[Z]",
            ~showTime=true,
            ~disablePastDates={false},
            ~disableFutureDates={true},
            ~predefinedDays=[Today, Yesterday, Day(2.0), Day(7.0), Day(30.0), ThisMonth, LastMonth],
            ~numMonths=2,
            ~disableApply=false,
            ~compareWithStartTime,
            ~compareWithEndTime,
          ),
          ~inputFields=[],
        ),
      }: EntityType.initialFilters<'t>
    ),
    (
      {
        localFilter: None,
        field: compareToInput(~comparisonKey),
      }: EntityType.initialFilters<'t>
    ),
  ]

  newArr
}
