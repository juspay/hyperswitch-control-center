@react.component
let make = () => {
  open RevenueRecoveryOnboardingUtils
  open VerticalStepIndicatorTypes
  open VerticalStepIndicatorUtils
  open RevenueRecoveryOnboardingTypes

  let (currentStep, setNextStep) = React.useState(() => {
    sectionId: (#connectProcessor: revenueRecoverySections :> string),
    subSectionId: Some((#selectProcessor: revenueRecoverySubsections :> string)),
  })

  let getNextStep = (currentStep: step): option<step> => {
    findNextStep(sections, currentStep)
  }

  let getPreviousStep = (currentStep: step): option<step> => {
    findPreviousStep(sections, currentStep)
  }

  let onNextClick = () => {
    switch getNextStep(currentStep) {
    | Some(nextStep) => setNextStep(_ => nextStep)
    | None => ()
    }
  }

  let onPreviousClick = () => {
    switch getPreviousStep(currentStep) {
    | Some(previousStep) => setNextStep(_ => previousStep)
    | None => ()
    }
  }

  let backClick = () => {
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recovery/home"))
  }

  <div className="flex flex-row">
    <VerticalStepIndicator title="Setup Recovery" sections currentStep backClick />
    <div className="flex flex-row gap-x-4">
      <Button text="Previous" onClick={_ => onPreviousClick()->ignore} />
      <Button text="Next" buttonType=Primary onClick={_ => onNextClick()->ignore} />
    </div>
  </div>
}
