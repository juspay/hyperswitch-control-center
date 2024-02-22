open ApplePayWalletIntegrationTypes

let getSessionTokenDict = (values: JSON.t, applePayIntegrationType: applePayIntegrationType) => {
  open LogicUtils
  values
  ->getDictFromJsonObject
  ->getDictfromDict("apple_pay_combined")
  ->getDictfromDict((applePayIntegrationType :> string))
  ->getDictfromDict("session_token_data")
}

let validate = (
  values: JSON.t,
  mandateKeys: array<string>,
  integrationType: ApplePayWalletIntegrationTypes.applePayIntegrationType,
) => {
  open LogicUtils
  let dict = values->getSessionTokenDict(integrationType)
  let errorDict = Dict.make()
  mandateKeys->Array.forEach(key => {
    let value = dict->getString(key, "")
    if value->isEmptyString {
      errorDict->Dict.set(key, `${key} cannot be empty!`->JSON.Encode.string)
    }
  })
  errorDict->JSON.Encode.object
}

let constructApplePayMetadata = (
  values: JSON.t,
  metadataInputs,
  integrationType: applePayIntegrationType,
) => {
  open LogicUtils
  let paymentRequestData =
    metadataInputs->getDictfromDict("apple_pay")->getDictfromDict("payment_request_data")

  let dict = values->getDictFromJsonObject
  let applePayDict =
    dict
    ->getDictfromDict("apple_pay_combined")
    ->getDictfromDict((integrationType: applePayIntegrationType :> string))
  // 1.remove existing apple_pay_combined
  // 2.At given time either #manual or #simplified can exists
  dict->Dict.set("apple_pay_combined", Dict.make()->JSON.Encode.object)->ignore

  applePayDict->Dict.set("payment_request_data", paymentRequestData->JSON.Encode.object)->ignore

  dict
  ->Dict.set(
    "apple_pay_combined",
    Dict.fromArray([
      ((integrationType: applePayIntegrationType :> string), applePayDict->JSON.Encode.object),
    ])->JSON.Encode.object,
  )
  ->ignore
  dict->JSON.Encode.object
}

let constructVerifyApplePayReq = (values, connectorID) => {
  open LogicUtils
  let domainName = values->getSessionTokenDict(#simplified)->getString("initiative_context", "")
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
