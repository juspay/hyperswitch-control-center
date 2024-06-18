open ApplePayIntegrationTypesV2
open LogicUtils
let paymentRequest = {
  label: "apple",
  supported_networks: ["visa", "masterCard", "amex", "discover"],
  merchant_capabilities: ["supports3DS"],
}

let sessionToken = (dict): sessionTokenData => {
  let sessionTokenDict = dict->getDictfromDict("manual")->getDictfromDict("session_token_data")
  {
    initiative: sessionTokenDict->getOptionString("initiative"),
    certificate: sessionTokenDict->getOptionString("certificate"),
    display_name: sessionTokenDict->getOptionString("display_name"),
    certificate_keys: sessionTokenDict->getOptionString("certificate_keys"),
    initiative_context: sessionTokenDict->getOptionString("initiative_context"),
    merchant_identifier: sessionTokenDict->getOptionString("merchant_identifier"),
    merchant_business_country: sessionTokenDict->getOptionString("merchant_business_country"),
    payment_processing_details_at: sessionTokenDict->getOptionString(
      "payment_processing_details_at",
    ),
    payment_processing_certificate: sessionTokenDict->getOptionString(
      "payment_processing_certificate",
    ),
    payment_processing_certificate_key: sessionTokenDict->getOptionString(
      "payment_processing_certificate_key",
    ),
  }
}

let sessionTokenSimplified = (dict): sessionTokenSimplified => {
  let sessionTokenDict = dict->getDictfromDict("simple")->getDictfromDict("session_token_data")
  {
    initiative_context: sessionTokenDict->getOptionString("initiative_context"),
    merchant_business_country: sessionTokenDict->getOptionString("merchant_business_country"),
  }
}
let manual = (dict): manual => {
  {
    session_token_data: dict->sessionToken,
    payment_request_data: paymentRequest,
  }
}

let simple = (dict): simple => {
  {
    session_token_data: dict->sessionTokenSimplified,
    payment_request_data: paymentRequest,
  }
}

let applePay = (dict, applePayIntegrationType: applePayIntegrationType) => {
  let data: applePayConfig = switch applePayIntegrationType {
  | #manual => #manual(dict->manual)
  | #simplified => #simplified(dict->simple)
  }
  let dict = Dict.make()
  let _ = switch data {
  | #manual(data) => dict->Dict.set("manual", data->Identity.genericTypeToJson)
  | #simplified(data) => dict->Dict.set("simple", data->Identity.genericTypeToJson)
  }

  let applePay = {
    apple_pay_combined: dict->JSON.Encode.object,
  }
  applePay
}

let applePayNameMapper = (~name, ~integrationType: applePayIntegrationType) => {
  switch name {
  | _ =>
    `metadata.apple_pay.apple_pay_combined.${(integrationType: applePayIntegrationType :> string)}.session_token_data.${name}`
  }
}

let paymentProcessingMapper = state => {
  switch state->String.toLowerCase {
  | "connector" => #Connector
  | "hyperswitch" => #Hyperswitch
  | _ => #Connector
  }
}
