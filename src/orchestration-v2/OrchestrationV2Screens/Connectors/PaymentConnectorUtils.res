open PaymentConnectorTypes
open VerticalStepIndicatorTypes

let sections = [
  {
    id: (#authenticateProcessor: paymentConnectorSections :> string),
    name: "Authenticate your processor",
    icon: "nd-shield",
    subSections: None,
  },
  {
    id: (#setupPMTS: paymentConnectorSections :> string),
    name: "Setup Payment Methods",
    icon: "nd-webhook",
    subSections: None,
  },
  {
    id: (#setupWebhook: paymentConnectorSections :> string),
    name: "Setup Webhook",
    icon: "nd-webhook",
    subSections: None,
  },
  {
    id: (#reviewAndConnect: paymentConnectorSections :> string),
    name: "Review and Connect",
    icon: "nd-flag",
    subSections: None,
  },
]

let stringToSectionVariantMapper = string => {
  switch string {
  | "authenticateProcessor" => #authenticateProcessor
  | "setupPMTS" => #setupPMTS
  | "setupWebhook" => #setupWebhook
  | "reviewAndConnect" => #reviewAndConnect
  | _ => #authenticateProcessor
  }
}

let getSectionVariant = ({sectionId}) => {
  switch sectionId {
  | "AuthenticateProcessor" => #AuthenticateProcessor
  | "SetupPmts" => #SetupPmts
  | "SetupWebhook" => #SetupWebhook
  | "ReviewAndConnect" | _ => #ReviewAndConnect
  }
}

let getPaymentConnectorMixPanelEvent = currentStep => {
  switch currentStep->getSectionVariant {
  | #AuthenticateProcessor => "orchestration_v2_onboarding_step1"
  | #SetupPmts => "orchestration_v2_onboarding_step2"
  | #SetupWebhook => "orchestration_v2_onboarding_step3"
  | #ReviewAndConnect => "orchestration_v2_onboarding_step4"
  }
}
