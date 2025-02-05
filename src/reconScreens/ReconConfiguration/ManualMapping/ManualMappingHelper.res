open VerticalStepIndicatorTypes
open VerticalStepIndicatorUtils

module TestLivePayment = {
  @react.component
  let make = (~currentStep: step, ~setCurrentStep, ~selectedProcessor, ~selectedOrderSource) => {
    open ReconConfigurationUtils
    open TempAPIUtils
    open ConnectOrderDataTypes

    let stepConfig = useStepConfig()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
    let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

    let getNextStep = (currentStep: step): option<step> => {
      findNextStep(sections, currentStep)
    }

    let onNextClick = () => {
      switch getNextStep(currentStep) {
      | Some(nextStep) => setCurrentStep(_ => nextStep)
      | None => ()
      }
    }

    let onDummySubmit = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let _ = await stepConfig(
          ~step=currentStep.subSectionId->getVariantFromSubsectionString,
          ~selectedOrderSource,
          ~paymentEntity=selectedProcessor->String.toUpperCase,
        )
        onNextClick()
      } catch {
      | Exn.Error(e) =>
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
    }

    let onSubmit = async () => {
      setShowSideBar(prev => !prev)
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recon/reports"))
    }

    <PageLoaderWrapper screenState={screenState}>
      <div className="flex flex-col h-full">
        {switch selectedOrderSource {
        | Hyperswitch =>
          <div className="flex justify-end items-center mt-10">
            <Button
              text="Go to Reports"
              customButtonStyle="rounded w-full"
              buttonType={Primary}
              onClick={_ => onSubmit()->ignore}
            />
          </div>
        | OrderManagementSystem =>
          <div className="flex justify-end items-center mt-10">
            <Button
              text="Proceed"
              customButtonStyle="rounded w-full"
              buttonType={Primary}
              onClick={_ => onDummySubmit()->ignore}
            />
          </div>
        | Dummy =>
          <div className="flex justify-end items-center mt-10">
            <Button
              text="Proceed"
              customButtonStyle="rounded w-full"
              buttonType={Primary}
              onClick={_ => onDummySubmit()->ignore}
            />
          </div>
        }}
      </div>
    </PageLoaderWrapper>
  }
}

module SetupCompleted = {
  @react.component
  let make = () => {
    let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

    let onSubmit = async () => {
      setShowSideBar(prev => !prev)
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recon/reports"))
    }

    <div className="flex flex-col h-full gap-4">
      <div className="flex flex-col gap-4 mt-10">
        <p className="text-medium text-grey-800 font-semibold">
          {"Setup Completed"->React.string}
        </p>
      </div>
      <div className="flex justify-end items-center">
        <Button
          text="Go to Reports"
          customButtonStyle="rounded w-full"
          buttonType={Primary}
          onClick={_ => onSubmit()->ignore}
        />
      </div>
    </div>
  }
}
