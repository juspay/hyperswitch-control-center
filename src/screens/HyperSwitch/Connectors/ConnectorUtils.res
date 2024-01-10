open ConnectorTypes

type data = {code?: string, message?: string, type_?: string}
@scope("JSON") @val
external parseIntoMyData: string => data = "parse"

let stepsArr = [IntegFields, PaymentMethods, SummaryAndTest]

let payoutStepsArr = [IntegFields, PaymentMethods, SummaryAndTest]

let getStepName = step => {
  switch step {
  | IntegFields => "Credentials"
  | PaymentMethods => "Payment Methods"
  | SummaryAndTest => "Summary"
  | Preview => "Preview"
  }
}

let toLCase = str => str->String.toLowerCase
let len = arr => arr->Array.length

let payoutConnectorList: array<connectorName> = [ADYEN, WISE]

let connectorList: array<connectorName> = [
  STRIPE,
  PAYPAL,
  ACI,
  ADYEN,
  AIRWALLEX,
  AUTHORIZEDOTNET,
  BANKOFAMERICA,
  BAMBORA,
  BITPAY,
  BLUESNAP,
  BRAINTREE,
  CASHTOCODE,
  CHECKOUT,
  COINBASE,
  CRYPTOPAY,
  CYBERSOURCE,
  DLOCAL,
  FISERV,
  FORTE,
  GLOBALPAY,
  GLOBEPAY,
  GOCARDLESS,
  HELCIM,
  IATAPAY,
  KLARNA,
  MOLLIE,
  MULTISAFEPAY,
  NEXINETS,
  NMI,
  NOON,
  NUVEI,
  OPENNODE,
  PAYME,
  PAYU,
  POWERTRANZ,
  PROPHETPAY,
  RAPYD,
  SHIFT4,
  STAX,
  TRUSTPAY,
  TSYS,
  VOLT,
  WORLDLINE,
  WORLDPAY,
  ZEN,
]

let connectorListForLive: array<connectorName> = [
  STRIPE,
  ADYEN,
  PAYPAL,
  BANKOFAMERICA,
  BLUESNAP,
  BRAINTREE,
  CHECKOUT,
  CRYPTOPAY,
  CASHTOCODE,
  IATAPAY,
  PAYME,
  TRUSTPAY,
  ZEN,
]

let getPaymentMethodFromString = paymentMethod => {
  switch paymentMethod->toLCase {
  | "card" => Card
  | "debit" | "credit" => Card
  | "paylater" => PayLater
  | "wallet" => Wallet
  | "bank_redirect" => BankRedirect
  | "bank_transfer" => BankTransfer
  | "crypto" => Crypto
  | "bank_debit" => BankDebit
  | _ => UnknownPaymentMethod(paymentMethod)
  }
}

let getPaymentMethodTypeFromString = paymentMethodType => {
  switch paymentMethodType->toLCase {
  | "credit" => Credit
  | "debit" => Debit
  | "google_pay" => GooglePay
  | "apple_pay" => ApplePay
  | _ => UnknownPaymentMethodType(paymentMethodType)
  }
}

let dummyConnectorList = isTestProcessorsEnabled =>
  isTestProcessorsEnabled ? [STRIPE_TEST, PAYPAL_TEST, FAUXPAY, PRETENDPAY] : []

let checkIsDummyConnector = (connectorName, isTestProcessorsEnabled) =>
  isTestProcessorsEnabled->dummyConnectorList->Array.includes(connectorName)

let stripeInfo = {
  description: "Versatile processor supporting credit cards, digital wallets, and bank transfers.",
  validate: [
    {
      name: "connector_account_details.api_key",
      liveValidationRegex: "^sk_live_(.+)$",
      testValidationRegex: "^sk_test_(.+)$",
      liveExpectedFormat: "Secret key should have the prefix sk_live_",
      testExpectedFormat: "Secret key should have the prefix sk_test_",
    },
  ],
}

let goCardLessInfo = {
  description: "Simplify payment collection with a single, hassle-free integration across 30+ countries for Direct Debit payments.",
}

let adyenInfo = {
  description: "Global processor accepting major credit cards, e-wallets, and local payment methods.",
}

let checkoutInfo = {
  description: "Streamlined processor offering multiple payment options for a seamless checkout experience.",
  validate: [
    {
      name: "connector_account_details.api_key",
      liveValidationRegex: "^pk(?!_sbox).*",
      testValidationRegex: "^pk(_sbox)?_(.+)$",
      liveExpectedFormat: "API public key should begin with pk_ and not begin with pk_sbox_",
      testExpectedFormat: "API public key should begin with pk_",
    },
    {
      name: "connector_account_details.api_secret",
      liveValidationRegex: "^sk(?!_sbox).*",
      testValidationRegex: "^sk(_sbox)?_(.+)$",
      liveExpectedFormat: "API secret key should begin with sk_ and not begin with sk_sbox_",
      testExpectedFormat: "API secret key should begin with sk_",
    },
  ],
}
let braintreeInfo = {
  description: "Trusted processor supporting credit cards, e-checks, and mobile payments for secure online transactions.",
}

