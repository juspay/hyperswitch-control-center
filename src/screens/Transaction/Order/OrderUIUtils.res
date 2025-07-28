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
let isParentChildFilterMatch = (name, key) => {
  let parentFilter = name->getFilterTypeFromString
  let child = key->AmountFilterUtils.mapStringToamountFilterChild
  switch (parentFilter, child) {
  | (#amount, #start_amount)
  | (#amount, #end_amount)
  | (#amount, #amount_option) => true
  | _ => false
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
    let showPopUp = PopUpState.useShowPopUp()
    let {sampleData} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

    let generateSampleData = async () => {
      mixpanelEvent(~eventName="generate_sample_data")
      try {
        let generateSampleDataUrl = getURL(~entityName=V1(GENERATE_SAMPLE_DATA), ~methodType=Post)
        let _ = await updateDetails(
          generateSampleDataUrl,
          [("record", 50.0->JSON.Encode.float)]->Dict.fromArray->JSON.Encode.object,
          Post,
        )
        showToast(~message="Sample data generated successfully.", ~toastType=ToastSuccess)
        getOrdersList()->ignore
      } catch {
      | _ => ()
      }
    }

    let deleteSampleData = async () => {
      try {
        let generateSampleDataUrl = getURL(~entityName=V1(GENERATE_SAMPLE_DATA), ~methodType=Delete)
        let _ = await updateDetails(generateSampleDataUrl, Dict.make()->JSON.Encode.object, Delete)
        showToast(~message="Sample data deleted successfully", ~toastType=ToastSuccess)
        getOrdersList()->ignore
      } catch {
      | _ => ()
      }
    }

    let openPopUpModal = _ =>
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: "Are you sure?",
        description: {
          "This action cannot be undone. This will permanently delete all the sample payments and refunds data. To confirm, click the 'Delete All' button below."->React.string
        },
        handleConfirm: {
          text: "Delete All",
          onClick: {
            _ => {
              deleteSampleData()->ignore
            }
          },
        },
        handleCancel: {
          text: "Cancel",
          onClick: {
            _ => ()
          },
        },
      })

    let rightIconClick = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      openPopUpModal()
    }

    <RenderIf condition={sampleData && !previewOnly}>
      <div className="flex items-start">
        <ACLButton
          authorization={userHasAccess(~groupAccess=OperationsManage)}
          buttonType={Secondary}
          buttonSize=Small
          text="Generate Sample Data"
          onClick={_ => generateSampleData()->ignore}
          leftIcon={CustomIcon(<Icon name="plus" size=13 />)}
        />
        <ACLDiv
          height="h-fit"
          authorization={userHasAccess(~groupAccess=OperationsManage)}
          className="bg-jp-gray-button_gray text-opacity-75 hover:bg-jp-gray-secondary_hover hover:text-jp-gray-890  focus:outline-none border-border_gray cursor-pointer p-2.5 overflow-hidden text-jp-gray-950 hover:text-black
          border flex items-center justify-center rounded-r-md"
          onClick={ev => rightIconClick(ev)}>
          <Icon name="delete" size=16 customWidth="14" className="scale-125" />
        </ACLDiv>
      </div>
    </RenderIf>
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

let startTimeFilterKey = (version: UserInfoTypes.version) => {
  switch version {
  | V1 => "start_time"
  | V2 => "created.gte"
  }
}

let endTimeFilterKey = (version: UserInfoTypes.version) =>
  switch version {
  | V1 => "end_time"
  | V2 => "created.lte"
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

let getLabelFromFilterType = (filter: filter) => (filter :> string)

let getValueFromFilterType = (filter: filter) => {
  switch filter {
  | #connector_label => "merchant_connector_id"
  | _ => (filter :> string)
  }
}

let getValueFromFilterTypeV2 = (filter: filter) => {
  switch filter {
  | #payment_method => "payment_method_type"
  | #payment_method_type => "payment_method_subtype"
  | _ => (filter :> string)
  }
}

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

let initialFilters = (json, filtervalues, removeKeys, filterKeys, setfilterKeys, version) => {
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
        ~name={
          switch (version: UserInfoTypes.version) {
          | V1 => getValueFromFilterType(key->getFilterTypeFromString)
          | V2 => getValueFromFilterTypeV2(key->getFilterTypeFromString)
          }
        },
        ~customInput,
      ),
      localFilter: Some(filterByData),
    }
  })
}

let initialFixedFilter = (version: UserInfoTypes.version) => [
  (
    {
      localFilter: None,
      field: FormRenderer.makeMultiInputFieldInfo(
        ~label="",
        ~comboCustomInput=InputFields.filterDateRangeField(
          ~startKey=startTimeFilterKey(version),
          ~endKey=endTimeFilterKey(version),
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

let isNonEmptyValue = value => {
  value->Option.getOr(Dict.make())->Dict.toArray->Array.length > 0
}

let orderViewList: OMPSwitchTypes.ompViews = [
  {
    lable: "All Profiles",
    entity: #Merchant,
  },
  {
    lable: "Profile",
    entity: #Profile,
  },
]
