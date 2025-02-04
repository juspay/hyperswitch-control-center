open VerticalStepIndicatorTypes

type revenueRecoverySections = [#connectProcessor | #addAPlatform | #reviewDetails]
type revenueRecoverySubsections = [
  | #selectProcessor
  | #activePaymentMethods
  | #setupWebhookProcessor
  | #selectAPlatform
  | #configureRetries
  | #connectProcessor
  | #setupWebhookPlatform
]

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
