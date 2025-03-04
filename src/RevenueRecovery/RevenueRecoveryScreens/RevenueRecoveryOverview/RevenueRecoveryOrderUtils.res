let getArrayDictFromRes = res => {
  open LogicUtils
  res->getDictFromJsonObject->getArrayFromDict("data", [])
}
let getSizeofRes = res => {
  open LogicUtils
  res->getDictFromJsonObject->getInt("size", 0)
}

let (startTimeFilterKey, endTimeFilterKey) = ("created.gte", "created.lte")

type filterTypes = {
  connector: array<string>,
  currency: array<string>,
  authentication_type: array<string>,
  payment_method: array<string>,
  payment_method_type: array<string>,
  status: array<string>,
  connector_label: array<string>,
  card_network: array<string>,
  card_discovery: array<string>,
  customer_id: array<string>,
  amount: array<string>,
  merchant_order_reference_id: array<string>,
}

let getAllPaymentMethodType = dict => {
  open LogicUtils
  let paymentMethods = dict->getDictfromDict("payment_method")->Dict.keysToArray
  paymentMethods->Array.reduce([], (acc, item) => {
    Array.concat(
      acc,
      {
        dict
        ->getDictfromDict("payment_method")
        ->getArrayFromDict(item, [])
        ->getStrArrayFromJsonArray
      },
    )
  })
}

let itemToObjMapper = dict => {
  open LogicUtils
  {
    connector: dict->getDictfromDict("connector")->Dict.keysToArray,
    currency: dict->getArrayFromDict("currency", [])->getStrArrayFromJsonArray,
    authentication_type: dict
    ->getArrayFromDict("authentication_type", [])
    ->getStrArrayFromJsonArray,
    status: dict->getArrayFromDict("status", [])->getStrArrayFromJsonArray,
    payment_method: dict->getDictfromDict("payment_method")->Dict.keysToArray,
    payment_method_type: getAllPaymentMethodType(dict),
    connector_label: [],
    card_network: dict->getArrayFromDict("card_network", [])->getStrArrayFromJsonArray,
    card_discovery: dict->getArrayFromDict("card_discovery", [])->getStrArrayFromJsonArray,
    customer_id: [],
    amount: [],
    merchant_order_reference_id: [],
  }
}

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

let getLabelFromFilterType = (filter: filter) => (filter :> string)

let getConditionalFilter = (key, dict, filterValues) => {
  open LogicUtils

  let filtersArr = switch key->getFilterTypeFromString {
  | #connector_label =>
    filterValues
    ->getArrayFromDict("connector", [])
    ->getStrArrayFromJsonArray
    ->Array.flatMap(connector => {
      dict
      ->getDictfromDict("connector")
      ->getArrayFromDict(connector, [])
      ->Array.map(item => {
        item->getDictFromJsonObject->getString("connector_label", "")
      })
    })
  | #payment_method_type =>
    filterValues
    ->getArrayFromDict("payment_method", [])
    ->getStrArrayFromJsonArray
    ->Array.flatMap(paymentMethod => {
      dict
      ->getDictfromDict("payment_method")
      ->getArrayFromDict(paymentMethod, [])
      ->getStrArrayFromJsonArray
      ->Array.map(item => item)
    })
  | _ => []
  }

  filtersArr
}

let getOptionsForOrderFilters = (dict, filterValues) => {
  open LogicUtils
  filterValues
  ->getArrayFromDict("connector", [])
  ->getStrArrayFromJsonArray
  ->Array.flatMap(connector => {
    let connectorLabelArr = dict->getDictfromDict("connector")->getArrayFromDict(connector, [])
    connectorLabelArr->Array.map(item => {
      let label = item->getDictFromJsonObject->getString("connector_label", "")
      let value = item->getDictFromJsonObject->getString("merchant_connector_id", "")
      let option: FilterSelectBox.dropdownOption = {
        label: label->LogicUtils.snakeToTitle,
        value,
      }
      option
    })
  })
}