let klarnaInfo = {
  description: "Flexible processor offering buy now, pay later options, and seamless checkout experiences for shoppers.",
  inputFieldDescription: `Please enter API Key in this format: Basic {API Key}\n
Ex: If your API key is UE4wO please enter Basic UE4wO`,
}

let authorizedotnetInfo = {
  description: "Trusted processor supporting credit cards, e-checks, and mobile payments for secure online transactions.",
}

let globalpayInfo = {
  description: "Comprehensive processor providing global payment solutions for businesses of all sizes.",
}

let bluesnapInfo = {
  description: "All-in-one processor supporting global payment methods, subscription billing, and built-in fraud prevention.",
}

let airwallexInfo = {
  description: "Innovative processor enabling businesses to manage cross-border payments and foreign exchange seamlessly.",
}

let worldpayInfo = {
  description: "Leading processor facilitating secure online and in-person payments with global coverage and a range of payment options.",
}

let cybersourceInfo = {
  description: "Reliable processor providing fraud management tools, secure payment processing, and a variety of payment methods.",
}

let aciInfo = {
  description: "Trusted processor offering a wide range of payment solutions, including cards, digital wallets, and real-time bank transfers.",
}

let worldlineInfo = {
  description: "Comprehensive processor supporting secure payment acceptance across various channels and devices with advanced security features.",
}

let fiservInfo = {
  description: "Full-service processor offering secure payment solutions and innovative banking technologies for businesses of all sizes.",
}

let shift4Info = {
  description: "Integrated processor providing secure payment processing, advanced fraud prevention, and comprehensive reporting and analytics.",
}

let rapydInfo = {
  description: "Flexible processor enabling businesses to accept and disburse payments globally with a wide range of payment methods.",
}

let payuInfo = {
  description: "Reliable processor offering easy integration, multiple payment methods, and localized solutions for global businesses.",
}

let nuveiInfo = {
  description: "Payment technology company providing flexible, scalable, and secure payment solutions for businesses across various industries.",
}

let dlocalInfo = {
  description: "Cross-border payment processor enabling businesses to accept and send payments in emerging markets worldwide.",
}

let multisafepayInfo = {
  description: "Versatile processor supporting a wide range of payment methods, including credit cards, e-wallets, and online banking.",
}

let bamboraInfo = {
  description: "Comprehensive processor offering secure payment solutions and advanced features for businesses in various industries.",
}

let zenInfo = {
  description: "Modern processor providing seamless payment solutions with a focus on simplicity, security, and user experience.",
}

let mollieInfo = {
  description: "Developer-friendly processor providing simple and customizable payment solutions for businesses of all sizes.",
}

let trustpayInfo = {
  description: "Reliable processor offering secure online payment solutions, including credit cards, bank transfers, and e-wallets.",
}

let paypalInfo = {
  description: "Well-known processor enabling individuals and businesses to send, receive, and manage online payments securely.",
}

let coinbaseInfo = {
  description: "Cryptocurrency processor allowing businesses to accept digital currencies like Bitcoin, Ethereum, and more.",
}

let openNodeInfo = {
  description: "Bitcoin payment processor enabling businesses to accept Bitcoin payments and settle in their local currency.",
}

let nmiInfo = {
  description: "Versatile payment processor supporting various payment methods and offering advanced customization and integration capabilities.",
}

let iataPayInfo = {
  description: "IATA Pay is an alternative method for travelers to pay for air tickets purchased online by directly debiting their bank account. It improves speed and security of payments, while reducing payment costs.",
}

let bitPayInfo = {
  description: "BitPay is a payment service provider that allows businesses and individuals to accept and process payments in Bitcoin and other cryptocurrencies securely and conveniently.",
}

let nexinetsInfo = {
  description: "Leading Italian payment processor providing a wide range of payment solutions for businesses of all sizes.",
}

let forteInfo = {
  description: "Payment processor specializing in secure and reliable payment solutions for variuos industries like healthcare.",
}

let cryptopayInfo = {
  description: "Secure cryptocurrency payment solution. Simplify transactions with digital currencies. Convenient and reliable.",
}

let cashToCodeInfo = {
  description: "Secure cash-based payment solution. Generate barcode, pay with cash at retail. Convenient alternative for cash transactions online.",
}

let powertranzInfo = {
  description: "Versatile processor empowering businesses with flexible payment solutions for online and mobile transactions.",
}

let paymeInfo = {
  description: "Convenient and secure mobile payment solution for quick transactions anytime, anywhere.",
}

let globepayInfo = {
  description: "Global gateway for seamless cross-border payments, ensuring efficient transactions worldwide.",
}

let tsysInfo = {
  description: "Trusted provider offering reliable payment processing services to businesses of all sizes across the globe.",
}

let noonInfo = {
  description: "A leading fintech company revolutionizing payments with innovative, secure, and convenient solutions for seamless financial transactions.",
}

// Dummy Connector Info
let pretendpayInfo = {
  description: "Don't be fooled by the name - PretendPay is the real deal when it comes to testing your payments.",
}

let fauxpayInfo = {
  description: "Don't worry, it's not really fake - it's just FauxPay! Use it to simulate payments and refunds.",
}

let phonypayInfo = {
  description: "Don't want to use real money to test your payment flow? - PhonyPay lets you simulate payments and refunds",
}

