module EventLogMobileView = {
  @react.component
  let make = () => {
    <>
      {HSwitchOrderUtils.eventLogHeader}
      <div
        className="flex items-center gap-2 bg-white w-fit border-2 p-3 !opacity-100 rounded-lg text-md font-medium">
        <Icon name="info-circle-unfilled" size=16 />
        <div className={`text-lg font-medium opacity-50`}>
          {"To view payment logs for this payment please switch to desktop mode"->React.string}
        </div>
      </div>
    </>
  }
}

module PaymentLogs = {
  @react.component
  let make = (~id, ~createdAt) => {
    let {auditTrail} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let isSmallDevice = MatchMedia.useMatchMedia("(max-width: 700px)")

    <div className="overflow-x-scroll">
      <UIUtils.RenderIf condition={isSmallDevice}>
        <EventLogMobileView />
      </UIUtils.RenderIf>
      <UIUtils.RenderIf condition={!isSmallDevice && auditTrail}>
        <PaymentLogs paymentId=id createdAt />
      </UIUtils.RenderIf>
    </div>
  }
}

module GenerateSampleDataButton = {
  open APIUtils
  @react.component
  let make = (~previewOnly, ~getOrdersList) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let {sampleData} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

    let generateSampleData = async () => {
      mixpanelEvent(~eventName="generate_sample_data", ())
      try {
        let generateSampleDataUrl = getURL(~entityName=GENERATE_SAMPLE_DATA, ~methodType=Post, ())
        let _ = await updateDetails(
          generateSampleDataUrl,
          [("record", 50.0->Js.Json.number)]->Dict.fromArray->Js.Json.object_,
          Post,
        )
        showToast(~message="Sample data generated successfully.", ~toastType=ToastSuccess, ())
        getOrdersList()->ignore
      } catch {
      | _ => ()
      }
    }

    <UIUtils.RenderIf condition={sampleData && !previewOnly}>
      <Button
        buttonType={Secondary}
        text="Generate Sample Data"
        customButtonStyle="!px-6 text-fs-13"
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
        : "Connect to a connector like Stripe, Adyen or Hyperswitch provided test connector to make your first payment."}
      buttonText={isConfigureConnector ? "Make a payment" : "Connect a connector"}
      moduleName=""
      paymentModal
      setPaymentModal
      showRedirectCTA={!isLiveMode}
      onClickUrl={isConfigureConnector
        ? "/sdk"
        : `${HSwitchGlobalVars.hyperSwitchFEPrefix}/connectors`}
    />
  }
}

let filterUrl = `${HSwitchGlobalVars.hyperSwitchApiPrefix}/payments/filter`

let (startTimeFilterKey, endTimeFilterKey) = ("start_time", "end_time")

let filterByData = (txnArr, value) => {
  open LogicUtils
  let searchText = value->getStringFromJson("")

  txnArr
  ->Belt.Array.keepMap(Js.Nullable.toOption)
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

    valueArr ? data->Js.Nullable.return->Some : None
  })
}

let initialFilters = json => {
  open LogicUtils
  let filterDict = json->getDictFromJsonObject

  filterDict
  ->Dict.keysToArray
  ->Array.map((key): EntityType.initialFilters<'t> => {
    let title = `Select ${key->snakeToTitle}`
    let values = filterDict->getArrayFromDict(key, [])->getStrArrayFromJsonArray

    {
      field: FormRenderer.makeFieldInfo(
        ~label="",
        ~name=key,
        ~customInput=InputFields.multiSelectInput(
          ~options=values->SelectBox.makeOptions,
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
        ~comboCustomInput=InputFields.dateRangeField(
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
  let arr = Belt.Array.make(offset, Dict.make())
  if total <= offset {
    setOffset(_ => 0)
  }

  if total > 0 {
    let orderDataDictArr = data->Belt.Array.keepMap(Js.Json.decodeObject)

    let orderData =
      arr
      ->Array.concat(orderDataDictArr)
      ->Array.map(OrderEntity.itemToObjMapper)
      ->Array.filterWithIndex((_, i) => {
        !previewOnly || i <= 2
      })

    let list = orderData->Array.map(Js.Nullable.return)
    setTotalCount(_ => total)
    setOrdersData(_ => list)
    setScreenState(_ => PageLoaderWrapper.Success)
  } else {
    setScreenState(_ => PageLoaderWrapper.Custom)
  }
}

let getOrdersList = async (
  filterValueJson,
  ~updateDetails,
  ~setOrdersData,
  ~previewOnly,
  ~setScreenState,
  ~setOffset,
  ~setTotalCount,
  ~offset,
) => {
  open APIUtils
  open LogicUtils
  setScreenState(_ => PageLoaderWrapper.Loading)

  try {
    let ordersUrl = getURL(~entityName=ORDERS, ~methodType=Post, ())
    let res = await updateDetails(ordersUrl, filterValueJson->Js.Json.object_, Fetch.Post)
    let data = res->LogicUtils.getDictFromJsonObject->LogicUtils.getArrayFromDict("data", [])
    let total = res->getDictFromJsonObject->getInt("total_count", 0)

    if data->Array.length === 0 && filterValueJson->Dict.get("payment_id")->Belt.Option.isSome {
      let payment_id =
        filterValueJson
        ->Dict.get("payment_id")
        ->Belt.Option.getWithDefault(""->Js.Json.string)
        ->Js.Json.decodeString
        ->Belt.Option.getWithDefault("")

      if Js.Re.test_(%re(`/^[A-Za-z0-9]+_[A-Za-z0-9]+_[0-9]+/`), payment_id) {
        let newID = payment_id->String.replaceRegExp(%re("/_[0-9]$/g"), "")
        filterValueJson->Dict.set("payment_id", newID->Js.Json.string)

        let res = await updateDetails(ordersUrl, filterValueJson->Js.Json.object_, Fetch.Post)
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
  | Js.Exn.Error(_) => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
  }
}
