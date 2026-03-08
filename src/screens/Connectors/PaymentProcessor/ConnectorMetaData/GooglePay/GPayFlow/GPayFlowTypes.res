// Type definitions for Google Pay Metadata

type merchantInfoMetadata = {
  merchant_id: option<string>,
  merchant_name: option<string>,
}

type allowedPaymentMethodsParametersMetadata = {
  allowed_auth_methods: array<string>,
  allowed_card_networks: array<string>,
}

type tokenizationSpecificationParametersMetadata = {
  gateway?: string,
  gateway_merchant_id?: string,
  \"stripe:version"?: string,
  \"stripe:publishableKey"?: string,
  public_key?: string,
  private_key?: string,
  recipient_id?: string,
}

type tokenSpecificationMetadata = {
  \"type": string,
  parameters: tokenizationSpecificationParametersMetadata,
}

type allowedMethodMetadata = {
  \"type": string,
  parameters: allowedPaymentMethodsParametersMetadata,
  tokenization_specification: tokenSpecificationMetadata,
}

type allowedPaymentMethodsMetadata = array<allowedMethodMetadata>

type googlePayMetadata = {
  support_predecrypted_token: option<bool>,
  merchant_info?: merchantInfoMetadata,
  allowed_payment_methods?: allowedPaymentMethodsMetadata,
}

// Type definitions for Google Pay Connector Wallet Details

type googlePayIntegrationType = [#payment_gateway | #direct | #predecrypt]
type googlePayIntegrationSteps = Landing | Configure

type tokenizationSpecificationParameters = {
  gateway?: string,
  gateway_merchant_id?: string,
  \"stripe:version"?: string,
  \"stripe:publishableKey"?: string,
  public_key?: string,
  private_key?: string,
  recipient_id?: string,
}

type tokenSpecification = {
  \"type": string,
  parameters: tokenizationSpecificationParameters,
}

type merchantInfo = {
  merchant_id: option<string>,
  merchant_name: option<string>,
  tokenization_specification: tokenSpecification,
}

type providerDetails = {merchant_info: merchantInfo}

type cards = {
  allowed_auth_methods: array<string>,
  allowed_card_networks: array<string>,
}

type googlePay = {
  provider_details: providerDetails,
  cards: cards,
  support_predecrypted_token: option<bool>,
}
