open RevenueRecoveryOnboardingTypes

let getMainStepName = step => {
  switch step {
  | #chooseDataSource => "Choose Your Data Source"
  | #connectProcessor => "Connect Processor"
  | #addAPlatform => "Add a Platform"
  | #reviewDetails => "Review Details"
  }
}

let getStepName = (step: revenueRecoverySubsections) => {
  switch step {
  | #selectProcessor => "Select a Processor"
  | #activePaymentMethods => "Active Payment Methods"
  | #selectAPlatform => "Select a Platform"
  | #processorSetUp => "Billing Processor Set-up"
  }
}

let getIcon = step => {
  switch step {
  | #chooseDataSource => "nd-shield"
  | #connectProcessor => "nd-inbox"
  | #addAPlatform => "nd-plugin"
  | #reviewDetails => "nd-flag"
  }
}

open VerticalStepIndicatorTypes
let getSections = isLiveMode => {
  let platformSubsectionsDefaultSteps = [
    {
      id: (#selectAPlatform: revenueRecoverySubsections :> string),
      name: #selectAPlatform->getStepName,
    },
  ]

  if !isLiveMode {
    platformSubsectionsDefaultSteps->Array.push({
      id: (#processorSetUp: revenueRecoverySubsections :> string),
      name: #processorSetUp->getStepName,
    })
  }

  let defaultSteps = [
    {
      id: (#connectProcessor: revenueRecoverySections :> string),
      name: #connectProcessor->getMainStepName,
      icon: #connectProcessor->getIcon,
      subSections: Some([
        {
          id: (#selectProcessor: revenueRecoverySubsections :> string),
          name: #selectProcessor->getStepName,
        },
      ]),
    },
    {
      id: (#addAPlatform: revenueRecoverySections :> string),
      name: #addAPlatform->getMainStepName,
      icon: #addAPlatform->getIcon,
      subSections: Some(platformSubsectionsDefaultSteps),
    },
    {
      id: (#reviewDetails: revenueRecoverySections :> string),
      name: #reviewDetails->getMainStepName,
      icon: #reviewDetails->getIcon,
      subSections: None,
    },
  ]

  if !isLiveMode {
    defaultSteps->Array.unshift({
      id: (#chooseDataSource: revenueRecoverySections :> string),
      name: #chooseDataSource->getMainStepName,
      icon: #chooseDataSource->getIcon,
      subSections: None,
    })
  }

  defaultSteps
}

let getDefaultStep = isLiveMode => {
  if isLiveMode {
    {
      sectionId: (#connectProcessor: revenueRecoverySections :> string),
      subSectionId: (#selectProcessor: revenueRecoverySubsections :> string)->Some,
    }
  } else {
    {
      sectionId: (#chooseDataSource: revenueRecoverySections :> string),
      subSectionId: None,
    }
  }
}

let defaultStepBilling = {
  sectionId: (#addAPlatform: revenueRecoverySections :> string),
  subSectionId: Some((#selectAPlatform: revenueRecoverySubsections :> string)),
}

open VerticalStepIndicatorUtils
let getNextStep = (currentStep: step, isLiveMode): option<step> => {
  findNextStep(getSections(isLiveMode), currentStep)
}

let getPreviousStep = (currentStep: step, isLiveMode): option<step> => {
  findPreviousStep(getSections(isLiveMode), currentStep)
}

let onNextClick = (currentStep, setNextStep, isLiveMode) => {
  switch getNextStep(currentStep, isLiveMode) {
  | Some(nextStep) => setNextStep(_ => nextStep)
  | None => ()
  }
}

let onPreviousClick = (currentStep, setNextStep, isLiveMode) => {
  switch getPreviousStep(currentStep, isLiveMode) {
  | Some(previousStep) => setNextStep(_ => previousStep)
  | None => ()
  }
}

let getSectionVariant = ({sectionId, subSectionId}) => {
  let mainSection = switch sectionId {
  | "chooseDataSource" => #chooseDataSource
  | "connectProcessor" => #connectProcessor
  | "addAPlatform" => #addAPlatform
  | "reviewDetails" | _ => #reviewDetails
  }

  let subSection: revenueRecoverySubsections = switch subSectionId {
  | Some("selectProcessor") => #selectProcessor
  | Some("activePaymentMethods") => #activePaymentMethods
  | Some("selectAPlatform") => #selectAPlatform
  | Some("processorSetUp") | _ => #processorSetUp
  }

  (mainSection, subSection)
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
let billingConnectorList: array<connectorTypes> = [
  BillingProcessor(CHARGEBEE),
  BillingProcessor(CUSTOMBILLING),
]

let prodBillingConnectorList: array<connectorTypes> = [BillingProcessor(CUSTOMBILLING)]

let billingConnectorProdList: array<BillingProcessorsUtils.optionType> = [
  {
    name: "Recurly",
    icon: "/assets/recurly-logo.png",
  },
  {
    name: "Recharge",
    icon: "/assets/recharge-logo.png",
  },
  {
    name: "Zoura",
    icon: "/assets/zoura-logo.png",
  },
  {
    name: "Stripe Billing",
    icon: "/Gateway/STRIPEBILLING.svg",
  },
]

let billingConnectorInHouseList: array<BillingProcessorsUtils.optionType> = [
  {
    name: "Kill Bill",
    icon: "/assets/kill_bill-logo.png",
  },
]

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
  | (#connectProcessor, #selectProcessor) => "recovery_payment_processor"
  | (#connectProcessor, #activePaymentMethods) => "recovery_processor_active_payment_method"
  | (#addAPlatform, #selectAPlatform) => "recovery_billing_processor"
  | (#addAPlatform, #processorSetUp) => "recovery_billing_processor_set_up"
  | _ => ""
  }
}
