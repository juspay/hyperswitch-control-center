type sessionTokenData = {
  initiative: option<string>,
  certificate: option<string>,
  display_name: option<string>,
  certificate_keys: option<string>,
  initiative_context: option<string>,
  merchant_identifier: option<string>,
  merchant_business_country: option<string>,
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

type simple = {
  session_token_data: sessionTokenSimplified,
  payment_request_data: paymentRequestData,
}

type applePayCombined = {
  manual: option<manual>,
  simple: option<simple>,
}
type applePay = {apple_pay_combined: Js.Json.t}
type applePayIntegrationType = [#manual | #simplified]
type applePayConfig = [#manual(manual) | #simplified(simple)]
type applePayIntegrationSteps = Landing | Configure | Verify
type simplifiedApplePayIntegartionTypes = EnterUrl | DownloadFile | HostUrl

type verifyApplePay = {
  domain_names: array<string>,
  merchant_connector_account_id: string,
}
