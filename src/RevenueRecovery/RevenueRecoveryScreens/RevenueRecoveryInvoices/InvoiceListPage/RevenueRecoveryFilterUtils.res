open LogicUtils

let tableTitle = "RecoveryInvoices"

// The recovery list has no remote filters endpoint, so the status options are static
let initialFilters = (_json, _filterValues, _removeKeys, _filterKeys, _setfilterKeys, _version) => {
  let options =
    RevenueRecoveryOrderUtils.recoveryStatusFilterOptions->FilterSelectBox.makeOptions(
      ~isTitle=true,
    )

  [
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="status",
          ~name=RevenueRecoveryOrderUtils.recoveryStatusFilterKey,
          ~customInput=InputFields.filterMultiSelectInput(
            ~options,
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
      }: EntityType.initialFilters<'t>
    ),
  ]
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
    | Array(arr) => arr->Array.map(item => item->getStringFromJson(""))->Array.joinWith(",")
    | _ => ""
    }
    if formatted->isNonEmptyString {
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
