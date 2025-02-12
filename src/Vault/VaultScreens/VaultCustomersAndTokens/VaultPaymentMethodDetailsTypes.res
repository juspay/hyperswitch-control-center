type psp_tokens = {
  mca_id: string,
  connector: string,
  status: string,
  tokentype: string,
  token: string,
  created: string,
}

type psp_tokensization = {psp_token: array<psp_tokens>}

type network_tokensization = {
  enabled: bool,
  status: string,
  token: string,
  created: string,
}

type cardDetails = {
  card_holder_name: string,
  card_type: string,
  card_network: string,
  last_four_digits: string,
  card_expiry_month: string,
  card_expiry_year: string,
  card_issuer: string,
  card_issuing_country: string,
  card_is_in: string,
  card_extended_bin: string,
  payment_checks: string,
  authentication_data: string,
}

type paymentMethodDetails = {
  merchant: string,
  customer_id: option<string>,
  payment_method_id: string,
  payment_method_type: option<string>,
  payment_method: string,
  card: cardDetails,
  recurring_enabled: bool,
  tokenization_type: JSON.t,
  psp_tokensization: psp_tokensization,
  network_tokensization: network_tokensization,
  created: string,
  last_used_at: string,
  network_transaction_id: string,
}

type paymentMethodDetailsColsType =
  | CardHolderName
  | CardType
  | CardNetwork
  | LastFourDigits
  | CardExpiryMonth
  | CardExpiryYear
  | CardIssuer
  | CardIssuingCountry
  | CardIsIn
  | CardExtendedBin
  | PaymentChecks
  | AuthenticationData
