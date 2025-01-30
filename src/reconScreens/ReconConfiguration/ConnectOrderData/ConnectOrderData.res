@react.component
let make = (~currentStep, ~setCurrentStep) => {
  open ReconConfigurationUtils

  <div className="flex flex-col h-full gap-y-10">
    {switch currentStep->getSubsectionFromStep {
    | SelectSource =>
      <ConnectOrderDataHelper.SelectSource
        currentStep={currentStep} setCurrentStep={setCurrentStep}
      />
    | SetupAPIConnection =>
      <ConnectOrderDataHelper.SetupAPIConnection
        currentStep={currentStep} setCurrentStep={setCurrentStep}
      />
    | _ => <div />
    }}
  </div>
}
