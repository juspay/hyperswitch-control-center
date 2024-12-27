@react.component
let make = () => {
  open ReconConfigurationTypes
  open ReconConfigurationUtils
  let (currentStep, setCurrentStep) = React.useState(_ => ConnectOrderData)
  <div className="flex flex-col gap-10">
    <ReconConfigurationHelper.ReconConfigurationCurrentStepIndicator currentStep stepsArr />
    <div className="bg-white rounded-xl border overflow-scroll border-grey-outline">
      {switch currentStep {
      | ConnectOrderData => <ConnectOrderData setCurrentStep />
      | ConnectProcessorData => <ConnectProcessorData setCurrentStep />
      | ConnectSettlementData => <ConnectSettlementData setCurrentStep />
      | ScheduleReconReports => <ScheduleReconReports setCurrentStep />
      }}
    </div>
    
  </div>
}
