open QuickStartTypes

let getTestConnectorName = (connector, quickStartPageState) => {
  open ConnectorUtils
  open QuickStartTypes
  open ConnectorTypes
  switch connector {
  | STRIPE | PAYPAL => `${connector->getConnectorNameString}_test`
  | _ =>
    switch quickStartPageState {
    | ConnectProcessor(CONFIGURE_PRIMARY) => "fauxpay"
    | _ => "pretendpay"
    }
  }
}

let quickStartEnumIntialArray: array<sectionHeadingVariant> = [
  #ConfigurationType,
  #FirstProcessorConnected,
  #SecondProcessorConnected,
  #ConfiguredRouting,
  #TestPayment,
  #IntegrationMethod,
  #IntegrationCompleted,
  #DownloadWoocom,
  #ConfigureWoocom,
  #SetupWoocomWebhook,
  #StripeConnected,
  #PaypalConnected,
  #SPTestPayment,
]

let connectorChoiceStringVariantMapper = stringValue =>
  switch stringValue {
  | "" => #NotSelected
  | "Single" => #SinglePaymentProcessor
  | "Multiple" | _ => #MultipleProcessorWithSmartRouting
  }

let connectorChoiceVariantToString = variantValue =>
  switch variantValue {
  | #SinglePaymentProcessor => "Single"
  | #MultipleProcessorWithSmartRouting => "Multiple"
  | _ => ""
  }

let defaultChoiceStateValue: landingChoiceType = {
  displayText: "Not Selected",
  description: "Not Selected",
  variantType: #NotSelected,
}

let connectorChoiceArray: array<landingChoiceType> = [
  {
    displayText: "Single Payment Processor",
    description: "Connect any one processor and test a payment with Hyperswitch Checkout",
    variantType: #SinglePaymentProcessor,
  },
  {
    displayText: "Multiple processors with Smart Routing",
    description: "Connect a primary and secondary processor, define smart routing rules and test a payment with Hyperswitch Checkout",
    variantType: #MultipleProcessorWithSmartRouting,
  },
]

let getTypeOfConfigurationArray: ConnectorTypes.connectorName => array<
  landingChoiceType,
> = selectedConnector => {
  open ConnectorUtils
  let connectorName = selectedConnector->getConnectorNameString->LogicUtils.capitalizeString
  let testAPIDescription = switch selectedConnector {
  | STRIPE | PAYPAL =>
    `We've got you covered. Try connecting with our test processor modeled like ${connectorName} to continue your setup.`
  | _ => "We've got you covered. Try connecting with one of Hyperswitch's test processor to continue your setup."
  }
  [
    {
      displayText: "Try with a test processor",
      description: testAPIDescription,
      variantType: #TestApiKeys,
    },
    {
      displayText: `I have ${connectorName} API keys`,
      description: `Enter your ${connectorName}  test mode secret key and enable desired payment methods to proceed with the setup. `,
      variantType: #ConnectorApiKeys,
    },
  ]
}

let getSmartRoutingConfigurationText: array<landingChoiceType> = [
  {
    displayText: "Fallback routing (active - passive)",
    description: "Fallback to the secondary processor in case your primary processor couldn't process the transactions",
    variantType: #DefaultFallback,
    imageLink: "/assets/FallbackRoutingImage.svg",
  },
  {
    displayText: "Volume based routing (active - active)",
    description: "Split & route your transaction volume via more than one processor. Default is 50-50, this can be updated later",
    variantType: #VolumeBasedRouting,
    imageLink: "/assets/VolumeBasedRoutingImage.svg",
  },
]

let integrateYourAppArray: array<landingChoiceType> = [
  {
    displayText: "Quick Integration for Stripe users",
    description: "Continue using Stripe with 40+ payment processors by changing few lines of code.",
    variantType: #MigrateFromStripe,
    footerTags: ["Low code", "Stripe elements compatible"],
    leftIcon: "stripe-icon",
  },
  {
    displayText: "Standard Integration",
    description: "Integrate Hyperswitch into your app with four simple steps",
    variantType: #StandardIntegration,
    footerTags: ["Code required", "Supports all platforms"],
    leftIcon: "hyperswitch-logo-short",
  },
  // {
  //   displayText: "Woocommerce plugin",
  //   description: "Use our Woocommerce plugin for accepting payments",
  //   variantType: #WooCommercePlugin,
  //   footerTags: ["No code", "Web only"],
  //   leftIcon: "woocommerce",
  // },
]