let stripeTestInfo = {
  description: "A stripe test processor to test payments and refunds without real world consequences.",
}

let paypalTestInfo = {
  description: "A paypal test processor to simulate payment flows and experience hyperswitch checkout.",
}

let wiseInfo = {
  description: "Get your money moving internationally. Save up to 3.9x when you send with Wise.",
}

let staxInfo = {
  description: "Empowering businesses with effortless payment solutions for truly seamless transactions",
}

let voltInfo = {
  description: "A secure and versatile payment processor that facilitates seamless electronic transactions for businesses and individuals, offering a wide range of payment options and robust fraud protection.",
}
let prophetpayInfo = {
  description: "A secure, affordable, and easy-to-use credit card processing platform for any business.",
}

let helcimInfo = {
  description: "Helcim is the easy and affordable solution for small businesses accepting credit card payments.",
}

let unknownConnectorInfo = {
  description: "unkown connector",
}

let bankOfAmericaInfo = {
  description: "A top financial firm offering banking, investing, and risk solutions to individuals and businesses.",
}

let getConnectorNameString = connector => {
  switch connector {
  | ADYEN => "adyen"
  | CHECKOUT => "checkout"
  | BRAINTREE => "braintree"
  | AUTHORIZEDOTNET => "authorizedotnet"
  | STRIPE => "stripe"
  | KLARNA => "klarna"
  | GLOBALPAY => "globalpay"
  | BLUESNAP => "bluesnap"
  | AIRWALLEX => "airwallex"
  | WORLDPAY => "worldpay"
  | CYBERSOURCE => "cybersource"
  | ACI => "aci"
  | WORLDLINE => "worldline"
  | FISERV => "fiserv"
  | SHIFT4 => "shift4"
  | RAPYD => "rapyd"
  | PAYU => "payu"
  | NUVEI => "nuvei"
  | MULTISAFEPAY => "multisafepay"
  | DLOCAL => "dlocal"
  | BAMBORA => "bambora"
  | MOLLIE => "mollie"
  | TRUSTPAY => "trustpay"
  | ZEN => "zen"
  | PAYPAL => "paypal"
  | COINBASE => "coinbase"
  | OPENNODE => "opennode"
  | NMI => "nmi"
  | FORTE => "forte"
  | NEXINETS => "nexinets"
  | IATAPAY => "iatapay"
  | BITPAY => "bitpay"
  | PHONYPAY => "phonypay"
  | FAUXPAY => "fauxpay"
  | PRETENDPAY => "pretendpay"
  | CRYPTOPAY => "cryptopay"
  | CASHTOCODE => "cashtocode"
  | PAYME => "payme"
  | GLOBEPAY => "globepay"
  | POWERTRANZ => "powertranz"
  | TSYS => "tsys"
  | NOON => "noon"
  | STRIPE_TEST => "stripe_test"
  | PAYPAL_TEST => "paypal_test"
  | WISE => "wise"
  | STAX => "stax"
  | GOCARDLESS => "gocardless"
  | VOLT => "volt"
  | PROPHETPAY => "prophetpay"
  | BANKOFAMERICA => "bankofamerica"
  | HELCIM => "helcim"
  | UnknownConnector(str) => str
  }
}

let getConnectorNameTypeFromString = connector => {
  switch connector {
  | "adyen" => ADYEN
  | "checkout" => CHECKOUT
  | "braintree" => BRAINTREE
  | "authorizedotnet" => AUTHORIZEDOTNET
  | "stripe" => STRIPE
  | "klarna" => KLARNA
  | "globalpay" => GLOBALPAY
  | "bluesnap" => BLUESNAP
  | "airwallex" => AIRWALLEX
  | "worldpay" => WORLDPAY
  | "cybersource" => CYBERSOURCE
  | "aci" => ACI
  | "worldline" => WORLDLINE
  | "fiserv" => FISERV
  | "shift4" => SHIFT4
  | "rapyd" => RAPYD
  | "payu" => PAYU
  | "nuvei" => NUVEI
  | "multisafepay" => MULTISAFEPAY
  | "dlocal" => DLOCAL
  | "bambora" => BAMBORA
  | "mollie" => MOLLIE
  | "trustpay" => TRUSTPAY
  | "zen" => ZEN
  | "paypal" => PAYPAL
  | "coinbase" => COINBASE
  | "opennode" => OPENNODE
  | "nmi" => NMI
  | "forte" => FORTE
  | "nexinets" => NEXINETS
  | "iatapay" => IATAPAY
  | "bitpay" => BITPAY
  | "phonypay" => PHONYPAY
  | "fauxpay" => FAUXPAY
  | "pretendpay" => PRETENDPAY
  | "stripe_test" => STRIPE_TEST
  | "paypal_test" => PAYPAL_TEST
  | "cashtocode" => CASHTOCODE
  | "payme" => PAYME
  | "globepay" => GLOBEPAY
  | "powertranz" => POWERTRANZ
  | "tsys" => TSYS
  | "noon" => NOON
  | "wise" => WISE
  | "stax" => STAX
  | "cryptopay" => CRYPTOPAY
  | "gocardless" => GOCARDLESS
  | "volt" => VOLT
  | "bankofamerica" => BANKOFAMERICA
  | "prophetpay" => PROPHETPAY
  | "helcim" => HELCIM
  | _ => UnknownConnector("Not known")
  }
}

