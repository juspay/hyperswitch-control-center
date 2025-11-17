let getArrayDictFromRes = res => {
  open LogicUtils
  res->getDictFromJsonObject->getArrayFromDict("data", [])
}
let getSizeofRes = res => {
  open LogicUtils
  res->getDictFromJsonObject->getInt("size", 0)
}

let (startTimeFilterKey, endTimeFilterKey) = ("created.gte", "created.lte")

type filter = [
  | #connector
  | #payment_method
  | #currency
  | #authentication_type
  | #status
  | #payment_method_type
  | #connector_label
  | #card_network
  | #card_discovery
  | #customer_id
  | #merchant_order_reference_id
  | #unknown
]

let getFilterTypeFromString = filterType => {
  switch filterType {
  | "connector" => #connector
  | "payment_method" => #payment_method
  | "currency" => #currency
  | "status" => #status
  | "authentication_type" => #authentication_type
  | "payment_method_type" => #payment_method_type
  | "connector_label" => #connector_label
  | "card_network" => #card_network
  | "card_discovery" => #card_discovery
  | "customer_id" => #customer_id
  | "merchant_order_reference_id" => #merchant_order_reference_id
  | _ => #unknown
  }
}

let initialFilters = (json, filtervalues, removeKeys, filterKeys, setfilterKeys) => {
  open LogicUtils

  let filterDict = json->getDictFromJsonObject

  let filterData = filterDict->OrderUIUtils.itemToObjMapper
  let filtersArray = filterDict->Dict.keysToArray
  let onDeleteClick = name => {
    [name]->removeKeys
    setfilterKeys(_ => filterKeys->Array.filter(item => item !== name))
  }

  let connectorFilter = filtervalues->getArrayFromDict("connector", [])->getStrArrayFromJsonArray
  if connectorFilter->Array.length !== 0 {
    filtersArray->Array.push(#connector_label->OrderUIUtils.getLabelFromFilterType)
  }

  let additionalFilters =
    [#payment_method_type, #customer_id, #merchant_order_reference_id]->Array.map(
      OrderUIUtils.getLabelFromFilterType,
    )

  let allFiltersArray = filtersArray->Array.concat(additionalFilters)

  allFiltersArray->Array.map((key): EntityType.initialFilters<'t> => {
    let values = switch key->getFilterTypeFromString {
    | #connector => filterData.connector
    | #payment_method => filterData.payment_method
    | #currency => filterData.currency
    | #authentication_type => filterData.authentication_type
    | #status => filterData.status
    | #payment_method_type =>
      OrderUIUtils.getConditionalFilter(key, filterDict, filtervalues)->Array.length > 0
        ? OrderUIUtils.getConditionalFilter(key, filterDict, filtervalues)
        : filterData.payment_method_type
    | #connector_label => OrderUIUtils.getConditionalFilter(key, filterDict, filtervalues)
    | #card_network => filterData.card_network
    | #card_discovery => filterData.card_discovery
    | _ => []
    }

    let title = `Select ${key->snakeToTitle}`

    let makeOptions = (options: array<string>): array<FilterSelectBox.dropdownOption> => {
      options->Array.map(str => {
        let option: FilterSelectBox.dropdownOption = {label: str->snakeToTitle, value: str}
        option
      })
    }

    let options = switch key->getFilterTypeFromString {
    | #connector_label => OrderUIUtils.getOptionsForOrderFilters(filterDict, filtervalues)
    | _ => values->makeOptions
    }

    let customInput = switch key->getFilterTypeFromString {
    | #customer_id
    | #merchant_order_reference_id =>
      (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder as _) =>
        InputFields.textInput(
          ~rightIcon=<div
            className="p-1 rounded-lg hover:bg-gray-200 cursor-pointer mr-6 "
            onClick={_ => input.name->onDeleteClick}>
            <Icon name="cross-outline" size=13 />
          </div>,
          ~customWidth="w-48",
        )(~input, ~placeholder=`Enter ${input.name->snakeToTitle}...`)
    | _ =>
      InputFields.filterMultiSelectInput(
        ~options,
        ~buttonText=title,
        ~showSelectionAsChips=false,
        ~searchable=true,
        ~showToolTip=true,
        ~allowMultiSelect=false,
        ~showNameAsToolTip=true,
        ~showAllSelectedOptions=false,
        ~customButtonStyle="bg-none",
        (),
      )
    }
    {
      field: FormRenderer.makeFieldInfo(
        ~label=key,
        ~name=OrderUIUtils.getValueFromFilterType(key->getFilterTypeFromString),
        ~customInput,
      ),
      localFilter: Some(OrderUIUtils.filterByData),
    }
  })
}

let initialFixedFilter = () => [
  (
    {
      localFilter: None,
      field: FormRenderer.makeMultiInputFieldInfo(
        ~label="",
        ~comboCustomInput=InputFields.filterDateRangeField(
          ~startKey=startTimeFilterKey,
          ~endKey=endTimeFilterKey,
          ~format="YYYY-MM-DDTHH:mm:ss[Z]",
          ~showTime=false,
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
        ),
        ~inputFields=[],
        ~isRequired=false,
      ),
    }: EntityType.initialFilters<'t>
  ),
]

let statusVariantMapper: string => RevenueRecoveryOrderTypes.status = statusLabel =>
  switch statusLabel->String.toUpperCase {
  | "SUCCEEDED" => Succeeded
  | "SCHEDULED" => Scheduled
  | "FAILED" => Failed
  | "CANCELLED" => Cancelled
  | "PROCESSING" => Processing
  | "REQUIRES_CUSTOMER_ACTION" => RequiresCustomerAction
  | "REQUIRES_PAYMENT_METHOD" => RequiresPaymentMethod
  | "REQUIRES_CONFIRMATION" => RequiresConfirmation
  | "PARTIALLY_CAPTURED" => PartiallyCaptured
  | _ => None
  }

let schedulerStatusVariantMapper: string => RevenueRecoveryOrderTypes.recoveryStatusType = statusLabel =>
  switch statusLabel->String.toUpperCase {
  | "finish" => Finish
  | "scheduled" | _ => Scheduled
  }

let schedulerStatusStringMapper: RevenueRecoveryOrderTypes.recoveryStatusType => string = statusLabel =>
  switch statusLabel {
  | Finish => "finish"
  | Scheduled => "scheduled"
  }
