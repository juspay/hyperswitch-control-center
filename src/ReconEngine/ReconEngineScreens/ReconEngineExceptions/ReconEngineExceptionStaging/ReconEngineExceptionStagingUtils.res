let (startTimeFilterKey, endTimeFilterKey) = ("startTime", "endTime")

let isNonEmptyValue = value => {
  value->Option.getOr(Dict.make())->Dict.toArray->Array.length > 0
}

let filterByData = (txnArr, value) => {
  open LogicUtils
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

let tabNames = ["entry_type", "currency"]

let initialDisplayFilters = () => {
  let entryTypeOptions: array<FilterSelectBox.dropdownOption> = [
    {label: "Credit", value: "credit"},
    {label: "Debit", value: "debit"},
  ]

  let currencyOptions: array<FilterSelectBox.dropdownOption> = [{label: "AUD", value: "AUD"}]

  [
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="entry_type",
          ~name="entry_type",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=entryTypeOptions,
            ~buttonText="Select Entry Type",
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
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="currency",
          ~name="currency",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=currencyOptions,
            ~buttonText="Select Currency",
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

let buildStagingFiltersQueryString = (
  ~startTimeVal: string,
  ~endTimeVal: string,
  ~filterValueJson: Dict.t<JSON.t>,
) => {
  open LogicUtils
  let filterParams = Dict.make()

  // Add date filters
  if startTimeVal->isNonEmptyString {
    filterParams->Dict.set("start_time", startTimeVal->JSON.Encode.string)
  }
  if endTimeVal->isNonEmptyString {
    filterParams->Dict.set("end_time", endTimeVal->JSON.Encode.string)
  }

  // Add entry_type filter from display filters
  let entryTypeFilter = filterValueJson->getArrayFromDict("entry_type", [])
  let currencyFilter = filterValueJson->getArrayFromDict("currency", [])
  if entryTypeFilter->Array.length > 0 {
    filterParams->Dict.set("entry_type", entryTypeFilter->JSON.Encode.array)
  }

  if currencyFilter->Array.length > 0 {
    filterParams->Dict.set("currency", currencyFilter->JSON.Encode.array)
  }

  // Add status filter (hardcoded for now)
  filterParams->Dict.set("status", "needs_manual_review"->JSON.Encode.string)

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
