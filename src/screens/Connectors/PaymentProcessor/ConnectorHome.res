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

@react.component
let make = (~showStepIndicator=true, ~showBreadCrumb=true) => {
  open ConnectorTypes
  open ConnectorUtils
  open APIUtils
  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastState.useShowToast()
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let connectorTypeFromName = connector->getConnectorNameTypeFromString
  let profileIdFromUrl =
    UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getOptionString("profile_id")
  let connectorID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (currentStep, setCurrentStep) = React.useState(_ => ConnectorTypes.IntegFields)
  let fetchDetails = useGetMethod()

  let isUpdateFlow = switch url.path->HSwitchUtils.urlPath {
  | list{"connectors", "new"} => false
  | _ => true
  }

  let setSetupAccountStatus = Recoil.useSetRecoilState(HyperswitchAtom.paypalAccountStatusAtom)

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

  let profileID =
    initialValues->LogicUtils.getDictFromJsonObject->LogicUtils.getOptionString("profile_id")

  let getPayPalStatus = React.useCallback(async () => {
    open PayPalFlowUtils
    open LogicUtils
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let profileId = switch profileID {
      | Some(value) => value
      | _ =>
        switch profileIdFromUrl {
        | Some(profileIdValue) => profileIdValue
        | _ => Exn.raiseError("Profile Id not found!")
        }
      }

      let paypalBody = generatePayPalBody(~connectorId={connectorID}, ~profileId=Some(profileId))
      let url = getURL(~entityName=V1(PAYPAL_ONBOARDING_SYNC), ~methodType=Post)
      let responseValue = await updateDetails(url, paypalBody, Post)
      let paypalDict = responseValue->getDictFromJsonObject->getJsonObjectFromDict("paypal")

      switch paypalDict->JSON.Classify.classify {
      | String(str) => {
          setSetupAccountStatus(_ => str->stringToVariantMapper)
          setCurrentStep(_ => AutomaticFlow)
        }
      | Object(dict) =>
        handleObjectResponse(
          ~dict,
          ~setInitialValues,
          ~connector,
          ~connectorType=Processor,
          ~handleStateToNextPage=_ => setCurrentStep(_ => PaymentMethods),
        )
      | _ => ()
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      if err->String.includes("Profile") {
        showToast(~message="Profile Id not found. Try Again", ~toastType=ToastError)
      }
      setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }, (connector, profileID, profileIdFromUrl, connectorID))

  let commonPageState = () => {
    if isUpdateFlow {
      setCurrentStep(_ => Preview)
    } else {
      setCurrentStep(_ => ConnectorTypes.IntegFields)
    }
    setScreenState(_ => Success)
  }

  let determinePageState = () => {
    switch (connectorTypeFromName, featureFlagDetails.paypalAutomaticFlow) {
    | (Processors(PAYPAL), true) =>
      PayPalFlowUtils.payPalPageState(
        ~setScreenState,
        ~url,
        ~setSetupAccountStatus,
        ~getPayPalStatus,
        ~setCurrentStep,
        ~isUpdateFlow,
      )->ignore
    | (_, _) => commonPageState()
    }
  }

  let getDetails = async () => {
    try {
      setScreenState(_ => Loading)
      let _ = await Window.connectorWasmInit()
      if isUpdateFlow {
        await getConnectorDetails()
      }
      determinePageState()
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

  let customUiForPaypal =
    <DefaultLandingPage
      title="Oops, we hit a little bump on the road!"
      customStyle={`py-16 !m-0 `}
      overriddingStylesTitle="text-2xl font-semibold"
      buttonText="Go back to processor"
      overriddingStylesSubtitle="!text-sm text-grey-700 opacity-50 !w-3/4"
      subtitle="We apologize for the inconvenience, but it seems like we encountered a hiccup while processing your request."
      onClickHandler={_ => {
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/connectors"))
        setScreenState(_ => PageLoaderWrapper.Success)
      }}
      isButton=true
    />

  <PageLoaderWrapper screenState customUI={customUiForPaypal}>
    <div className="flex flex-col gap-10 overflow-scroll h-full w-full">
      <RenderIf condition={showBreadCrumb}>
        <BreadCrumbNavigation
          path=[
            connectorID === "new"
              ? {
                  title: "Processor",
                  link: "/connectors",
                  warning: `You have not yet completed configuring your ${connector->LogicUtils.snakeToTitle} connector. Are you sure you want to go back?`,
                }
              : {
                  title: "Processor",
                  link: "/connectors",
                },
          ]
          currentPageTitle={connector->getDisplayNameForConnector}
          cursorStyle="cursor-pointer"
        />
      </RenderIf>
      <RenderIf condition={currentStep !== Preview && showStepIndicator}>
        <ConnectorCurrentStepIndicator currentStep stepsArr={stepsArr(~connector)} />
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
        | AutomaticFlow =>
          switch connectorTypeFromName {
          | Processors(PAYPAL) =>
            <ConnectPayPal
              connector isUpdateFlow setInitialValues initialValues setCurrentStep getPayPalStatus
            />
          | _ => React.null
          }
        | IntegFields =>
          <ConnectorAccountDetails setCurrentStep setInitialValues initialValues isUpdateFlow />
        | PaymentMethods =>
          <ConnectorPaymentMethod
            setCurrentStep connector setInitialValues initialValues isUpdateFlow
          />
        | CustomMetadata =>
          <ConnectorCustomMetadata
            setCurrentStep connector setInitialValues initialValues isUpdateFlow
          />
        | SummaryAndTest
        | Preview =>
          // <PaymentProcessorSummary />
          <ConnectorPreview
            connectorInfo={initialValues}
            currentStep
            setCurrentStep
            isUpdateFlow
            setInitialValues
            getPayPalStatus
            getConnectorDetails={Some(getConnectorDetails)}
          />
        }}
      </div>
    </div>
  </PageLoaderWrapper>
}
