open GooglePayIntegrationTypes
open LogicUtils
let allowedAuthMethod = ["PAN_ONLY"]
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

let allowedAuthMethodsArray = dict => {
  let authMethodsArray =
    dict
    ->getDictfromDict("parameters")
    ->getStrArrayFromDict("allowed_auth_methods", allowedAuthMethod)
  authMethodsArray
}

let allowedPaymentMethodparameters = dict => {
  allowed_auth_methods: dict->allowedAuthMethodsArray,
  allowed_card_networks: allowedCardNetworks,
}

let tokenizationSpecificationParameters = (dict, connector) => {
  open ConnectorUtils
  open ConnectorTypes
  let tokenizationSpecificationDict =
    dict->getDictfromDict("tokenization_specification")->getDictfromDict("parameters")
  switch connector->getConnectorNameTypeFromString {
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
  parameters: dict->allowedPaymentMethodparameters,
  tokenization_specification: dict->tokenizationSpecification(connector),
}

let zenGooglePayConfig = dict => {
  {
    terminal_uuid: dict->getString("terminal_uuid", ""),
    pay_wall_secret: dict->getString("pay_wall_secret", ""),
  }
}

let validateZenFlow = values => {
  let data =
    values
    ->getDictFromJsonObject
    ->getDictfromDict("metadata")
    ->getDictfromDict("google_pay")
    ->zenGooglePayConfig
  data.terminal_uuid->isNonEmptyString && data.pay_wall_secret->isNonEmptyString
    ? Button.Normal
    : Button.Disabled
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
  switch connector->getConnectorNameTypeFromString {
  | Processors(ZEN) => Zen(dict->zenGooglePayConfig)
  | _ => Standard(standGooglePayConfig)
  }
}

let googlePayNameMapper = name => {
  switch name {
  | "merchant_id" => `metadata.google_pay.merchant_info.${name}`
  | "merchant_name" => `metadata.google_pay.merchant_info.${name}`
  | "allowed_auth_methods" => `metadata.google_pay.allowed_payment_methods[0].parameters.${name}`
  | "terminal_uuid" => `metadata.google_pay.${name}`
  | "pay_wall_secret" => `metadata.google_pay.${name}`
  | _ =>
    `metadata.google_pay.allowed_payment_methods[0].tokenization_specification.parameters.${name}`
  }
}

let validateGooglePay = (values, connector) => {
  open ConnectorUtils
  open ConnectorTypes
  let googlePayData =
    values
    ->getDictFromJsonObject
    ->getDictfromDict("metadata")
    ->getDictfromDict("google_pay")
  let merchantId = googlePayData->getDictfromDict("merchant_info")->getString("merchant_id", "")
  let merchantName = googlePayData->getDictfromDict("merchant_info")->getString("merchant_name", "")
  let allowedPaymentMethodDict =
    googlePayData
    ->getArrayFromDict("allowed_payment_methods", [])
    ->getValueFromArray(0, JSON.Encode.null)
    ->getDictFromJsonObject
  let allowedAuthMethodsArray =
    allowedPaymentMethodDict
    ->getDictfromDict("parameters")
    ->getArrayFromDict("allowed_auth_methods", [])
  let tokenizationSpecificationDict =
    allowedPaymentMethodDict
    ->getDictfromDict("tokenization_specification")
    ->getDictfromDict("parameters")

  switch connector->getConnectorNameTypeFromString {
  | Processors(ZEN) =>
    googlePayData->getString("terminal_uuid", "")->isNonEmptyString &&
      googlePayData->getString("pay_wall_secret", "")->isNonEmptyString
      ? Button.Normal
      : Button.Disabled
  | Processors(STRIPE) =>
    merchantId->isNonEmptyString &&
    merchantName->isNonEmptyString &&
    tokenizationSpecificationDict->getString("stripe:publishableKey", "")->isNonEmptyString &&
    allowedAuthMethodsArray->Array.length > 0
      ? Button.Normal
      : Button.Disabled
  | Processors(BRAINTREE) =>
    merchantId->isNonEmptyString &&
    merchantName->isNonEmptyString &&
    allowedAuthMethodsArray->Array.length > 0
      ? Button.Normal
      : Button.Disabled
  | _ =>
    merchantId->isNonEmptyString &&
    merchantName->isNonEmptyString &&
    tokenizationSpecificationDict->getString("gateway_merchant_id", "")->isNonEmptyString &&
    allowedAuthMethodsArray->Array.length > 0
      ? Button.Normal
      : Button.Disabled
  }
}

let googlePayValueInput = (~googlePayField: CommonConnectorTypes.inputField) => {
  open CommonConnectorHelper
  let {\"type", name} = googlePayField
  let formName = googlePayNameMapper(name)

  {
    switch \"type" {
    | Text => textInput(~field={googlePayField}, ~formName)
    | Select => selectInput(~field={googlePayField}, ~formName)
    | MultiSelect => multiSelectInput(~field={googlePayField}, ~formName)
    | _ => textInput(~field={googlePayField}, ~formName)
    }
  }
}
