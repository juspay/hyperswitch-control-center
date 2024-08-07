open ApplePayIntegrationTypes
open LogicUtils
let paymentRequest = (dict, integrationType) => {
  let paymentRequestDict =
    dict
    ->getDictfromDict((integrationType: applePayIntegrationType :> string))
    ->getDictfromDict("payment_request_data")
  let sessionTokenDict =
    dict
    ->getDictfromDict((integrationType: applePayIntegrationType :> string))
    ->getDictfromDict("session_token_data")
  {
    label: sessionTokenDict->getString("display_name", "apple"),
    supported_networks: paymentRequestDict->getStrArrayFromDict(
      "supported_networks",
      ["visa", "masterCard", "amex", "discover"],
    ),
    merchant_capabilities: paymentRequestDict->getStrArrayFromDict(
      "merchant_capabilities",
      ["supports3DS"],
    ),
  }
}

let sessionToken = (dict): sessionTokenData => {
  let sessionTokenDict =
    dict
    ->getDictfromDict((#manual: applePayIntegrationType :> string))
    ->getDictfromDict("session_token_data")
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
  let sessionTokenDict =
    dict
    ->getDictfromDict((#simplified: applePayIntegrationType :> string))
    ->getDictfromDict("session_token_data")
  {
    initiative_context: sessionTokenDict->getOptionString("initiative_context"),
    merchant_business_country: sessionTokenDict->getOptionString("merchant_business_country"),
  }
}
let manual = (dict): manual => {
  {
    session_token_data: dict->sessionToken,
    payment_request_data: dict->paymentRequest(#manual),
  }
}

let simplified = (dict): simplified => {
  {
    session_token_data: dict->sessionTokenSimplified,
    payment_request_data: dict->paymentRequest(#simplified),
  }
}

let zenApplePayConfig = dict => {
  {
    terminal_uuid: dict->getOptionString("terminal_uuid"),
    pay_wall_secret: dict->getOptionString("pay_wall_secret"),
  }
}

let applePayCombined = (dict, applePayIntegrationType) => {
  let data: applePayConfig = switch applePayIntegrationType {
  | #manual => #manual(dict->manual)
  | #simplified => #simplified(dict->simplified)
  }

  let dict = Dict.make()
  let _ = switch data {
  | #manual(data) =>
    dict->Dict.set((#manual: applePayIntegrationType :> string), data->Identity.genericTypeToJson)
  | #simplified(data) =>
    dict->Dict.set(
      (#simplified: applePayIntegrationType :> string),
      data->Identity.genericTypeToJson,
    )
  }

  dict
}

let applePay = (
  dict,
  ~connector: string="",
  ~applePayIntegrationType: option<applePayIntegrationType>=None,
  (),
): applePay => {
  open ConnectorUtils
  open ConnectorTypes
  switch connector->getConnectorNameTypeFromString {
  | Processors(ZEN) => Zen(dict->zenApplePayConfig)
  | _ => {
      let integrationType = applePayIntegrationType->Option.getOr(#manual)
      let data = {
        apple_pay_combined: applePayCombined(dict, integrationType)->JSON.Encode.object,
      }
      ApplePayCombined(data)
    }
  }
}

let applePayNameMapper = (~name, ~integrationType: option<applePayIntegrationType>) => {
  switch name {
  | `terminal_uuid` => `metadata.apple_pay.${name}`
  | `pay_wall_secret` => `metadata.apple_pay.${name}`
  | _ =>
    `metadata.apple_pay_combined.${(integrationType->Option.getOr(
        #manual,
      ): applePayIntegrationType :> string)}.session_token_data.${name}`
  }
}

let paymentProcessingMapper = state => {
  switch state->String.toLowerCase {
  | "connector" => #Connector
  | "hyperswitch" => #Hyperswitch
  | _ => #Connector
  }
}

let initiativeMapper = state => {
  switch state->String.toLowerCase {
  | "ios" => #ios
  | "web" => #web
  | _ => #web
  }
}

let applePayIntegrationTypeMapper = state => {
  switch state->String.toLowerCase {
  | "manual" => #manual
  | "simplified" => #simplified
  | _ => #manual
  }
}

let ignoreFieldsonSimplified = [
  "certificate",
  "certificate_keys",
  "merchant_identifier",
  "display_name",
  "initiative",
  "payment_processing_details_at",
]

let validateZenFlow = values => {
  let data =
    values
    ->getDictFromJsonObject
    ->getDictfromDict("metadata")
    ->getDictfromDict("apple_pay")
    ->zenApplePayConfig
  data.terminal_uuid->Option.isSome && data.pay_wall_secret->Option.isSome
    ? Button.Normal
    : Button.Disabled
}

let validateInitiative = data => {
  switch data.initiative {
  | Some(value) => value->initiativeMapper == #web ? data.initiative_context->Option.isSome : true
  | None => false
  }
}

let validatePaymentProcessingDetailsAt = data => {
  switch data.payment_processing_details_at {
  | Some(value) =>
    value->paymentProcessingMapper == #Hyperswitch
      ? data.payment_processing_certificate->Option.isSome &&
          data.payment_processing_certificate_key->Option.isSome
      : true
  | None => false
  }
}

let validateManualFlow = values => {
  let data =
    values
    ->getDictFromJsonObject
    ->getDictfromDict("metadata")
    ->getDictfromDict("apple_pay_combined")
    ->sessionToken
  data->validateInitiative &&
  data.certificate->Option.isSome &&
  data.display_name->Option.isSome &&
  data.merchant_identifier->Option.isSome &&
  data->validatePaymentProcessingDetailsAt
    ? Button.Normal
    : Button.Disabled
}

let validateSimplifedFlow = values => {
  let data =
    values
    ->getDictFromJsonObject
    ->getDictfromDict("metadata")
    ->getDictfromDict("apple_pay_combined")
    ->sessionTokenSimplified
  data.initiative_context->Option.isSome && data.merchant_business_country->Option.isSome
    ? Button.Normal
    : Button.Disabled
}

let constructVerifyApplePayReq = (values, connectorID) => {
  let context =
    values
    ->getDictFromJsonObject
    ->getDictfromDict("metadata")
    ->getDictfromDict("apple_pay_combined")
    ->sessionTokenSimplified
  let domainName = context.initiative_context->Option.getOr("")
  let data = {
    domain_names: [domainName],
    merchant_connector_account_id: connectorID,
  }->JSON.stringifyAny

  let body = switch data {
  | Some(val) => val->LogicUtils.safeParse
  | None => Dict.make()->JSON.Encode.object
  }
  body
}
