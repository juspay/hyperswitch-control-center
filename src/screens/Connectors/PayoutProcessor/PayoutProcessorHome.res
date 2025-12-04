module ConnectorCurrentStepIndicator = {
  @react.component
  let make = (~currentStep: ConnectorTypes.steps, ~stepsArr) => {
    let cols = stepsArr->Array.length->Int.toString
    let currIndex = stepsArr->Array.findIndex(item => item === currentStep)
    <div className=" w-full md:w-2/3">
      <div className={`grid grid-cols-${cols} relative gap-2`}>
        {stepsArr
        ->Array.mapWithIndex((step, i) => {
          let isStepCompleted = i <= currIndex
          let isPreviousStepCompleted = i < currIndex
          let isCurrentStep = i == currIndex

          let stepNumberIndicator = if isPreviousStepCompleted {
            "border-black bg-white"
          } else if isCurrentStep {
            "bg-black"
          } else {
            "border-gray-300 bg-white"
          }

          let stepNameIndicator = isStepCompleted
            ? "text-black break-all"
            : "text-jp-gray-700 break-all"

          let textColor = isCurrentStep ? "text-white" : "text-grey-700"

          let stepLineIndicator = isPreviousStepCompleted ? "bg-gray-700" : "bg-gray-200"

          <div key={i->Int.toString} className="flex flex-col gap-2 font-semibold ">
            <div className="flex items-center w-full">
              <div
                className={`h-8 w-8 flex items-center justify-center border rounded-full ${stepNumberIndicator}`}>
                {if isPreviousStepCompleted {
                  <Icon name="check-black" size=20 />
                } else {
                  <p className=textColor> {(i + 1)->Int.toString->React.string} </p>
                }}
              </div>
              <RenderIf condition={i !== stepsArr->Array.length - 1}>
                <div className={`h-0.5 ${stepLineIndicator} ml-2 flex-1`} />
              </RenderIf>
            </div>
            <div className={stepNameIndicator}>
              {step->ConnectorUtils.getStepName->React.string}
            </div>
          </div>
        })
        ->React.array}
      </div>
    </div>
  }
}

module MenuOption = {
  open HeadlessUI
  @react.component
  let make = (~disableConnector, ~isConnectorDisabled) => {
    let showPopUp = PopUpState.useShowPopUp()
    let openConfirmationPopUp = _ => {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: "Confirm Action?",
        description: `You are about to ${isConnectorDisabled
            ? "Enable"
            : "Disable"->String.toLowerCase} this connector. This might impact your desired routing configurations. Please confirm to proceed.`->React.string,
        handleConfirm: {
          text: "Confirm",
          onClick: _ => disableConnector(isConnectorDisabled)->ignore,
        },
        handleCancel: {text: "Cancel"},
      })
    }

    let connectorStatusAvailableToSwitch = isConnectorDisabled ? "Enable" : "Disable"

    <Popover \"as"="div" className="relative inline-block text-left">
      {_ => <>
        <Popover.Button> {_ => <Icon name="menu-option" size=28 />} </Popover.Button>
        <Popover.Panel className="absolute z-20 right-5 top-4">
          {panelProps => {
            <div
              id="neglectTopbarTheme"
              className="relative flex flex-col bg-white py-1 overflow-hidden rounded ring-1 ring-black ring-opacity-5 w-40">
              {<Navbar.MenuOption
                text={connectorStatusAvailableToSwitch}
                onClick={_ => {
                  panelProps["close"]()
                  openConfirmationPopUp()
                }}
              />}
            </div>
          }}
        </Popover.Panel>
      </>}
    </Popover>
  }
}

