open LogicUtils
open ReconEngineOverviewTypes
let accountItemToObjMapper = dict => {
  {
    account_name: dict->getString("account_name", ""),
    account_id: dict->getString("account_id", ""),
    currency: dict->getString("currency", ""),
    pending_balance: dict->getString("pending_balance", ""),
    posted_balance: dict->getString("posted_balance", ""),
  }
}

let (
  startTimeFilterKey,
  endTimeFilterKey,
  smartRetryKey,
  compareToStartTimeKey,
  compareToEndTimeKey,
  comparisonKey,
  sampleDataKey,
) = (
  "startTime",
  "endTime",
  "is_smart_retry_enabled",
  "compareToStartTime",
  "compareToEndTime",
  "comparison",
  "is_sample_data_enabled",
)
let initialFixedFilterFields = (~events=?, ~sampleDataIsEnabled=false) => {
  let events = switch events {
  | Some(fn) => fn
  | _ => () => ()
  }
  let customButtonStyle = sampleDataIsEnabled
    ? "!bg-nd_gray-50 !text-nd_gray-400 !rounded-lg !bg-none"
    : "border !rounded-lg !bg-none"
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
            ~disable=sampleDataIsEnabled,
            ~events,
            ~customButtonStyle,
          ),
          ~inputFields=[],
          ~isRequired=false,
        ),
      }: EntityType.initialFilters<'t>
    ),
  ]

  newArr
}
