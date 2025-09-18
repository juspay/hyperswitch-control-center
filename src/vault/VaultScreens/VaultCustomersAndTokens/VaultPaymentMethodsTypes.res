type psp_tokens = {
  mca_id: string,
  connector: string,
  status: string,
  tokentype: string,
  token: string,
}

type psp_tokensization = {psp_token: array<psp_tokens>}

type paymentMethodCardType = {
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
  saved_to_locker: string,
}

type paymentMethodType = {card: paymentMethodCardType}

type network_tokensization = {payment_method_data: JSON.t}

//TODO: network and psp types move to details page, modify as per API response

type vaultPaymentMethods = {
  customer_id: option<string>,
  id: string,
  payment_method_type: option<string>,
  payment_method: string,
  recurring_enabled: bool,
  metadata: JSON.t,
  tokenization_type: JSON.t,
  psp_tokensization: psp_tokensization,
  network_tokensization: network_tokensization,
  bank_transfer: string,
  created: string,
  last_used_at: string,
  network_transaction_id: string,
  payment_method_data: paymentMethodType,
  psp_tokenization_enabled: bool,
}

type paymentMethodsColsTypes =
  | PaymentMethodId
  | PaymentMethodType
  | PaymentMethodData
  | PSPTokensization
  | NetworkTokenization
  | CreatedAt
  | LastUsed
