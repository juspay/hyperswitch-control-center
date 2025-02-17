@react.component
let make = (
  ~currentStep: VerticalStepIndicatorTypes.step,
  ~setCurrentStep,
  ~selectedOrderSource,
  ~setSelectedOrderSource,
) => {
  open ReconConfigurationUtils

  <div className="flex flex-col h-full gap-y-10">
    {switch currentStep.subSectionId->getVariantFromSubsectionString {
    | #selectSource =>
      <ConnectOrderDataHelper.SelectSource
        currentStep={currentStep}
        setCurrentStep={setCurrentStep}
        selectedOrderSource={selectedOrderSource}
        setSelectedOrderSource={setSelectedOrderSource}
      />
    | #setupAPIConnection =>
      <ConnectOrderDataHelper.SetupAPIConnection
        selectedOrderSource={selectedOrderSource}
        currentStep={currentStep}
        setCurrentStep={setCurrentStep}
      />
    | _ => React.null
    }}
  </div>
}
