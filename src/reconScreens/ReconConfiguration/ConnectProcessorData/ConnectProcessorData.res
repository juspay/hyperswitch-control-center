@react.component
let make = (
  ~currentStep,
  ~setCurrentStep,
  ~selectedProcessor,
  ~setSelectedProcessor,
  ~selectedOrderSource,
) => {
  open ReconConfigurationUtils
  open VerticalStepIndicatorTypes

  <div className="flex flex-col h-full gap-y-10">
    {switch currentStep.subSectionId->getVariantFromSubsectionString {
    | #apiKeysAndLiveEndpoints =>
      <ConnectProcessorDataHelper.APIKeysAndLiveEndpoints
        currentStep={currentStep}
        setCurrentStep={setCurrentStep}
        selectedProcessor
        setSelectedProcessor
        selectedOrderSource
      />
    | #webHooks =>
      <ConnectProcessorDataHelper.WebHooks
        currentStep={currentStep}
        setCurrentStep={setCurrentStep}
        selectedProcessor
        selectedOrderSource
      />
    | _ => React.null
    }}
  </div>
}
