open GPayFlowTypes
open LogicUtils

let allowedCardNetworks = ["AMEX", "DISCOVER", "INTERAC", "JCB", "MASTERCARD", "VISA"]

let getCustomGateWayName = connector => {
  open ConnectorUtils
  open ConnectorTypes
  switch connector->getConnectorNameTypeFromString {
  | Processors(CHECKOUT) => "checkoutltd"
  | Processors(NUVEI) => "nuveidigital"
  | Processors(AUTHORIZEDOTNET) => "authorizenet"
  | Processors(GLOBALPAY) => "globalpayments"
  | Processors(BANKOFAMERICA) | Processors(CYBERSOURCE) => "cybersource"
  | Processors(FIUU) => "molpay"
  | Processors(WORLDPAYXML) => "worldpay"
  | _ => connector
  }
}

let tokenizationSpecificationParameters = (
  dict,
  connector,
  ~googlePayIntegrationType: googlePayIntegrationType,
) => {
  open ConnectorUtils
  open ConnectorTypes
  switch googlePayIntegrationType {
  | #payment_gateway =>
    switch connector->getConnectorNameTypeFromString {
    | Processors(STRIPE) => {
        gateway: connector,
        \"stripe:version": dict->getString("stripe:version", "2018-10-31"),
        \"stripe:publishableKey": dict->getString("stripe:publishableKey", ""),
      }
    | _ => {
        gateway: connector->getCustomGateWayName,
        gateway_merchant_id: dict->getString("gateway_merchant_id", ""),
      }
    }
  | #direct => {
      public_key: dict->getString("public_key", ""),
      private_key: dict->getString("private_key", ""),
      recipient_id: dict->getString("recipient_id", ""),
    }
  }
}

let tokenizationSpecification = (
  dict,
  connector,
  ~googlePayIntegrationType: googlePayIntegrationType,
) => {
  {
    \"type": (googlePayIntegrationType :> string)->String.toUpperCase,
    parameters: dict
    ->getDictfromDict("tokenization_specification")
    ->getDictfromDict("parameters")
    ->tokenizationSpecificationParameters(connector, ~googlePayIntegrationType),
  }
}

let merchantInfo = (dict, connector, ~googlePayIntegrationType: googlePayIntegrationType) => {
  {
    merchant_id: googlePayIntegrationType == #payment_gateway
      ? dict->getOptionString("merchant_id")
      : None,
    merchant_name: dict->getOptionString("merchant_name"),
    tokenization_specification: dict->tokenizationSpecification(
      connector,
      ~googlePayIntegrationType,
    ),
  }
}

let googlePay = (
  dict,
  connector: string,
  ~googlePayIntegrationType: GPayFlowTypes.googlePayIntegrationType,
) => {
  {
    provider_details: {
      merchant_info: dict
      ->getDictfromDict("provider_details")
      ->getDictfromDict("merchant_info")
      ->merchantInfo(connector, ~googlePayIntegrationType),
    },
    cards: {
      allowed_auth_methods: dict
      ->getDictfromDict("cards")
      ->getStrArrayFromDict("allowed_auth_methods", []),
      allowed_card_networks: allowedCardNetworks,
    },
  }
}

let isNonEmptyStringWithoutSpaces = str => {
  str->String.trim->isNonEmptyString
}

let validateGooglePay = (values, connector, ~googlePayIntegrationType) => {
  let data =
    values
    ->getDictFromJsonObject
    ->getDictfromDict("connector_wallets_details")
    ->getDictfromDict("google_pay")
    ->googlePay(connector, ~googlePayIntegrationType)

  switch googlePayIntegrationType {
  | #payment_gateway =>
    data.provider_details.merchant_info.merchant_name
    ->Option.getOr("")
    ->isNonEmptyStringWithoutSpaces &&
    data.provider_details.merchant_info.merchant_id
    ->Option.getOr("")
    ->isNonEmptyStringWithoutSpaces &&
    data.cards.allowed_auth_methods->Array.length > 0 &&
    (data.provider_details.merchant_info.tokenization_specification.parameters.\"stripe:publishableKey"
    ->Option.getOr("")
    ->isNonEmptyStringWithoutSpaces ||
      data.provider_details.merchant_info.tokenization_specification.parameters.gateway_merchant_id
      ->Option.getOr("")
      ->isNonEmptyStringWithoutSpaces)
      ? Button.Normal
      : Button.Disabled
  | #direct =>
    data.provider_details.merchant_info.merchant_name
    ->Option.getOr("")
    ->isNonEmptyStringWithoutSpaces &&
    data.cards.allowed_auth_methods->Array.length > 0 &&
    data.provider_details.merchant_info.tokenization_specification.parameters.public_key
    ->Option.getOr("")
    ->isNonEmptyStringWithoutSpaces &&
    data.provider_details.merchant_info.tokenization_specification.parameters.private_key
    ->Option.getOr("")
    ->isNonEmptyStringWithoutSpaces &&
    data.provider_details.merchant_info.tokenization_specification.parameters.recipient_id
    ->Option.getOr("")
    ->isNonEmptyStringWithoutSpaces
      ? Button.Normal
      : Button.Disabled
  }
}

