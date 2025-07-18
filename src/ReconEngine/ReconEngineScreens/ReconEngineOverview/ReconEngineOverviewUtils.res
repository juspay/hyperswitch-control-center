open LogicUtils
open ReconEngineOverviewTypes
let accountItemToObjMapper = dict => {
  {
    account_name: dict->getString("account_name", ""),
    account_id: dict->getString("account_id", ""),
    currency: dict->getDictfromDict("posted_balance")->getString("currency", ""),
    pending_balance: dict->getDictfromDict("pending_balance")->getFloat("value", 0.0),
    posted_balance: dict->getDictfromDict("posted_balance")->getFloat("value", 0.0),
  }
}

let getAmountString = (amount, currency) => {
  amount->Float.toString ++ " " ++ currency
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
let initialFixedFilterFields = (~events=?) => {
  let events = switch events {
  | Some(fn) => fn
  | _ => () => ()
  }
  let customButtonStyle = "border !rounded-lg !bg-none"
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

let accountBalanceOptions: ColumnGraphTypes.columnGraphPayload = {
  title: {
    text: "",
  },
  data: [
    {
      showInLegend: false,
      name: "Account Balance",
      colorByPoint: true,
      data: [
        {
          name: "1 Day",
          y: 13711.0,
          color: "#8BC2F3",
        },
        {
          name: "2 Day",
          y: 44579.0,
          color: "#8BC2F3",
        },
        {
          name: "3 Day",
          y: 40510.0,
          color: "#8BC2F3",
        },
        {
          name: "4 Day",
          y: 48035.0,
          color: "#8BC2F3",
        },
        {
          name: "5 Day",
          y: 51640.0,
          color: "#8BC2F3",
        },
        {
          name: "6 Day",
          y: 51483.0,
          color: "#8BC2F3",
        },
        {
          name: "7 Day",
          y: 50049.0,
          color: "#8BC2F3",
        },
      ],
      color: "",
    },
  ],
  tooltipFormatter: ColumnGraphUtils.columnGraphTooltipFormatter(
    ~title="Account Balance",
    ~metricType=FormattedAmount,
  ),
  yAxisFormatter: ColumnGraphUtils.columnGraphYAxisFormatter(
    ~statType=FormattedAmount,
    ~currency="$",
  ),
}

let getAccountIcon = index => {
  switch index {
  | 0 => "settings"
  | 1 => "credit-card"
  | 2 => "nd-bank"
  | _ => "building"
  }
}
