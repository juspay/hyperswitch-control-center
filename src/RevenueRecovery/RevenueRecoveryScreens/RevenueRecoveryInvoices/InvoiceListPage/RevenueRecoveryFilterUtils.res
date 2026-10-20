open LogicUtils

let tableTitle = "RecoveryInvoices"

// Filters the recovery-list endpoint accepts besides the date range and recovery status.
// The endpoint rejects unknown params, so anything else is dropped from the query.
let supportedFilterKeys = [
  "connector",
  "currency",
  "payment_method_type",
  "payment_method_subtype",
  "authentication_type",
  "card_network",
  "customer_id",
  "merchant_order_reference_id",
  "start_amount",
  "end_amount",
  "recovery_status",
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

// Recovery status replaces the payment status filter; the rest come from the payments filters
let initialFilters = (json, filterValues, removeKeys, filterKeys, setfilterKeys, version) => {
  let paymentFilters =
    OrderUIUtils.initialFilters(
      json,
      filterValues,
      removeKeys,
      filterKeys,
      setfilterKeys,
      version,
    )->Array.filter((item: EntityType.initialFilters<'t>) =>
      Array.concat(supportedFilterKeys, ["amount"])->Array.includes(
        item.field.inputNames->Array.get(0)->Option.getOr(""),
      )
    )
  [recoveryStatusFilter()]->Array.concat(paymentFilters)
}

let initialFixedFilter = (~disable=false) => OrderUIUtils.initialFixedFilter(V2, ~disable)

// Builds the query params for `recovery-list` from the applied filters
let buildQuery = (~filters: Dict.t<JSON.t>, ~offset, ~limit, ~searchText) => {
  let query = Dict.make()
  let filters = AmountFilterUtils.createAmountQuery(~dict=filters->Dict.copy)

  switch filters->Dict.get("amount_filter") {
  | Some(amountFilter) =>
    let amountDict = amountFilter->getDictFromJsonObject
    ["start_amount", "end_amount"]->Array.forEach(key =>
      switch amountDict->Dict.get(key) {
      | Some(value) if value !== JSON.Encode.null => filters->Dict.set(key, value)
      | _ => ()
      }
    )
  | None => ()
  }

  filters
  ->Dict.toArray
  ->Array.forEach(((key, value)) => {
    let formatted = switch value->JSON.Classify.classify {
    | String(str) => str
    | Number(num) => num->Float.toString
    | Array(arr) => arr->Array.map(item => item->getStringFromJson(""))->Array.joinWith(",")
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
