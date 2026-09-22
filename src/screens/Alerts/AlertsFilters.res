open HSAnalyticsUtils

let priorityFilterKey = "priority"
let merchantIdFilterKey = "merchant_id"
let profileIdFilterKey = "profile_id"
let connectorFilterKey = "connector"
let paymentMethodFilterKey = "payment_method"
let stateFilterKey = "state"

let priorityOptions: array<FilterSelectBox.dropdownOption> =
  ["P0", "P1", "P2", "P3"]->Array.map(value => {FilterSelectBox.label: value, value})

let stateOptions: array<FilterSelectBox.dropdownOption> = [
  {FilterSelectBox.label: "Active", value: "firing"},
  {FilterSelectBox.label: "Inactive", value: "recovered"},
]

let multiSelectField = (~name, ~label, ~options: array<string>): EntityType.initialFilters<'t> => {
  localFilter: None,
  field: FormRenderer.makeFieldInfo(
    ~label,
    ~name,
    ~customInput=InputFields.filterMultiSelectInput(
      ~options=options->FilterSelectBox.makeOptions,
      ~buttonText=label,
      ~showSelectionAsChips=false,
      ~searchable=true,
      (),
    ),
  ),
}

let initialFilters = (~dictionary: AlertsTypes.alertsDictionary): array<
  EntityType.initialFilters<'t>,
> => [
  {
    localFilter: None,
    field: FormRenderer.makeFieldInfo(
      ~label="Priority",
      ~name=priorityFilterKey,
      ~customInput=InputFields.filterMultiSelectInput(
        ~options=priorityOptions,
        ~buttonText="Priority",
        ~showSelectionAsChips=false,
        ~searchable=true,
        (),
      ),
    ),
  },
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
    ~options=dictionary.merchantIds,
  ),
  multiSelectField(~name=profileIdFilterKey, ~label="Profile ID", ~options=dictionary.profileIds),
  multiSelectField(~name=connectorFilterKey, ~label="Connector", ~options=dictionary.connectors),
  multiSelectField(
    ~name=paymentMethodFilterKey,
    ~label="Payment Method",
    ~options=dictionary.paymentMethods,
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