@react.component
let make = (~showStepIndicator=true, ~showBreadCrumb=true) => {
  open ConnectorTypes
  open ConnectorUtils
  open APIUtils
  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let connectorTypeFromName = connector->getConnectorNameTypeFromString
  let connectorID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (currentStep, setCurrentStep) = React.useState(_ => ConnectorTypes.IntegFields)
  let fetchDetails = useGetMethod()
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let connectorInfo = ConnectorInterface.mapDictToTypedConnectorPayload(
    ConnectorInterface.connectorInterfaceV1,
    initialValues->LogicUtils.getDictFromJsonObject,
  )

  let isUpdateFlow = switch url.path->HSwitchUtils.urlPath {
  | list{"payoutconnectors", "new"} => false
  | _ => true
  }
  let getConnectorDetails = async () => {
    try {
      let connectorUrl = getURL(~entityName=V1(CONNECTOR), ~methodType=Get, ~id=Some(connectorID))
      let json = await fetchDetails(connectorUrl)
      setInitialValues(_ => json)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to update!")
        Exn.raiseError(err)
      }
    | _ => Exn.raiseError("Something went wrong")
    }
  }

  let commonPageState = () => {
    if isUpdateFlow {
      setCurrentStep(_ => Preview)
    } else {
      setCurrentStep(_ => ConnectorTypes.IntegFields)
    }
    setScreenState(_ => Success)
  }

  let getDetails = async () => {
    try {
      setScreenState(_ => Loading)
      let _ = await Window.connectorWasmInit()
      if isUpdateFlow {
        await getConnectorDetails()
      }
      commonPageState()
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        setScreenState(_ => Error(err))
      }
    | _ => setScreenState(_ => Error("Something went wrong"))
    }
  }

  let connectorStatusStyle = connectorStatus =>
    switch connectorStatus {
    | true => "border bg-red-600 bg-opacity-40 border-red-400 text-red-500"
    | false => "border bg-green-600 bg-opacity-40 border-green-700 text-green-700"
    }

  let isConnectorDisabled = connectorInfo.disabled

  let disableConnector = async isConnectorDisabled => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let connectorID = connectorInfo.merchant_connector_id
      let disableConnectorPayload = getDisableConnectorPayload(
        connectorInfo.connector_type->connectorTypeTypedValueToStringMapper,
        isConnectorDisabled,
      )

      let url = getURL(~entityName=V1(CONNECTOR), ~methodType=Post, ~id=Some(connectorID))
      let res = await updateDetails(url, disableConnectorPayload->JSON.Encode.object, Post)
      setInitialValues(_ => res)
      let _ = await fetchConnectorListResponse()
      setScreenState(_ => PageLoaderWrapper.Success)
      showToast(~message="Successfully Saved the Changes", ~toastType=ToastSuccess)
    } catch {
    | Exn.Error(_) => showToast(~message="Failed to Disable connector!", ~toastType=ToastError)
    }
  }

  let summaryPageButton = switch currentStep {
  | Preview =>
    <div className="flex gap-6 items-center">
      <div
        className={`px-4 py-2 rounded-full w-fit font-medium text-sm !text-black ${isConnectorDisabled->connectorStatusStyle}`}>
        {(isConnectorDisabled ? "DISABLED" : "ENABLED")->React.string}
      </div>
      <MenuOption disableConnector isConnectorDisabled />
    </div>
  | _ =>
    <Button
      text="Done"
      buttonType=Primary
      onClick={_ =>
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/payoutconnectors"))}
    />
  }

  React.useEffect(() => {
    if connector->LogicUtils.isNonEmptyString {
      getDetails()->ignore
    } else {
      setScreenState(_ => Error("Connector name not found"))
    }
    None
  }, [connector])

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-10 overflow-scroll h-full w-full">
      <RenderIf condition={showBreadCrumb}>
        <BreadCrumbNavigation
          path=[
            connectorID === "new"
              ? {
                  title: "Payout Processor",
                  link: "/payoutconnectors",
                  warning: `You have not yet completed configuring your ${connector->LogicUtils.snakeToTitle} connector. Are you sure you want to go back?`,
                }
              : {
                  title: "Payout Processor",
                  link: "/payoutconnectors",
                },
          ]
          currentPageTitle={connector->ConnectorUtils.getDisplayNameForConnector(
            ~connectorType=PayoutProcessor,
          )}
          cursorStyle="cursor-pointer"
        />
      </RenderIf>
      <RenderIf condition={currentStep !== Preview && showStepIndicator}>
        <ConnectorCurrentStepIndicator currentStep stepsArr=payoutStepsArr />
      </RenderIf>
      <RenderIf
        condition={connectorTypeFromName->checkIsDummyConnector(featureFlagDetails.testProcessors)}>
        <HSwitchUtils.AlertBanner
          bannerContent={<p>
            {"This is a test connector and will not be reflected on your payment processor dashboard."->React.string}
          </p>}
          bannerType=Warning
        />
      </RenderIf>
      <div
        className="bg-white rounded-lg border h-3/4 overflow-scroll shadow-boxShadowMultiple show-scrollbar">
        {switch currentStep {
        | AutomaticFlow => React.null
        | IntegFields =>
          <PayoutProcessorAccountDetails
            setCurrentStep setInitialValues initialValues isUpdateFlow
          />
        | PaymentMethods =>
          <PayoutProcessorPaymentMethod
            setCurrentStep connector setInitialValues initialValues isUpdateFlow
          />
        | CustomMetadata
        | SummaryAndTest
        | Preview =>
          <ConnectorAccountDetailsHelper.ConnectorHeaderWrapper
            connector connectorType={PayoutProcessor} headerButton={summaryPageButton}>
            <ConnectorPreview.ConnectorSummaryGrid
              connectorInfo={ConnectorInterface.mapDictToTypedConnectorPayload(
                ConnectorInterface.connectorInterfaceV1,
                initialValues->LogicUtils.getDictFromJsonObject,
              )}
              connector
              setCurrentStep
              updateStepValue={Some(ConnectorTypes.PaymentMethods)}
              getConnectorDetails={Some(getConnectorDetails)}
            />
          </ConnectorAccountDetailsHelper.ConnectorHeaderWrapper>
        }}
      </div>
    </div>
  </PageLoaderWrapper>
}
