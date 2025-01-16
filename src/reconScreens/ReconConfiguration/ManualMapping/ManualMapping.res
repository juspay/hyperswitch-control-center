@react.component
let make = (~currentStep, ~setCurrentStep, ~selectedProcessor) => {
  open ReconConfigurationUtils

  let currentStepCount = currentStep->getSectionFromStep->getSectionCount

  <div className="flex flex-col h-full">
    <div className="flex flex-col gap-10 p-2 md:p-6">
      <ReconConfigurationHelper.SubHeading
        currentStepCount
        title="Manual Mapping"
        subTitle="Map the fields from your order data to the processor data to ensure accurate reconciliation"
      />
    </div>
    {switch currentStep->getSubsectionFromStep {
    | TestLivePayment =>
      <ManualMappingHelper.TestLivePayment
        currentStep={currentStep} setCurrentStep={setCurrentStep} selectedProcessor
      />
    | SetupCompleted =>
      <ManualMappingHelper.SetupCompleted
        currentStep={currentStep} setCurrentStep={setCurrentStep}
      />
    | _ => <div />
    }}
  </div>
}
