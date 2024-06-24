@react.component
let make = () => {
  open FRMUtils
  open APIUtils
  open ConnectorTypes
  open LogicUtils
  open FRMInfo
  let getURL = useGetURL()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let url = RescriptReactRouter.useUrl()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let frmName = UrlUtils.useGetFilterDictFromUrl("")->getString("name", "")
  let frmID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "")

  let initStep = PaymentMethods

  let isUpdateFlow = switch url.path->HSwitchUtils.urlPath {
  | list{"fraud-risk-management", "new"} => false
  | _ => true
  }

  let (currentStep, setCurrentStep) = React.useState(_ => isUpdateFlow ? Preview : initStep)

  let selectedFRMName: ConnectorTypes.connectorTypes = React.useMemo1(() => {
    let frmName =
      frmName->ConnectorUtils.getConnectorNameTypeFromString(~connectorType=FRMPlayer, ())
    setInitialValues(_ => {
      generateInitialValuesDict(
        ~selectedFRMName=frmName,
        ~isLiveMode=featureFlagDetails.isLiveMode,
        (),
      )
    })
    setCurrentStep(_ => isUpdateFlow ? Preview : initStep)
    frmName
  }, [frmName])

  let getFRMDetails = async url => {
    try {
      let res = await fetchDetails(url)
      setInitialValues(_ => res)
      setScreenState(_ => Success)
      setCurrentStep(prev => prev->getNextStep)
    } catch {
    | _ => setScreenState(_ => Error("Error Occured!"))
    }
  }

  React.useEffect0(() => {
    if frmID !== "new" {
      setScreenState(_ => Loading)
      let url = getURL(~entityName=FRAUD_RISK_MANAGEMENT, ~methodType=Get, ()) ++ "/" ++ frmID
      getFRMDetails(url)->ignore
    } else {
      setScreenState(_ => Success)
    }
    None
  })

  let path: array<BreadCrumbNavigation.breadcrumb> = []
  if frmID === "new" {
    path
    ->Array.push({
      title: {"Fraud Risk Management"},
      link: "/fraud-risk-management",
      warning: `You have not yet completed configuring your ${selectedFRMName
        ->ConnectorUtils.getConnectorNameString
        ->snakeToTitle} player. Are you sure you want to go back?`,
      mixPanelCustomString: ` ${selectedFRMName->ConnectorUtils.getConnectorNameString}`,
    })
    ->ignore
  } else {
    path
    ->Array.push({
      title: {"Fraud Risk Management"},
      link: "/fraud-risk-management",
    })
    ->ignore
  }
  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-8 h-full">
      <BreadCrumbNavigation
        path currentPageTitle={frmName->capitalizeString} cursorStyle="cursor-pointer"
      />
      <UIUtils.RenderIf condition={currentStep !== Preview}>
        <ConnectorHome.ConnectorCurrentStepIndicator currentStep stepsArr />
      </UIUtils.RenderIf>
      <div className="bg-white rounded border h-3/4 p-2 md:p-6 overflow-scroll">
        {switch currentStep {
        | IntegFields =>
          <FRMIntegrationFields
            setCurrentStep
            selectedFRMName
            setInitialValues
            retrivedValues=Some(initialValues)
            isUpdateFlow
          />
        | PaymentMethods =>
          <FRMPaymentMethods
            setCurrentStep retrivedValues=Some(initialValues) setInitialValues isUpdateFlow
          />
        | SummaryAndTest
        | Preview =>
          <FRMSummary initialValues currentStep setCurrentStep />
        | _ => React.null
        }}
      </div>
    </div>
  </PageLoaderWrapper>
}
