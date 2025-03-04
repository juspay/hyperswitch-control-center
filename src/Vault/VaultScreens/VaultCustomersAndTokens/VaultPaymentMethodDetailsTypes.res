type psp_tokens = {
  mca_id: string,
  connector: string,
  status: string,
  tokentype: string,
  token: string,
  created: string,
}

type psp_tokensization = {psp_token: array<psp_tokens>}

type network_tokens = {
  enabled: bool,
  status: string,
  token: string,
  created: string,
}

type network_tokensization = {network_token: array<network_tokens>}

type cardDetails = {
  issuer_country: string,
  last4_digits: string,
  expiry_month: string,
  expiry_year: string,
  card_holder_name: string,
  card_fingerprint: string,
  nick_name: string,
  card_network: string,
  card_isin: string,
  card_issuer: string,
  card_type: string,
  saved_to_locker: bool,
}

type paymentMethodDetails = {
  id: string,
  merchant_id: string,
  customer_id: option<string>,
  payment_method_subtype: option<string>,
  payment_method_type: option<string>,
  recurring_enabled: bool,
  created: string,
  last_used_at: string,
  card: cardDetails,
  card_tokens: Dict.t<JSON.t>,
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
