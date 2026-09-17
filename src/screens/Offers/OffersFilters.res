open OffersUtils

let toDropdownOptions = (values, ~toLabel) =>
  values->Array.map((value): FilterSelectBox.dropdownOption => {
    label: value->toLabel,
    value,
  })

let statusOptions = allStatuses->Array.map((status): FilterSelectBox.dropdownOption => {
  label: status->statusToDisplayName,
  value: (status :> string),
})

let paymentMethodTypeFilterOptions =
  paymentMethodTypeOptions->toDropdownOptions(~toLabel=LogicUtils.snakeToTitle)

let benefitTypeFilterOptions = allBenefitTypes->Array.map((
  benefitType
): FilterSelectBox.dropdownOption => {
  label: benefitType->benefitTypeToDisplayName,
  value: (benefitType :> string),
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

let textField = (~name, ~label) =>
  FormRenderer.makeFieldInfo(~label, ~name, ~customInput=InputFields.textInput())

let makeInlineFilter = (field): EntityType.initialFilters<'t> => {
  field,
  localFilter: None,
}

let makePopupFilter = (~urlKey, ~field, ~parser): EntityType.optionType<'t> => {
  urlKey,
  field,
  parser,
  localFilter: None,
}

let asStringArray = value =>
  switch value->JSON.Decode.string {
  | Some(str) => str->String.split(",")->LogicUtils.getJsonFromArrayOfString
  | None => value
  }

let asString = value => value

let initialFilters = () => [
  makeInlineFilter(
    multiSelectField(~name="status", ~label="Status", ~buttonText="Status", ~options=statusOptions),
  ),
]

let popupFilterFields = () => [
  makePopupFilter(
    ~urlKey="offer_code",
    ~field=textField(~name="offer_code", ~label="Offer Code"),
    ~parser=asStringArray,
  ),
  makePopupFilter(
    ~urlKey="title",
    ~field=textField(~name="title", ~label="Offer Title"),
    ~parser=asString,
  ),
  makePopupFilter(
    ~urlKey="group_id",
    ~field=textField(~name="group_id", ~label="Group ID"),
    ~parser=asStringArray,
  ),
  makePopupFilter(
    ~urlKey="payment_method_type",
    ~field=multiSelectField(
      ~name="payment_method_type",
      ~label="Payment Method Type",
      ~buttonText="Payment Method Type",
      ~options=paymentMethodTypeFilterOptions,
    ),
    ~parser=asString,
  ),
  makePopupFilter(
    ~urlKey="benefit_type",
    ~field=multiSelectField(
      ~name="benefit_type",
      ~label="Benefit Type",
      ~buttonText="Benefit Type",
      ~options=benefitTypeFilterOptions,
    ),
    ~parser=asString,
  ),
]
