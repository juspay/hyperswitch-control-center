type filterTypes = {
  connector: array<string>,
  currency: array<string>,
  authentication_type: array<string>,
  payment_method: array<string>,
  payment_method_type: array<string>,
  status: array<string>,
  connector_label: array<string>,
}

type filter = [
  | #connector
  | #payment_method
  | #currency
  | #authentication_type
  | #status
  | #payment_method_type
  | #connector_label
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
  | _ => #unknown
  }
}

module RenderAccordian = {
  @react.component
  let make = (~initialExpandedArray=[], ~accordion) => {
    <Accordion
      initialExpandedArray
      accordion
      accordianTopContainerCss="border"
      accordianBottomContainerCss="p-5"
      contentExpandCss="px-4 py-3 !border-t-0"
      titleStyle="font-semibold text-bold text-md"
    />
  }
}

module GenerateSampleDataButton = {
  open APIUtils
  @react.component
  let make = (~previewOnly, ~getOrdersList) => {
    let getURL = useGetURL()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let {sampleData} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)

    let generateSampleData = async () => {
      mixpanelEvent(~eventName="generate_sample_data", ())
      try {
        let generateSampleDataUrl = getURL(~entityName=GENERATE_SAMPLE_DATA, ~methodType=Post, ())
        let _ = await updateDetails(
          generateSampleDataUrl,
          [("record", 50.0->JSON.Encode.float)]->Dict.fromArray->JSON.Encode.object,
          Post,
          (),
        )
        showToast(~message="Sample data generated successfully.", ~toastType=ToastSuccess, ())
        getOrdersList()->ignore
      } catch {
      | _ => ()
      }
    }

    <UIUtils.RenderIf condition={sampleData && !previewOnly}>
      <ACLButton
        access={userPermissionJson.operationsManage}
        buttonType={Secondary}
        buttonSize={XSmall}
        text="Generate Sample Data"
        onClick={_ => generateSampleData()->ignore}
        leftIcon={CustomIcon(<Icon name="plus" size=13 />)}
      />
    </UIUtils.RenderIf>
  }
}

module NoData = {
  @react.component
  let make = (~isConfigureConnector, ~paymentModal, ~setPaymentModal) => {
    let {isLiveMode} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

    <HelperComponents.BluredTableComponent
      infoText={isConfigureConnector
        ? isLiveMode
            ? "There are no payments as of now."
            : "There are no payments as of now. Try making a test payment and visualise the checkout experience."
        : "Connect to a payment processor to make your first payment"}
      buttonText={isConfigureConnector ? "Make a payment" : "Connect a connector"}
      moduleName=""
      paymentModal
      setPaymentModal
      showRedirectCTA={!isLiveMode}
      onClickUrl={isConfigureConnector ? "/sdk" : `/connectors`}
    />
  }
}

let (startTimeFilterKey, endTimeFilterKey) = ("start_time", "end_time")

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

    valueArr ? data->Nullable.make->Some : None
  })
}

let getConditionalFilter = (key, dict, filterValues) => {
  open LogicUtils

  let filtersArr = switch key->getFilterTypeFromString {
  | #connector_label => {
      let arr = filterValues->getArrayFromDict("connector", [])->getStrArrayFromJsonArray
      let newArr = arr->Array.flatMap(connector => {
        let connectorLabelArr = dict->getDictfromDict("connector")->getArrayFromDict(connector, [])
        connectorLabelArr->Array.map(item => {
          item->getDictFromJsonObject->getString("connector_label", "")
        })
      })
      newArr
    }
  | #payment_method_type => {
      let arr = filterValues->getArrayFromDict("payment_method", [])->getStrArrayFromJsonArray
      let newArr = arr->Array.flatMap(paymentMethod => {
        let paymentMethodTypeArr =
          dict
          ->getDictfromDict("payment_method")
          ->getArrayFromDict(paymentMethod, [])
          ->getStrArrayFromJsonArray
        paymentMethodTypeArr->Array.map(item => {
          item
        })
      })
      newArr
    }
  | _ => []
  }

  filtersArr
}

let getOptionsForOrderFilters = (dict, filterValues) => {
  open LogicUtils
  let arr = filterValues->getArrayFromDict("connector", [])->getStrArrayFromJsonArray
  let newArr = arr->Array.flatMap(connector => {
    let connectorLabelArr = dict->getDictfromDict("connector")->getArrayFromDict(connector, [])
    connectorLabelArr->Array.map(item => {
      let label = item->getDictFromJsonObject->getString("connector_label", "")
      let value = item->getDictFromJsonObject->getString("merchant_connector_id", "")
      let option: FilterSelectBox.dropdownOption = {
        label,
        value,
      }
      option
    })
  })
  newArr
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
    payment_method_type: [],
    connector_label: [],
  }
}

