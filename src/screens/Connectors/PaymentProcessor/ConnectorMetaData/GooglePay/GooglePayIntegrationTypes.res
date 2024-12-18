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
  \"stripe:version"?: string,
  \"stripe:publishableKey"?: string,
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
type zenGooglepay = {
  terminal_uuid: string,
  pay_wall_secret: string,
}
type googlePay = {merchant_info: merchantInfo, allowed_payment_methods: allowedPaymentMethods}
type googlePayConfig = Zen(zenGooglepay) | Standard(googlePay)

type inputType = Text | Toggle | Select

type inputField = {
  name: string,
  label: string,
  placeholder: string,
  required: bool,
  options: array<string>,
  \"type": inputType,
}
