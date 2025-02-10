@react.component
let make = () => {
  open ReconConfigurationTypes
  open ConnectOrderDataTypes
  open VerticalStepIndicatorTypes
  open ReconConfigurationUtils

  let (currentStep, setCurrentStep) = React.useState(_ => {
    sectionId: (#connectOrderData: reconConfigurationSections :> string),
    subSectionId: Some((#selectSource: reconConfigurationSubsections :> string)),
  })

  let (selectedOrderSource, setSelectedOrderSource) = React.useState(_ => Hyperswitch)
  let (selectedProcessor, setSelectedProcessor) = React.useState(() => "")
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  let backClick = () => {
    setShowSideBar(prev => !prev)
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recon/onboarding"))
  }

  <div className="flex flex-col gap-10">
    <div className="rounded-lg h-774-px flex flex-col">
      <div className="flex h-full">
        <VerticalStepIndicator title="Setup Reconciliation" currentStep sections backClick />
        <div className="flex-[7] h-full p-12">
          <div className="w-500-px">
            {switch currentStep.sectionId->getVariantFromSectionString {
            | #connectOrderData =>
              <ConnectOrderData
                currentStep={currentStep}
                setCurrentStep={setCurrentStep}
                selectedOrderSource
                setSelectedOrderSource
              />
            | #connectProcessorData =>
              <ConnectProcessorData
                currentStep={currentStep}
                setCurrentStep={setCurrentStep}
                selectedProcessor
                setSelectedProcessor
                selectedOrderSource
              />
            | #reviewDetails =>
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
