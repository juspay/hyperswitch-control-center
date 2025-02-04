@react.component
let make = (~showStepIndicator=true, ~showBreadCrumb=true) => {
  let (currentStep, setCurrentStep) = React.useState(_ => ConnectorTypes.IntegFields)

  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  React.useEffect(() => {
    setShowSideBar(_ => false)

    (
      () => {
        setShowSideBar(_ => true)
      }
    )->Some
  }, [])

  let backClick = () => {
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recovery/connectors"))
  }

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
            <RecoveryConfigurationHelper.RecoveryBillingConfigurationCurrentStepIndicator
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
}
