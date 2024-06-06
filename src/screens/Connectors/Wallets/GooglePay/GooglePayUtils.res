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
  Js.log(dict)
  switch connector->getConnectorNameTypeFromString() {
  | Processors(STRIPE) => {
      gateway: connector,
      stripe_version: dict->getString("stripe_version", ""),
      stripe_publishableKey: dict->getString("stripe_publishableKey", ""),
    }
  | _ => {
      gateway: connector,
      gateway_merchant_id: dict->getString("stripe_version", ""),
    }
  }
}
let merchantInfo = dict => {
  merchant_id: dict->getOptionString("merchant_id"),
  merchant_name: dict->getOptionString("merchant_name"),
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
  merchant_info: dict->merchantInfo,
  allowed_payment_methods: [dict->allowedPaymentMethod(connector)],
}

let googlePayNameMapper = name => {
  switch name {
  | "merchant_id" => `metadata.google_pay.merchant_info.${name}`
  | "merchant_name" => `metadata.google_pay.merchant_info.${name}`
  | "gateway" =>
    `metadata.google_pay.allowed_payment_methods[0].tokenization_specification.parameters.${name}`
  | "stripe_version" =>
    `metadata.google_pay.allowed_payment_methods[0].tokenization_specification.parameters.${name}`
  | "stripe_publishableKey" =>
    `metadata.google_pay.allowed_payment_methods[0].tokenization_specification.parameters.${name}`
  | _ => ""
  }
}
