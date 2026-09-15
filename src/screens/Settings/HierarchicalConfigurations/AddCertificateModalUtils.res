open HierarchicalConfigTypes
open LogicUtils

let csrFileName = "apple_pay.csr"
let csrFileType = "application/pkcs10"

let getFormattedErrorMessage = (~error, ~fallback, ~retryHint) => {
  let message =
    error
    ->Exn.message
    ->Option.getOr("")
    ->safeParse
    ->getDictFromJsonObject
    ->getString("message", "")
  let resolvedMessage = getErrorMessage(~message, ~error="", ~fallback)->capitalizeString
  `${resolvedMessage} ${retryHint}`
}

let getGenerateState = (csrState): Button.buttonState =>
  switch csrState {
  | Generating => Loading
  | NotGenerated | Generated(_) => Normal
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

let getStepSubHeading = step =>
  switch step {
  | Download => "Step 1 of 2 - Download the certificate signing request"
  | Upload => "Step 2 of 2 - Upload the signed certificate"
  }
