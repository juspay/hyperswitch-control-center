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
      {
        id: (#setupWebhookProcessor: revenueRecoverySubsections :> string),
        name: #setupWebhookProcessor->getStepName,
      },
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
      {
        id: (#configureRetries: revenueRecoverySubsections :> string),
        name: #configureRetries->getStepName,
      },
      {
        id: (#connectProcessor: revenueRecoverySubsections :> string),
        name: #connectProcessor->getStepName,
      },
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
  sectionId: (#connectProcessor: revenueRecoverySections :> string),
  subSectionId: Some((#selectProcessor: revenueRecoverySubsections :> string)),
}

let defaultStepBilling = {
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

let getSectionVariant = ({sectionId, subSectionId}) => {
  let mainSection = switch sectionId {
  | "connectProcessor" => #connectProcessor
  | "addAPlatform" => #addAPlatform
  | "reviewDetails" | _ => #reviewDetails
  }

  let subSection = switch subSectionId {
  | Some("selectProcessor") => #selectProcessor
  | Some("activePaymentMethods") => #activePaymentMethods
  | Some("setupWebhookProcessor") => #setupWebhookProcessor
  | Some("selectAPlatform") => #selectAPlatform
  | Some("configureRetries") => #configureRetries
  | Some("connectProcessor") => #connectProcessor
  | Some("setupWebhookPlatform") | _ => #setupWebhookPlatform
  }

  (mainSection, subSection)
}

let sampleDataBanner =
  <div
    className="absolute z-10 top-76-px left-0 w-full py-4 px-10 bg-orange-50 flex justify-between items-center">
    <div className="flex gap-4 items-center">
      <Icon name="nd-information-triangle" size=24 />
      <p className="text-nd_gray-600 text-base leading-6 font-medium">
        {"You are in demo environment and this is sample setup."->React.string}
      </p>
    </div>
  </div>

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

let getOptions: array<ConnectorTypes.connectorTypes> => array<
  SelectBox.dropdownOption,
> = dropdownList => {
  open ConnectorUtils

  let options: array<SelectBox.dropdownOption> = dropdownList->Array.map((
    connector
  ): SelectBox.dropdownOption => {
    let connectorValue = connector->getConnectorNameString
    let connectorName = switch connector {
    | BillingProcessor(processor) => processor->getDisplayNameForBillingProcessor
    | Processors(processor) => processor->getDisplayNameForProcessor
    | _ => ""
    }

    {
      label: connectorName,
      customRowClass: "my-1",
      value: connectorValue,
      icon: Button.CustomIcon(
        <GatewayIcon gateway={connectorValue->String.toUpperCase} className="mr-2 w-5 h-5" />,
      ),
    }
  })
  options
}

let getMixpanelEventName = currentStep => {
  switch currentStep->getSectionVariant {
  | (#connectProcessor, #selectProcessor) => "recovery_payment_processor_step1"
  | (#connectProcessor, #activePaymentMethods) => "recovery_payment_processor_step2"
  | (#connectProcessor, #setupWebhookProcessor) => "recovery_payment_processor_step3"
  | (#addAPlatform, #selectAPlatform) => "recovery_billing_processor_step1"
  | (#addAPlatform, #configureRetries) => "recovery_billing_processor_step2"
  | (#addAPlatform, #connectProcessor) => "recovery_billing_processor_step3"
  | (#addAPlatform, #setupWebhookPlatform) => "recovery_billing_processor_step4"
  | _ => ""
  }
}
