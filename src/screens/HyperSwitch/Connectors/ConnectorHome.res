module ConnectorCurrentStepIndicator = {
  @react.component
  let make = (~currentStep: ConnectorTypes.steps, ~stepsArr, ~borderWidth="w-8/12") => {
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
                  <p className=textColor> {(i + 1)->string_of_int->React.string} </p>
                }}
              </div>
              <UIUtils.RenderIf condition={i !== stepsArr->Array.length - 1}>
                <div className={`h-0.5 ${stepLineIndicator} ml-2 flex-1`} />
              </UIUtils.RenderIf>
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
let make = (~isPayoutFlow=false, ~showStepIndicator=true, ~showBreadCrumb=true) => {
  open ConnectorTypes
  open ConnectorUtils
  open APIUtils
  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastState.useShowToast()
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let profileIdFromUrl =
    UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getOptionString("profile_id")
  let connectorID = url.path->List.toArray->Array.get(1)->Option.getOr("")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (currentStep, setCurrentStep) = React.useState(_ => ConnectorTypes.IntegFields)
  let fetchDetails = useGetMethod()

  let isUpdateFlow = switch url.path {
  | list{"connectors", "new"} => false
  | list{"payoutconnectors", "new"} => false
  | _ => true
  }

  let setSetupAccountStatus = Recoil.useSetRecoilState(HyperswitchAtom.paypalAccountStatusAtom)

  let getConnectorDetails = async () => {
    try {
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Get, ~id=Some(connectorID), ())
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

  let getPayPalStatus = React.useCallback4(async () => {
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

      let paypalBody = generatePayPalBody(
        ~connectorId={connectorID},
        ~profileId=Some(profileId),
        (),
      )
      let url = `${getURL(~entityName=PAYPAL_ONBOARDING, ~methodType=Post, ())}/sync`
      let responseValue = await updateDetails(url, paypalBody, Fetch.Post, ())
      let paypalDict = responseValue->getDictFromJsonObject->getJsonObjectFromDict("paypal")

      switch paypalDict->JSON.Classify.classify {
      | String(str) => {
          setSetupAccountStatus(._ => str->stringToVariantMapper)
          setCurrentStep(_ => AutomaticFlow)
        }
      | Object(dict) =>
        handleObjectResponse(~dict, ~setInitialValues, ~connector, ~handleStateToNextPage=_ =>
          setCurrentStep(_ => PaymentMethods)
        )
      | _ => ()
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      if err->String.includes("Profile") {
        showToast(~message="Profile Id not found. Try Again", ~toastType=ToastError, ())
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
    switch (connector->getConnectorNameTypeFromString, featureFlagDetails.paypalAutomaticFlow) {
    | (PAYPAL, true) =>
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
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        setScreenState(_ => Error(err))
      }
    | _ => setScreenState(_ => Error("Something went wrong"))
    }
  }

  React.useEffect1(() => {
    if connector->String.length > 0 {
      getDetails()->ignore
    } else {
      setScreenState(_ => Error("Connector name not found"))
    }
    None
  }, [connector])

  let (title, link) = isPayoutFlow
    ? ("Payout Processor", "/payoutconnectors")
    : ("Processor", "/connectors")

  let stepsArr = isPayoutFlow ? payoutStepsArr : stepsArr
  let borderWidth = isPayoutFlow ? "w-8/12" : "w-9/12"

  let customUiForPaypal =
    <DefaultLandingPage
      title="Oops, we hit a little bump on the road!"
      customStyle={`py-16 !m-0 `}
      overriddingStylesTitle="text-2xl font-semibold"
      buttonText="Go back to processor"
      overriddingStylesSubtitle="!text-sm text-grey-700 opacity-50 !w-3/4"
      subtitle="We apologize for the inconvenience, but it seems like we encountered a hiccup while processing your request."
      onClickHandler={_ => {
        RescriptReactRouter.push("/connectors")
        setScreenState(_ => PageLoaderWrapper.Success)
      }}
      isButton=true
    />

  <PageLoaderWrapper screenState customUI={customUiForPaypal}>
    <div className="flex flex-col gap-10 overflow-scroll h-full w-full">
      <UIUtils.RenderIf condition={showBreadCrumb}>
        <BreadCrumbNavigation
          path=[
            connectorID === "new"
              ? {
                  title,
                  link,
                  warning: `You have not yet completed configuring your ${connector->LogicUtils.snakeToTitle} connector. Are you sure you want to go back?`,
                }
              : {
                  title,
                  link,
                },
          ]
          currentPageTitle={connector->ConnectorUtils.getDisplayNameForConnectors}
          cursorStyle="cursor-pointer"
        />
      </UIUtils.RenderIf>
      <UIUtils.RenderIf condition={currentStep !== Preview && showStepIndicator}>
        <ConnectorCurrentStepIndicator currentStep stepsArr borderWidth />
      </UIUtils.RenderIf>
      <div
        className="bg-white rounded-lg border h-3/4 overflow-scroll shadow-boxShadowMultiple show-scrollbar">
        {switch currentStep {
        | AutomaticFlow =>
          switch connector->ConnectorUtils.getConnectorNameTypeFromString {
          | PAYPAL =>
            <ConnectPayPal
              connector isUpdateFlow setInitialValues initialValues setCurrentStep getPayPalStatus
            />
          | _ => React.null
          }
        | IntegFields =>
          <ConnectorAccountDetails
            setCurrentStep setInitialValues initialValues isUpdateFlow isPayoutFlow
          />
        | PaymentMethods =>
          <ConnectorPaymentMethod
            setCurrentStep connector setInitialValues initialValues isUpdateFlow isPayoutFlow
          />
        | SummaryAndTest
        | Preview =>
          <ConnectorPreview
            connectorInfo={initialValues}
            currentStep
            setCurrentStep
            isUpdateFlow
            isPayoutFlow
            setInitialValues
            getPayPalStatus
          />
        }}
      </div>
    </div>
  </PageLoaderWrapper>
}
