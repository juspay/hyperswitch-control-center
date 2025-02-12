type psp_tokens = {
  mca_id: string,
  connector: string,
  status: string,
  tokentype: string,
  token: string,
}

type psp_tokensization = {psp_token: array<psp_tokens>}

type network_tokensization = {
  enabled: bool,
  status: string,
  token: string,
}

// network and psp types move to details page
// not required to map here

type vaultPaymentMethods = {
  merchant: string,
  customer_id: option<string>,
  payment_method_id: string,
  payment_method_type: option<string>,
  payment_method: string,
  card: option<JSON.t>,
  recurring_enabled: bool,
  metadata: JSON.t,
  tokenization_type: JSON.t,
  psp_tokensization: psp_tokensization,
  network_tokensization: network_tokensization,
  bank_transfer: string,
  created: string,
  last_used_at: string,
  network_transaction_id: string,
}

type paymentMethodsColsTypes =
  | PaymentMethodId
  | PaymentMethodType
  | PaymentMethodData
  | PSPTokensization
  | NetworkTokenization
  | CreatedAt
  | LastUsed