let getConnectorInfo = (connector: connectorName) => {
  switch connector {
  | STRIPE => stripeInfo
  | ADYEN => adyenInfo
  | GOCARDLESS => goCardLessInfo
  | CHECKOUT => checkoutInfo
  | BRAINTREE => braintreeInfo
  | AUTHORIZEDOTNET => authorizedotnetInfo
  | KLARNA => klarnaInfo
  | GLOBALPAY => globalpayInfo
  | BLUESNAP => bluesnapInfo
  | AIRWALLEX => airwallexInfo
  | WORLDPAY => worldpayInfo
  | CYBERSOURCE => cybersourceInfo
  | ACI => aciInfo
  | WORLDLINE => worldlineInfo
  | FISERV => fiservInfo
  | SHIFT4 => shift4Info
  | RAPYD => rapydInfo
  | PAYU => payuInfo
  | NUVEI => nuveiInfo
  | DLOCAL => dlocalInfo
  | MULTISAFEPAY => multisafepayInfo
  | BAMBORA => bamboraInfo
  | MOLLIE => mollieInfo
  | TRUSTPAY => trustpayInfo
  | ZEN => zenInfo
  | PAYPAL => paypalInfo
  | COINBASE => coinbaseInfo
  | OPENNODE => openNodeInfo
  | NEXINETS => nexinetsInfo
  | FORTE => forteInfo
  | NMI => nmiInfo
  | IATAPAY => iataPayInfo
  | BITPAY => bitPayInfo
  | CRYPTOPAY => cryptopayInfo
  | CASHTOCODE => cashToCodeInfo
  | PHONYPAY => phonypayInfo
  | FAUXPAY => fauxpayInfo
  | PRETENDPAY => pretendpayInfo
  | PAYME => paymeInfo
  | GLOBEPAY => globepayInfo
  | POWERTRANZ => powertranzInfo
  | WISE => wiseInfo
  | TSYS => tsysInfo
  | NOON => noonInfo
  | STRIPE_TEST => stripeTestInfo
  | PAYPAL_TEST => paypalTestInfo
  | STAX => staxInfo
  | VOLT => voltInfo
  | PROPHETPAY => prophetpayInfo
  | BANKOFAMERICA => bankOfAmericaInfo
  | HELCIM => helcimInfo
  | UnknownConnector(_) => unknownConnectorInfo
  }
}

let acceptedValues = dict => {
  open LogicUtils
  let values = {
    type_: dict->getString("type", "enable_only"),
    list: dict->getStrArray("list"),
  }
  values.list->Array.length > 0 ? Some(values) : None
}

let itemProviderMapper = dict => {
  open LogicUtils
  {
    payment_method_type: dict->getString("payment_method_type", ""),
    accepted_countries: dict->getDictfromDict("accepted_countries")->acceptedValues,
    accepted_currencies: dict->getDictfromDict("accepted_currencies")->acceptedValues,
    minimum_amount: dict->getOptionInt("minimum_amount"),
    maximum_amount: dict->getOptionInt("maximum_amount"),
    recurring_enabled: dict->getOptionBool("recurring_enabled"),
    installment_payment_enabled: dict->getOptionBool("installment_payment_enabled"),
    payment_experience: dict->getOptionString("payment_method_type"),
    card_networks: dict->getStrArrayFromDict("card_networks", []),
  }
}

let getPaymentMethodMapper: Js.Json.t => array<paymentMethodConfigType> = json => {
  open LogicUtils
  getArrayDataFromJson(json, itemProviderMapper)
}

let itemToObjMapper = dict => {
  open LogicUtils
  {
    payment_method: dict->getString("payment_method", ""),
    payment_method_type: dict->getString("payment_method_type", ""),
    provider: dict->getArrayFromDict("provider", [])->Js.Json.array->getPaymentMethodMapper,
    card_provider: dict
    ->getArrayFromDict("card_provider", [])
    ->Js.Json.array
    ->getPaymentMethodMapper,
  }
}

let getPaymentMethodEnabled: Js.Json.t => array<paymentMethodEnabled> = json => {
  open LogicUtils
  getArrayDataFromJson(json, itemToObjMapper)
}

let connectorIgnoredField = [
  "business_country",
  "business_label",
  "business_sub_label",
  "connector_label",
  "merchant_connector_id",
  "connector_name",
  "profile_id",
  "applepay_verified_domains",
]

let configKeysToIgnore = [
  "connector_auth",
  "is_verifiable",
  "metadata",
  "connector_webhook_details",
]

let verifyConnectorIgnoreField = [
  "business_country",
  "business_label",
  "business_sub_label",
  "connector_label",
  "merchant_connector_id",
  "applepay_verified_domains",
]

let ignoreFields = (json, id, fields) => {
  if id->String.length <= 0 || id === "new" {
    json
  } else {
    json
    ->LogicUtils.getDictFromJsonObject
    ->Dict.toArray
    ->Array.filter(entry => {
      let (key, _val) = entry
      !(fields->Array.includes(key))
    })
    ->Dict.fromArray
    ->Js.Json.object_
  }
}

