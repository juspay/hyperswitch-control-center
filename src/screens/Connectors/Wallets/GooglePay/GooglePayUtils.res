open GooglePayIntegrationTypes
open LogicUtils
let allowedAuthMethod = ["PAN_ONLY", "CRYPTOGRAM_3DS"]
let allowedCardNetworks = ["AMEX", "DISCOVER", "INTERAC", "JCB", "MASTERCARD", "VISA"]
let allowedPaymentMethodparameters = {
  allowed_auth_methods: allowedAuthMethod,
  allowed_card_networks: allowedCardNetworks,
}

let tokenizationSpecificationParameters = (dict, connector) => {
  open ConnectorUtils
  open ConnectorTypes
  Js.log2(connector,"connector")
  let tokenizationSpecificationDict =
    dict->getDictfromDict("tokenization_specification")->getDictfromDict("parameters")
  switch connector->getConnectorNameTypeFromString() {
  | Processors(STRIPE) => {
      gateway: connector,
      stripe_version: tokenizationSpecificationDict->getString("stripe_version", ""),
      stripe_publishableKey: tokenizationSpecificationDict->getString("stripe_publishableKey", ""),
    }
  | _ => {
      gateway: connector,
      gateway_merchant_id: tokenizationSpecificationDict->getString("gateway_merchant_id", ""),
    }
  }
}
let merchantInfo = dict => {
  {
    merchant_id: dict->getOptionString("merchant_id"),
    merchant_name: dict->getOptionString("merchant_name"),
  }
}
let tokenizationSpecification = (dict, connector) => {
  \"type": "PAYMENT_GATEWAY",
  parameters: dict->tokenizationSpecificationParameters(connector),
}

let allowedPaymentMethod = (dict, connector) => {
  \"type": "CARD",
  parameters: allowedPaymentMethodparameters,
  tokenization_specification: dict->tokenizationSpecification(connector),
}

let googlePay = (dict, connector: string) => {
  let merchantInfoDict = dict->getDictfromDict("merchant_info")
  let allowedPaymentMethodDict =
    dict
    ->getArrayFromDict("allowed_payment_methods", [])
    ->Array.get(0)
    ->Option.getOr(Dict.make()->JSON.Encode.object)
    ->getDictFromJsonObject
  {
    merchant_info: merchantInfoDict->merchantInfo,
    allowed_payment_methods: [allowedPaymentMethodDict->allowedPaymentMethod(connector)],
  }
}

let googlePayNameMapper = name => {
  switch name {
  | "merchant_id" => `metadata.google_pay.merchant_info.${name}`
  | "merchant_name" => `metadata.google_pay.merchant_info.${name}`
  | "gateway_merchant_id" =>
    `metadata.google_pay.allowed_payment_methods[0].tokenization_specification.parameters.${name}`
  | "stripe_version" =>
    `metadata.google_pay.allowed_payment_methods[0].tokenization_specification.parameters.${name}`
  | "stripe_publishableKey" =>
    `metadata.google_pay.allowed_payment_methods[0].tokenization_specification.parameters.${name}`
  | _ => ""
  }
}
let inputTypeMapperr = ipType => {
  switch ipType {
  | "Text" => Text
  | "Toggle" => Toggle
  | "Select" => Select
  | _ => Text
  }
}

let inputFieldMapper = dict => {
  {
    name: dict->getString("name", ""),
    label: dict->getString("label", ""),
    placeholder: dict->getString("placeholder", ""),
    required: dict->getBool("required", true),
    options: dict->getStrArray("options"),
    \"type": dict->getString("type", "")->inputTypeMapperr,
  }
}