let getValueFromFilterType = (filter: filter) => {
  switch filter {
  | #connector_label => "merchant_connector_id"
  | _ => (filter :> string)
  }
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

let initialFilters = (json, filtervalues, removeKeys, filterKeys, setfilterKeys) => {
  open LogicUtils

  let filterDict = json->getDictFromJsonObject

  let filterData = filterDict->itemToObjMapper
  let filtersArray = filterDict->Dict.keysToArray
  let onDeleteClick = name => {
    [name]->removeKeys
    setfilterKeys(_ => filterKeys->Array.filter(item => item !== name))
  }

  let connectorFilter = filtervalues->getArrayFromDict("connector", [])->getStrArrayFromJsonArray
  if connectorFilter->Array.length !== 0 {
    filtersArray->Array.push(#connector_label->getLabelFromFilterType)
  }

  let additionalFilters =
    [#payment_method_type, #customer_id, #merchant_order_reference_id]->Array.map(
      getLabelFromFilterType,
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
      getConditionalFilter(key, filterDict, filtervalues)->Array.length > 0
        ? getConditionalFilter(key, filterDict, filtervalues)
        : filterData.payment_method_type
    | #connector_label => getConditionalFilter(key, filterDict, filtervalues)
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
    | #connector_label => getOptionsForOrderFilters(filterDict, filtervalues)
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
        ~name=getValueFromFilterType(key->getFilterTypeFromString),
        ~customInput,
      ),
      localFilter: Some(filterByData),
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

let setData = (offset, setOffset, total, data, setTotalCount, setOrdersData, setScreenState) => {
  let arr = Array.make(~length=offset, Dict.make())
  if total <= offset {
    setOffset(_ => 0)
  }

  if total > 0 {
    let orderDataDictArr = data->Belt.Array.keepMap(JSON.Decode.object)

    let orderData =
      arr
      ->Array.concat(orderDataDictArr)
      ->Array.map(RevenueRecoveryEntity.itemToObjMapper)

    let list = orderData->Array.map(Nullable.make)
    setTotalCount(_ => total)
    setOrdersData(_ => list)
    setScreenState(_ => PageLoaderWrapper.Success)
  } else {
    setScreenState(_ => PageLoaderWrapper.Custom)
  }
}

let getPaymentsList = async (
  filterValueJson: RescriptCore.Dict.t<Core__JSON.t>,
  ~fetchDetails: string => promise<JSON.t>,
  ~getURL: APIUtilsTypes.getUrlTypes,
  ~setOrdersData,
  ~setScreenState,
  ~setOffset,
  ~setTotalCount,
  ~offset,
) => {
  open LogicUtils
  setScreenState(_ => PageLoaderWrapper.Loading)
  try {
    let filter =
      filterValueJson
      ->Dict.toArray
      ->Array.map(item => {
        let (key, value) = item

        let value = switch value->JSON.Classify.classify {
        | String(str) => str
        | Number(num) => num->Float.toString
        | _ => ""
        }

        (key, value)
      })
      ->Dict.fromArray

    let ordersUrl = getURL(
      ~entityName=V2(V2_ORDERS_LIST),
      ~methodType=Get,
      ~queryParamerters=Some(filter->FilterUtils.parseFilterDict),
    )
    let res = await fetchDetails(ordersUrl)

    let data = res->getDictFromJsonObject->getArrayFromDict("data", [])
    let total = res->getDictFromJsonObject->getInt("total_count", 0)

    if data->Array.length === 0 && filterValueJson->Dict.get("payment_id")->Option.isSome {
      let payment_id =
        filterValueJson
        ->Dict.get("payment_id")
        ->Option.getOr(""->JSON.Encode.string)
        ->JSON.Decode.string
        ->Option.getOr("")

      if RegExp.test(%re(`/^[A-Za-z0-9]+_[A-Za-z0-9]+_[0-9]+/`), payment_id) {
        let newID = payment_id->String.replaceRegExp(%re("/_[0-9]$/g"), "")
        filterValueJson->Dict.set("payment_id", newID->JSON.Encode.string)

        // TODO: need to include V2 routes
        //let res = await  fetchDetails(ordersUrl)
        let data = res->getDictFromJsonObject->getArrayFromDict("data", [])
        let total = res->getDictFromJsonObject->getInt("total_count", 0)

        setData(offset, setOffset, total, data, setTotalCount, setOrdersData, setScreenState)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } else {
      setData(offset, setOffset, total, data, setTotalCount, setOrdersData, setScreenState)
    }
  } catch {
  | Exn.Error(_) => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
  }
}