let mapAuthType = (authType: string) => {
  switch authType->toLCase {
  | "bodykey" => #BodyKey
  | "headerkey" => #HeaderKey
  | "signaturekey" => #SignatureKey
  | "multiauthkey" => #MultiAuthKey
  | "currencyauthkey" => #CurrencyAuthKey
  | _ => #Nokey
  }
}

let getConnectorType = (connector, ~isPayoutFlow, ()) => {
  isPayoutFlow
    ? "payout_processor"
    : switch connector {
      | UnknownConnector(str) => str
      | _ => "payment_processor"
      }
}

let getSelectedPaymentObj = (paymentMethodsEnabled: array<paymentMethodEnabled>, paymentMethod) => {
  paymentMethodsEnabled
  ->Array.find(item => item.payment_method_type->toLCase == paymentMethod->toLCase)
  ->Belt.Option.getWithDefault({
    payment_method: "unknown",
    payment_method_type: "unkonwn",
  })
}

let addMethod = (paymentMethodsEnabled, paymentMethod, method) => {
  let pmts = paymentMethodsEnabled->Array.copy
  switch paymentMethod->getPaymentMethodFromString {
  | Card =>
    pmts->Array.forEach((val: paymentMethodEnabled) => {
      if val.payment_method_type->toLCase === paymentMethod->toLCase {
        val.card_provider
        ->Belt.Option.getWithDefault([]->Js.Json.array->getPaymentMethodMapper)
        ->Array.push(method)
      }
    })
  | _ =>
    pmts->Array.forEach((val: paymentMethodEnabled) => {
      if val.payment_method_type->toLCase === paymentMethod->toLCase {
        val.provider
        ->Belt.Option.getWithDefault([]->Js.Json.array->getPaymentMethodMapper)
        ->Array.push(method)
      }
    })
  }
  pmts
}

let removeMethod = (paymentMethodsEnabled, paymentMethod, method: paymentMethodConfigType) => {
  let pmts = paymentMethodsEnabled->Array.copy
  switch paymentMethod->getPaymentMethodFromString {
  | Card =>
    pmts->Array.forEach((val: paymentMethodEnabled) => {
      if val.payment_method_type->toLCase === paymentMethod->toLCase {
        let indexOfRemovalItem =
          val.card_provider
          ->Belt.Option.getWithDefault([]->Js.Json.array->getPaymentMethodMapper)
          ->Array.map(ele => ele.payment_method_type)
          ->Array.indexOf(method.payment_method_type)

        val.card_provider
        ->Belt.Option.getWithDefault([]->Js.Json.array->getPaymentMethodMapper)
        ->Array.splice(
          ~start=indexOfRemovalItem,
          ~remove=1,
          ~insert=[]->Js.Json.array->getPaymentMethodMapper,
        )
      }
    })

  | _ =>
    pmts->Array.forEach((val: paymentMethodEnabled) => {
      if val.payment_method_type->toLCase === paymentMethod->toLCase {
        let indexOfRemovalItem =
          val.provider
          ->Belt.Option.getWithDefault([]->Js.Json.array->getPaymentMethodMapper)
          ->Array.map(ele => ele.payment_method_type)
          ->Array.indexOf(method.payment_method_type)

        val.provider
        ->Belt.Option.getWithDefault([]->Js.Json.array->getPaymentMethodMapper)
        ->Array.splice(
          ~start=indexOfRemovalItem,
          ~remove=1,
          ~insert=[]->Js.Json.array->getPaymentMethodMapper,
        )
      }
    })
  }

  pmts
}

let generateInitialValuesDict = (
  ~values,
  ~connector: string,
  ~bodyType,
  ~isPayoutFlow=false,
  ~isLiveMode=false,
  (),
) => {
  open LogicUtils
  let dict = values->getDictFromJsonObject

  let connectorAccountDetails =
    dict->getJsonObjectFromDict("connector_account_details")->getDictFromJsonObject

  connectorAccountDetails->Dict.set("auth_type", bodyType->Js.Json.string)

  dict->Dict.set("connector_account_details", connectorAccountDetails->Js.Json.object_)

  dict->Dict.set("connector_name", connector->Js.Json.string)
  dict->Dict.set(
    "connector_type",
    getConnectorType(connector->getConnectorNameTypeFromString, ~isPayoutFlow, ())->Js.Json.string,
  )
  dict->Dict.set("disabled", dict->getBool("disabled", false)->Js.Json.boolean)
  dict->Dict.set("test_mode", (isLiveMode ? false : true)->Js.Json.boolean)
  dict->Dict.set("connector_label", dict->getString("connector_label", "")->Js.Json.string)

  let connectorWebHookDetails =
    dict->getJsonObjectFromDict("connector_webhook_details")->getDictFromJsonObject

  dict->Dict.set(
    "connector_webhook_details",
    connectorWebHookDetails->getOptionString("merchant_secret")->Belt.Option.isSome
      ? connectorWebHookDetails->Js.Json.object_
      : Js.Json.null,
  )

  dict->Js.Json.object_
}

