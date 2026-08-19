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
// processors supported for MIT, offered in both test and live mode
let recoverySupportedConnectors: array<connectorTypes> = [
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

/* ConnectorAuthKeys only stamps auth_type onto connector_account_details when
   updateAccountDetails is set, which it is not in sandbox. Connectors carrying
   dummy data bring their own auth_type; every other one would be submitted
   without it and rejected, so take it from the wasm config. */
let ensureAuthType = (~connectorDetails, ~valuesDict) => {
  open LogicUtils
  let bodyType =
    connectorDetails
    ->getDictFromJsonObject
    ->getDictfromDict("connector_auth")
    ->Dict.keysToArray
    ->getValueFromArray(0, "")

  let accountDetails = valuesDict->getObj("connector_account_details", Dict.make())->Dict.copy

  if bodyType->isNonEmptyString && accountDetails->getString("auth_type", "")->isEmptyString {
    accountDetails->Dict.set("auth_type", bodyType->JSON.Encode.string)
    valuesDict->Dict.set("connector_account_details", accountDetails->JSON.Encode.object)
  }
  valuesDict
}

/* the connector update endpoint accepts a fixed set of fields and rejects
   anything else, so build the body from what it knows rather than stripping
   what it does not - a read response carries more than the write accepts. */
let updatableConnectorFields = [
  "connector_type",
  "connector_label",
  "payment_methods_enabled",
  "connector_webhook_details",
  "metadata",
  "disabled",
  "frm_configs",
  "pm_auth_config",
  "status",
  "additional_merchant_data",
  "connector_wallets_details",
  "feature_metadata",
]

let getUpdatableConnectorBody = (~valuesDict, ~merchantId) => {
  let body = Dict.make()
  updatableConnectorFields->Array.forEach(field => {
    switch valuesDict->Dict.get(field) {
    | Some(value) => body->Dict.set(field, value)
    | None => ()
    }
  })
  body->Dict.set("merchant_id", merchantId->JSON.Encode.string)
  body
}