let getProcessorType: Js.Dict.t<'a> => processorType = value => {
  open LogicUtils
  let processorID = value->getString("processor_id", "")
  let processorName = value->getString("processor_name", "")
  {
    processorID,
    processorName,
  }
}
let getRoutingType: Js.Dict.t<'a> => routingType = value => {
  {
    routing_id: value->LogicUtils.getString("routing_id", ""),
  }
}
let getPaymentType: Js.Dict.t<'a> => paymentType = value => {
  {
    payment_id: value->LogicUtils.getString("payment_id", ""),
  }
}

let getIntegrationType: Js.Dict.t<'a> => integrationMethod = value => {
  {
    integration_type: value->LogicUtils.getString("integration_type", ""),
  }
}

let getStringFromVariant = variant => {
  (variant: sectionHeadingVariant :> string)
}

let getTypedValueFromDict = valueString => {
  open LogicUtils
  let value = valueString->getDictFromJsonObject
  let typedValue = {
    productionAgreement: value->getBool(#ProductionAgreement->getStringFromVariant, false),
    firstProcessorConnected: value
    ->getDictfromDict(#FirstProcessorConnected->getStringFromVariant)
    ->getProcessorType,
    secondProcessorConnected: value
    ->getDictfromDict(#SecondProcessorConnected->getStringFromVariant)
    ->getProcessorType,
    configuredRouting: value
    ->getDictfromDict(#ConfiguredRouting->getStringFromVariant)
    ->getRoutingType,
    testPayment: value->getDictfromDict(#TestPayment->getStringFromVariant)->getPaymentType,
    integrationMethod: value
    ->getDictfromDict(#IntegrationMethod->getStringFromVariant)
    ->getIntegrationType,
    integrationCompleted: value->getBool(#IntegrationCompleted->getStringFromVariant, false),
    downloadTestAPIKey: value->getString(#DownloadTestAPIKey->getStringFromVariant, ""),
    createPayment: value->getString(#CreatePayment->getStringFromVariant, ""),
    displayCheckout: value->getString(#DisplayCheckout->getStringFromVariant, ""),
    displayPaymentConfirmation: value->getString(
      #DisplayPaymentConfirmation->getStringFromVariant,
      "",
    ),
    stripeConnected: value
    ->getDictfromDict(#StripeConnected->getStringFromVariant)
    ->getProcessorType,
    paypalConnected: value
    ->getDictfromDict(#PaypalConnected->getStringFromVariant)
    ->getProcessorType,
    sPRoutingConfigured: value
    ->getDictfromDict(#SPRoutingConfigured->getStringFromVariant)
    ->getRoutingType,
    sPTestPayment: value->getBool(#SPTestPayment->getStringFromVariant, false),
    downloadWoocom: value->getBool(#DownloadWoocom->getStringFromVariant, false),
    configureWoocom: value->getBool(#ConfigureWoocom->getStringFromVariant, false),
    setupWoocomWebhook: value->getBool(#SetupWoocomWebhook->getStringFromVariant, false),
    downloadTestAPIKeyStripe: value->getString(#DownloadTestAPIKeyStripe->getStringFromVariant, ""),
    installDeps: value->getString(#InstallDeps->getStringFromVariant, ""),
    replaceAPIKeys: value->getString(#ReplaceAPIKeys->getStringFromVariant, ""),
    reconfigureCheckout: value->getString(#ReconfigureCheckout->getStringFromVariant, ""),
    loadCheckout: value->getString(#LoadCheckout->getStringFromVariant, ""),
    configurationType: value->getString(#ConfigurationType->getStringFromVariant, ""),
  }
  typedValue
}

let variantToEnumMapper = variantValue => {
  switch variantValue {
  | ConnectProcessor(connectProcesorValue) =>
    switch connectProcesorValue {
    | CONFIGURE_PRIMARY => #FirstProcessorConnected
    | CONFIGURE_SECONDARY => #SecondProcessorConnected
    | CONFIGURE_SMART_ROUTING => #ConfiguredRouting
    | CHECKOUT => #TestPayment
    | _ => #TestPayment
    }
  | IntegrateApp(integrateAppValue) =>
    switch integrateAppValue {
    | CHOOSE_INTEGRATION => #IntegrationMethod
    | CUSTOM_INTEGRATION => #IntegrationCompleted
    | _ => #IntegrationCompleted
    }
  | _ => #IntegrationCompleted
  }
}
let enumToVarinatMapper = enum =>
  switch enum {
  | #ConfigurationType => ConnectProcessor(LANDING)
  | #FirstProcessorConnected => ConnectProcessor(CONFIGURE_PRIMARY)
  | #SecondProcessorConnected => ConnectProcessor(CONFIGURE_SECONDARY)
  | #ConfiguredRouting => ConnectProcessor(CONFIGURE_SMART_ROUTING)
  | #TestPayment => ConnectProcessor(CHECKOUT)
  | #IntegrationMethod => IntegrateApp(CHOOSE_INTEGRATION)
  | #IntegrationCompleted => IntegrateApp(CUSTOM_INTEGRATION)
  | _ => GoLive(LANDING)
  }

let getStatusValue = (comparator: valueType, enumVariant, dashboardPageState) => {
  open HSSelfServeSidebar
  switch comparator {
  | String(strValue) =>
    strValue->String.length > 0 ? COMPLETED : dashboardPageState === enumVariant ? ONGOING : PENDING
  | Boolean(boolValue) =>
    boolValue ? COMPLETED : dashboardPageState === enumVariant ? ONGOING : PENDING
  }
}

let getStatusFromString = statusString => {
  open HSSelfServeSidebar
  switch statusString->String.toUpperCase {
  | "PENDING" => PENDING
  | "COMPLETED" => COMPLETED
  | "ONGOING" => ONGOING
  | _ => PENDING
  }
}

let sidebarTextBasedOnVariant = choiceState =>
  switch choiceState {
  | #MigrateFromStripe => "Hyperswitch For Stripe Users"
  | #StandardIntegration => "Standard integration"
  | #WooCommercePlugin => "Woocommerce plugin"
  | _ => "Hyperswitch For Stripe Users"
  }

let getSidebarOptionsForIntegrateYourApp: (
  string,
  quickStartType,
  UserOnboardingTypes.buildHyperswitchTypes,
  choiceStateTypes,
) => array<HSSelfServeSidebar.sidebarOption> = (
  enumDetails,
  quickStartPageState,
  currentRoute,
  choiceState,
) => {
  // TODO:Refactor code to more dynamic cases

  let currentPageStateEnum = quickStartPageState->variantToEnumMapper

  open LogicUtils
  let enumValue = enumDetails->safeParse->getTypedValueFromDict

  let migrateFromStripeSidebar: array<HSSelfServeSidebar.sidebarOption> = [
    {
      title: "Choose integration method",
      status: String(enumValue.integrationMethod.integration_type)->getStatusValue(
        #IntegrationMethod,
        currentPageStateEnum,
      ),
      link: "/",
    },
    {
      title: choiceState->sidebarTextBasedOnVariant,
      status: Boolean(enumValue.integrationCompleted)->getStatusValue(
        #IntegrationCompleted,
        currentPageStateEnum,
      ),
      link: "/",
      subOptions: [
        {
          title: "Download Test API Keys",
          status: enumValue.downloadTestAPIKeyStripe->getStatusFromString,
        },
        {
          title: "Install Dependencies",
          status: enumValue.installDeps->getStatusFromString,
        },
        {
          title: "Replace API keys",
          status: enumValue.replaceAPIKeys->getStatusFromString,
        },
        {
          title: "Reconfigure Checkout Form",
          status: enumValue.reconfigureCheckout->getStatusFromString,
        },
        {
          title: "Load Hyperswitch Checkout",
          status: enumValue.loadCheckout->getStatusFromString,
        },
      ],
    },
  ]

  let standardIntegrationSidebar: array<HSSelfServeSidebar.sidebarOption> = [
    {
      title: "Choose integration method",
      status: String(enumValue.integrationMethod.integration_type)->getStatusValue(
        #IntegrationMethod,
        currentPageStateEnum,
      ),
      link: "/",
    },
    {
      title: choiceState->sidebarTextBasedOnVariant,
      status: Boolean(enumValue.integrationCompleted)->getStatusValue(
        #IntegrationCompleted,
        currentPageStateEnum,
      ),
      link: "/",
      subOptions: [
        {
          title: "Download Test API Key",
          status: enumValue.downloadTestAPIKey->getStatusFromString,
        },
        {
          title: "Create a Payment",
          status: enumValue.createPayment->getStatusFromString,
        },
        {
          title: "Display Hyperswitch Checkout",
          status: enumValue.displayCheckout->getStatusFromString,
        },
        {
          title: "Display Payment Confirmation",
          status: enumValue.displayPaymentConfirmation->getStatusFromString,
        },
      ],
    },
  ]

  switch currentRoute {
  | MigrateFromStripe => migrateFromStripeSidebar
  | IntegrateFromScratch | _ => standardIntegrationSidebar
  }
}

let getConnectorStatus = (enumValueToCheck, connectorConfigureState, checkValue, currentEnum) => {
  open HSSelfServeSidebar
  let isConnectorConnected = enumValueToCheck->String.length > 0
  if isConnectorConnected || connectorConfigureState === checkValue {
    COMPLETED
  } else if connectorConfigureState == currentEnum {
    ONGOING
  } else {
    PENDING
  }
}

let getConnectorSubOptions = (
  choiceStateForTestConnector,
  valueToCheck,
  connectorConfigureState,
) => {
  if choiceStateForTestConnector === #TestApiKeys {
    []
  } else {
    let conectorSubOptions: array<HSSelfServeSidebar.subOption> = [
      {
        title: "Setup Sandbox Credentials",
        status: getConnectorStatus(
          valueToCheck.processorID,
          connectorConfigureState,
          Setup_payment_methods,
          Configure_keys,
        ),
      },
      {
        title: "Setup Payment Methods",
        status: getConnectorStatus(
          valueToCheck.processorID,
          connectorConfigureState,
          Summary,
          Setup_payment_methods,
        ),
      },
    ]
    conectorSubOptions
  }
}

let getSidebarOptionsForConnectProcessor: (
  string,
  quickStartType,
  configureProcessorTypes,
  choiceStateTypes,
) => array<HSSelfServeSidebar.sidebarOption> = (
  enumDetails,
  quickStartPageState,
  connectorConfigureState,
  choiceStateForTestConnector,
) => {
  // TODO:Refactor code to more dynamic cases

  open LogicUtils
  let enumValue = enumDetails->safeParse->getTypedValueFromDict
  let currentPageStateEnum = quickStartPageState->variantToEnumMapper
  if (
    enumValue.configurationType->connectorChoiceStringVariantMapper ===
      #MultipleProcessorWithSmartRouting
  ) {
    [
      {
        title: "Connect primary processor",
        status: String(enumValue.firstProcessorConnected.processorID)->getStatusValue(
          #FirstProcessorConnected,
          currentPageStateEnum,
        ),
        subOptions: choiceStateForTestConnector->getConnectorSubOptions(
          enumValue.firstProcessorConnected,
          connectorConfigureState,
        ),
        link: "/quick-start",
      },
      {
        title: "Connect secondary processor",
        status: String(enumValue.secondProcessorConnected.processorID)->getStatusValue(
          #SecondProcessorConnected,
          currentPageStateEnum,
        ),
        subOptions: choiceStateForTestConnector->getConnectorSubOptions(
          enumValue.secondProcessorConnected,
          connectorConfigureState,
        ),
        link: "/quick-start",
      },
      {
        title: "Configure smart routing",
        status: String(enumValue.configuredRouting.routing_id)->getStatusValue(
          #ConfiguredRouting,
          currentPageStateEnum,
        ),
        link: "/quick-start",
      },
      {
        title: "Try hyperswitch checkout",
        status: String(enumValue.testPayment.payment_id)->getStatusValue(
          #TestPayment,
          currentPageStateEnum,
        ),
        link: "/quick-start",
      },
    ]
  } else {
    [
      {
        title: "Connect Primary Processor",
        status: String(enumValue.firstProcessorConnected.processorID)->getStatusValue(
          #FirstProcessorConnected,
          currentPageStateEnum,
        ),
        subOptions: choiceStateForTestConnector->getConnectorSubOptions(
          enumValue.firstProcessorConnected,
          connectorConfigureState,
        ),
        link: "/quick-start",
      },
      {
        title: "Try hyperswitch checkout",
        status: String(enumValue.testPayment.payment_id)->getStatusValue(
          #TestPayment,
          currentPageStateEnum,
        ),
        link: "/quick-start",
      },
    ]
  }
}

let textToVariantMapper: string => choiceStateTypes = str => {
  switch str {
  | "MigrateFromStripe" => #MigrateFromStripe
  | "StandardIntegration" => #StandardIntegration
  | "WooCommercePlugin" => #WooCommercePlugin
  | _ => #MigrateFromStripe
  }
}
let textToVariantMapperForBuildHS = str => {
  open UserOnboardingTypes
  switch str {
  | "MigrateFromStripe" => MigrateFromStripe
  | "StandardIntegration" => IntegrateFromScratch
  | "WooCommercePlugin" => WooCommercePlugin
  | _ => MigrateFromStripe
  }
}

let stringToVariantMapperForUserData = str =>
  switch str {
  | "ProductionAgreement" => #ProductionAgreement
  | "FirstProcessorConnected" => #FirstProcessorConnected
  | "SecondProcessorConnected" => #SecondProcessorConnected
  | "ConfiguredRouting" => #ConfiguredRouting
  | "TestPayment" => #TestPayment
  | "IntegrationMethod" => #IntegrationMethod
  | "IntegrationCompleted" => #IntegrationCompleted
  | "StripeConnected" => #StripeConnected
  | "PaypalConnected" => #PaypalConnected
  | "SPRoutingConfigured" => #SPRoutingConfigured
  | "SPTestPayment" => #SPTestPayment
  | "DownloadWoocom" => #DownloadWoocom
  | "ConfigureWoocom" => #ConfigureWoocom
  | "SetupWoocomWebhook" => #SetupWoocomWebhook
  | "ConfigurationType" => #ConfigurationType
  | _ => #ProductionAgreement
  }

let generateBodyBasedOnType = (parentVariant: sectionHeadingVariant, value: requestObjectType) => {
  open LogicUtils
  switch value {
  | ProcesorType(processorTypeVal) =>
    [
      (
        (parentVariant :> string),
        [
          ("processor_id", processorTypeVal.processorID->Js.Json.string),
          ("processor_name", processorTypeVal.processorName->Js.Json.string),
        ]->getJsonFromArrayOfJson,
      ),
    ]->getJsonFromArrayOfJson
  | RoutingType(routingTypeVal) =>
    [
      (
        (parentVariant :> string),
        [("routing_id", routingTypeVal.routing_id->Js.Json.string)]->getJsonFromArrayOfJson,
      ),
    ]->getJsonFromArrayOfJson
  | PaymentType(paymentTypeVal) =>
    [
      (
        (parentVariant :> string),
        [("payment_id", paymentTypeVal.payment_id->Js.Json.string)]->getJsonFromArrayOfJson,
      ),
    ]->getJsonFromArrayOfJson

  | IntegrationMethod(integrationType) =>
    [
      (
        (parentVariant :> string),
        [
          ("integration_type", integrationType.integration_type->Js.Json.string),
        ]->getJsonFromArrayOfJson,
      ),
    ]->getJsonFromArrayOfJson
  | Boolean(_) => (parentVariant :> string)->Js.Json.string
  | String(str) => str->Js.Json.string
  | StringEnumType(stringValue) =>
    [((parentVariant :> string), stringValue->Js.Json.string)]->getJsonFromArrayOfJson
  }
}

let getInitialValueForConnector = enumValue => {
  let arr = []
  if enumValue.firstProcessorConnected.processorID->String.length > 0 {
    arr->Array.push(enumValue.firstProcessorConnected.processorName)
  }
  if enumValue.secondProcessorConnected.processorID->String.length > 0 {
    arr->Array.push(enumValue.secondProcessorConnected.processorName)
  }
  arr
}

let checkEmptyDict = (dict, variant) => {
  open LogicUtils
  dict->getJsonObjectFromDict(variant->getStringFromVariant)->getDictFromJsonObject->isEmptyDict
}

let checkBool = (dict, variant) => {
  open LogicUtils
  dict->getBool(variant->getStringFromVariant, false)
}

let checkString = (dict, variant) => {
  open LogicUtils
  dict->getString(variant->getStringFromVariant, "")
}

let getCurrentStep = dict => {
  if (
    // 1.ConfigurationType is empty
    // 2.FirstProcessorConnected dict is empty
    dict->checkString(#ConfigurationType)->String.length === 0 &&
      dict->checkEmptyDict(#FirstProcessorConnected)
  ) {
    #ConfigurationType
  } else if (
    // 1.ConfigurationType is Single
    // 2.FirstProcessorConnected dict is empty
    dict->checkString(#ConfigurationType)->connectorChoiceStringVariantMapper ===
      #SinglePaymentProcessor && dict->checkEmptyDict(#FirstProcessorConnected)
  ) {
    #FirstProcessorConnected
  } else if (
    // 1.ConfigurationType is Single
    // 2.FirstProcessorConnected dict is not empty
    dict->checkString(#ConfigurationType)->connectorChoiceStringVariantMapper ===
      #SinglePaymentProcessor &&
    !(dict->checkEmptyDict(#FirstProcessorConnected)) &&
    dict->checkEmptyDict(#TestPayment) === true
  ) {
    #TestPayment
  } else if (
    // 1.ConfigurationType is Single
    // 2.FirstProcessorConnected dict is not empty
    // 3.IntegrationMethod dict is empty
    dict->checkString(#ConfigurationType)->connectorChoiceStringVariantMapper ===
      #SinglePaymentProcessor &&
    !(dict->checkEmptyDict(#FirstProcessorConnected)) &&
    dict->checkEmptyDict(#IntegrationMethod) === true
  ) {
    #IntegrationMethod
  } else if (
    // 1.ConfigurationType is Multiple
    // 2.FirstProcessorConnected dict is empty
    dict->checkString(#ConfigurationType)->connectorChoiceStringVariantMapper ===
      #MultipleProcessorWithSmartRouting && dict->checkEmptyDict(#FirstProcessorConnected)
  ) {
    #FirstProcessorConnected
  } else if (
    // 1.ConfigurationType is Multiple
    // 2.FirstProcessorConnected dict is not empty
    // 3.SecondProcessorConnected dict is empty
    dict->checkString(#ConfigurationType)->connectorChoiceStringVariantMapper ===
      #MultipleProcessorWithSmartRouting &&
    !(dict->checkEmptyDict(#FirstProcessorConnected)) &&
    dict->checkEmptyDict(#SecondProcessorConnected)
  ) {
    #SecondProcessorConnected
  } else if (
    // 1.ConfigurationType is Multiple
    // 2.FirstProcessorConnected dict is not empty
    // 3.SecondProcessorConnected dict is not empty
    // 4.ConfiguredRouting dict is empty
    dict->checkString(#ConfigurationType)->connectorChoiceStringVariantMapper ===
      #MultipleProcessorWithSmartRouting &&
    !(dict->checkEmptyDict(#FirstProcessorConnected)) &&
    !(dict->checkEmptyDict(#SecondProcessorConnected)) &&
    dict->checkEmptyDict(#ConfiguredRouting)
  ) {
    #ConfiguredRouting
  } else if (
    // 1.ConfigurationType is Multiple
    // 2.FirstProcessorConnected dict is not empty
    // 3.SecondProcessorConnected dict is not empty
    // 4.ConfigureRouting dict is not empty
    // 5.TestPayment dict is empty
    dict->checkString(#ConfigurationType)->connectorChoiceStringVariantMapper ===
      #MultipleProcessorWithSmartRouting &&
    !(dict->checkEmptyDict(#FirstProcessorConnected)) &&
    !(dict->checkEmptyDict(#SecondProcessorConnected)) &&
    !(dict->checkEmptyDict(#ConfiguredRouting)) &&
    dict->checkEmptyDict(#TestPayment)
  ) {
    #TestPayment
  } else if (
    // 1.ConfigurationType is Multiple
    // 2.FirstProcessorConnected dict is not empty
    // 3.SecondProcessorConnected dict is not empty
    // 4.ConfiguredRouting dict is not empty
    // 5.IntegrationMethod dict is empty
    dict->checkString(#ConfigurationType)->connectorChoiceStringVariantMapper ===
      #MultipleProcessorWithSmartRouting &&
    !(dict->checkEmptyDict(#FirstProcessorConnected)) &&
    !(dict->checkEmptyDict(#SecondProcessorConnected)) &&
    !(dict->checkEmptyDict(#ConfiguredRouting)) &&
    dict->checkEmptyDict(#IntegrationMethod)
  ) {
    #IntegrationMethod
  } else if (
    // 1.IntegrationMethod dict is empty
    // 2.IntegrationCompleted false
    !(dict->checkEmptyDict(#IntegrationMethod)) && !(dict->checkBool(#IntegrationCompleted))
  ) {
    #IntegrationCompleted
  } else {
    #GoLive
  }
}