let getDisableConnectorPayload = (connectorType, previousConnectorState) => {
  [
    ("connector_type", connectorType->Js.Json.string),
    ("disabled", !previousConnectorState->Js.Json.boolean),
  ]->Dict.fromArray
}

let getWebHookRequiredFields = (connector: connectorName, fieldName: string) => {
  switch (connector, fieldName) {
  | (ADYEN, "merchant_secret") => true
  | _ => false
  }
}

let getMetaDataRequiredFields = (connector: connectorName, fieldName: string) => {
  switch (connector, fieldName) {
  | (BLUESNAP, "merchant_id") => false
  | _ => true
  }
}

let getAuthKeyMapFromConnectorAccountFields = connectorAccountFields => {
  open LogicUtils
  open MapTypes
  let authKeyMap =
    connectorAccountFields->getDictfromDict("auth_key_map")->Js.Json.object_->changeType
  convertMapObjectToDict(authKeyMap)
}
let checkCashtoCodeFields = (keys, country, valuesFlattenJson) => {
  open LogicUtils
  keys->Array.map(field => {
    let key = `connector_account_details.auth_key_map.${country}.${field}`
    let value = valuesFlattenJson->getString(`${key}`, "")
    value->String.length === 0 ? false : true
  })
}

let checkCashtoCodeInnerField = (valuesFlattenJson, dict, country: string): bool => {
  open LogicUtils
  let value = dict->getDictfromDict(country)->Js.Dict.keys
  let result = value->Array.map(method => {
    let keys = dict->getDictfromDict(country)->getDictfromDict(method)->Js.Dict.keys
    keys->checkCashtoCodeFields(country, valuesFlattenJson)->Array.includes(false) ? false : true
  })

  result->Array.includes(true)
}

let validateConnectorRequiredFields = (
  connector: connectorName,
  valuesFlattenJson,
  connectorAccountFields,
  connectorMetaDataFields,
  connectorWebHookDetails,
  connectorLabelDetailField,
  errors,
) => {
  open LogicUtils
  let newDict = getDictFromJsonObject(errors)
  if connector === CASHTOCODE {
    let dict = connectorAccountFields->getAuthKeyMapFromConnectorAccountFields

    let indexLength = dict->Js.Dict.keys->Array.length
    let vector = Js.Vector.make(indexLength, false)

    dict
    ->Dict.keysToArray
    ->Array.forEachWithIndex((country, index) => {
      let res = checkCashtoCodeInnerField(valuesFlattenJson, dict, country)

      vector->Js.Vector.set(index, res)
    })

    let _ = Js.Vector.filterInPlace((. val) => val == true, vector)

    if vector->Js.Vector.length === 0 {
      Dict.set(newDict, "Currency", `Please enter currency`->Js.Json.string)
    }
  } else {
    connectorAccountFields
    ->Dict.keysToArray
    ->Array.forEach(value => {
      let key = `connector_account_details.${value}`
      let errorKey = connectorAccountFields->getString(value, "")
      let value = valuesFlattenJson->getString(`connector_account_details.${value}`, "")
      if value->String.length === 0 {
        Dict.set(newDict, key, `Please enter ${errorKey}`->Js.Json.string)
      }
    })
  }
  connectorMetaDataFields
  ->Dict.keysToArray
  ->Array.forEach(fieldName => {
    let walletType = fieldName->getPaymentMethodTypeFromString
    if walletType !== GooglePay && walletType !== ApplePay {
      let key = `metadata.${fieldName}`
      let errorKey = connectorMetaDataFields->LogicUtils.getString(fieldName, "")
      let value = valuesFlattenJson->LogicUtils.getString(`metadata.${fieldName}`, "")
      if value->String.length === 0 && connector->getMetaDataRequiredFields(fieldName) {
        Dict.set(newDict, key, `Please enter ${errorKey}`->Js.Json.string)
      }
    }
  })

  connectorWebHookDetails
  ->Dict.keysToArray
  ->Array.forEach(fieldName => {
    let key = `connector_webhook_details.${fieldName}`
    let errorKey = connectorWebHookDetails->LogicUtils.getString(fieldName, "")
    let value =
      valuesFlattenJson->LogicUtils.getString(`connector_webhook_details.${fieldName}`, "")
    if value->String.length === 0 && connector->getWebHookRequiredFields(fieldName) {
      Dict.set(newDict, key, `Please enter ${errorKey}`->Js.Json.string)
    }
  })
  connectorLabelDetailField
  ->Dict.keysToArray
  ->Array.forEach(fieldName => {
    let errorKey = connectorLabelDetailField->LogicUtils.getString(fieldName, "")
    let value = valuesFlattenJson->LogicUtils.getString(fieldName, "")
    if value->String.length === 0 {
      Dict.set(newDict, fieldName, `Please enter ${errorKey}`->Js.Json.string)
    }
  })
  newDict->Js.Json.object_
}

let getPlaceHolder = (connector: connectorName, fieldName, label) => {
  switch (connector, fieldName) {
  | (KLARNA, "api_key") => "Enter as:-Basic{API Key}"
  | _ => `Enter ${label->LogicUtils.snakeToTitle}`
  }
}

