open ApplePayIntegrationTypesV2
open LogicUtils
let paymentRequest = {
  label: "apple",
  supported_networks: ["visa", "masterCard", "amex", "discover"],
  merchant_capabilities: ["supports3DS"],
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
    payment_request_data: paymentRequest,
  }
}

let simplified = (dict): simplified => {
  {
    session_token_data: dict->sessionTokenSimplified,
    payment_request_data: paymentRequest,
  }
}

let zenApplePayConfig = dict => {
  {
    terminal_uuid: dict->getOptionString("terminal_uuid"),
    pay_wall_secret: dict->getOptionString("pay_wall_secret"),
  }
}

let applePay = (
  dict,
  applePayIntegrationType: applePayIntegrationType,
  connector: string,
): applePay => {
  open ConnectorUtils
  open ConnectorTypes
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

  let applePayCombined = {
    apple_pay_combined: dict->JSON.Encode.object,
  }

  switch connector->getConnectorNameTypeFromString() {
  | Processors(ZEN) => Zen(dict->zenApplePayConfig)
  | _ => ApplePayCombined(applePayCombined)
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

let validateManualFlow = (values, connector) => {
  open ConnectorUtils
  open ConnectorTypes
  switch connector->getConnectorNameTypeFromString() {
  | Processors(ZEN) => {
      let data =
        values
        ->getDictFromJsonObject
        ->getDictfromDict("metadata")
        ->getDictfromDict("apple_pay")
        ->zenApplePayConfig
      Js.log(data)
      data.terminal_uuid->Option.isSome && data.pay_wall_secret->Option.isSome
        ? Button.Normal
        : Button.Disabled
    }
  | _ => {
      let data =
        values
        ->getDictFromJsonObject
        ->getDictfromDict("metadata")
        ->getDictfromDict("apple_pay_combined")
        ->sessionToken
      data.initiative_context->Option.isSome && data.merchant_business_country->Option.isSome
        ? Button.Normal
        : Button.Disabled
    }
  }
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
  (body, domainName)
}
