open VerticalStepIndicatorTypes

@react.component
let make = (~currentStep: step, ~setCurrentStep, ~selectedOrderSource, ~setSelectedOrderSource) => {
  open APIUtils
  open ReconConfigurationUtils
  open OrderDataConnectionUtils
  open VerticalStepIndicatorUtils

  let mixpanelEvent = MixpanelHook.useSendEvent()
  let updateDetails = useUpdateMethod()
  let getURL = useGetURL()
  let showToast = ToastState.useShowToast()

  let getNextStep = (currentStep: step): option<step> => {
    findNextStep(sections, currentStep)
  }

  let onNextClick = async () => {
    try {
      let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
      let body = getRequestBody(~isOrderDataSet=true, ~isProcessorDataSet=false)

      let _ = await updateDetails(url, body->Identity.genericTypeToJson, Post)
      switch getNextStep(currentStep) {
      | Some(nextStep) => setCurrentStep(_ => nextStep)
      | None => ()
      }
    } catch {
    | Exn.Error(_err) =>
      showToast(~message="Something went wrong. Please try again", ~toastType=ToastError)
    }
  }

  let onSubmit = async () => {
    mixpanelEvent(~eventName="recon_onboarding_step1")
    let _ = await onNextClick()
  }

  <div className="flex flex-col h-full gap-y-10">
    <ReconConfigurationHelper.SubHeading
      title="Connect Order Data Source"
      subTitle="Link your order data source to streamline the reconciliation process"
    />
    <div className="flex flex-col h-full gap-y-10">
      <div className="flex flex-col gap-y-4">
        <p className="text-sm text-nd_gray-700 font-semibold">
          {"Where do you want to fetch your data from?"->React.string}
        </p>
        <div className="flex flex-col gap-y-4">
          {orderDataStepsArr
          ->Array.map(step => {
            let stepName = step->getSelectedStepName
            let description = step->getSelectedStepDescription
            let isSelected = selectedOrderSource === step
            <ReconConfigurationHelper.StepCard
              key={stepName}
              stepName={stepName}
              description={description}
              isSelected={isSelected}
              iconName={step->getIconName}
              onClick={_ => setSelectedOrderSource(_ => step)}
              customSelectionComponent={<Icon name="nd-checkbox-base" customHeight="16" />}
              isDisabled={step->isDisabled}
            />
          })
          ->React.array}
        </div>
      </div>
      <div className="flex justify-end items-center mx-0.5">
        <Button
          text="Next"
          customButtonStyle="rounded w-full"
          buttonType={Primary}
          buttonState={Normal}
          onClick={_ => onSubmit()->ignore}
        />
      </div>
    </div>
  </div>
}
