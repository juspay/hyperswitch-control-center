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
let recoveryConnectorList: array<connectorTypes> = [Processors(STRIPE), Processors(WORLDPAYVANTIV)]

// processors the backend supports for MIT in live mode
let recoveryConnectorProdList: array<connectorTypes> = [
  Processors(ACI),
  Processors(ADYEN),
  Processors(AIRWALLEX),
  Processors(ARCHIPEL),
  Processors(AUTHORIZEDOTNET),
  Processors(BAMBORA_APAC),
  Processors(BANKOFAMERICA),
  Processors(BRAINTREE),
  Processors(CHECKOUT),
  Processors(CYBERSOURCE),
  Processors(DEUTSCHEBANK),
  Processors(ELAVON),
  Processors(FINIX),
  Processors(FISERVCOMMERCEHUB),
  Processors(FIUU),
  Processors(GIVEPAYMENTS),
  Processors(GLOBALPAY),
  Processors(GOCARDLESS),
  Processors(HELCIM),
  Processors(IMERCHANTSOLUTIONS),
  Processors(MOLLIE),
  Processors(MONERIS),
  Processors(MULTISAFEPAY),
  Processors(NEXINETS),
  Processors(NEXIXPAY),
  Processors(NMI),
  Processors(NOON),
  Processors(NOVALNET),
  Processors(NUVEI),
  Processors(PAYBOX),
  Processors(PAYLOAD),
  Processors(PAYME),
  Processors(PAYPAL),
  Processors(PAYSAFE),
  Processors(REVOLV3),
  Processors(SANTANDER),
  Processors(STRIPE),
  Processors(TESOURO),
  Processors(TSYSTRANSIT),
  Processors(WELLSFARGO),
  Processors(WORLDPAY),
  Processors(WORLDPAYMODULAR),
  Processors(WORLDPAYVANTIV),
  Processors(WORLDPAYXML),
  Processors(XENDIT),
  Processors(ZIFT),
]

let recoveryConnectorListProd: array<connectorTypes> = [
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
