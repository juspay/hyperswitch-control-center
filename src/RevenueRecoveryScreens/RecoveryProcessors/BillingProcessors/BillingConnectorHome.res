@react.component
let make = (~showStepIndicator=true, ~showBreadCrumb=true) => {
  open APIUtils
  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (currentStep, setCurrentStep) = React.useState(_ => ConnectorTypes.IntegFields)
  let fetchDetails = useGetMethod()

  // let getConnectorDetails = async () => {
  //   try {
  //     // TODO: need to converted into V2
  //     let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Get, ~id=Some(connectorID))
  //     let json = await fetchDetails(connectorUrl)
  //     setInitialValues(_ => json)
  //   } catch {
  //   | Exn.Error(e) => {
  //       let err = Exn.message(e)->Option.getOr("Failed to update!")
  //       Exn.raiseError(err)
  //     }
  //   | _ => Exn.raiseError("Something went wrong")
  //   }
  // }

  // let getDetails = async () => {
  //   try {
  //     setScreenState(_ => Loading)
  //     let _ = await Window.connectorWasmInit()
  //     if isUpdateFlow {
  //       await getConnectorDetails()
  //     }
  //     commonPageState()
  //     setScreenState(_ => Success)
  //   } catch {
  //   | Exn.Error(e) => {
  //       let err = Exn.message(e)->Option.getOr("Something went wrong")
  //       setScreenState(_ => Error(err))
  //     }
  //   | _ => setScreenState(_ => Error("Something went wrong"))
  //   }
  // }

  // React.useEffect(() => {
  //   if connector->LogicUtils.isNonEmptyString {
  //     getDetails()->ignore
  //   } else {
  //     setScreenState(_ => Error("Connector name not found"))
  //   }
  //   None
  // }, [connector])

  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  React.useEffect(() => {
    setShowSideBar(_ => false)
    setScreenState(_ => Success)

    (
      () => {
        setShowSideBar(_ => true)
      }
    )->Some
  }, [])

  let backClick = () => {
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recovery/connectors"))
  }

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-10">
      <div className="rounded-lg h-774-px flex flex-col">
        <div className="flex h-full">
          <div className="flex-[3] border-r h-full">
            <div className="flex flex-col">
              <div className="flex items-center gap-x-3 px-6">
                <Icon
                  name="nd-arrow-left"
                  className="text-gray-500 cursor-pointer"
                  onClick={_ => backClick()}
                  customHeight="20"
                />
                <h1 className="text-medium font-semibold text-gray-600">
                  {"Setup Recovery"->React.string}
                </h1>
              </div>
              <RecoveryConfigurationHelper.RecoveryConfigurationCurrentStepIndicator
                currentStep stepsArr={BillingConnectorUtils.stepsArr}
              />
            </div>
          </div>
          <div className="flex-[7] h-full p-12">
            <div className="w-500-px">
              {switch currentStep {
              | IntegFields => <BillingConnectorAccountDetails setCurrentStep />
              | SummaryAndTest => <BillingConfigureRetries setCurrentStep />
              | AutomaticFlow => <BillingConnectPaymentProcessor setCurrentStep />
              | Webhooks => <BillingConnectorWebhooks setCurrentStep />
              | PaymentMethods
              | Preview => React.null
              }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </PageLoaderWrapper>
}
