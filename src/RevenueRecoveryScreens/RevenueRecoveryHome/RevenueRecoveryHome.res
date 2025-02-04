open VerticalStepIndicatorTypes

let sections = [
  {
    id: "connect-processor",
    name: "Connect Processor",
    icon: "nd-inbox",
    subSections: Some([
      {id: "select-processor", name: "Select a Processor"},
      {id: "active-payment-methods", name: "Active Payment Methods"},
      {id: "setup-webhook-processor", name: "Setup Webhook"},
    ]),
  },
  {
    id: "add-a-platform",
    name: "Add a Platform",
    icon: "nd-plugin",
    subSections: Some([
      {id: "select-a-platform", name: "Select a Platform"},
      {id: "configure-retries", name: "Configure Retries"},
      {id: "connect-processor", name: "Connect Processor"},
      {id: "setup-webhook-platform", name: "Setup Webhook"},
    ]),
  },
  {
    id: "review-details",
    name: "Review Details",
    icon: "nd-flag",
    subSections: None,
  },
]

@react.component
let make = () => {
  open VerticalStepIndicatorUtils
  let (currentStep, setNextStep) = React.useState(() => {
    sectionId: "connect-processor",
    subSectionId: Some("select-processor"),
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
    | None => Js.log("No more steps")
    }
  }

  let onPreviousClick = () => {
    switch getPreviousStep(currentStep) {
    | Some(previousStep) => setNextStep(_ => previousStep)
    | None => Js.log("No more steps")
    }
  }

  <div className="flex flex-row">
    <VerticalStepIndicator sections currentStep />
    <div className="flex flex-row gap-x-4">
      <Button text="Previous" onClick={_ => onPreviousClick()->ignore} />
      <Button text="Next" buttonType=Primary onClick={_ => onNextClick()->ignore} />
    </div>
  </div>
}
