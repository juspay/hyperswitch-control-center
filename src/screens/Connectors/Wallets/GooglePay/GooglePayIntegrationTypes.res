type merchantInfo = {
  merchant_id: option<string>,
  merchant_name: option<string>,
}
type allowedPaymentMethodsParameters = {
  allowed_auth_methods: array<string>,
  allowed_card_networks: array<string>,
}
type tokenizationSpecificationParameters = {
  gateway: string,
  gateway_merchant_id?: string,
  stripe_version?: string,
  stripe_publishableKey?: string,
}
type tokenSpecification = {
  \"type": string,
  parameters: tokenizationSpecificationParameters,
}
type allowedMethod = {
  \"type": string,
  parameters: allowedPaymentMethodsParameters,
  tokenization_specification: tokenSpecification,
}
type allowedPaymentMethods = array<allowedMethod>
type googlePay = {merchant_info: merchantInfo, allowed_payment_methods: allowedPaymentMethods}
