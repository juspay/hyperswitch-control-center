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
  let connectorID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "", ~someIndex=4)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (currentStep, setCurrentStep) = React.useState(_ => ConnectorTypes.IntegFields)
  let fetchDetails = useGetMethod()

  let isUpdateFlow = switch url.path->HSwitchUtils.urlPath {
  | list{"v2", "recovery", "payment-processors", "new"} => false
  | _ => true
  }

  let getConnectorDetails = async () => {
    try {
      // TODO: need to converted into V2
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Get, ~id=Some(connectorID))
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
                  title: "Processor",
                  link: "v2/recovery/payment-processors",
                  warning: `You have not yet completed configuring your ${connector->LogicUtils.snakeToTitle} connector. Are you sure you want to go back?`,
                }
              : {
                  title: "Processor",
                  link: "v2/recovery/payment-processors",
                },
          ]
          currentPageTitle={connector->getDisplayNameForConnector}
          cursorStyle="cursor-pointer"
        />
      </RenderIf>
      <RenderIf condition={currentStep !== Preview && showStepIndicator}>
        <ConnectorHome.ConnectorCurrentStepIndicator currentStep stepsArr />
      </RenderIf>
      <RenderIf
        condition={connectorTypeFromName->checkIsDummyConnector(featureFlagDetails.testProcessors)}>
        <HSwitchUtils.AlertBanner
          bannerText="This is a test connector and will not be reflected on your payment processor dashboard."
          bannerType=Warning
        />
      </RenderIf>
      <div
        className="bg-white rounded-lg border h-3/4 overflow-scroll shadow-boxShadowMultiple show-scrollbar">
        {switch currentStep {
        | IntegFields =>
          <RecoveryConnectorAccountDetails
            setCurrentStep setInitialValues initialValues isUpdateFlow
          />
        | PaymentMethods =>
          <RecoveryConnectorPaymentMethod
            setCurrentStep connector setInitialValues initialValues isUpdateFlow
          />
        | SummaryAndTest
        | Preview
        | AutomaticFlow =>
          <RecoveryConnectorPreview
            connectorInfo={initialValues}
            currentStep
            setCurrentStep
            isUpdateFlow
            setInitialValues
            getConnectorDetails={Some(getConnectorDetails)}
          />
        }}
      </div>
    </div>
  </PageLoaderWrapper>
}
