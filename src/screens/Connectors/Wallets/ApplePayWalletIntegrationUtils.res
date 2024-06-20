open ApplePayWalletIntegrationTypes
type paymentProcessingState = [#Connector | #Hyperswitch]
let paymentProcessingMapper = state => {
  switch state->String.toLowerCase {
  | "connector" => #Connector
  | "hyperswitch" => #Hyperswitch
  | _ => #Connector
  }
}
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
  let processingAt = dict->getString("payment_processing_details_at", "")->paymentProcessingMapper
  if processingAt === #Hyperswitch {
    let processingCertificate = dict->getString("payment_processing_certificate", "")
    let processingCertificateKey = dict->getString("payment_processing_certificate_key", "")
    if processingCertificate->isEmptyString {
      errorDict->Dict.set(
        "payment_processing_certificate",
        `Processing Certificate cannot be empty!`->JSON.Encode.string,
      )
    }
    if processingCertificateKey->isEmptyString {
      errorDict->Dict.set(
        "payment_processing_certificate_key",
        `Processing Certificate Key cannot be empty!`->JSON.Encode.string,
      )
    }
  }

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
  // Need to refactor
  switch integrationType {
  | #manual => {
      let label =
        values
        ->getDictFromJsonObject
        ->getDictfromDict("apple_pay_combined")
        ->getDictfromDict((#manual: applePayIntegrationType :> string))
        ->getDictfromDict("payment_request_data")
        ->getString("label", "apple")
      paymentRequestData->Dict.set("label", label->JSON.Encode.string)
    }

  | _ => ()
  }

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

type customApplePayFields = [#merchant_business_country | #payment_processing_details_at | #other]

let customApplePlayFields = field => {
  switch field {
  | "merchant_business_country" => #merchant_business_country
  | "payment_processing_details_at" => #payment_processing_details_at
  | _ => #other
  }
}

let paymentProcessingAtField = (
  ~name,
  ~label,
  ~options,
  ~setProcessingAt,
  ~form: ReactFinalForm.formApi,
  ~textColor,
) => {
  FormRenderer.makeFieldInfo(
    ~name,
    ~label,
    ~customInput=(~input) =>
      InputFields.radioInput(
        ~input={
          ...input,
          onChange: event => {
            let value = event->Identity.formReactEventToString->paymentProcessingMapper
            setProcessingAt(_ => value)
            if value === #Connector {
              form.change(
                "apple_pay_combined.manual.session_token_data.payment_processing_certificate",
                JSON.Encode.null,
              )
              form.change(
                "apple_pay_combined.manual.session_token_data.payment_processing_certificate_key",
                JSON.Encode.null,
              )
            }
            input.onChange(event)
          },
        },
        ~options=options->SelectBox.makeOptions,
        ~buttonText="",
        ~isHorizontal=true,
        ~customStyle="cursor-pointer gap-2",
        ~fill={`${textColor}`},
        (),
      ),
    (),
  )
}
