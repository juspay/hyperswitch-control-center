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

type paymentMethodDataType = {card: JSON.t}

type networkTokensData = {
  token: string,
  card_network: string,
}

type connectorTokenType = {
  connector_id: string,
  token_type: string,
  status: string,
  connector_token_request_reference_id: string,
  original_payment_authorized_amount: int,
  original_payment_authorized_currency: string,
  metadata: Dict.t<JSON.t>,
  token: string,
  connector: string,
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
  payment_method_data: paymentMethodDataType,
  connector_tokens: array<connectorTokenType>,
  network_tokens: JSON.t,
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
