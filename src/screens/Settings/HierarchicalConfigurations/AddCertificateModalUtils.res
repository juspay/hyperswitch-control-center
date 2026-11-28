open HierarchicalConfigTypes
open LogicUtils

let csrFileName = "apple_pay.csr"
let csrFileType = "application/pkcs10"

let googlePayPublicKeyFileName = "google_pay_public_key.txt"
let googlePayPublicKeyFileType = "text/plain"

let getFormattedErrorMessage = (~error, ~fallback, ~retryHint) => {
  let resolvedMessage =
    HierarchicalConfigUtils.getApiErrorMessage(~error, ~fallback)->capitalizeString
  `${resolvedMessage} ${retryHint}`
}

let getGenerateState = (csrState): Button.buttonState =>
  switch csrState {
  | Generating => Loading
  | NotGenerated | Generated(_) => Normal
  }

let getGooglePayGenerateState = (~keyState, ~googleMerchantId): Button.buttonState =>
  switch keyState {
  | KeyGenerating => Loading
  | KeyGenerated(_) => Disabled
  | KeyNotGenerated => googleMerchantId->String.trim->isNonEmptyString ? Normal : Disabled
  }

let getResourceId = csrState =>
  switch csrState {
  | Generated({resourceId}) => Some(resourceId)
  | _ => None
  }

let getCsr = csrState =>
  switch csrState {
  | Generated({csr}) => csr
  | _ => ""
  }

let getModalHeading = step =>
  switch step {
  | ChooseType => "Add New Resource"
  | ApplePayDownload | ApplePayUpload => "Add New Apple Pay Certificate"
  | GooglePayGenerate => "Add New Google Pay Key"
  }

let getStepSubHeading = step =>
  switch step {
  | ChooseType => "Choose the wallet you want to generate credentials for"
  | ApplePayDownload => "Step 1 of 2 - Download the certificate signing request"
  | ApplePayUpload => "Step 2 of 2 - Upload the signed certificate"
  | GooglePayGenerate => "Generate a managed key for Google Pay DIRECT tokenization"
  }

let getResourceTypeDescription = resourceType =>
  switch resourceType {
  | ApplePay => "Generate a CSR and upload the Apple Pay Payment Processing Certificate signed by Apple."
  | GooglePay => "Generate a managed key pair for DIRECT tokenization. Only the public key is shared with you."
  }
