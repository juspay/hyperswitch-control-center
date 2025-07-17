open LogicUtils

let (startTimeFilterKey, endTimeFilterKey) = ("startTime", "endTime")

let initialFixedFilterFields = (~events=?) => {
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
            ~disable=false,
            ~events,
          ),
          ~inputFields=[],
          ~isRequired=false,
        ),
      }: EntityType.initialFilters<'t>
    ),
  ]

  newArr
}

let buildTransactionsFiltersQueryString = (
  ~startTimeVal: string,
  ~endTimeVal: string,
  ~filterValueJson: Dict.t<JSON.t>,
  ~defaultTransactionStatus: array<string>=[],
) => {
  let filterParams = Dict.make()

  // Add date filters
  if startTimeVal->isNonEmptyString {
    filterParams->Dict.set("start_time", startTimeVal->JSON.Encode.string)
  }
  if endTimeVal->isNonEmptyString {
    filterParams->Dict.set("end_time", endTimeVal->JSON.Encode.string)
  }

  // Add status filter from display filters or use default
  let statusFilter = filterValueJson->getArrayFromDict("transaction_status", [])
  if statusFilter->Array.length > 0 {
    filterParams->Dict.set("transaction_status", statusFilter->JSON.Encode.array)
  } else if defaultTransactionStatus->Array.length > 0 {
    // Use default transaction status if provided
    filterParams->Dict.set(
      "transaction_status",
      defaultTransactionStatus->Array.map(JSON.Encode.string)->JSON.Encode.array,
    )
  }

  // Build query string directly
  let queryParts = []
  filterParams
  ->Dict.toArray
  ->Array.forEach(((key, value)) => {
    switch value->JSON.Classify.classify {
    | String(str) => queryParts->Array.push(`${key}=${str}`)
    | Number(num) => queryParts->Array.push(`${key}=${num->Float.toString}`)
    | Array(arr) => {
        let arrayValues = arr->Array.map(item => item->getStringFromJson(""))->Array.joinWith(",")
        if arrayValues->isNonEmptyString {
          queryParts->Array.push(`${key}=${arrayValues}`)
        }
      }
    | _ => ()
    }
  })

  queryParts->Array.joinWith("&")
}

let filterByData = (txnArr, value) => {
  let searchText = value->getStringFromJson("")

  txnArr
  ->Belt.Array.keepMap(Nullable.toOption)
  ->Belt.Array.keepMap(data => {
    let valueArr =
      data
      ->Identity.genericTypeToDictOfJson
      ->Dict.toArray
      ->Array.map(item => {
        let (_, value) = item
        value->getStringFromJson("")->String.toLowerCase->String.includes(searchText)
      })
      ->Array.reduce(false, (acc, item) => item || acc)

    valueArr ? Some(data->Nullable.make) : None
  })
}

let tabNames = ["transaction_status"]

let initialDisplayFilters = () => {
  let statusOptions: array<FilterSelectBox.dropdownOption> = [
    {label: "Mismatched", value: "mismatched"},
    {label: "Expected", value: "expected"},
  ]

  [
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="transaction_status",
          ~name="transaction_status",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=statusOptions,
            ~buttonText="Select Transaction Status",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            (),
          ),
        ),
        localFilter: Some(filterByData),
      }: EntityType.initialFilters<'t>
    ),
  ]
}
