@react.component
let make = (~currentStep, ~setCurrentStep, ~selectedOrderSource, ~setSelectedOrderSource) => {
  open ReconConfigurationUtils

  <div className="flex flex-col h-full gap-y-10">
    {switch currentStep->getSubsectionFromStep {
    | SelectSource =>
      <ConnectOrderDataHelper.SelectSource
        currentStep={currentStep}
        setCurrentStep={setCurrentStep}
        selectedOrderSource={selectedOrderSource}
        setSelectedOrderSource={setSelectedOrderSource}
      />
    | SetupAPIConnection =>
      <ConnectOrderDataHelper.SetupAPIConnection
        selectedOrderSource={selectedOrderSource}
        currentStep={currentStep}
        setCurrentStep={setCurrentStep}
      />
    | _ => <div />
    }}
  </div>
}
