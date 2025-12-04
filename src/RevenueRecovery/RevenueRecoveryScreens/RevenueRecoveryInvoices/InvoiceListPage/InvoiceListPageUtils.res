let startTimeFilterKey = "created.gte"
let endTimeFilterKey = "created.lte"

let initialFixedFilter = _ => [
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
        ),
        ~inputFields=[],
        ~isRequired=false,
      ),
    }: EntityType.initialFilters<'t>
  ),
]

open RevenueRecoveryOrderTypes

let getAllPaymentMethodType = dict => {
  open LogicUtils
  let paymentMethods =
    dict->getDictfromDict((#payment_method: recoveryFilter :> string))->Dict.keysToArray
  paymentMethods->Array.reduce([], (acc, item) => {
    Array.concat(
      acc,
      {
        dict
        ->getDictfromDict((#payment_method: recoveryFilter :> string))
        ->getArrayFromDict(item, [])
        ->getStrArrayFromJsonArray
      },
    )
  })
}

let getLabelFromFilterType = (filter: recoveryFilter) => (filter :> string)

let itemToObjMapper = dict => {
  open LogicUtils
  {
    connector: dict->getDictfromDict((#connector: recoveryFilter :> string))->Dict.keysToArray,
    currency: dict
    ->getArrayFromDict((#currency: recoveryFilter :> string), [])
    ->getStrArrayFromJsonArray,
    payment_method: dict
    ->getDictfromDict((#payment_method: recoveryFilter :> string))
    ->Dict.keysToArray,
    payment_method_type: getAllPaymentMethodType(dict),
    connector_label: [],
    card_network: dict
    ->getArrayFromDict((#card_network: recoveryFilter :> string), [])
    ->getStrArrayFromJsonArray,
    customer_id: [],
    amount: [],
    merchant_order_reference_id: [],
  }
}

let getFilterTypeFromString = filterType => {
  switch filterType {
  | "connector" => #connector
  | "payment_method" => #payment_method
  | "currency" => #currency
  | "payment_method_type" => #payment_method_type
  | "connector_label" => #connector_label
  | "card_network" => #card_network
  | "customer_id" => #customer_id
  | "amount" => #amount
  | "merchant_order_reference_id" => #merchant_order_reference_id
  | _ => #unknown
  }
}

let getConditionalFilter = (key, dict, filterValues) => {
  open LogicUtils

  let filtersArr = switch key->getFilterTypeFromString {
  | #connector_label =>
    filterValues
    ->getArrayFromDict((#connector: recoveryFilter :> string), [])
    ->getStrArrayFromJsonArray
    ->Array.flatMap(connector => {
      dict
      ->getDictfromDict((#connector: recoveryFilter :> string))
      ->getArrayFromDict(connector, [])
      ->Array.map(item => {
        item->getDictFromJsonObject->getString((#connector_label: recoveryFilter :> string), "")
      })
    })
  | #payment_method_type =>
    filterValues
    ->getArrayFromDict((#payment_method: recoveryFilter :> string), [])
    ->getStrArrayFromJsonArray
    ->Array.flatMap(paymentMethod => {
      dict
      ->getDictfromDict((#payment_method: recoveryFilter :> string))
      ->getArrayFromDict(paymentMethod, [])
      ->getStrArrayFromJsonArray
      ->Array.map(item => item)
    })
  | _ => []
  }

  filtersArr
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

let getOptionsForOrderFilters = (dict, filterValues) => {
  open LogicUtils
  filterValues
  ->getArrayFromDict((#connector: recoveryFilter :> string), [])
  ->getStrArrayFromJsonArray
  ->Array.flatMap(connector => {
    let connectorLabelArr =
      dict->getDictfromDict((#connector: recoveryFilter :> string))->getArrayFromDict(connector, [])
    connectorLabelArr->Array.map(item => {
      let label =
        item->getDictFromJsonObject->getString((#connector_label: recoveryFilter :> string), "")
      let value = item->getDictFromJsonObject->getString("merchant_connector_id", "")
      let option: FilterSelectBox.dropdownOption = {
        label: label->LogicUtils.snakeToTitle,
        value,
      }
      option
    })
  })
}

let getValueFromFilterType = (filter: recoveryFilter) => {
  switch filter {
  | #payment_method => "payment_method_type"
  | #payment_method_type => "payment_method_subtype"
  | _ => (filter :> string)
  }
}

let initialFilters = (json, filterValues, removeKeys, filterKeys, setFilterKeys, _version) => {
  open LogicUtils

  let filterDict = json->getDictFromJsonObject

  let filterData = filterDict->itemToObjMapper
  let filtersArray = filterDict->Dict.keysToArray

  let onDeleteClick = name => {
    [name]->removeKeys
    setFilterKeys(_ => filterKeys->Array.filter(item => item !== name))
  }

  let connectorFilter =
    filterValues
    ->getArrayFromDict((#connector: recoveryFilter :> string), [])
    ->getStrArrayFromJsonArray

  if connectorFilter->Array.length !== 0 {
    filtersArray->Array.push(#connector_label->getLabelFromFilterType)
  }

  let additionalFilters =
    [#payment_method_type, #customer_id, #amount, #merchant_order_reference_id]->Array.map(
      getLabelFromFilterType,
    )

  let allFiltersArray = filtersArray->Array.concat(additionalFilters)

  allFiltersArray
  ->Array.filter(key => key->getFilterTypeFromString != #unknown)
  ->Array.map((key): EntityType.initialFilters<'t> => {
    let values = switch key->getFilterTypeFromString {
    | #connector => filterData.connector
    | #payment_method => filterData.payment_method
    | #currency => filterData.currency
    | #payment_method_type => {
        let conditionalFilter = getConditionalFilter(key, filterDict, filterValues)
        conditionalFilter->Array.length > 0 ? conditionalFilter : filterData.payment_method_type
      }
    | #connector_label => getConditionalFilter(key, filterDict, filterValues)
    | #card_network => filterData.card_network
    | _ => []
    }

    let makeOptions = (options: array<string>): array<FilterSelectBox.dropdownOption> => {
      options->Array.map(str => {
        let option: FilterSelectBox.dropdownOption = {label: str->snakeToTitle, value: str}
        option
      })
    }

    let options = switch key->getFilterTypeFromString {
    | #connector_label => getOptionsForOrderFilters(filterDict, filterValues)
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
    | #amount =>
      (~input as _, ~placeholder as _) => {
        <AmountFilter options=AmountFilterUtils.amountFilterOptions />
      }
    | _ =>
      InputFields.filterMultiSelectInput(
        ~options,
        ~buttonText=`Select ${key->snakeToTitle}`,
        ~showSelectionAsChips=false,
        ~searchable=true,
        ~showToolTip=true,
        ~showNameAsToolTip=true,
        ~customButtonStyle="bg-none",
        (),
      )
    }
    {
      field: FormRenderer.makeFieldInfo(
        ~label=key,
        ~name=getValueFromFilterType(key->getFilterTypeFromString),
        ~customInput,
      ),
      localFilter: Some(filterByData),
    }
  })
}
