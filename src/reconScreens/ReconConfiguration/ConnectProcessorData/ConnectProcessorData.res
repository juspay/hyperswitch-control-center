@react.component
let make = (
  ~currentStep,
  ~setCurrentStep,
  ~selectedProcessor,
  ~setSelectedProcessor,
  ~selectedOrderSource,
) => {
  open ReconConfigurationUtils

  <div className="flex flex-col h-full gap-y-10">
    {switch currentStep->getSubsectionFromStep {
    | APIKeysAndLiveEndpoints =>
      <ConnectProcessorDataHelper.APIKeysAndLiveEndpoints
        currentStep={currentStep}
        setCurrentStep={setCurrentStep}
        selectedProcessor
        setSelectedProcessor
        selectedOrderSource
      />
    | WebHooks =>
      <ConnectProcessorDataHelper.WebHooks
        currentStep={currentStep}
        setCurrentStep={setCurrentStep}
        selectedProcessor
        selectedOrderSource
      />
    | _ => <div />
    }}
  </div>
}
