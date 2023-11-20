open ApplePayWalletIntegrationTypes
let getNextStep = (currentStep: applePayIntegrationSteps) => {
  switch currentStep {
  | Landing => Configure
  | Configure => Verify
  | Verify => Landing
  }
}

let getSessionTokenDict = (values: Js.Json.t, applePayIntegrationType: applePayIntegrationType) => {
  open LogicUtils
  values
  ->getDictFromJsonObject
  ->getDictfromDict("apple_pay_combined")
  ->getDictfromDict((applePayIntegrationType :> string))
  ->getDictfromDict("session_token_data")
}

let validate = (
  values: Js.Json.t,
  mandateKeys: array<string>,
  integrationType: ApplePayWalletIntegrationTypes.applePayIntegrationType,
) => {
  open LogicUtils
  let dict = values->getSessionTokenDict(integrationType)
  let errorDict = Js.Dict.empty()
  mandateKeys->Js.Array2.forEach(key => {
    let value = dict->getString(key, "")
    if value === "" {
      errorDict->Js.Dict.set(key, `${key} cannot be empty!`->Js.Json.string)
    }
  })
  errorDict->Js.Json.object_
}

let constructApplePayMetadata = (
  values: Js.Json.t,
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
  dict->Js.Dict.set("apple_pay_combined", Js.Dict.empty()->Js.Json.object_)->ignore

  applePayDict->Js.Dict.set("payment_request_data", paymentRequestData->Js.Json.object_)->ignore

  dict
  ->Js.Dict.set(
    "apple_pay_combined",
    Js.Dict.fromArray([
      ((integrationType: applePayIntegrationType :> string), applePayDict->Js.Json.object_),
    ])->Js.Json.object_,
  )
  ->ignore
  dict->Js.Json.object_
}

let constructVerifyApplePayReq = (values, connectorID) => {
  open LogicUtils
  let domainName = values->getSessionTokenDict(#simplified)->getString("initiative_context", "")
  let data = {
    domain_names: [domainName],
    merchant_connector_account_id: connectorID,
  }->Js.Json.stringifyAny

  let body = switch data {
  | Some(val) => val->LogicUtils.safeParse
  | None => Js.Dict.empty()->Js.Json.object_
  }
  (body, domainName)
}
