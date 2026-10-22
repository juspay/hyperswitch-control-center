open LogicUtils

let tableTitle = "RecoveryInvoices"

// Filters the recovery list exposes. The endpoint rejects unknown params, so anything else is
// dropped from the query.
let supportedFilterKeys = [
  "recovery_status",
  "merchant_connector_id",
  "payment_method_type",
  "payment_method_subtype",
  "created.gte",
  "created.lte",
]

let recoveryStatusFilter = (): EntityType.initialFilters<'t> => {
  field: FormRenderer.makeFieldInfo(
    ~label="status",
    ~name=RevenueRecoveryOrderUtils.recoveryStatusFilterKey,
    ~customInput=InputFields.filterMultiSelectInput(
      ~options=RevenueRecoveryOrderUtils.recoveryStatusFilterOptions->FilterSelectBox.makeOptions(
        ~isTitle=true,
      ),
      ~buttonText="Select Status",
      ~showSelectionAsChips=false,
      ~searchable=true,
      ~showToolTip=true,
      ~showNameAsToolTip=true,
      ~customButtonStyle="bg-none",
      (),
    ),
  ),
  localFilter: None,
}

// Connector filter shows the connector label and sends the merchant connector id
let connectorLabelFilter = (json): EntityType.initialFilters<'t> => {
  let options =
    json
    ->getDictFromJsonObject
    ->getDictfromDict("connector")
    ->Dict.valuesToArray
    ->Array.flatMap(items =>
      items
      ->getArrayFromJson([])
      ->Array.map(item => {
        let dict = item->getDictFromJsonObject
        let option: FilterSelectBox.dropdownOption = {
          label: dict->getString("connector_label", ""),
          value: dict->getString("merchant_connector_id", ""),
        }
        option
      })
    )
    ->Array.filter(option => option.value->isNonEmptyString)

  {
    field: FormRenderer.makeFieldInfo(
      ~label="connector_label",
      ~name="merchant_connector_id",
      ~customInput=InputFields.filterMultiSelectInput(
        ~options,
        ~buttonText="Select Connector Label",
        ~showSelectionAsChips=false,
        ~searchable=true,
        ~showToolTip=true,
        ~showNameAsToolTip=true,
        ~customButtonStyle="bg-none",
        (),
      ),
    ),
    localFilter: None,
  }
}

// Status, connector label, payment method type and subtype
let initialFilters = (json, filterValues, removeKeys, filterKeys, setfilterKeys, version) => {
  let paymentMethodFilters =
    OrderUIUtils.initialFilters(
      json,
      filterValues,
      removeKeys,
      filterKeys,
      setfilterKeys,
      version,
    )->Array.filter((item: EntityType.initialFilters<'t>) =>
      ["payment_method_type", "payment_method_subtype"]->Array.includes(
        item.field.inputNames->getValueFromArray(0, ""),
      )
    )
  [recoveryStatusFilter(), connectorLabelFilter(json)]->Array.concat(paymentMethodFilters)
}

let initialFixedFilter = (~disable=false) => OrderUIUtils.initialFixedFilter(V2, ~disable)

// Builds the query params for `recovery-list` from the applied filters
let buildQuery = (~filters: Dict.t<JSON.t>, ~offset, ~limit, ~searchText) => {
  let query = Dict.make()

  filters
  ->Dict.toArray
  ->Array.forEach(((key, value)) => {
    let formatted = switch value->JSON.Classify.classify {
    | String(str) => str
    | Number(num) => num->Float.toString
    | Array(arr) => arr->getStrArrayFromJsonArray->Array.joinWith(",")
    | _ => ""
    }
    if formatted->isNonEmptyString && supportedFilterKeys->Array.includes(key) {
      query->Dict.set(key, formatted)
    }
  })

  query->Dict.set("offset", offset->Int.toString)
  query->Dict.set("limit", limit->Int.toString)

  let trimmedSearchText = searchText->String.trim
  if trimmedSearchText->isNonEmptyString {
    query->Dict.set("payment_id", trimmedSearchText)
  }

  query
}
