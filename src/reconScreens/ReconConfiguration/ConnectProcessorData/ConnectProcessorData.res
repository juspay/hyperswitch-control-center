@react.component
let make = (~currentStep, ~setCurrentStep, ~selectedProcessor, ~setSelectedProcessor) => {
  open ReconConfigurationUtils

  <div className="flex flex-col h-full gap-y-10">
    {switch currentStep->getSubsectionFromStep {
    | APIKeysAndLiveEndpoints =>
      <ConnectProcessorDataHelper.APIKeysAndLiveEndpoints
        currentStep={currentStep}
        setCurrentStep={setCurrentStep}
        selectedProcessor
        setSelectedProcessor
      />
    | WebHooks =>
      <ConnectProcessorDataHelper.WebHooks
        currentStep={currentStep} setCurrentStep={setCurrentStep} selectedProcessor
      />
    | _ => <div />
    }}
  </div>
}
