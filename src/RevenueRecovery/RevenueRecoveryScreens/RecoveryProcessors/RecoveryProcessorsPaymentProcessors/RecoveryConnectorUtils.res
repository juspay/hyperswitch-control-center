let getSectionName = section => {
  switch section {
  | #AuthenticateProcessor => "Authenticate your processor"
  | #SetupPmts => "Setup Payment Methods"
  | #SetupWebhook => "Setup Webhook"
  | #ReviewAndConnect => "Review and Connect"
  }
}

let getSectionIcon = section => {
  switch section {
  | #AuthenticateProcessor => "nd-shield"
  | #SetupPmts => "nd-webhook"
  | #SetupWebhook => "nd-webhook"
  | #ReviewAndConnect => "nd-flag"
  }
}

open VerticalStepIndicatorTypes
open RecoveryConnectorTypes
let sections = [
  {
    id: (#AuthenticateProcessor: sectionType :> string),
    name: #AuthenticateProcessor->getSectionName,
    icon: #AuthenticateProcessor->getSectionIcon,
    subSections: None,
  },
  {
    id: (#SetupPmts: sectionType :> string),
    name: #SetupPmts->getSectionName,
    icon: #SetupPmts->getSectionIcon,
    subSections: None,
  },
  {
    id: (#SetupWebhook: sectionType :> string),
    name: #SetupWebhook->getSectionName,
    icon: #SetupWebhook->getSectionIcon,
    subSections: None,
  },
  {
    id: (#ReviewAndConnect: sectionType :> string),
    name: #ReviewAndConnect->getSectionName,
    icon: #ReviewAndConnect->getSectionIcon,
    subSections: None,
  },
]

let getSectionVariant = ({sectionId}) => {
  switch sectionId {
  | "AuthenticateProcessor" => #AuthenticateProcessor
  | "SetupPmts" => #SetupPmts
  | "SetupWebhook" => #SetupWebhook
  | "ReviewAndConnect" | _ => #ReviewAndConnect
  }
}

let getOptions: array<ConnectorTypes.connectorTypes> => array<
  SelectBox.dropdownOption,
> = dropdownList => {
  open ConnectorUtils
  open ConnectorTypes

  let options: array<SelectBox.dropdownOption> = dropdownList->Array.map((
    connector
  ): SelectBox.dropdownOption => {
    let connectorValue = connector->getConnectorNameString
    let connectorName = switch connector {
    | Processors(connector) => connector->getDisplayNameForProcessor
    | _ => ""
    }

    {
      label: connectorName,
      value: connectorValue,
    }
  })
  options
}

open ConnectorTypes
let recoveryConnectorList: array<connectorTypes> = [Processors(WORLDPAYVANTIV)]

let recoveryConnectorListProd: array<connectorTypes> = [
  Processors(STRIPE),
  Processors(ADYEN),
  Processors(CYBERSOURCE),
  Processors(GLOBEPAY),
  Processors(NOON),
  Processors(BANKOFAMERICA),
]

let recoveryConnectorInHouseList: array<BillingProcessorsUtils.optionType> = [
  {
    name: "Hyperswitch",
    icon: "/assets/Light/hyperswitchLogoIcon.svg",
  },
]
