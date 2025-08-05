open VerticalStepIndicatorTypes

@react.component
let make = (~currentStep: step, ~setCurrentStep, ~setShowOnBoarding) => {
  open ReconConfigurationUtils
  open VerticalStepIndicatorUtils
  open Typography

  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let getNextStep = (currentStep: step): option<step> => {
    findNextStep(sections, currentStep)
  }

  let onNextClick = () => {
    switch getNextStep(currentStep) {
    | Some(nextStep) => setCurrentStep(_ => nextStep)
    | None => ()
    }
    setShowSideBar(_ => true)
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recon/overview"))
    setShowOnBoarding(_ => false)
  }

  let customSelectionComponent =
    <>
      <Icon name="nd-tick-circle" customHeight="16" />
      <p className={`${body.sm.regular} leading-5 text-nd_green-600`}>
        {"Completed"->React.string}
      </p>
    </>

  <div className="flex flex-col h-full gap-y-10">
    <div className="flex flex-col h-full gap-y-10">
      <ReconConfigurationHelper.SubHeading
        title="Reconciliation Successful" subTitle="Explore all the Recon metrics in the dashboard"
      />
      <div className="flex flex-col gap-6">
        <ReconConfigurationHelper.StepCard
          key="order_data_successful"
          stepName="Order data connection successful"
          description=""
          isSelected=true
          customSelectionComponent
          iconName="nd-inbox-with-outline"
          onClick={_ => ()}
          customSelectionBorderClass="border-nd_br_gray-500"
        />
        <ReconConfigurationHelper.StepCard
          key="processor_data_sucessful"
          stepName="Processor connection successful"
          description=""
          isSelected=true
          customSelectionComponent
          iconName="nd-plugin-with-outline"
          onClick={_ => ()}
          customSelectionBorderClass="border-nd_br_gray-500"
        />
      </div>
    </div>
    <div className="flex justify-end items-center">
      <Button
        text="Start exploring"
        customButtonStyle="rounded w-full"
        buttonType={Primary}
        buttonState={Normal}
        onClick={_ => {
          mixpanelEvent(~eventName="recon_onboarding_step3")
          onNextClick()->ignore
        }}
      />
    </div>
  </div>
}