let initialFilters = (json, filtervalues) => {
  open LogicUtils

  let connectorFilter = filtervalues->getArrayFromDict("connector", [])->getStrArrayFromJsonArray

  let paymentMethodFilter =
    filtervalues->getArrayFromDict("payment_method", [])->getStrArrayFromJsonArray

  let filterDict = json->getDictFromJsonObject
  let filterArr = filterDict->itemToObjMapper
  let arr = filterDict->Dict.keysToArray

  if connectorFilter->Array.length !== 0 {
    arr->Array.push("connector_label")
  }
  if paymentMethodFilter->Array.length !== 0 {
    arr->Array.push("payment_method_type")
  }

  arr->Array.map((key): EntityType.initialFilters<'t> => {
    let values = switch key->getFilterTypeFromString {
    | #connector => filterArr.connector
    | #payment_method => filterArr.payment_method
    | #currency => filterArr.currency
    | #authentication_type => filterArr.authentication_type
    | #status => filterArr.status
    | #payment_method_type => getConditionalFilter(key, filterDict, filtervalues)
    | #connector_label => getConditionalFilter(key, filterDict, filtervalues)
    | _ => []
    }

    let title = `Select ${key->snakeToTitle}`

    let options = switch key->getFilterTypeFromString {
    | #connector_label => getOptionsForOrderFilters(filterDict, filtervalues)
    | _ => values->FilterSelectBox.makeOptions
    }

    let name = switch key->getFilterTypeFromString {
    | #connector_label => "merchant_connector_id"
    | _ => key
    }

    {
      field: FormRenderer.makeFieldInfo(
        ~label=key,
        ~name,
        ~customInput=InputFields.filterMultiSelectInput(
          ~options,
          ~buttonText=title,
          ~showSelectionAsChips=false,
          ~searchable=true,
          ~showToolTip=true,
          ~showNameAsToolTip=true,
          ~customButtonStyle="bg-none",
          (),
        ),
        (),
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
          ~predefinedDays=[Today, Yesterday, Day(2.0), Day(7.0), Day(30.0), ThisMonth, LastMonth],
          ~numMonths=2,
          ~disableApply=false,
          ~dateRangeLimit=60,
          (),
        ),
        ~inputFields=[],
        ~isRequired=false,
        (),
      ),
    }: EntityType.initialFilters<'t>
  ),
]

let setData = (
  offset,
  setOffset,
  total,
  data,
  setTotalCount,
  setOrdersData,
  setScreenState,
  previewOnly,
) => {
  let arr = Array.make(~length=offset, Dict.make())
  if total <= offset {
    setOffset(_ => 0)
  }

  if total > 0 {
    let orderDataDictArr = data->Belt.Array.keepMap(JSON.Decode.object)

    let orderData =
      arr
      ->Array.concat(orderDataDictArr)
      ->Array.map(OrderEntity.itemToObjMapper)
      ->Array.filterWithIndex((_, i) => {
        !previewOnly || i <= 2
      })

    let list = orderData->Array.map(Nullable.make)
    setTotalCount(_ => total)
    setOrdersData(_ => list)
    setScreenState(_ => PageLoaderWrapper.Success)
  } else {
    setScreenState(_ => PageLoaderWrapper.Custom)
  }
}

let getOrdersList = async (
  filterValueJson,
  ~updateDetails: (
    string,
    JSON.t,
    Fetch.requestMethod,
    ~bodyFormData: Fetch.formData=?,
    ~headers: Dict.t<'a>=?,
    ~contentType: AuthHooks.contentType=?,
    unit,
  ) => promise<JSON.t>,
  ~getURL: (
    ~entityName: APIUtilsTypes.entityName,
    ~methodType: Fetch.requestMethod,
    ~id: option<string>=?,
    ~connector: option<'a>=?,
    ~userType: APIUtilsTypes.userType=?,
    ~userRoleTypes: APIUtilsTypes.userRoleTypes=?,
    ~reconType: APIUtilsTypes.reconType=?,
    ~queryParamerters: option<string>=?,
    unit,
  ) => string,
  ~setOrdersData,
  ~previewOnly,
  ~setScreenState,
  ~setOffset,
  ~setTotalCount,
  ~offset,
) => {
  open LogicUtils
  setScreenState(_ => PageLoaderWrapper.Loading)
  try {
    let ordersUrl = getURL(~entityName=ORDERS, ~methodType=Post, ())
    let res = await updateDetails(ordersUrl, filterValueJson->JSON.Encode.object, Fetch.Post, ())
    let data = res->LogicUtils.getDictFromJsonObject->LogicUtils.getArrayFromDict("data", [])
    let total = res->getDictFromJsonObject->getInt("total_count", 0)

    if data->Array.length === 0 && filterValueJson->Dict.get("payment_id")->Option.isSome {
      let payment_id =
        filterValueJson
        ->Dict.get("payment_id")
        ->Option.getOr(""->JSON.Encode.string)
        ->JSON.Decode.string
        ->Option.getOr("")

      if Js.Re.test_(%re(`/^[A-Za-z0-9]+_[A-Za-z0-9]+_[0-9]+/`), payment_id) {
        let newID = payment_id->String.replaceRegExp(%re("/_[0-9]$/g"), "")
        filterValueJson->Dict.set("payment_id", newID->JSON.Encode.string)

        let res = await updateDetails(
          ordersUrl,
          filterValueJson->JSON.Encode.object,
          Fetch.Post,
          (),
        )
        let data = res->LogicUtils.getDictFromJsonObject->LogicUtils.getArrayFromDict("data", [])
        let total = res->getDictFromJsonObject->getInt("total_count", 0)

        setData(
          offset,
          setOffset,
          total,
          data,
          setTotalCount,
          setOrdersData,
          setScreenState,
          previewOnly,
        )
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } else {
      setData(
        offset,
        setOffset,
        total,
        data,
        setTotalCount,
        setOrdersData,
        setScreenState,
        previewOnly,
      )
    }
  } catch {
  | Exn.Error(_) => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
  }
}

let isNonEmptyValue = value => {
  value->Option.getOr(Dict.make())->Dict.toArray->Array.length > 0
}
