open GooglePayIntegrationTypes
open LogicUtils
let allowedAuthMethod = ["PAN_ONLY", "CRYPTOGRAM_3DS"]
let allowedCardNetworks = ["AMEX", "DISCOVER", "INTERAC", "JCB", "MASTERCARD", "VISA"]
let allowedPaymentMethodparameters = {
  allowed_auth_methods: allowedAuthMethod,
  allowed_card_networks: allowedCardNetworks,
}

let getCustomGateWayName = connector => {
  open ConnectorUtils
  open ConnectorTypes
  switch connector->getConnectorNameTypeFromString() {
  | Processors(CHECKOUT) => "checkoutltd"
  | Processors(NUVEI) => "nuveidigital"
  | Processors(AUTHORIZEDOTNET) => "authorizenet"
  | Processors(GLOBALPAY) => "globalpayments"
  | Processors(BANKOFAMERICA) | Processors(CYBERSOURCE) => "cybersource"
  | _ => connector
  }
}

let tokenizationSpecificationParameters = (dict, connector) => {
  open ConnectorUtils
  open ConnectorTypes
  let tokenizationSpecificationDict =
    dict->getDictfromDict("tokenization_specification")->getDictfromDict("parameters")
  switch connector->getConnectorNameTypeFromString() {
  | Processors(STRIPE) => {
      gateway: connector,
      \"stripe:version": tokenizationSpecificationDict->getString("stripe:version", "2018-10-31"),
      \"stripe:publishableKey": tokenizationSpecificationDict->getString(
        "stripe:publishableKey",
        "",
      ),
    }
  | _ => {
      gateway: connector->getCustomGateWayName,
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

let zenGooglePayConfig = dict => {
  Js.log2(dict, "dict")
  {
    terminal_uuid: dict->getString("terminal_uuid", ""),
    pay_wall_secret: dict->getString("pay_wall_secret", ""),
  }
}

let googlePay = (dict, connector: string) => {
  open ConnectorUtils
  open ConnectorTypes
  let merchantInfoDict = dict->getDictfromDict("merchant_info")
  let allowedPaymentMethodDict =
    dict
    ->getArrayFromDict("allowed_payment_methods", [])
    ->Array.get(0)
    ->Option.getOr(Dict.make()->JSON.Encode.object)
    ->getDictFromJsonObject
  let standGooglePayConfig = {
    merchant_info: merchantInfoDict->merchantInfo,
    allowed_payment_methods: [allowedPaymentMethodDict->allowedPaymentMethod(connector)],
  }
  switch connector->getConnectorNameTypeFromString() {
  | Processors(ZEN) => Zen(dict->zenGooglePayConfig)
  | _ => Standard(standGooglePayConfig)
  }
}

let googlePayNameMapper = name => {
  switch name {
  | "merchant_id" => `metadata.google_pay.merchant_info.${name}`
  | "merchant_name" => `metadata.google_pay.merchant_info.${name}`
  | "terminal_uuid" => `metadata.google_pay.${name}`
  | "pay_wall_secret" => `metadata.google_pay.${name}`
  | _ =>
    `metadata.google_pay.allowed_payment_methods[0].tokenization_specification.parameters.${name}`
  }
}
