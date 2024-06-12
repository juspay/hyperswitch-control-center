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

type applePayCombined = Simple(simple) | Manual(manual)
type applePay = {apple_pay_combined: applePayCombined}
