type connectProcessor =
  | CONFIGURE_PRIMARY
  | CONFIGURE_SECONDARY
  | CONFIGURE_SMART_ROUTING
  | CHECKOUT
  | LANDING

type integrateApp = LANDING | CHOOSE_INTEGRATION | CUSTOM_INTEGRATION

type golive = LANDING | GO_LIVE

type quickStartType =
  | ConnectProcessor(connectProcessor)
  | IntegrateApp(integrateApp)
  | GoLive(golive)
  | FinalLandingPage

type configureProcessorTypes =
  Select_processor | Select_configuration_type | Configure_keys | Setup_payment_methods | Summary

type choiceStateTypes = [
  | #MultipleProcessorWithSmartRouting
  | #SinglePaymentProcessor
  | #DefaultFallback
  | #VolumeBasedRouting
  | #MigrateFromStripe
  | #StandardIntegration
  | #WooCommercePlugin
  | #TestApiKeys
  | #ConnectorApiKeys
  | #NotSelected
]
type landingChoiceType = {
  displayText: string,
  description: string,
  leftIcon?: string,
  footerTags?: array<string>,
  variantType: choiceStateTypes,
  imageLink?: string,
}

type sectionHeadingVariant = [
  | #ProductionAgreement
  | #FirstProcessorConnected
  | #SecondProcessorConnected
  | #ConfiguredRouting
  | #TestPayment
  | #IntegrationMethod
  | #IntegrationCompleted
  | #DownloadTestAPIKey
  | #CreatePayment
  | #DisplayCheckout
  | #DisplayPaymentConfirmation
  | #StripeConnected
  | #PaypalConnected
  | #SPRoutingConfigured
  | #SPTestPayment
  | #DownloadWoocom
  | #ConfigureWoocom
  | #SetupWoocomWebhook
  | #ConfigurationType
  | #GoLive
  | #DownloadTestAPIKeyStripe
  | #InstallDeps
  | #ReplaceAPIKeys
  | #ReconfigureCheckout
  | #LoadCheckout
]

type processorType = {
  processorID: string,
  processorName: string,
}
type routingType = {routing_id: string}

type paymentType = {payment_id: string}

type integrationMethod = {integration_type: string}

type responseType = {
  productionAgreement: bool,
  firstProcessorConnected: processorType,
  secondProcessorConnected: processorType,
  configuredRouting: routingType,
  testPayment: paymentType,
  integrationMethod: integrationMethod,
  integrationCompleted: bool,
  stripeConnected: processorType,
  paypalConnected: processorType,
  sPRoutingConfigured: routingType,
  sPTestPayment: bool,
  downloadWoocom: bool,
  configureWoocom: bool,
  setupWoocomWebhook: bool,
  downloadTestAPIKeyStripe: string,
  installDeps: string,
  replaceAPIKeys: string,
  reconfigureCheckout: string,
  loadCheckout: string,
  downloadTestAPIKey: string,
  createPayment: string,
  displayCheckout: string,
  displayPaymentConfirmation: string,
  configurationType: string,
}

type requestObjectType =
  | ProcesorType(processorType)
  | RoutingType(routingType)
  | PaymentType(paymentType)
  | IntegrationMethod(integrationMethod)
  | Boolean(bool)
  | String(string)
  | StringEnumType(string)

type valueType = String(string) | Boolean(bool)
