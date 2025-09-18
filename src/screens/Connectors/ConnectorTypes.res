type steps =
  IntegFields | PaymentMethods | CustomMetadata | SummaryAndTest | Preview | AutomaticFlow
type connectorIntegrationField = {
  placeholder?: string,
  label?: string,
  name: string,
  isRequired?: bool,
  encodeToBase64?: bool,
  liveValidationRegex?: string,
  testValidationRegex?: string,
  liveExpectedFormat?: string,
  testExpectedFormat?: string,
  description?: string,
}

type metadataFields = {
  google_pay?: array<connectorIntegrationField>,
  apple_pay?: array<connectorIntegrationField>,
}
type integrationFields = {
  description: string,
  validate?: array<connectorIntegrationField>,
  inputFieldDescription?: string,
}

type verifyResponse = Success | Failure | NoAttempt | Loading
type authType = [#HeaderKey | #BodyKey | #SignatureKey | #MultiAuthKey | #CurrencyAuthKey | #Nokey]
type cashToCodeMthd = [#Classic | #Evoucher]

type processorTypes =
  | ADYEN
  | CHECKOUT
  | BRAINTREE
  | BANKOFAMERICA
  | BILLWERK
  | AUTHORIZEDOTNET
  | STRIPE
  | KLARNA
  | GLOBALPAY
  | BLUESNAP
  | AFFIRM
  | AIRWALLEX
  | WORLDPAY
  | WORLDPAYXML
  | CYBERSOURCE
  | COINGATE
  | ELAVON
  | ACI
  | WORLDLINE
  | FISERV
  | FISERVIPG
  | SHIFT4
  | RAPYD
  | PAYU
  | NUVEI
  | DLOCAL
  | MULTISAFEPAY
  | BAMBORA
  | MOLLIE
  | TRUSTPAY
  | ZEN
  | PAYPAL
  | COINBASE
  | OPENNODE
  | PHONYPAY
  | FAUXPAY
  | PRETENDPAY
  | NMI
  | FORTE
  | NEXINETS
  | IATAPAY
  | BITPAY
  | CRYPTOPAY
  | CASHTOCODE
  | CHECKBOOK
  | PAYME
  | GLOBEPAY
  | POWERTRANZ
  | TSYS
  | NOON
  | STRIPE_TEST
  | PAYPAL_TEST
  | STAX
  | GOCARDLESS
  | VOLT
  | PROPHETPAY
  | HELCIM
  | PLACETOPAY
  | ZSL
  | MIFINITY
  | RAZORPAY
  | BAMBORA_APAC
  | ITAUBANK
  | DATATRANS
  | PLAID
  | SQUARE
  | PAYBOX
  | WELLSFARGO
  | FIUU
  | NOVALNET
  | DEUTSCHEBANK
  | NEXIXPAY
  | NORDEA
  | XENDIT
  | JPMORGAN
  | INESPAY
  | MONERIS
  | REDSYS
  | HIPAY
  | PAYSTACK
  | FACILITAPAY
  | ARCHIPEL
  | AUTHIPAY
  | WORLDPAYVANTIV
  | BARCLAYCARD
  | SILVERFLOW
  | TOKENIO
  | PAYLOAD
  | PAYTM
  | PHONEPE
  | FLEXITI
  | BREADPAY
  | BLUECODE
  | BLACKHAWKNETWORK
  | DWOLLA
  | PAYSAFE
  | PEACHPAYMENTS

type payoutProcessorTypes =
  | ADYEN
  | ADYENPLATFORM
  | CYBERSOURCE
  | EBANX
  | PAYPAL
  | STRIPE
  | WISE
  | NOMUPAY

type threeDsAuthenticatorTypes =
  THREEDSECUREIO | NETCETERA | CLICK_TO_PAY_MASTERCARD | JUSPAYTHREEDSSERVER | CLICK_TO_PAY_VISA

type frmTypes =
  | Signifyd
  | Riskifyed

type pmAuthenticationProcessorTypes = PLAID

type taxProcessorTypes = TAXJAR

type billingProcessorTypes = CHARGEBEE | STRIPE_BILLING | CUSTOMBILLING

type connectorTypeVariants =
  | PaymentProcessor
  | PaymentVas
  | PayoutProcessor
  | AuthenticationProcessor
  | PMAuthProcessor
  | TaxProcessor
  | BillingProcessor

type connectorTypes =
  | Processors(processorTypes)
  | PayoutProcessor(payoutProcessorTypes)
  | ThreeDsAuthenticator(threeDsAuthenticatorTypes)
  | FRM(frmTypes)
  | PMAuthenticationProcessor(pmAuthenticationProcessorTypes)
  | TaxProcessor(taxProcessorTypes)
  | BillingProcessor(billingProcessorTypes)
  | UnknownConnector(string)

type paymentMethod =
  | Card
  | PayLater
  | Wallet
  | BankRedirect
  | BankTransfer
  | Crypto
  | BankDebit
  | UnknownPaymentMethod(string)

type paymentMethodTypes =
  | Credit
  | Debit
  | GooglePay
  | ApplePay
  | SamsungPay
  | PayPal
  | Klarna
  | BankDebit
  | OpenBankingPIS
  | Paze
  | AliPay
  | WeChatPay
  | DirectCarrierBilling
  | UnknownPaymentMethodType(string)

type advancedConfigurationList = {
  @as("type") type_: string,
  list: array<string>,
}

type advancedConfiguration = {options: advancedConfigurationList}

type paymentMethodConfigCommonType = {
  card_networks: array<string>,
  accepted_currencies: option<advancedConfigurationList>,
  accepted_countries: option<advancedConfigurationList>,
  minimum_amount: option<int>,
  maximum_amount: option<int>,
  recurring_enabled: option<bool>,
  installment_payment_enabled: option<bool>,
  payment_experience: option<string>,
}

type paymentMethodConfigType = {
  payment_method_type: string,
  ...paymentMethodConfigCommonType,
}

type paymentMethodConfigTypeV2 = {
  payment_method_subtype: string,
  ...paymentMethodConfigCommonType,
}

type paymentMethodConfigTypeCommon = {
  payment_method_subtype: string,
  ...paymentMethodConfigCommonType,
}

type paymentMethodEnabled = {
  payment_method: string,
  payment_method_type: string,
  provider?: array<paymentMethodConfigType>,
  card_provider?: array<paymentMethodConfigType>,
}

type applePay = {
  merchant_identifier: string,
  certificate: string,
  display_name: string,
  initiative_context: string,
  certificate_keys: string,
}
type googlePay = {
  merchant_name: string,
  publishable_key?: string,
  merchant_id: string,
}

type metaData = {
  apple_pay?: applePay,
  goole_pay?: googlePay,
}
type pmAuthPaymentMethods = {
  payment_method: string,
  payment_method_type: string,
  connector_name: string,
  mca_id: string,
}

type wasmRequest = {
  payment_methods_enabled: array<paymentMethodEnabled>,
  connector: string,
}

type wasmExtraPayload = {
  profile_id: string,
  connector_type: string,
  connector_name: string,
  connector_account_details: JSON.t,
  disabled: bool,
  test_mode: bool,
  connector_webhook_details: option<JSON.t>,
}

// This type are used for FRM configuration which need to moved to wasm

type headerKey = {auth_type: string, api_key: string}
type bodyKey = {
  auth_type: string,
  api_key: string,
  key1: string,
}
type signatureKey = {
  auth_type: string,
  api_key: string,
  key1: string,
  api_secret: string,
}
type multiAuthKey = {
  auth_type: string,
  api_key: string,
  key1: string,
  api_secret: string,
  key2: string,
}
type currencyKey = {
  auth_type: string,
  merchant_id_classic: string,
  password_classic: string,
  username_classic: string,
}
type currencyAuthKey = {auth_key_map: Js.Dict.t<JSON.t>, auth_type: string}
type certificateAuth = {
  auth_type: string,
  certificate: string,
  private_key: string,
}
type noKeyAuth = {auth_type: string}

type connectorAuthType =
  | HeaderKey
  | BodyKey
  | SignatureKey
  | MultiAuthKey
  | CurrencyAuthKey
  | CertificateAuth
  | NoKey
  | UnKnownAuthType

type connectorAuthTypeObj =
  | HeaderKey(headerKey)
  | BodyKey(bodyKey)
  | SignatureKey(signatureKey)
  | MultiAuthKey(multiAuthKey)
  | CurrencyAuthKey(currencyAuthKey)
  | CertificateAuth(certificateAuth)
  | NoKey(noKeyAuth)
  | UnKnownAuthType(JSON.t)

type paymentMethodEnabledType = {
  payment_method: string,
  mutable payment_method_types: array<paymentMethodConfigType>,
}

type paymentMethodEnabledTypeV2 = {
  payment_method_type: string,
  payment_method_subtypes: array<paymentMethodConfigTypeV2>,
}

type paymentMethodEnabledTypeCommon = {
  payment_method_type: string,
  payment_method_subtypes: array<paymentMethodConfigTypeCommon>,
}

type payment_methods_enabled = array<paymentMethodEnabledType>
type payment_methods_enabledV2 = array<paymentMethodEnabledTypeV2>
type payment_methods_enabledCommon = array<paymentMethodEnabledTypeCommon>

type frm_payment_method_type = {
  payment_method_type: string,
  flow: string,
  action: string,
}

type frm_payment_method = {
  payment_method: string,
  payment_method_types?: array<frm_payment_method_type>,
  flow: string,
}

type frm_config = {
  gateway: string,
  mutable payment_methods: array<frm_payment_method>,
}

type connectorPayload = {
  connector_type: connectorTypeVariants,
  connector_name: string,
  connector_label: string,
  connector_account_details: connectorAuthTypeObj,
  test_mode: bool,
  disabled: bool,
  payment_methods_enabled: payment_methods_enabled,
  profile_id: string,
  metadata: JSON.t,
  merchant_connector_id: string,
  frm_configs?: array<frm_config>,
  status: string,
  connector_webhook_details: JSON.t,
  additional_merchant_data: JSON.t,
}

type connectorPayloadV2 = {
  connector_type: connectorTypeVariants,
  connector_name: string,
  connector_label: string,
  connector_account_details: connectorAuthTypeObj,
  disabled: bool,
  payment_methods_enabled: payment_methods_enabledV2,
  profile_id: string,
  metadata: JSON.t,
  id: string,
  frm_configs: array<frm_config>,
  status: string,
  connector_webhook_details: JSON.t,
  additional_merchant_data: JSON.t,
  feature_metadata: JSON.t,
}

type connectorPayloadCommonType = {
  connector_type: connectorTypeVariants,
  connector_name: string,
  connector_label: string,
  connector_account_details: connectorAuthTypeObj,
  test_mode?: bool,
  disabled: bool,
  payment_methods_enabled: payment_methods_enabledCommon,
  profile_id: string,
  metadata: JSON.t,
  id: string,
  frm_configs?: array<frm_config>,
  status: string,
  connector_webhook_details: JSON.t,
  additional_merchant_data: JSON.t,
  feature_metadata?: JSON.t,
}

type connector =
  | FRMPlayer
  | Processor
  | PayoutProcessor
  | ThreeDsAuthenticator
  | PMAuthenticationProcessor
  | TaxProcessor
  | BillingProcessor

type connectorFieldTypes = {
  bodyType: string,
  connectorAccountFields: Dict.t<JSON.t>,
  connectorMetaDataFields: Dict.t<JSON.t>,
  isVerifyConnector: bool,
  connectorWebHookDetails: Dict.t<JSON.t>,
  connectorLabelDetailField: Dict.t<JSON.t>,
  connectorAdditionalMerchantData: Dict.t<JSON.t>,
}
