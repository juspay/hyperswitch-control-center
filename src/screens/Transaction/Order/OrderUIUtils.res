open LogicUtils
open OrderTypes
let getFilterTypeFromString = (filterType): filter => {
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
  | "customer_email" => #customer_email
  | "card_last_4" => #card_last_4
  | "active_attempt_id" => #active_attempt_id
  | "merchant_connector_id" => #merchant_connector_id
  | "refunds_status" => #refunds_status
  | "dispute_status" => #dispute_status
  | "routing_approach" => #routing_approach
  | "card_issuer" => #card_issuer
  | _ => #unknown
  }
}
let isParentChildFilterMatch = (name, key) => {
  let parentFilter = name->getFilterTypeFromString
  let child = key->AmountFilterUtils.mapStringToAmountFilterChild
  switch (parentFilter, child) {
  | (#amount, #start_amount)
  | (#amount, #end_amount)
  | (#amount, #amount_option) => true
  | _ => false
  }
}
module RenderAccordion = {
  @react.component
  let make = (~initialExpandedArray=[], ~accordion) => {
    <AccordionAdapter
      initialExpandedArray
      accordion
      accordionTopContainerCss="border"
      accordionBottomContainerCss="p-5"
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
    let showToast = ToastAdapter.useShowToast()
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

    <BlurredTableComponent
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
  filterValues
  ->getArrayFromDict("connector", [])
  ->getStrArrayFromJsonArray
  ->Array.flatMap(connector => {
    let connectorLabelArr = dict->getDictfromDict("connector")->getArrayFromDict(connector, [])
    connectorLabelArr->Array.map(item => {
      let label = item->getDictFromJsonObject->getString("connector_label", "")
      let value = item->getDictFromJsonObject->getString("merchant_connector_id", "")
      let option: FilterSelectBox.dropdownOption = {
        label: label->snakeToTitle,
        value,
      }
      option
    })
  })
}

let getAllPaymentMethodType = dict => {
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

let itemToObjMapper = (dict): filterTypes => {
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
    customer_email: [],
    card_last_4: [],
    active_attempt_id: [],
    merchant_connector_id: [],
    refunds_status: dict->getArrayFromDict("refunds_status", [])->getStrArrayFromJsonArray,
    dispute_status: dict->getArrayFromDict("dispute_status", [])->getStrArrayFromJsonArray,
    routing_approach: dict->getArrayFromDict("routing_approach", [])->getStrArrayFromJsonArray,
    card_issuer: dict->getArrayFromDict("card_issuer", [])->getStrArrayFromJsonArray,
  }
}

let advancedPaymentFilterTypes: array<filter> = [
  #customer_email,
  #card_last_4,
  #active_attempt_id,
  #merchant_connector_id,
  #refunds_status,
  #dispute_status,
  #routing_approach,
  #card_issuer,
]

let advancedPaymentOnlyFilterKeys =
  advancedPaymentFilterTypes->Array.map(filterType => filterType->getValueFromFilterType)

let unsupportedAdvancedPaymentFilterKeys = [
  (#unified_code: unsupportedAdvancedPaymentFilter :> string),
  (#unified_message: unsupportedAdvancedPaymentFilter :> string),
]

let firstAttemptFilterKey = (#first_attempt: hiddenAdvancedPaymentFilter :> string)
let paymentIdFilterKey = (#payment_id: basePaymentListFilter :> string)
let customerEmailFilterKey = (#customer_email: filter)->getValueFromFilterType
let cardLast4FilterKey = (#card_last_4: advancedPaymentTextListFilter :> string)

let hiddenAdvancedPaymentFilterKeys = [firstAttemptFilterKey]

let advancedPaymentFilterCleanupKeys =
  advancedPaymentOnlyFilterKeys
  ->Array.concat(unsupportedAdvancedPaymentFilterKeys)
  ->Array.concat(hiddenAdvancedPaymentFilterKeys)

let advancedPaymentSearchDescription = "Search across payment ID, customer email, card last 4, amount, attempt ID, connector account, and error details."

let getAdvancedPaymentFilterDescription = key =>
  switch key->getFilterTypeFromString {
  | #customer_email => "Filter payments by customer email."
  | #card_last_4 => "Find payments by the last 4 digits of the card."
  | #active_attempt_id => "Filter payments by the active payment attempt ID."
  | #merchant_connector_id => "Filter payments by the connector account used for processing."
  | #refunds_status => "Filter payments by refund state, such as partial or full refund."
  | #dispute_status => "Filter payments by dispute state."
  | #routing_approach => "Filter payments by the routing strategy used for connector selection."
  | #card_issuer => "Filter payments by the issuing bank or card institution."
  | _ => "Advanced payment filter."
  }

let advancedPaymentTextListFilterTypes: array<filter> = [
  #card_last_4,
  #active_attempt_id,
  #merchant_connector_id,
  #card_issuer,
]

let advancedPaymentTextListFilterKeys =
  advancedPaymentTextListFilterTypes->Array.map(filter => (filter :> string))

let advancedRoutingApproaches: array<advancedRoutingApproach> = [
  #default_fallback,
  #straight_through_routing,
  #rule_based_routing,
  #volume_based_routing,
]

let advancedRoutingApproachValues =
  advancedRoutingApproaches->Array.map(routingApproach => (routingApproach :> string))

let openSearchRefundStatuses: array<openSearchRefundStatus> = [#partial_refunded, #full_refunded]

let openSearchRefundStatusValues = openSearchRefundStatuses->Array.map(status => (status :> string))

let openSearchDisputeStatuses: array<openSearchDisputeStatus> = [
  #dispute_present,
  #dispute_opened,
  #dispute_challenged,
  #dispute_lost,
  #dispute_won,
  #dispute_accepted,
  #dispute_cancelled,
  #dispute_expired,
]

let openSearchDisputeStatusValues =
  openSearchDisputeStatuses->Array.map(status => (status :> string))

let basePaymentListFilters: array<basePaymentListFilter> = [
  #payment_id,
  #payment_method,
  #currency,
  #status,
  #connector,
  #connector_label,
  #payment_method_type,
  #card_network,
  #customer_id,
  #authentication_type,
  #card_discovery,
  #merchant_order_reference_id,
]

let basePaymentListFilterKeys = basePaymentListFilters->Array.map(filter => (filter :> string))

let advancedPaymentListFilterKeys =
  basePaymentListFilterKeys
  ->Array.concat(advancedPaymentOnlyFilterKeys)
  ->Array.concat(hiddenAdvancedPaymentFilterKeys)

let copyAdvancedPaymentFilterIfPresent = (~fromDict, ~toDict, key) => {
  switch fromDict->getOptionValFromDict(key) {
  | Some(value) =>
    let stringValues = switch value->JSON.Decode.array {
    | Some(values) =>
      values
      ->getStrArrayFromJsonArray
      ->Array.map(value => value->String.trim)
      ->Belt.Array.keepMap(getNonEmptyString)
    | None =>
      let value = value->getStringFromJson("")->String.trim
      value->isNonEmptyString ? [value] : []
    }

    if key === customerEmailFilterKey {
      switch stringValues->Array.get(0) {
      | Some(email) if !(email->CommonAuthUtils.isValidEmail) =>
        toDict->setOptionString(key, Some(email))
      | _ => ()
      }
    } else if advancedPaymentTextListFilterKeys->Array.includes(key) {
      if stringValues->isNonEmptyArray {
        toDict->setOptionJson(key, Some(stringValues->getJsonFromArrayOfString))
      }
    } else if key === firstAttemptFilterKey {
      let getBoolFilterValue = value =>
        switch value->JSON.Decode.bool {
        | Some(value) => Some(value)
        | None =>
          let value = value->getStringFromJson("")->String.trim->String.toLowerCase
          value === "true" || value === "false" ? Some(value->getBoolFromString(false)) : None
        }
      let boolValues = switch value->JSON.Decode.array {
      | Some(values) => values->Belt.Array.keepMap(getBoolFilterValue)
      | None =>
        switch value->getBoolFilterValue {
        | Some(value) => [value]
        | None => []
        }
      }
      if boolValues->isNonEmptyArray {
        toDict->setOptionArray(key, Some(boolValues->Array.map(JSON.Encode.bool)))
      }
    } else {
      toDict->setOptionJson(key, Some(value))
    }
  | None => ()
  }
}

let buildAdvancedPaymentListPayload = (
  ~filterParams: Dict.t<JSON.t>,
  ~searchText,
  ~startTimeKey,
  ~endTimeKey,
) => {
  let body = Dict.make()
  let trimmedSearchText = searchText->String.trim

  body->setOptionJson("offset", filterParams->Dict.get("offset"))
  body->setOptionJson("limit", filterParams->Dict.get("limit"))
  body->setOptionJson("order", filterParams->Dict.get("order"))
  body->setOptionJson("amount_filter", filterParams->Dict.get("amount_filter"))

  if trimmedSearchText->isEmptyString {
    body->setOptionJson(startTimeKey, filterParams->Dict.get(startTimeKey))
    body->setOptionJson(endTimeKey, filterParams->Dict.get(endTimeKey))
  }

  advancedPaymentListFilterKeys->Array.forEach(key => {
    copyAdvancedPaymentFilterIfPresent(~fromDict=filterParams, ~toDict=body, key)
  })

  if trimmedSearchText->isNonEmptyString {
    if !(trimmedSearchText->CommonAuthUtils.isValidEmail) {
      body->setOptionString(customerEmailFilterKey, Some(trimmedSearchText))
    } else if trimmedSearchText->String.startsWith("pay_") {
      body->setOptionString(paymentIdFilterKey, Some(trimmedSearchText))
    } else if RegExp.test(%re("/^\d{4}$/"), trimmedSearchText) {
      body->setOptionArray(cardLast4FilterKey, Some([trimmedSearchText->JSON.Encode.string]))
    } else {
      body->setOptionString("query", Some(trimmedSearchText))
    }
  }

  body
}

let initialFiltersWithSource = (
  ~isAdvancedSource=false,
  json,
  filterValues,
  removeKeys,
  filterKeys,
  setfilterKeys,
  version,
) => {
  let filterDict = json->getDictFromJsonObject

  let filterData = filterDict->itemToObjMapper
  let filtersArray = filterDict->Dict.keysToArray
  let onDeleteClick = name => {
    [name]->removeKeys
    setfilterKeys(_ => filterKeys->Array.filter(item => item !== name))
  }

  let connectorFilter = filterValues->getArrayFromDict("connector", [])->getStrArrayFromJsonArray
  if connectorFilter->isNonEmptyArray {
    filtersArray->Array.push(#connector_label->getLabelFromFilterType)
  }

  let additionalFilters =
    [#payment_method_type, #customer_id, #amount, #merchant_order_reference_id]
    ->Array.concat(isAdvancedSource ? advancedPaymentFilterTypes : [])
    ->Array.map(getLabelFromFilterType)

  let allFiltersArray = filtersArray->Array.concat(additionalFilters)

  allFiltersArray->Array.map((key): EntityType.initialFilters<'t> => {
    let filterType = key->getFilterTypeFromString
    let values = switch filterType {
    | #connector => filterData.connector
    | #payment_method => filterData.payment_method
    | #currency => filterData.currency
    | #authentication_type => filterData.authentication_type
    | #status => filterData.status
    | #payment_method_type =>
      let conditionalFilter = getConditionalFilter(key, filterDict, filterValues)
      conditionalFilter->isNonEmptyArray ? conditionalFilter : filterData.payment_method_type
    | #connector_label => getConditionalFilter(key, filterDict, filterValues)
    | #card_network => filterData.card_network
    | #card_discovery => filterData.card_discovery
    | #refunds_status => filterData.refunds_status
    | #dispute_status => filterData.dispute_status
    | #routing_approach => filterData.routing_approach
    | #card_issuer => filterData.card_issuer
    | _ => []
    }
    let staticValues = switch filterType {
    | #refunds_status => openSearchRefundStatusValues
    | #dispute_status => openSearchDisputeStatusValues
    | #routing_approach => advancedRoutingApproachValues
    | _ => []
    }
    let values = isAdvancedSource
      ? Array.concat(values, staticValues)->Array.filter(isNonEmptyString)->getUniqueArray
      : values

    let title = `Select ${key->snakeToTitle}`
    let filterKey = filterType->getValueFromFilterType
    let labelRightComponent = if (
      isAdvancedSource &&
      advancedPaymentOnlyFilterKeys->Array.includes(filterKey) &&
      !(filterKeys->Array.includes(filterKey))
    ) {
      Some(<NewFeatureTag description={filterKey->getAdvancedPaymentFilterDescription} />)
    } else {
      None
    }

    let options = switch filterType {
    | #connector_label => getOptionsForOrderFilters(filterDict, filterValues)
    | #connector => values->ConnectorUtils.getConnectorFilterOptions
    | _ => values->FilterSelectBox.makeOptions(~isTitle=true)
    }

    let customInput = switch filterType {
    | #customer_id
    | #merchant_order_reference_id
    | #customer_email
    | #card_last_4
    | #active_attempt_id
    | #merchant_connector_id
    | #card_issuer =>
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
        ~labelRightComponent?,
      ),
      localFilter: Some(filterByData),
    }
  })
}

let initialFilters = (json, filterValues, removeKeys, filterKeys, setfilterKeys, version) =>
  initialFiltersWithSource(
    ~isAdvancedSource=false,
    json,
    filterValues,
    removeKeys,
    filterKeys,
    setfilterKeys,
    version,
  )

let initialFixedFilter = (version: UserInfoTypes.version, ~disable=false) => [
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
          ~disable,
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
  data: array<PaymentInterfaceTypes.order>,
  setTotalCount,
  setOrdersData,
  setScreenState,
  previewOnly,
) => {
  let arr = Array.make(~length=offset, Dict.make()->PaymentInterfaceUtils.mapDictToPaymentPayload)
  if total <= offset {
    setOffset(_ => 0)
  }

  if total > 0 {
    let orderData =
      arr
      ->Array.concat(data)
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
    label: "All Profiles",
    entity: #Merchant,
  },
  {
    label: "Profile",
    entity: #Profile,
  },
]
