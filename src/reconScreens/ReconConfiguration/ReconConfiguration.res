@react.component
let make = () => {
  open ReconConfigurationTypes

  let (currentStep, setCurrentStep) = React.useState(_ => ConnectOrderData(SelectSource))

  <Form>
    <div className="flex flex-col gap-10">
      <div className="bg-white rounded-lg border border-grey-outline h-923-px flex flex-col">
        <ReconConfigurationHelper.Heading title="Reconciliation Setup" />
        <div className="flex justify-center items-center h-full">
          <div className="flex-[3] border-r h-full">
            <div className="flex flex-col">
              <ReconConfigurationHelper.ProgressBar currentStep={currentStep} />
              <div className="h-[1px] bg-gray-200 w-full" />
              <ReconConfigurationHelper.ReconConfigurationCurrentStepIndicator currentStep />
            </div>
          </div>
          <div className="flex-[7] h-full bg-gray-50 flex flex-col justify-between">
            <div className="flex-1">
              {switch currentStep->ReconConfigurationUtils.getSectionFromStep {
              | ConnectOrderData =>
                <ConnectOrderData currentStep={currentStep} setCurrentStep={setCurrentStep} />
              | ConnectProcessorData =>
                <ConnectProcessorData currentStep={currentStep} setCurrentStep={setCurrentStep} />
              | ManualMapping =>
                <ManualMapping currentStep={currentStep} setCurrentStep={setCurrentStep} />
              }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </Form>
}