let ignoreDirectFields = ["public_key", "private_key", "recipient_id"]
let directFields = [
  "merchant_name",
  "public_key",
  "private_key",
  "recipient_id",
  "allowed_auth_methods",
]

let getMetadataFromConnectorWalletDetailsGooglePay = (dict, connector) => {
  open ConnectorUtils
  let googlePayDict = dict->getDictfromDict("google_pay")
  let merchantInfoDict =
    googlePayDict->getDictfromDict("provider_details")->getDictfromDict("merchant_info")
  let tokenSpecificationParametersDict =
    merchantInfoDict->getDictfromDict("tokenization_specification")->getDictfromDict("parameters")

  let tokenSpecificationParameters: GPayFlowTypes.tokenizationSpecificationParametersMetadata = switch connector->getConnectorNameTypeFromString {
  | Processors(STRIPE) => {
      gateway: tokenSpecificationParametersDict->getString("gateway", ""),
      \"stripe:version": tokenSpecificationParametersDict->getString(
        "stripe:version",
        "2018-10-31",
      ),
      \"stripe:publishableKey": tokenSpecificationParametersDict->getString(
        "stripe:publishableKey",
        "",
      ),
    }
  | _ => {
      gateway: tokenSpecificationParametersDict->getString("gateway", ""),
      gateway_merchant_id: tokenSpecificationParametersDict->getString("gateway_merchant_id", ""),
    }
  }

  {
    merchant_info: {
      merchant_id: merchantInfoDict->getOptionString("merchant_id"),
      merchant_name: merchantInfoDict->getOptionString("merchant_name"),
    },
    allowed_payment_methods: [
      {
        \"type": "CARD",
        parameters: {
          allowed_auth_methods: googlePayDict
          ->getDictfromDict("cards")
          ->getStrArrayFromDict("allowed_auth_methods", []),
          allowed_card_networks: googlePayDict
          ->getDictfromDict("cards")
          ->getStrArrayFromDict("allowed_card_networks", []),
        },
        tokenization_specification: {
          \"type": "PAYMENT_GATEWAY",
          parameters: tokenSpecificationParameters,
        },
      },
    ],
  }
}

let googlePayNameMapper = (
  ~name,
  ~googlePayIntegrationType: GPayFlowTypes.googlePayIntegrationType,
) => {
  switch googlePayIntegrationType {
  | #payment_gateway =>
    switch name {
    | "merchant_id" => `connector_wallets_details.google_pay.provider_details.merchant_info.${name}`
    | "merchant_name" =>
      `connector_wallets_details.google_pay.provider_details.merchant_info.${name}`
    | "allowed_auth_methods" => `connector_wallets_details.google_pay.cards.${name}`
    | "allowed_card_networks" => `connector_wallets_details.google_pay.cards.${name}`
    | _ =>
      `connector_wallets_details.google_pay.provider_details.merchant_info.tokenization_specification.parameters.${name}`
    }
  | #direct =>
    switch name {
    | "merchant_name" =>
      `connector_wallets_details.google_pay.provider_details.merchant_info.${name}`
    | "allowed_auth_methods" => `connector_wallets_details.google_pay.cards.${name}`
    | "allowed_card_networks" => `connector_wallets_details.google_pay.cards.${name}`
    | _ =>
      `connector_wallets_details.google_pay.provider_details.merchant_info.tokenization_specification.parameters.${name}`
    }
  }
}

let googlePayValueInput = (
  ~googlePayField: CommonConnectorTypes.inputField,
  ~googlePayIntegrationType: GPayFlowTypes.googlePayIntegrationType,
) => {
  open CommonConnectorHelper
  let {\"type", name} = googlePayField
  let formName = googlePayNameMapper(~name, ~googlePayIntegrationType)

  {
    switch \"type" {
    | Text => textInput(~field={googlePayField}, ~formName)
    | Select => selectInput(~field={googlePayField}, ~formName)
    | MultiSelect => multiSelectInput(~field={googlePayField}, ~formName)
    | _ => textInput(~field={googlePayField}, ~formName)
    }
  }
}

let getIntegrationTypeFromConnectorWalletDetailsGooglePay = dict => {
  dict
  ->getDictfromDict("google_pay")
  ->getDictfromDict("provider_details")
  ->getDictfromDict("merchant_info")
  ->getDictfromDict("tokenization_specification")
  ->getString("type", "PAYMENT_GATEWAY")
}

let getGooglePayIntegrationTypeFromName = (name: string) => {
  switch name {
  | "PAYMENT_GATEWAY" => #payment_gateway
  | "DIRECT" => #direct
  | _ => #payment_gateway
  }
}
