open VerticalStepIndicatorTypes

@react.component
let make = (~currentStep: step, ~setCurrentStep, ~selectedOrderSource, ~setSelectedOrderSource) => {
  open ReconConfigurationUtils
  open OrderDataConnectionUtils
  open VerticalStepIndicatorUtils

  let getNextStep = (currentStep: step): option<step> => {
    findNextStep(sections, currentStep)
  }

  let onNextClick = () => {
    switch getNextStep(currentStep) {
    | Some(nextStep) => setCurrentStep(_ => nextStep)
    | None => ()
    }
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
      <div className="flex justify-end items-center">
        <Button
          text="Next"
          customButtonStyle="rounded w-full"
          buttonType={Primary}
          buttonState={Normal}
          onClick={_ => onNextClick()->ignore}
        />
      </div>
    </div>
  </div>
}
