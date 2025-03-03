let getArrayDictFromRes = res => {
  open LogicUtils
  res->getDictFromJsonObject->getArrayFromDict("data", [])
}
let getSizeofRes = res => {
  open LogicUtils
  res->getDictFromJsonObject->getInt("size", 0)
}

let (startTimeFilterKey, endTimeFilterKey) = ("start_time", "end_time")

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
  | #amount
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
  | "amount" => #amount
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
    [#payment_method_type, #customer_id, #amount, #merchant_order_reference_id]->Array.map(
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
    | #amount =>
      (~input as _, ~placeholder as _) => {
        <AmountFilter options=AmountFilterUtils.amountFilterOptions />
      }

    | _ =>
      InputFields.filterMultiSelectInput(
        ~options,
        ~buttonText=title,
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
  filterValueJson,
  ~fetchDetails as _: string => promise<JSON.t>,
  ~getURL as _: APIUtilsTypes.getUrlTypes,
  ~setOrdersData,
  ~setScreenState,
  ~setOffset,
  ~setTotalCount,
  ~offset,
) => {
  open LogicUtils
  setScreenState(_ => PageLoaderWrapper.Loading)
  try {
    // TODO: need to include V2 routes
    //let ordersUrl = getURL(~entityName=ORDERS, ~methodType=Post)
    //let res = await  fetchDetails(ordersUrl)

    let res = {
      "size": 5,
      "total_count": 23,
      "data": [
        {
          "id": "12345_pay_01926c58bc6e77c09e809964e72af8c8",
          "merchant_id": "merchant_1668273825",
          "profile_id": "<string>",
          "customer_id": "12345_cus_01926c58bc6e77c09e809964e72af8c8",
          "payment_method_id": "<string>",
          "status": "succeeded",
          "amount": {
            "order_amount": 6540,
            "currency": "AED",
            "shipping_cost": 123,
            "order_tax_amount": 123,
            "external_tax_calculation": "skip",
            "surcharge_calculation": "skip",
            "surcharge_amount": 123,
            "tax_on_surcharge": 123,
            "net_amount": 123,
            "amount_to_capture": 123,
            "amount_capturable": 123,
            "amount_captured": 123,
          },
          "created": "2022-09-10T10:11:12Z",
          "payment_method_type": "card",
          "payment_method_subtype": "ach",
          "connector": "adyen",
          "merchant_connector_id": "<string>",
          "customer": {
            "id": "cus_y3oqhf46pyzuxjbcn2giaqnb44",
            "name": "John Doe",
            "email": "johntest@test.com",
            "phone": "9123456789",
            "phone_country_code": "+1",
          },
          "merchant_reference_id": "pay_mbabizu24mvu3mela5njyhpit4",
          "connector_payment_id": "993672945374576J",
          "connector_response_reference_id": "<string>",
          "metadata": "{}",
          "description": "It's my first payment request",
          "authentication_type": "three_ds",
          "capture_method": "automatic",
          "setup_future_usage": "off_session",
          "attempt_count": 123,
          "error": {
            "code": "<string>",
            "message": "<string>",
            "unified_code": "<string>",
            "unified_message": "<string>",
          },
          "cancellation_reason": "<string>",
          "order_details": "[{\n        \"product_name\": \"gillete creme\",\n        \"quantity\": 15,\n        \"amount\" : 900\n    }]",
          "return_url": "https://hyperswitch.io",
          "statement_descriptor_name": "Hyperswitch Router",
          "statement_descriptor_suffix": "Payment for shoes purchase",
          "allowed_payment_method_types": ["ach"],
          "authorization_count": 123,
          "modified_at": "2022-09-10T10:11:12Z",
        },
        {
          "id": "12345_pay_01926c58bc6e77c09e809964e72af8c8",
          "merchant_id": "merchant_1668273825",
          "profile_id": "<string>",
          "customer_id": "12345_cus_01926c58bc6e77c09e809964e72af8c8",
          "payment_method_id": "<string>",
          "status": "succeeded",
          "amount": {
            "order_amount": 6540,
            "currency": "AED",
            "shipping_cost": 123,
            "order_tax_amount": 123,
            "external_tax_calculation": "skip",
            "surcharge_calculation": "skip",
            "surcharge_amount": 123,
            "tax_on_surcharge": 123,
            "net_amount": 123,
            "amount_to_capture": 123,
            "amount_capturable": 123,
            "amount_captured": 123,
          },
          "created": "2022-09-10T10:11:12Z",
          "payment_method_type": "card",
          "payment_method_subtype": "ach",
          "connector": "adyen",
          "merchant_connector_id": "<string>",
          "customer": {
            "id": "cus_y3oqhf46pyzuxjbcn2giaqnb44",
            "name": "John Doe",
            "email": "johntest@test.com",
            "phone": "9123456789",
            "phone_country_code": "+1",
          },
          "merchant_reference_id": "pay_mbabizu24mvu3mela5njyhpit4",
          "connector_payment_id": "993672945374576J",
          "connector_response_reference_id": "<string>",
          "metadata": "{}",
          "description": "It's my first payment request",
          "authentication_type": "three_ds",
          "capture_method": "automatic",
          "setup_future_usage": "off_session",
          "attempt_count": 123,
          "error": {
            "code": "<string>",
            "message": "<string>",
            "unified_code": "<string>",
            "unified_message": "<string>",
          },
          "cancellation_reason": "<string>",
          "order_details": "[{\n        \"product_name\": \"gillete creme\",\n        \"quantity\": 15,\n        \"amount\" : 900\n    }]",
          "return_url": "https://hyperswitch.io",
          "statement_descriptor_name": "Hyperswitch Router",
          "statement_descriptor_suffix": "Payment for shoes purchase",
          "allowed_payment_method_types": ["ach"],
          "authorization_count": 123,
          "modified_at": "2022-09-10T10:11:12Z",
        },
        {
          "id": "12345_pay_01926c58bc6e77c09e809964e72af8c8",
          "merchant_id": "merchant_1668273825",
          "profile_id": "<string>",
          "customer_id": "12345_cus_01926c58bc6e77c09e809964e72af8c8",
          "payment_method_id": "<string>",
          "status": "succeeded",
          "amount": {
            "order_amount": 6540,
            "currency": "AED",
            "shipping_cost": 123,
            "order_tax_amount": 123,
            "external_tax_calculation": "skip",
            "surcharge_calculation": "skip",
            "surcharge_amount": 123,
            "tax_on_surcharge": 123,
            "net_amount": 123,
            "amount_to_capture": 123,
            "amount_capturable": 123,
            "amount_captured": 123,
          },
          "created": "2022-09-10T10:11:12Z",
          "payment_method_type": "card",
          "payment_method_subtype": "ach",
          "connector": "adyen",
          "merchant_connector_id": "<string>",
          "customer": {
            "id": "cus_y3oqhf46pyzuxjbcn2giaqnb44",
            "name": "John Doe",
            "email": "johntest@test.com",
            "phone": "9123456789",
            "phone_country_code": "+1",
          },
          "merchant_reference_id": "pay_mbabizu24mvu3mela5njyhpit4",
          "connector_payment_id": "993672945374576J",
          "connector_response_reference_id": "<string>",
          "metadata": "{}",
          "description": "It's my first payment request",
          "authentication_type": "three_ds",
          "capture_method": "automatic",
          "setup_future_usage": "off_session",
          "attempt_count": 123,
          "error": {
            "code": "<string>",
            "message": "<string>",
            "unified_code": "<string>",
            "unified_message": "<string>",
          },
          "cancellation_reason": "<string>",
          "order_details": "[{\n        \"product_name\": \"gillete creme\",\n        \"quantity\": 15,\n        \"amount\" : 900\n    }]",
          "return_url": "https://hyperswitch.io",
          "statement_descriptor_name": "Hyperswitch Router",
          "statement_descriptor_suffix": "Payment for shoes purchase",
          "allowed_payment_method_types": ["ach"],
          "authorization_count": 123,
          "modified_at": "2022-09-10T10:11:12Z",
        },
        {
          "id": "12345_pay_01926c58bc6e77c09e809964e72af8c8",
          "merchant_id": "merchant_1668273825",
          "profile_id": "<string>",
          "customer_id": "12345_cus_01926c58bc6e77c09e809964e72af8c8",
          "payment_method_id": "<string>",
          "status": "succeeded",
          "amount": {
            "order_amount": 6540,
            "currency": "AED",
            "shipping_cost": 123,
            "order_tax_amount": 123,
            "external_tax_calculation": "skip",
            "surcharge_calculation": "skip",
            "surcharge_amount": 123,
            "tax_on_surcharge": 123,
            "net_amount": 123,
            "amount_to_capture": 123,
            "amount_capturable": 123,
            "amount_captured": 123,
          },
          "created": "2022-09-10T10:11:12Z",
          "payment_method_type": "card",
          "payment_method_subtype": "ach",
          "connector": "adyen",
          "merchant_connector_id": "<string>",
          "customer": {
            "id": "cus_y3oqhf46pyzuxjbcn2giaqnb44",
            "name": "John Doe",
            "email": "johntest@test.com",
            "phone": "9123456789",
            "phone_country_code": "+1",
          },
          "merchant_reference_id": "pay_mbabizu24mvu3mela5njyhpit4",
          "connector_payment_id": "993672945374576J",
          "connector_response_reference_id": "<string>",
          "metadata": "{}",
          "description": "It's my first payment request",
          "authentication_type": "three_ds",
          "capture_method": "automatic",
          "setup_future_usage": "off_session",
          "attempt_count": 123,
          "error": {
            "code": "<string>",
            "message": "<string>",
            "unified_code": "<string>",
            "unified_message": "<string>",
          },
          "cancellation_reason": "<string>",
          "order_details": "[{\n        \"product_name\": \"gillete creme\",\n        \"quantity\": 15,\n        \"amount\" : 900\n    }]",
          "return_url": "https://hyperswitch.io",
          "statement_descriptor_name": "Hyperswitch Router",
          "statement_descriptor_suffix": "Payment for shoes purchase",
          "allowed_payment_method_types": ["ach"],
          "authorization_count": 123,
          "modified_at": "2022-09-10T10:11:12Z",
        },
        {
          "id": "12345_pay_01926c58bc6e77c09e809964e72af8c8",
          "merchant_id": "merchant_1668273825",
          "profile_id": "<string>",
          "customer_id": "12345_cus_01926c58bc6e77c09e809964e72af8c8",
          "payment_method_id": "<string>",
          "status": "succeeded",
          "amount": {
            "order_amount": 6540,
            "currency": "AED",
            "shipping_cost": 123,
            "order_tax_amount": 123,
            "external_tax_calculation": "skip",
            "surcharge_calculation": "skip",
            "surcharge_amount": 123,
            "tax_on_surcharge": 123,
            "net_amount": 123,
            "amount_to_capture": 123,
            "amount_capturable": 123,
            "amount_captured": 123,
          },
          "created": "2022-09-10T10:11:12Z",
          "payment_method_type": "card",
          "payment_method_subtype": "ach",
          "connector": "adyen",
          "merchant_connector_id": "<string>",
          "customer": {
            "id": "cus_y3oqhf46pyzuxjbcn2giaqnb44",
            "name": "John Doe",
            "email": "johntest@test.com",
            "phone": "9123456789",
            "phone_country_code": "+1",
          },
          "merchant_reference_id": "pay_mbabizu24mvu3mela5njyhpit4",
          "connector_payment_id": "993672945374576J",
          "connector_response_reference_id": "<string>",
          "metadata": "{}",
          "description": "It's my first payment request",
          "authentication_type": "three_ds",
          "capture_method": "automatic",
          "setup_future_usage": "off_session",
          "attempt_count": 123,
          "error": {
            "code": "<string>",
            "message": "<string>",
            "unified_code": "<string>",
            "unified_message": "<string>",
          },
          "cancellation_reason": "<string>",
          "order_details": "[{\n        \"product_name\": \"gillete creme\",\n        \"quantity\": 15,\n        \"amount\" : 900\n    }]",
          "return_url": "https://hyperswitch.io",
          "statement_descriptor_name": "Hyperswitch Router",
          "statement_descriptor_suffix": "Payment for shoes purchase",
          "allowed_payment_method_types": ["ach"],
          "authorization_count": 123,
          "modified_at": "2022-09-10T10:11:12Z",
        },
      ],
    }->Identity.genericTypeToJson

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