let getConnectorDetailsValue = (connectorInfo: ConnectorTypes.connectorPayload, str) => {
  switch str {
  | "api_key" => connectorInfo.connector_account_details.api_key
  | "api_secret" => connectorInfo.connector_account_details.api_secret
  | "key1" => connectorInfo.connector_account_details.key1
  | "key2" => connectorInfo.connector_account_details.key2
  | "auth_type" => Some(connectorInfo.connector_account_details.auth_type)
  | _ => Some("")
  }
}

let getConnectorFields = connectorDetails => {
  let connectorAccountDict =
    connectorDetails->LogicUtils.getDictFromJsonObject->LogicUtils.getDictfromDict("connector_auth")
  let bodyType =
    connectorAccountDict->Dict.keysToArray->Belt.Array.get(0)->Belt.Option.getWithDefault("")
  let connectorAccountFields = connectorAccountDict->LogicUtils.getDictfromDict(bodyType)
  let connectorMetaDataFields =
    connectorDetails->LogicUtils.getDictFromJsonObject->LogicUtils.getDictfromDict("metadata")
  let isVerifyConnector =
    connectorDetails->LogicUtils.getDictFromJsonObject->LogicUtils.getBool("is_verifiable", false)
  let connectorWebHookDetails =
    connectorDetails
    ->LogicUtils.getDictFromJsonObject
    ->LogicUtils.getDictfromDict("connector_webhook_details")
  let connectorLabelDetailField = Dict.fromArray([
    ("connector_label", "Connector label"->Js.Json.string),
  ])
  (
    bodyType,
    connectorAccountFields,
    connectorMetaDataFields,
    isVerifyConnector,
    connectorWebHookDetails,
    connectorLabelDetailField,
  )
}

let validateRequiredFiled = (valuesFlattenJson, dict, fieldName, errors) => {
  open LogicUtils
  let newDict = getDictFromJsonObject(errors)
  dict
  ->Dict.keysToArray
  ->Array.forEach(_value => {
    let lastItem = fieldName->String.split(".")->Array.pop->Belt.Option.getWithDefault("")
    let errorKey = dict->getString(lastItem, "")
    let value = valuesFlattenJson->getString(`${fieldName}`, "")
    if value->String.length === 0 {
      Dict.set(newDict, fieldName, `Please enter ${errorKey}`->Js.Json.string)
    }
  })
  newDict->Js.Json.object_
}

let validate = (values, ~selectedConnector, ~dict, ~fieldName, ~isLiveMode) => {
  let errors = Dict.make()
  let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)
  let labelArr = dict->Dict.valuesToArray
  selectedConnector.validate
  ->Belt.Option.getWithDefault([])
  ->Array.forEachWithIndex((field, index) => {
    let key = field.name
    let value =
      valuesFlattenJson
      ->Dict.get(key)
      ->Belt.Option.getWithDefault(""->Js.Json.string)
      ->LogicUtils.getStringFromJson("")
    let regexToUse = isLiveMode ? field.liveValidationRegex : field.testValidationRegex
    let validationResult = switch regexToUse {
    | Some(regex) => regex->Js.Re.fromString->Js.Re.test_(value)
    | None => true
    }
    if field.isRequired->Belt.Option.getWithDefault(true) && value->String.length === 0 {
      let errorLabel =
        labelArr
        ->Belt.Array.get(index)
        ->Belt.Option.getWithDefault(""->Js.Json.string)
        ->LogicUtils.getStringFromJson("")
      Dict.set(errors, key, `Please enter ${errorLabel}`->Js.Json.string)
    } else if !validationResult && value->String.length !== 0 {
      let expectedFormat = isLiveMode ? field.liveExpectedFormat : field.testExpectedFormat
      let warningMessage = expectedFormat->Belt.Option.getWithDefault("")
      Dict.set(errors, key, warningMessage->Js.Json.string)
    }
  })

  let profileId = valuesFlattenJson->LogicUtils.getString("profile_id", "")
  if profileId->String.length === 0 {
    Dict.set(errors, "Profile Id", `Please select your business profile`->Js.Json.string)
  }
  validateRequiredFiled(valuesFlattenJson, dict, fieldName, errors->Js.Json.object_)
}

let getSuggestedAction = (~verifyErrorMessage, ~connector) => {
  let (suggestedAction, suggestedActionExists) = {
    open SuggestedActionHelper
    let msg = verifyErrorMessage->Belt.Option.getWithDefault("")
    switch connector->getConnectorNameTypeFromString {
    | STRIPE => (
        {
          if msg->String.includes("Sending credit card numbers directly") {
            <StripSendingCreditCard />
          } else if msg->String.includes("Invalid API Key") {
            <StripeInvalidAPIKey />
          } else {
            React.null
          }
        },
        true,
      )
    | PAYPAL => (
        {
          if msg->String.includes("Client Authentication failed") {
            <PaypalClientAuthenticationFalied />
          } else {
            React.null
          }
        },
        true,
      )
    | _ => (React.null, false)
    }
  }
  (suggestedAction, suggestedActionExists)
}

