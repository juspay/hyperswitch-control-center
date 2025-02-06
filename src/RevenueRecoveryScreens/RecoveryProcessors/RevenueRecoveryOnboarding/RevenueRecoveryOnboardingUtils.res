open VerticalStepIndicatorTypes
open RevenueRecoveryOnboardingTypes

let sections = [
  {
    id: (#connectProcessor: revenueRecoverySections :> string),
    name: "Connect Processor",
    icon: "nd-inbox",
    subSections: Some([
      {id: (#selectProcessor: revenueRecoverySubsections :> string), name: "Select a Processor"},
      {
        id: (#activePaymentMethods: revenueRecoverySubsections :> string),
        name: "Active Payment Methods",
      },
      {id: (#setupWebhookProcessor: revenueRecoverySubsections :> string), name: "Setup Webhook"},
    ]),
  },
  {
    id: (#addAPlatform: revenueRecoverySections :> string),
    name: "Add a Platform",
    icon: "nd-plugin",
    subSections: Some([
      {id: (#selectAPlatform: revenueRecoverySubsections :> string), name: "Select a Platform"},
      {id: (#configureRetries: revenueRecoverySubsections :> string), name: "Configure Retries"},
      {id: (#connectProcessor: revenueRecoverySubsections :> string), name: "Connect Processor"},
      {id: (#setupWebhookPlatform: revenueRecoverySubsections :> string), name: "Setup Webhook"},
    ]),
  },
  {
    id: (#reviewDetails: revenueRecoverySections :> string),
    name: "Review Details",
    icon: "nd-flag",
    subSections: None,
  },
]

let defaultStep = {
  sectionId: (#connectProcessor: revenueRecoverySections :> string),
  subSectionId: Some((#selectProcessor: revenueRecoverySubsections :> string)),
}

open VerticalStepIndicatorUtils
let getNextStep = (currentStep: step): option<step> => {
  findNextStep(sections, currentStep)
}

let getPreviousStep = (currentStep: step): option<step> => {
  findPreviousStep(sections, currentStep)
}

let onNextClick = (currentStep, setNextStep) => {
  switch getNextStep(currentStep) {
  | Some(nextStep) => setNextStep(_ => nextStep)
  | None => ()
  }
}

let onPreviousClick = (currentStep, setNextStep) => {
  switch getPreviousStep(currentStep) {
  | Some(previousStep) => setNextStep(_ => previousStep)
  | None => ()
  }
}

let backClick = () => {
  RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recovery/home"))
}
