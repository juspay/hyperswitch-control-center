@react.component
let make = () => {
  open ReconConfigurationTypes
  open ReconConfigurationUtils

  let (currentStep, setCurrentStep) = React.useState(_ => ConnectOrderData(SelectSource))

  <div className="flex flex-col gap-10">
    <div className="bg-white rounded-xl border border-grey-outline h-screen flex flex-col">
      <ReconConfigurationHelper.Heading title="Reconciliation Setup" />
      <div className="flex justify-center items-center h-full">
        <div className="flex-[3] border-r h-full">
          <div className="flex flex-col">
            <ReconConfigurationHelper.ProgressBar currentStep={currentStep} />
            <div className="h-[1px] bg-gray-200 w-full" />
            <ReconConfigurationHelper.ReconConfigurationCurrentStepIndicator currentStep />
          </div>
        </div>
        <div className="flex-[6] h-full bg-gray-50 flex flex-col items-center justify-center">
          {switch currentStep {
          | ConnectOrderData(SelectSource) => <ConnectOrderData />
          | ConnectOrderData(ConnectionType) => <ConnectOrderData />
          | ConnectProcessorData(_) => <ConnectProcessorData />
          | ManualMapping(_) => <ManualMapping />
          }}
          <Button
            text="Back"
            customButtonStyle="rounded-lg"
            buttonType={Secondary}
            onClick={_ => setCurrentStep(prev => getPreviousStep(prev))}
          />
          <Button
            text="Continue"
            customButtonStyle="rounded-lg"
            buttonType={Primary}
            onClick={_ => setCurrentStep(prev => getNextStep(prev))}
          />
        </div>
      </div>
    </div>
  </div>
}
