@react.component
let make = (~currentStep, ~setCurrentStep, ~selectedProcessor, ~selectedOrderSource) => {
  open ReconConfigurationUtils
  open ConnectOrderDataTypes
  open VerticalStepIndicatorTypes

  <div className="flex flex-col h-full">
    {switch selectedOrderSource {
    | Hyperswitch =>
      <div className="flex flex-col gap-10">
        <ReconConfigurationHelper.SubHeading
          title="Recon Setup is complete"
          subTitle="You have successfully connected to Hyperswitch and PSP"
        />
      </div>
    | Dummy =>
      <div className="flex flex-col gap-10">
        <ReconConfigurationHelper.SubHeading
          title="Run Recon" subTitle="Run Recon to view the reports"
        />
      </div>
    | OrderManagementSystem =>
      <div className="flex flex-col gap-10">
        <ReconConfigurationHelper.SubHeading
          title="Run Recon" subTitle="Run Recon to view the reports"
        />
      </div>
    }}
    {switch currentStep.subSectionId->getVariantFromSubsectionString {
    | #testLivePayment =>
      <ManualMappingHelper.TestLivePayment
        currentStep={currentStep}
        setCurrentStep={setCurrentStep}
        selectedProcessor
        selectedOrderSource
      />
    | #setupCompleted => <ManualMappingHelper.SetupCompleted />
    | _ => React.null
    }}
  </div>
}
