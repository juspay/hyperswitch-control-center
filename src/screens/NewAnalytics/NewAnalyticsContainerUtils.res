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

let (startTimeFilterKey, endTimeFilterKey) = ("startTime", "endTime")

let initialFixedFilterFields = () => {
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
            ~enableComparision=true,
            ~compareOptions=[Previous_Period, No_Comparison],
            ~numMonths=2,
            ~disableApply=false,
            ~dateRangeLimit=180,
          ),
          ~inputFields=[],
          ~isRequired=false,
        ),
      }: EntityType.initialFilters<'t>
    ),
  ]

  newArr
}
