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
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let connectorID = url.path->Belt.List.toArray->Belt.Array.get(1)->Belt.Option.getWithDefault("")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->Js.Json.object_)
  let (currentStep, setCurrentStep) = React.useState(_ => ConnectorTypes.IntegFields)
  let fetchDetails = useGetMethod()

  let isUpdateFlow = switch url.path {
  | list{"connectors", "new"} => false
  | list{"payoutconnectors", "new"} => false
  | _ => true
  }

  let getConnectorDetails = async () => {
    try {
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Get, ~id=Some(connectorID), ())
      let json = await fetchDetails(connectorUrl)
      setInitialValues(_ => json)
      setCurrentStep(_ => Preview)
    } catch {
    | _ => ()
    }
  }

  let getDetails = async () => {
    try {
      setScreenState(_ => Loading)
      let _ = await Window.connectorWasmInit()
      if isUpdateFlow {
        await getConnectorDetails()
      }
      setScreenState(_ => Success)
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Something went wrong")
        setScreenState(_ => Error(err))
      }
    }
  }

  React.useEffect1(() => {
    if connector->String.length > 0 {
      getDetails()->ignore
    }
    None
  }, [connector])

  let (title, link) = isPayoutFlow
    ? ("Payout Processor", "/payoutconnectors")
    : ("Processor", "/connectors")

  let stepsArr = isPayoutFlow ? payoutStepsArr : stepsArr
  let borderWidth = isPayoutFlow ? "w-8/12" : "w-9/12"

  <PageLoaderWrapper screenState>
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
            connectorInfo={initialValues} currentStep setCurrentStep isUpdateFlow isPayoutFlow
          />
        }}
      </div>
    </div>
  </PageLoaderWrapper>
}
