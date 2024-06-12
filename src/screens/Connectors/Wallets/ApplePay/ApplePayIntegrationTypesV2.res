type sessionTokenData = {
  initiative: string,
  certificate: string,
  display_name: string,
  certificate_keys: string,
  initiative_context: string,
  merchant_identifier: string,
  merchant_business_country: string,
}

type sessionTokenSimplified = {
  initiative: string,
  certificate: string,
  display_name: string,
  certificate_keys: string,
  initiative_context: string,
  merchant_identifier: string,
  merchant_business_country: string,
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
