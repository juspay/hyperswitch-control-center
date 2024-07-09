type sessionTokenData = {
  initiative: option<string>,
  certificate: option<string>,
  display_name: option<string>,
  certificate_keys: option<string>,
  initiative_context: option<string>,
  merchant_identifier: option<string>,
  merchant_business_country: option<string>,
  payment_processing_details_at: option<string>,
  payment_processing_certificate: option<string>,
  payment_processing_certificate_key: option<string>,
}

type sessionTokenSimplified = {
  initiative_context: option<string>,
  merchant_business_country: option<string>,
}

type paymentRequestData = {
  label: string,
  supported_networks: array<string>,
  merchant_capabilities: array<string>,
}

type manual = {
  session_token_data: sessionTokenData,
  payment_request_data: paymentRequestData,
}

type simplified = {
  session_token_data: sessionTokenSimplified,
  payment_request_data: paymentRequestData,
}

// type applePayCombined = {
//   manual?: option<manual>,
//   simplified?: option<simplified>,
// }
type applePayIntegrationType = [#manual | #simplified]
type applePayConfig = [#manual(manual) | #simplified(simplified)]
type applePayIntegrationSteps = Landing | Configure | Verify
type simplifiedApplePayIntegartionTypes = EnterUrl | DownloadFile | HostUrl

type applePayCombined = {apple_pay_combined: Js.Json.t}
type zenConfig = {
  terminal_uuid: option<string>,
  pay_wall_secret: option<string>,
}

type applePay = ApplePayCombined(applePayCombined) | Zen(zenConfig)
type verifyApplePay = {
  domain_names: array<string>,
  merchant_connector_account_id: string,
}

type paymentProcessingState = [#Connector | #Hyperswitch]
type initiativeState = [#web | #ios]

type inputType = Text | Toggle | Select

type inputField = {
  name: string,
  label: string,
  placeholder: string,
  required: bool,
  options: array<string>,
  \"type": inputType,
}
