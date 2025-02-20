@react.component
let make = () => {
  open ReconConfigurationTypes
  open ConnectOrderDataTypes

  let (currentStep, setCurrentStep) = React.useState(_ => ConnectOrderData(SelectSource))
  let (selectedOrderSource, setSelectedOrderSource) = React.useState(_ => Hyperswitch)
  let (selectedProcessor, setSelectedProcessor) = React.useState(() => "")
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  let backClick = () => {
    setShowSideBar(_ => true)
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recon/onboarding"))
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
                {"Setup Reconciliation"->React.string}
              </h1>
            </div>
            <ReconConfigurationHelper.ReconConfigurationCurrentStepIndicator currentStep />
          </div>
        </div>
        <div className="flex-[7] h-full p-12">
          <div className="w-500-px">
            {switch currentStep->ReconConfigurationUtils.getSectionFromStep {
            | ConnectOrderData =>
              <ConnectOrderData
                currentStep={currentStep}
                setCurrentStep={setCurrentStep}
                selectedOrderSource
                setSelectedOrderSource
              />
            | ConnectProcessorData =>
              <ConnectProcessorData
                currentStep={currentStep}
                setCurrentStep={setCurrentStep}
                selectedProcessor
                setSelectedProcessor
                selectedOrderSource
              />
            | ManualMapping =>
              <ManualMapping
                currentStep={currentStep}
                setCurrentStep={setCurrentStep}
                selectedProcessor
                selectedOrderSource
              />
            }}
          </div>
        </div>
      </div>
    </div>
  </div>
}
