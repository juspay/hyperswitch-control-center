@react.component
let make = (~currentStep, ~setCurrentStep) => {
  open ReconConfigurationUtils

  let currentStepCount = currentStep->getSectionFromStep->getSectionCount

  <div className="flex flex-col h-full">
    <div className="flex flex-col gap-10 p-2 md:p-6">
      <ReconConfigurationHelper.SubHeading
        currentStepCount
        title="Connect Order Data"
        subTitle="Enable automatic fetching of your order data to ensure seamless transaction matching and reconciliation"
      />
    </div>
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
