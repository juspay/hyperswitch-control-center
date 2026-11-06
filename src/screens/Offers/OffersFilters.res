open OffersUtils

let statusOptions = allStatuses->Array.map((status): FilterSelectBox.dropdownOption => {
  label: status->statusToDisplayName,
  value: (status :> string),
})

let multiSelectField = (~name, ~label, ~buttonText, ~options) =>
  FormRenderer.makeFieldInfo(
    ~label,
    ~name,
    ~customInput=InputFields.filterMultiSelectInput(
      ~options,
      ~buttonText,
      ~showSelectionAsChips=false,
      ~searchable=true,
      ~customButtonStyle="bg-none",
      (),
    ),
  )

let makeInlineFilter = (field): EntityType.initialFilters<'t> => {
  field,
  localFilter: None,
}

let initialFilters = () => [
  makeInlineFilter(
    multiSelectField(~name="status", ~label="Status", ~buttonText="Status", ~options=statusOptions),
  ),
]
