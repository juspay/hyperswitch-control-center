open HSAnalyticsUtils
open FilterSelectBox
open AlertsTypes

let priorityFilterKey = "priority"
let merchantIdFilterKey = "merchant_id"
let profileIdFilterKey = "profile_id"
let connectorFilterKey = "connector"
let paymentMethodFilterKey = "payment_method"
let stateFilterKey = "state"

let priorityOptions: array<dropdownOption> = allPriorities->Array.map(priority => {
  let value = (priority :> string)
  {label: value, value}
})

let stateOptions: array<dropdownOption> = [
  {label: "Active", value: (Firing :> string)},
  {label: "Inactive", value: (Recovered :> string)},
]

let multiSelectField = (~name, ~label, ~options: array<dropdownOption>): EntityType.initialFilters<
  't,
> => {
  localFilter: None,
  field: FormRenderer.makeFieldInfo(
    ~label,
    ~name,
    ~customInput=InputFields.filterMultiSelectInput(
      ~options,
      ~buttonText=label,
      ~showSelectionAsChips=false,
      ~searchable=true,
      (),
    ),
  ),
}

let initialFilters = (~dictionary: alertsDictionary): array<EntityType.initialFilters<'t>> => [
  multiSelectField(~name=priorityFilterKey, ~label="Priority", ~options=priorityOptions),
  {
    localFilter: None,
    field: FormRenderer.makeFieldInfo(
      ~label="Status",
      ~name=stateFilterKey,
      ~customInput=InputFields.filterMultiSelectInput(
        ~options=stateOptions,
        ~buttonText="Status",
        ~showSelectionAsChips=false,
        ~searchable=false,
        (),
      ),
    ),
  },
  multiSelectField(
    ~name=merchantIdFilterKey,
    ~label="Merchant ID",
    ~options=dictionary.merchantIds->makeOptions,
  ),
  multiSelectField(
    ~name=profileIdFilterKey,
    ~label="Profile ID",
    ~options=dictionary.profileIds->makeOptions,
  ),
  multiSelectField(
    ~name=connectorFilterKey,
    ~label="Connector",
    ~options=dictionary.connectors->makeOptions,
  ),
  multiSelectField(
    ~name=paymentMethodFilterKey,
    ~label="Payment Method",
    ~options=dictionary.paymentMethods->makeOptions,
  ),
]

let initialFixedFilter = (): array<EntityType.initialFilters<'t>> => [
  {
    localFilter: None,
    field: FormRenderer.makeMultiInputFieldInfo(
      ~label="",
      ~comboCustomInput=InputFields.filterDateRangeField(
        ~startKey=startTimeFilterKey,
        ~endKey=endTimeFilterKey,
        ~format="YYYY-MM-DDTHH:mm:ss[Z]",
        ~showTime=true,
        ~disablePastDates=false,
        ~disableFutureDates=true,
        ~predefinedDays=[Hour(1.0), Today, Yesterday, Day(2.0), Day(7.0), Day(30.0)],
        ~numMonths=2,
        ~disableApply=false,
        ~dateRangeLimit=90,
      ),
      ~inputFields=[],
      ~isRequired=false,
    ),
  },
]
