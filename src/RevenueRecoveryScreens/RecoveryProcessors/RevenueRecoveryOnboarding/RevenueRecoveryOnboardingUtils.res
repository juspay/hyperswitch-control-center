open VerticalStepIndicatorTypes
open RevenueRecoveryOnboardingTypes

let getMainStepName = step => {
  switch step {
  | #connectProcessor => "Connect Processor"
  | #addAPlatform => "Add a Platform"
  | #reviewDetails => "Review Details"
  }
}

let getStepName = step => {
  switch step {
  | #selectProcessor => "Select a Processor"
  | #activePaymentMethods => "Active Payment Methods"
  | #setupWebhookProcessor => "Setup Webhook"
  | #selectAPlatform => "Select a Platform"
  | #configureRetries => "Configure Retries"
  | #connectProcessor => "Connect Processor"
  | #setupWebhookPlatform => "Setup Webhook"
  }
}

let getIcon = step => {
  switch step {
  | #connectProcessor => "nd-inbox"
  | #addAPlatform => "nd-plugin"
  | #reviewDetails => "nd-flag"
  }
}

let sections = [
  {
    id: (#connectProcessor: revenueRecoverySections :> string),
    name: #connectProcessor->getMainStepName,
    icon: #connectProcessor->getIcon,
    subSections: Some([
      {
        id: (#selectProcessor: revenueRecoverySubsections :> string),
        name: #selectProcessor->getStepName,
      },
      // {
      //   id: (#activePaymentMethods: revenueRecoverySubsections :> string),
      //   name: #activePaymentMethods->getStepName,
      // },
      // {
      //   id: (#setupWebhookProcessor: revenueRecoverySubsections :> string),
      //   name: #setupWebhookProcessor->getStepName,
      // },
    ]),
  },
  {
    id: (#addAPlatform: revenueRecoverySections :> string),
    name: #addAPlatform->getMainStepName,
    icon: #addAPlatform->getIcon,
    subSections: Some([
      {
        id: (#selectAPlatform: revenueRecoverySubsections :> string),
        name: #selectAPlatform->getStepName,
      },
      // {
      //   id: (#configureRetries: revenueRecoverySubsections :> string),
      //   name: #configureRetries->getStepName,
      // },
      // {
      //   id: (#connectProcessor: revenueRecoverySubsections :> string),
      //   name: #connectProcessor->getStepName,
      // },
      {
        id: (#setupWebhookPlatform: revenueRecoverySubsections :> string),
        name: #setupWebhookPlatform->getStepName,
      },
    ]),
  },
  {
    id: (#reviewDetails: revenueRecoverySections :> string),
    name: #reviewDetails->getMainStepName,
    icon: #reviewDetails->getIcon,
    subSections: None,
  },
]

let defaultStep = {
  sectionId: (#addAPlatform: revenueRecoverySections :> string),
  subSectionId: Some((#selectAPlatform: revenueRecoverySubsections :> string)),
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

module PageWrapper = {
  @react.component
  let make = (~title, ~subTitle, ~children) => {
    <div className="flex flex-col gap-7">
      <PageUtils.PageHeading
        title subTitle customSubTitleStyle="font-500 font-normal text-nd_gray-700"
      />
      {children}
    </div>
  }
}

open ConnectorTypes
let billingConnectorList: array<connectorTypes> = [BillingProcessor(CHARGEBEE)]
