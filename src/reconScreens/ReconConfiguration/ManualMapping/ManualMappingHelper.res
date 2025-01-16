module TestLivePayment = {
  @react.component
  let make = (~currentStep, ~setCurrentStep, ~selectedProcessor) => {
    open ReconConfigurationUtils
    open TempAPIUtils

    let stepConfig = useStepConfig(
      ~step=currentStep->getSubsectionFromStep,
      ~paymentEntity=selectedProcessor->String.toUpperCase,
    )
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

    let onSubmit = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let _ = await stepConfig()
        setCurrentStep(prev => getNextStep(prev))
      } catch {
      | Exn.Error(e) =>
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
    }

    <PageLoaderWrapper screenState={screenState}>
      <div className="flex flex-col h-full">
        <div className="flex flex-col gap-4 flex-grow p-2 md:p-7">
          <p className="text-medium text-grey-800 font-semibold mb-5">
            {"Test Live Payment"->React.string}
          </p>
          <Button
            text="Run Recon"
            customButtonStyle="rounded w-90-px"
            buttonType={Primary}
            onClick={_ => onSubmit()->ignore}
          />
        </div>
        <div className="flex justify-end items-center border-t">
          <ReconConfigurationHelper.Footer
            currentStep={currentStep}
            buttonName="Continue"
            onSubmit={_ => setCurrentStep(prev => prev->getNextStep)}
          />
        </div>
      </div>
    </PageLoaderWrapper>
  }
}

module SetupCompleted = {
  @react.component
  let make = (~currentStep, ~setCurrentStep) => {
    open ReconConfigurationUtils

    <div className="flex flex-col h-full">
      <div className="flex flex-col gap-4 flex-grow p-2 md:p-7">
        <p className="text-medium text-grey-800 font-semibold mb-5">
          {"Setup Completed"->React.string}
        </p>
      </div>
      <div className="flex justify-end items-center border-t">
        <ReconConfigurationHelper.Footer
          currentStep={currentStep}
          buttonName="Continue"
          onSubmit={_ => setCurrentStep(prev => prev->getNextStep)}
        />
      </div>
    </div>
  }
}
