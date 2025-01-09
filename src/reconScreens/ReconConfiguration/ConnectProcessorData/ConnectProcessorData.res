@react.component
let make = (~currentStep, ~setCurrentStep) => {
  open ReconConfigurationUtils

  let currentStepCount = currentStep->getSectionFromStep->getSectionCount

  <div className="flex flex-col h-full">
    <div className="flex flex-col gap-10 p-2 md:p-7">
      <ReconConfigurationHelper.SubHeading
        currentStepCount
        title="Connect Processor Data"
        subTitle="Select the processor you want to connect to and configure the data fetching process"
      />
    </div>
    {switch currentStep->getSubsectionFromStep {
    | APIKeysAndLiveEndpoints =>
      <ConnectProcessorDataHelper.APIKeysAndLiveEndpoints
        currentStep={currentStep} setCurrentStep={setCurrentStep}
      />
    | WebHooks =>
      <ConnectProcessorDataHelper.WebHooks
        currentStep={currentStep} setCurrentStep={setCurrentStep}
      />
    | _ => <div />
    }}
  </div>
}
