module ConnectorCurrentStepIndicator = {
  @react.component
  let make = (~currentStep: ConnectorTypes.steps, ~stepsArr, ~borderWidth="w-8/12") => {
    let cols = stepsArr->Array.length->Belt.Int.toString
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

          <div key={i->Belt.Int.toString} className="flex flex-col gap-2 font-semibold ">
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
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let connectorID = url.path->Belt.List.toArray->Belt.Array.get(1)->Option.getWithDefault("")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->Js.Json.object_)
  let (currentStep, setCurrentStep) = React.useState(_ => ConnectorTypes.IntegFields)
  let fetchDetails = useGetMethod()

  let isUpdateFlow = switch url.path {
  | list{"connectors", "new"} => false
  | list{"payoutconnectors", "new"} => false
  | _ => true
  }

  let setSetupAccountStatus = Recoil.useSetRecoilState(HyperswitchAtom.paypalAccountStatusAtom)
  let profileId =
    initialValues->LogicUtils.getDictFromJsonObject->LogicUtils.getString("profile_id", "")

  let getConnectorDetails = async () => {
    try {
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Get, ~id=Some(connectorID), ())
      let json = await fetchDetails(connectorUrl)
      setInitialValues(_ => json)
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Option.getWithDefault("Failed to update!")
        Js.Exn.raiseError(err)
      }
    | _ => Js.Exn.raiseError("Something went wrong")
    }
  }

  let getPayPalStatus = React.useCallback3(async () => {
    open PayPalFlowUtils
    open LogicUtils
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let paypalBody = generatePayPalBody(
        ~connectorId={connectorID},
        ~profileId=Some(profileId),
        (),
      )
      let url = `${getURL(~entityName=PAYPAL_ONBOARDING, ~methodType=Post, ())}/sync`
      let responseValue = await updateDetails(url, paypalBody, Fetch.Post, ())
      let paypalDict = responseValue->getDictFromJsonObject->getJsonObjectFromDict("paypal")

      switch paypalDict->Js.Json.classify {
      | JSONString(str) => {
          setSetupAccountStatus(._ => str->stringToVariantMapper)
          setCurrentStep(_ => AutomaticFlow)
        }
      | JSONObject(dict) =>
        handleObjectResponse(~dict, ~setInitialValues, ~connector, ~handleStateToNextPage=_ =>
          setCurrentStep(_ => PaymentMethods)
        )
      | _ => ()
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }, (connector, profileId, connectorID))

  let commonLogic = async () => {
    try {
      if isUpdateFlow {
        await getConnectorDetails()
        setCurrentStep(_ => Preview)
      } else {
        setCurrentStep(_ => ConnectorTypes.IntegFields)
      }
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Option.getWithDefault("Something went wrong")
        setScreenState(_ => Error(err))
      }
    }
  }

  let getDetails = async () => {
    try {
      setScreenState(_ => Loading)
      let _ = await Window.connectorWasmInit()

      switch connector->getConnectorNameTypeFromString {
      | PAYPAL =>
        await PayPalFlowUtils.payPalLogics(
          ~setScreenState,
          ~url,
          ~setSetupAccountStatus,
          ~getConnectorDetails,
          ~getPayPalStatus,
          ~setCurrentStep,
          ~isUpdateFlow,
        )
      | _ => await commonLogic()
      }
      setScreenState(_ => Success)
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Option.getWithDefault("Something went wrong")
        setScreenState(_ => Error(err))
      }
    | _ => setScreenState(_ => Error("Something went wrong"))
    }
  }

  // let getDetails1 = async () => {
  //   try {
  //     setScreenState(_ => Loading)
  //     if connector->getConnectorNameTypeFromString == PAYPAL {
  //       setSetupAccountStatus(._ => PayPalFlowTypes.Connect_paypal_landing)
  //     }

  //     if isRedirectedFromPaypalModal {
  //       await getPayPalStatus()
  //     } else {
  //       setCurrentStep(_ =>
  //         connectorListWithAutomaticFlow->Js.Array2.includes(
  //           connector->ConnectorUtils.getConnectorNameTypeFromString,
  //         )
  //           ? ConnectorTypes.AutomaticFlow
  //           : ConnectorTypes.IntegFields
  //       )
  //     }

  //     if isUpdateFlow {
  //       await getConnectorDetails()
  //       if !(isSimplifiedPayPalFlow && isRedirectedFromPaypalModal) {
  //         setCurrentStep(_ => Preview)
  //       }
  //     }

  //     setScreenState(_ => Success)
  //   } catch {
  //   | Js.Exn.Error(e) => {
  //       let err = Js.Exn.message(e)->Option.getWithDefault("Something went wrong")
  //       setScreenState(_ => Error(err))
  //     }
  //   }
  // }

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
      buttonText="Try again"
      overriddingStylesSubtitle="!text-sm text-grey-700 opacity-50 !w-3/4"
      subtitle="We apologize for the inconvenience, but it seems like we encountered a hiccup while processing your request."
      onClickHandler={_ => {
        setCurrentStep(_ => AutomaticFlow)
        setSetupAccountStatus(._ => PayPalFlowTypes.Connect_paypal_landing)
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
          currentPageTitle={connector->LogicUtils.capitalizeString}
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