let onSubmit = async (
  ~values,
  ~onSubmitVerify,
  ~onSubmitMain,
  ~setVerifyDone,
  ~verifyDone,
  ~isVerifyConnector,
  ~isVerifyConnectorFeatureEnabled,
) => {
  setVerifyDone(_ => Loading)
  if isVerifyConnectorFeatureEnabled && verifyDone === NoAttempt && isVerifyConnector {
    onSubmitVerify(values)->ignore
  } else {
    onSubmitMain(values)->ignore
  }
  Js.Nullable.null
}

let getWebhooksUrl = (~connectorName, ~merchantId) => {
  `${HSwitchGlobalVars.hyperSwitchApiPrefix}/webhooks/${merchantId}/${connectorName}`
}

let constructConnectorRequestBody = (wasmRequest: wasmRequest, payload: Js.Json.t) => {
  open LogicUtils
  let dict = payload->getDictFromJsonObject
  let connectorAccountDetails = dict->getDictfromDict("connector_account_details")->Js.Json.object_
  let payLoadDetails: wasmExtraPayload = {
    connector_account_details: connectorAccountDetails,
    connector_webhook_details: dict->getDictfromDict("connector_webhook_details")->isEmptyDict
      ? None
      : Some(dict->getDictfromDict("connector_webhook_details")->Js.Json.object_),
    connector_type: dict->getString("connector_type", ""),
    connector_name: dict->getString("connector_name", ""),
    profile_id: dict->getString("profile_id", ""),
    disabled: dict->getBool("disabled", false),
    test_mode: dict->getBool("test_mode", false),
  }
  let values = Window.getRequestPayload(wasmRequest, payLoadDetails)
  let dict = Dict.fromArray([
    ("connector_account_details", connectorAccountDetails),
    ("connector_label", dict->getString("connector_label", "")->Js.Json.string),
    ("status", dict->getString("status", "active")->Js.Json.string),
  ])
  values
  ->getDictFromJsonObject
  ->Dict.toArray
  ->Array.concat(dict->Dict.toArray)
  ->Dict.fromArray
  ->Js.Json.object_
}

let useFetchConnectorList = () => {
  open APIUtils
  let fetchDetails = useGetMethod()
  let setConnectorList = HyperswitchAtom.connectorListAtom->Recoil.useSetRecoilState

  async _ => {
    try {
      let url = getURL(~entityName=CONNECTOR, ~methodType=Get, ())
      let res = await fetchDetails(url)
      let stringifiedResponse = res->Js.Json.stringify
      setConnectorList(._ => stringifiedResponse)
      res
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
        Js.Exn.raiseError(err)
      }
    }
  }
}

let defaultSelectAllCards = (
  pmts: array<ConnectorTypes.paymentMethodEnabled>,
  isUpdateFlow,
  isPayoutFlow,
  connector,
  updateDetails,
) => {
  open LogicUtils
  if !isUpdateFlow {
    let config =
      (
        isPayoutFlow
          ? Window.getPayoutConnectorConfig(connector)
          : Window.getConnectorConfig(connector)
      )->getDictFromJsonObject
    pmts->Array.forEach(val => {
      switch val.payment_method->getPaymentMethodFromString {
      | Card => {
          let arr =
            config
            ->getArrayFromDict(val.payment_method_type, [])
            ->Js.Json.array
            ->getPaymentMethodMapper

          let length =
            val.card_provider
            ->Belt.Option.getWithDefault([]->Js.Json.array->getPaymentMethodMapper)
            ->len
          val.card_provider
          ->Belt.Option.getWithDefault([]->Js.Json.array->getPaymentMethodMapper)
          ->Array.splice(~start=0, ~remove=length, ~insert=arr)
        }
      | BankTransfer | BankRedirect => {
          let arr =
            config
            ->getArrayFromDict(val.payment_method_type, [])
            ->Js.Json.array
            ->getPaymentMethodMapper

          let length =
            val.provider->Belt.Option.getWithDefault([]->Js.Json.array->getPaymentMethodMapper)->len
          val.provider
          ->Belt.Option.getWithDefault([]->Js.Json.array->getPaymentMethodMapper)
          ->Array.splice(~start=0, ~remove=length, ~insert=arr)
        }
      | _ => ()
      }
    })
    updateDetails(pmts)
  }
}

let getConnectorPaymentMethodDetails = async (
  initialValues,
  setPaymentMethods,
  setMetaData,
  setScreenState,
  isUpdateFlow,
  isPayoutFlow,
  connector,
  updateDetails,
) => {
  open LogicUtils
  try {
    let json = Window.getResponsePayload(initialValues)
    let metaData = json->getDictFromJsonObject->getJsonObjectFromDict("metadata")
    let paymentMethodEnabled =
      json
      ->getDictFromJsonObject
      ->getJsonObjectFromDict("payment_methods_enabled")
      ->getPaymentMethodEnabled
    setPaymentMethods(_ => paymentMethodEnabled)
    setMetaData(_ => metaData)
    setScreenState(_ => PageLoaderWrapper.Success)
    defaultSelectAllCards(
      paymentMethodEnabled,
      isUpdateFlow,
      isPayoutFlow,
      connector,
      updateDetails,
    )
  } catch {
  | Js.Exn.Error(e) => {
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Something went wrong")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }
}
