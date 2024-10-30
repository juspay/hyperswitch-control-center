open NewAnalyticsTypes

let getPageVariant = string => {
  switch string {
  | "new-analytics-payment" | _ => NewAnalyticsPayment
  }
}

let getPageIndex = (url: RescriptReactRouter.url) => {
  switch url.path->HSwitchUtils.urlPath {
  | list{"new-analytics-payment"} | _ => 0
  }
}

let getPageFromIndex = index => {
  switch index {
  | 1 | _ => NewAnalyticsPayment
  }
}

let (
  startTimeFilterKey,
  endTimeFilterKey,
  smartRetryKey,
  compareToStartTimeKey,
  compareToEndTimeKey,
) = ("startTime", "endTime", "is_smart_retry_enabled", "compareToStartTime", "compareToEndTime")

let initialFixedFilterFields = (~compareWithStartTime, ~compareWithEndTime) => {
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
            ~compareWithStartTime,
            ~compareWithEndTime,
          ),
          ~inputFields=[],
          ~isRequired=false,
        ),
      }: EntityType.initialFilters<'t>
    ),
  ]

  newArr
}
