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
  | AutomaticFlow => "AutomaticFlow"
  }
}

let payoutConnectorList: array<connectorTypes> = [Processors(ADYEN), Processors(WISE)]

let threedsAuthenticatorList: array<connectorTypes> = [
  ThreeDsAuthenticator(THREEDSECUREIO),
  ThreeDsAuthenticator(NETCETERA),
]

let connectorList: array<connectorTypes> = [
  Processors(STRIPE),
  Processors(PAYPAL),
  Processors(ACI),
  Processors(ADYEN),
  Processors(AIRWALLEX),
  Processors(AUTHORIZEDOTNET),
  Processors(BANKOFAMERICA),
  Processors(BAMBORA),
  Processors(BILLWERK),
  Processors(BITPAY),
  Processors(BLUESNAP),
  Processors(BRAINTREE),
  Processors(CASHTOCODE),
  Processors(CHECKOUT),
  Processors(COINBASE),
  Processors(CRYPTOPAY),
  Processors(CYBERSOURCE),
  Processors(DLOCAL),
  Processors(FISERV),
  Processors(FORTE),
  Processors(GLOBALPAY),
  Processors(GLOBEPAY),
  Processors(GOCARDLESS),
  Processors(HELCIM),
  Processors(IATAPAY),
  Processors(KLARNA),
  Processors(MOLLIE),
  Processors(MULTISAFEPAY),
  Processors(NEXINETS),
  Processors(NMI),
  Processors(NOON),
  Processors(NUVEI),
  Processors(OPENNODE),
  Processors(PAYME),
  Processors(PAYU),
  Processors(POWERTRANZ),
  Processors(PROPHETPAY),
  Processors(RAPYD),
  Processors(SHIFT4),
  Processors(STAX),
  Processors(TRUSTPAY),
  Processors(TSYS),
  Processors(VOLT),
  Processors(WORLDLINE),
  Processors(WORLDPAY),
  Processors(ZEN),
  Processors(ZSL),
  Processors(PLACETOPAY),
]

let connectorListForLive: array<connectorTypes> = [
  Processors(STRIPE),
  Processors(ADYEN),
  Processors(AUTHORIZEDOTNET),
  Processors(PAYPAL),
  Processors(BANKOFAMERICA),
  Processors(BLUESNAP),
  Processors(BRAINTREE),
  Processors(CHECKOUT),
  Processors(CRYPTOPAY),
  Processors(CASHTOCODE),
  Processors(CYBERSOURCE),
  Processors(IATAPAY),
  Processors(NMI),
  Processors(PAYME),
  Processors(TRUSTPAY),
  Processors(VOLT),
  Processors(ZEN),
]

let connectorListWithAutomaticFlow = [PAYPAL]

let getPaymentMethodFromString = paymentMethod => {
  switch paymentMethod->String.toLowerCase {
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
  switch paymentMethodType->String.toLowerCase {
  | "credit" => Credit
  | "debit" => Debit
  | "google_pay" => GooglePay
  | "apple_pay" => ApplePay
  | _ => UnknownPaymentMethodType(paymentMethodType)
  }
}

let dummyConnectorList = isTestProcessorsEnabled =>
  isTestProcessorsEnabled
    ? [
        Processors(STRIPE_TEST),
        Processors(PAYPAL_TEST),
        Processors(FAUXPAY),
        Processors(PRETENDPAY),
      ]
    : []

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

let threedsecuredotioInfo = {
  description: "A secure, affordable and easy to connect 3DS authentication platform. Improve the user experience during checkout, enhance the conversion rates and stay compliant with the regulations with 3dsecure.io",
}
let netceteraInfo = {
  description: "Cost-effective 3DS authentication platform ensuring security. Elevate checkout experience, boost conversion rates, and maintain regulatory compliance with Netcetera",
}

let unknownConnectorInfo = {
  description: "unkown connector",
}

let bankOfAmericaInfo = {
  description: "A top financial firm offering banking, investing, and risk solutions to individuals and businesses.",
}

let placetopayInfo = {
  description: "Reliable payment processor facilitating secure transactions online for businesses, ensuring seamless transactions.",
}

let billwerkInfo = {
  description: "Billwerk+ Pay is an acquirer independent payment gateway that helps you get the best acquirer rates, select a wide variety of payment methods.",
}

let zslInfo = {
  description: "It is a payment processor that enables businesses to accept payments securely through local bank transfers.",
}

let getConnectorNameString = (connector: processorTypes) =>
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
  | PLACETOPAY => "placetopay"
  | BILLWERK => "billwerk"
  | ZSL => "zsl"
  }

let getThreeDsAuthenticatorNameString = (threeDsAuthenticator: threeDsAuthenticatorTypes) =>
  switch threeDsAuthenticator {
  | THREEDSECUREIO => "threedsecureio"
  | NETCETERA => "netcetera"
  }

let getConnectorNameString = (connector: connectorTypes) => {
  switch connector {
  | Processors(connector) => connector->getConnectorNameString
  | ThreeDsAuthenticator(threeDsAuthenticator) =>
    threeDsAuthenticator->getThreeDsAuthenticatorNameString
  | UnknownConnector(str) => str
  }
}

let getConnectorNameTypeFromString = (connector, ~connectorType=ConnectorTypes.Processor, ()) => {
  switch connectorType {
  | Processor =>
    switch connector {
    | "adyen" => Processors(ADYEN)
    | "checkout" => Processors(CHECKOUT)
    | "braintree" => Processors(BRAINTREE)
    | "authorizedotnet" => Processors(AUTHORIZEDOTNET)
    | "stripe" => Processors(STRIPE)
    | "klarna" => Processors(KLARNA)
    | "globalpay" => Processors(GLOBALPAY)
    | "bluesnap" => Processors(BLUESNAP)
    | "airwallex" => Processors(AIRWALLEX)
    | "worldpay" => Processors(WORLDPAY)
    | "cybersource" => Processors(CYBERSOURCE)
    | "aci" => Processors(ACI)
    | "worldline" => Processors(WORLDLINE)
    | "fiserv" => Processors(FISERV)
    | "shift4" => Processors(SHIFT4)
    | "rapyd" => Processors(RAPYD)
    | "payu" => Processors(PAYU)
    | "nuvei" => Processors(NUVEI)
    | "multisafepay" => Processors(MULTISAFEPAY)
    | "dlocal" => Processors(DLOCAL)
    | "bambora" => Processors(BAMBORA)
    | "mollie" => Processors(MOLLIE)
    | "trustpay" => Processors(TRUSTPAY)
    | "zen" => Processors(ZEN)
    | "paypal" => Processors(PAYPAL)
    | "coinbase" => Processors(COINBASE)
    | "opennode" => Processors(OPENNODE)
    | "nmi" => Processors(NMI)
    | "forte" => Processors(FORTE)
    | "nexinets" => Processors(NEXINETS)
    | "iatapay" => Processors(IATAPAY)
    | "bitpay" => Processors(BITPAY)
    | "phonypay" => Processors(PHONYPAY)
    | "fauxpay" => Processors(FAUXPAY)
    | "pretendpay" => Processors(PRETENDPAY)
    | "stripe_test" => Processors(STRIPE_TEST)
    | "paypal_test" => Processors(PAYPAL_TEST)
    | "cashtocode" => Processors(CASHTOCODE)
    | "payme" => Processors(PAYME)
    | "globepay" => Processors(GLOBEPAY)
    | "powertranz" => Processors(POWERTRANZ)
    | "tsys" => Processors(TSYS)
    | "noon" => Processors(NOON)
    | "wise" => Processors(WISE)
    | "stax" => Processors(STAX)
    | "cryptopay" => Processors(CRYPTOPAY)
    | "gocardless" => Processors(GOCARDLESS)
    | "volt" => Processors(VOLT)
    | "bankofamerica" => Processors(BANKOFAMERICA)
    | "prophetpay" => Processors(PROPHETPAY)
    | "helcim" => Processors(HELCIM)
    | "placetopay" => Processors(PLACETOPAY)
    | "billwerk" => Processors(BILLWERK)
    | "zsl" => Processors(ZSL)
    | _ => UnknownConnector("Not known")
    }
  | ThreeDsAuthenticator =>
    switch connector {
    | "threedsecureio" => ThreeDsAuthenticator(THREEDSECUREIO)
    | "netcetera" => ThreeDsAuthenticator(NETCETERA)
    | _ => UnknownConnector("Not known")
    }
  | _ => UnknownConnector("Not known")
  }
}

let getProcessorInfo = connector => {
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
  | PLACETOPAY => placetopayInfo
  | BILLWERK => billwerkInfo
  | ZSL => zslInfo
  }
}
let getThreedsAuthenticatorInfo = threeDsAuthenticator =>
  switch threeDsAuthenticator {
  | THREEDSECUREIO => threedsecuredotioInfo
  | NETCETERA => netceteraInfo
  }

let getConnectorInfo = connector => {
  switch connector {
  | Processors(connector) => connector->getProcessorInfo
  | ThreeDsAuthenticator(threeDsAuthenticator) => threeDsAuthenticator->getThreedsAuthenticatorInfo
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

let getPaymentMethodMapper: JSON.t => array<paymentMethodConfigType> = json => {
  open LogicUtils
  getArrayDataFromJson(json, itemProviderMapper)
}

let itemToObjMapper = dict => {
  open LogicUtils
  {
    payment_method: dict->getString("payment_method", ""),
    payment_method_type: dict->getString("payment_method_type", ""),
    provider: dict->getArrayFromDict("provider", [])->JSON.Encode.array->getPaymentMethodMapper,
    card_provider: dict
    ->getArrayFromDict("card_provider", [])
    ->JSON.Encode.array
    ->getPaymentMethodMapper,
  }
}

let getPaymentMethodEnabled: JSON.t => array<paymentMethodEnabled> = json => {
  open LogicUtils
  getArrayDataFromJson(json, itemToObjMapper)
}

let connectorIgnoredField = [
  "business_country",
  "business_label",
  "business_sub_label",
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
    ->LogicUtils.getJsonFromArrayOfJson
  }
}

let mapAuthType = (authType: string) => {
  switch authType->String.toLowerCase {
  | "bodykey" => #BodyKey
  | "headerkey" => #HeaderKey
  | "signaturekey" => #SignatureKey
  | "multiauthkey" => #MultiAuthKey
  | "currencyauthkey" => #CurrencyAuthKey
  | "temporaryauth" => #TemporaryAuth
  | _ => #Nokey
  }
}

let getConnectorType = (connector: ConnectorTypes.connectorTypes, ~isPayoutFlow, ()) => {
  isPayoutFlow
    ? "payout_processor"
    : switch connector {
      | ThreeDsAuthenticator(_) => "authentication_processor"
      | UnknownConnector(str) => str
      | _ => "payment_processor"
      }
}

let getSelectedPaymentObj = (paymentMethodsEnabled: array<paymentMethodEnabled>, paymentMethod) => {
  paymentMethodsEnabled
  ->Array.find(item =>
    item.payment_method_type->String.toLowerCase == paymentMethod->String.toLowerCase
  )
  ->Option.getOr({
    payment_method: "unknown",
    payment_method_type: "unkonwn",
  })
}

let addMethod = (paymentMethodsEnabled, paymentMethod, method) => {
  let pmts = paymentMethodsEnabled->Array.copy
  switch paymentMethod->getPaymentMethodFromString {
  | Card =>
    pmts->Array.forEach((val: paymentMethodEnabled) => {
      if val.payment_method_type->String.toLowerCase === paymentMethod->String.toLowerCase {
        val.card_provider
        ->Option.getOr([]->JSON.Encode.array->getPaymentMethodMapper)
        ->Array.push(method)
      }
    })
  | _ =>
    pmts->Array.forEach((val: paymentMethodEnabled) => {
      if val.payment_method_type->String.toLowerCase === paymentMethod->String.toLowerCase {
        val.provider
        ->Option.getOr([]->JSON.Encode.array->getPaymentMethodMapper)
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
      if val.payment_method_type->String.toLowerCase === paymentMethod->String.toLowerCase {
        let indexOfRemovalItem =
          val.card_provider
          ->Option.getOr([]->JSON.Encode.array->getPaymentMethodMapper)
          ->Array.map(ele => ele.payment_method_type)
          ->Array.indexOf(method.payment_method_type)

        val.card_provider
        ->Option.getOr([]->JSON.Encode.array->getPaymentMethodMapper)
        ->Array.splice(
          ~start=indexOfRemovalItem,
          ~remove=1,
          ~insert=[]->JSON.Encode.array->getPaymentMethodMapper,
        )
      }
    })

  | _ =>
    pmts->Array.forEach((val: paymentMethodEnabled) => {
      if val.payment_method_type->String.toLowerCase === paymentMethod->String.toLowerCase {
        let indexOfRemovalItem =
          val.provider
          ->Option.getOr([]->JSON.Encode.array->getPaymentMethodMapper)
          ->Array.map(ele => ele.payment_method_type)
          ->Array.indexOf(method.payment_method_type)

        val.provider
        ->Option.getOr([]->JSON.Encode.array->getPaymentMethodMapper)
        ->Array.splice(
          ~start=indexOfRemovalItem,
          ~remove=1,
          ~insert=[]->JSON.Encode.array->getPaymentMethodMapper,
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
  ~connectorType: ConnectorTypes.connector=ConnectorTypes.Processor,
  (),
) => {
  open LogicUtils
  let dict = values->getDictFromJsonObject

  let connectorAccountDetails =
    dict->getJsonObjectFromDict("connector_account_details")->getDictFromJsonObject

  connectorAccountDetails->Dict.set("auth_type", bodyType->JSON.Encode.string)

  dict->Dict.set("connector_account_details", connectorAccountDetails->JSON.Encode.object)

  dict->Dict.set("connector_name", connector->JSON.Encode.string)
  dict->Dict.set(
    "connector_type",
    getConnectorType(
      connector->getConnectorNameTypeFromString(~connectorType, ()),
      ~isPayoutFlow,
      (),
    )->JSON.Encode.string,
  )
  dict->Dict.set("disabled", dict->getBool("disabled", false)->JSON.Encode.bool)
  dict->Dict.set("test_mode", (isLiveMode ? false : true)->JSON.Encode.bool)
  dict->Dict.set("connector_label", dict->getString("connector_label", "")->JSON.Encode.string)

  let connectorWebHookDetails =
    dict->getJsonObjectFromDict("connector_webhook_details")->getDictFromJsonObject

  dict->Dict.set(
    "connector_webhook_details",
    connectorWebHookDetails->getOptionString("merchant_secret")->Option.isSome
      ? connectorWebHookDetails->JSON.Encode.object
      : JSON.Encode.null,
  )

  dict->JSON.Encode.object
}

let getDisableConnectorPayload = (connectorType, previousConnectorState) => {
  [
    ("connector_type", connectorType->JSON.Encode.string),
    ("disabled", !previousConnectorState->JSON.Encode.bool),
  ]->Dict.fromArray
}

let getWebHookRequiredFields = (connector: connectorTypes, fieldName: string) => {
  switch (connector, fieldName) {
  | (Processors(ADYEN), "merchant_secret") => true
  | _ => false
  }
}

let getMetaDataRequiredFields = (connector: connectorTypes, fieldName: string) => {
  switch (connector, fieldName) {
  | (Processors(BLUESNAP), "merchant_id") => false
  | (Processors(CHECKOUT), "acquirer_bin") | (Processors(NMI), "acquirer_bin") => false
  | (Processors(CHECKOUT), "acquirer_merchant_id")
  | (Processors(NMI), "acquirer_merchant_id") => false
  | (ThreeDsAuthenticator(THREEDSECUREIO), "pull_mechanism_for_external_3ds_enabled") => false
  | _ => true
  }
}

let getAuthKeyMapFromConnectorAccountFields = connectorAccountFields => {
  open LogicUtils
  let authKeyMap =
    connectorAccountFields
    ->getDictfromDict("auth_key_map")
    ->JSON.Encode.object
    ->Identity.jsonToAnyType
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
  let value = dict->getDictfromDict(country)->Dict.keysToArray
  let result = value->Array.map(method => {
    let keys = dict->getDictfromDict(country)->getDictfromDict(method)->Dict.keysToArray
    keys->checkCashtoCodeFields(country, valuesFlattenJson)->Array.includes(false) ? false : true
  })

  result->Array.includes(true)
}

let validateConnectorRequiredFields = (
  connector: connectorTypes,
  valuesFlattenJson,
  connectorAccountFields,
  connectorMetaDataFields,
  connectorWebHookDetails,
  connectorLabelDetailField,
  errors,
) => {
  open LogicUtils
  let newDict = getDictFromJsonObject(errors)
  switch connector {
  | Processors(CASHTOCODE) => {
      let dict = connectorAccountFields->getAuthKeyMapFromConnectorAccountFields

      let indexLength = dict->Dict.keysToArray->Array.length
      let vector = Js.Vector.make(indexLength, false)

      dict
      ->Dict.keysToArray
      ->Array.forEachWithIndex((country, index) => {
        let res = checkCashtoCodeInnerField(valuesFlattenJson, dict, country)

        vector->Js.Vector.set(index, res)
      })

      let _ = Js.Vector.filterInPlace((. val) => val == true, vector)

      if vector->Js.Vector.length === 0 {
        Dict.set(newDict, "Currency", `Please enter currency`->JSON.Encode.string)
      }
    }
  | _ =>
    connectorAccountFields
    ->Dict.keysToArray
    ->Array.forEach(value => {
      let key = `connector_account_details.${value}`
      let errorKey = connectorAccountFields->getString(value, "")
      let value = valuesFlattenJson->getString(`connector_account_details.${value}`, "")
      if value->String.length === 0 {
        Dict.set(newDict, key, `Please enter ${errorKey}`->JSON.Encode.string)
      }
    })
  }
  connectorMetaDataFields
  ->Dict.keysToArray
  ->Array.forEach(fieldName => {
    let walletType = fieldName->getPaymentMethodTypeFromString
    if walletType !== GooglePay && walletType !== ApplePay {
      let key = `metadata.${fieldName}`
      let errorKey = connectorMetaDataFields->getString(fieldName, "")
      let value = valuesFlattenJson->getString(`metadata.${fieldName}`, "")
      if value->String.length === 0 && connector->getMetaDataRequiredFields(fieldName) {
        Dict.set(newDict, key, `Please enter ${errorKey}`->JSON.Encode.string)
      }
    }
  })

  connectorWebHookDetails
  ->Dict.keysToArray
  ->Array.forEach(fieldName => {
    let key = `connector_webhook_details.${fieldName}`
    let errorKey = connectorWebHookDetails->getString(fieldName, "")
    let value = valuesFlattenJson->getString(`connector_webhook_details.${fieldName}`, "")
    if value->String.length === 0 && connector->getWebHookRequiredFields(fieldName) {
      Dict.set(newDict, key, `Please enter ${errorKey}`->JSON.Encode.string)
    }
  })
  connectorLabelDetailField
  ->Dict.keysToArray
  ->Array.forEach(fieldName => {
    let errorKey = connectorLabelDetailField->getString(fieldName, "")
    let value = valuesFlattenJson->getString(fieldName, "")
    if value->String.length === 0 {
      Dict.set(newDict, fieldName, `Please enter ${errorKey}`->JSON.Encode.string)
    }
  })
  newDict->JSON.Encode.object
}

let getPlaceHolder = (connector: connectorTypes, fieldName, label) => {
  switch (connector, fieldName) {
  | (Processors(KLARNA), "api_key") => "Enter as:-Basic{API Key}"
  | _ => `Enter ${label->LogicUtils.snakeToTitle}`
  }
}

let getConnectorDetailsValue = (connectorInfo: connectorPayload, str) => {
  switch str {
  | "api_key" => connectorInfo.connector_account_details.api_key
  | "api_secret" => connectorInfo.connector_account_details.api_secret
  | "key1" => connectorInfo.connector_account_details.key1
  | "key2" => connectorInfo.connector_account_details.key2
  | "auth_type" => Some(connectorInfo.connector_account_details.auth_type)
  | _ => Some("")
  }
}
let connectorLabelDetailField = Dict.fromArray([
  ("connector_label", "Connector label"->JSON.Encode.string),
])
let getConnectorFields = connectorDetails => {
  open LogicUtils
  let connectorAccountDict =
    connectorDetails->getDictFromJsonObject->getDictfromDict("connector_auth")
  let bodyType = connectorAccountDict->Dict.keysToArray->Array.get(0)->Option.getOr("")
  let connectorAccountFields = connectorAccountDict->getDictfromDict(bodyType)
  let connectorMetaDataFields = connectorDetails->getDictFromJsonObject->getDictfromDict("metadata")
  let isVerifyConnector = connectorDetails->getDictFromJsonObject->getBool("is_verifiable", false)
  let connectorWebHookDetails =
    connectorDetails->getDictFromJsonObject->getDictfromDict("connector_webhook_details")
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
    let lastItem = fieldName->String.split(".")->Array.pop->Option.getOr("")
    let errorKey = dict->getString(lastItem, "")
    let value = valuesFlattenJson->getString(`${fieldName}`, "")
    if value->String.length === 0 {
      Dict.set(newDict, fieldName, `Please enter ${errorKey}`->JSON.Encode.string)
    }
  })
  newDict->JSON.Encode.object
}

let validate = (values, ~selectedConnector, ~dict, ~fieldName, ~isLiveMode) => {
  let errors = Dict.make()
  let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)
  let labelArr = dict->Dict.valuesToArray
  selectedConnector.validate
  ->Option.getOr([])
  ->Array.forEachWithIndex((field, index) => {
    let key = field.name
    let value =
      valuesFlattenJson
      ->Dict.get(key)
      ->Option.getOr(""->JSON.Encode.string)
      ->LogicUtils.getStringFromJson("")
    let regexToUse = isLiveMode ? field.liveValidationRegex : field.testValidationRegex
    let validationResult = switch regexToUse {
    | Some(regex) => regex->Js.Re.fromString->Js.Re.test_(value)
    | None => true
    }
    if field.isRequired->Option.getOr(true) && value->String.length === 0 {
      let errorLabel =
        labelArr
        ->Array.get(index)
        ->Option.getOr(""->JSON.Encode.string)
        ->LogicUtils.getStringFromJson("")
      Dict.set(errors, key, `Please enter ${errorLabel}`->JSON.Encode.string)
    } else if !validationResult && value->String.length !== 0 {
      let expectedFormat = isLiveMode ? field.liveExpectedFormat : field.testExpectedFormat
      let warningMessage = expectedFormat->Option.getOr("")
      Dict.set(errors, key, warningMessage->JSON.Encode.string)
    }
  })

  let profileId = valuesFlattenJson->LogicUtils.getString("profile_id", "")
  if profileId->String.length === 0 {
    Dict.set(errors, "Profile Id", `Please select your business profile`->JSON.Encode.string)
  }
  validateRequiredFiled(valuesFlattenJson, dict, fieldName, errors->JSON.Encode.object)
}

let getSuggestedAction = (~verifyErrorMessage, ~connector) => {
  let (suggestedAction, suggestedActionExists) = {
    open SuggestedActionHelper
    let msg = verifyErrorMessage->Option.getOr("")
    switch connector->getConnectorNameTypeFromString() {
    | Processors(STRIPE) => (
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
    | Processors(PAYPAL) => (
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
) => {
  setVerifyDone(_ => Loading)
  if verifyDone === NoAttempt && isVerifyConnector {
    onSubmitVerify(values)->ignore
  } else {
    onSubmitMain(values)->ignore
  }
  Nullable.null
}

let getWebhooksUrl = (~connectorName, ~merchantId) => {
  `${Window.env.apiBaseUrl}/webhooks/${merchantId}/${connectorName}`
}

let constructConnectorRequestBody = (wasmRequest: wasmRequest, payload: JSON.t) => {
  open LogicUtils
  let dict = payload->getDictFromJsonObject
  let connectorAccountDetails =
    dict->getDictfromDict("connector_account_details")->JSON.Encode.object
  let payLoadDetails: wasmExtraPayload = {
    connector_account_details: connectorAccountDetails,
    connector_webhook_details: dict->getDictfromDict("connector_webhook_details")->isEmptyDict
      ? None
      : Some(dict->getDictfromDict("connector_webhook_details")->JSON.Encode.object),
    connector_type: dict->getString("connector_type", ""),
    connector_name: dict->getString("connector_name", ""),
    profile_id: dict->getString("profile_id", ""),
    disabled: dict->getBool("disabled", false),
    test_mode: dict->getBool("test_mode", false),
  }
  let values = Window.getRequestPayload(wasmRequest, payLoadDetails)
  let dict = Dict.fromArray([
    ("connector_account_details", connectorAccountDetails),
    ("connector_label", dict->getString("connector_label", "")->JSON.Encode.string),
    ("status", dict->getString("status", "active")->JSON.Encode.string),
  ])
  values
  ->getDictFromJsonObject
  ->Dict.toArray
  ->Array.concat(dict->Dict.toArray)
  ->Dict.fromArray
  ->JSON.Encode.object
}

let defaultSelectAllCards = (
  pmts: array<paymentMethodEnabled>,
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
            ->JSON.Encode.array
            ->getPaymentMethodMapper

          let length =
            val.card_provider
            ->Option.getOr([]->JSON.Encode.array->getPaymentMethodMapper)
            ->Array.length
          val.card_provider
          ->Option.getOr([]->JSON.Encode.array->getPaymentMethodMapper)
          ->Array.splice(~start=0, ~remove=length, ~insert=arr)
        }
      | BankTransfer | BankRedirect => {
          let arr =
            config
            ->getArrayFromDict(val.payment_method_type, [])
            ->JSON.Encode.array
            ->getPaymentMethodMapper

          let length =
            val.provider->Option.getOr([]->JSON.Encode.array->getPaymentMethodMapper)->Array.length
          val.provider
          ->Option.getOr([]->JSON.Encode.array->getPaymentMethodMapper)
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
    defaultSelectAllCards(
      paymentMethodEnabled,
      isUpdateFlow,
      isPayoutFlow,
      connector,
      updateDetails,
    )
  } catch {
  | Exn.Error(e) => {
      let err = Exn.message(e)->Option.getOr("Something went wrong")
      Exn.raiseError(err)
    }
  }
}

let filterList = (items: array<ConnectorTypes.connectorPayload>, ~removeFromList: connector) => {
  items->Array.filter(dict => {
    let connectorType = dict.connector_type
    let isPayoutConnector = connectorType == "payout_processor"
    let isThreeDsAuthenticator = connectorType == "authentication_processor"
    let isConnector =
      connectorType !== "payment_vas" && !isPayoutConnector && !isThreeDsAuthenticator

    switch removeFromList {
    | Processor => !isConnector
    | FRMPlayer => isConnector
    | PayoutConnector => isPayoutConnector
    | ThreeDsAuthenticator => isThreeDsAuthenticator
    }
  })
}

let getProcessorsListFromJson = (
  connnectorList: array<ConnectorTypes.connectorPayload>,
  ~removeFromList: connector=FRMPlayer,
  (),
) => {
  connnectorList->filterList(~removeFromList)
}

let getDisplayNameForProcessor = connector =>
  switch connector {
  | ADYEN => "Adyen"
  | CHECKOUT => "Checkout"
  | BRAINTREE => "Braintree"
  | BILLWERK => "Billwerk"
  | AUTHORIZEDOTNET => "Authorize.net"
  | STRIPE => "Stripe"
  | KLARNA => "Klarna"
  | GLOBALPAY => "Global Payments"
  | BLUESNAP => "Bluesnap"
  | AIRWALLEX => "Airwallex"
  | WORLDPAY => "Worldpay"
  | CYBERSOURCE => "Cybersource"
  | ACI => "ACI Worldwide"
  | WORLDLINE => "Worldline"
  | FISERV => "Fiserv"
  | SHIFT4 => "Shift4"
  | RAPYD => "Rapyd"
  | PAYU => "PayU"
  | NUVEI => "Nuvei"
  | MULTISAFEPAY => "MultiSafepay"
  | DLOCAL => "dLocal"
  | BAMBORA => "Bambora"
  | MOLLIE => "Mollie"
  | TRUSTPAY => "TrustPay"
  | ZEN => "Zen"
  | PAYPAL => "PayPal"
  | COINBASE => "Coinbase"
  | OPENNODE => "Opennode"
  | NMI => "NMI"
  | FORTE => "Forte"
  | NEXINETS => "Nexinets"
  | IATAPAY => "IATA Pay"
  | BITPAY => "Bitpay"
  | PHONYPAY => "Phony Pay"
  | FAUXPAY => "Fauxpay"
  | PRETENDPAY => "Pretendpay"
  | CRYPTOPAY => "Cryptopay"
  | CASHTOCODE => "CashtoCode"
  | PAYME => "PayMe"
  | GLOBEPAY => "GlobePay"
  | POWERTRANZ => "Powertranz"
  | TSYS => "TSYS"
  | NOON => "Noon"
  | STRIPE_TEST => "Stripe Dummy"
  | PAYPAL_TEST => "Paypal Dummy"
  | WISE => "Wise"
  | STAX => "Stax"
  | GOCARDLESS => "GoCardless"
  | VOLT => "Volt"
  | PROPHETPAY => "Prophet Pay"
  | BANKOFAMERICA => "Bank of America"
  | HELCIM => "Helcim"
  | PLACETOPAY => "Placetopay"
  | ZSL => "ZSL"
  }

let getDisplayNameForThreedsAuthenticator = threeDsAuthenticator =>
  switch threeDsAuthenticator {
  | THREEDSECUREIO => "3dsecure.io"
  | NETCETERA => "Netcetera"
  }

let getDisplayNameForConnector = (~connectorType=ConnectorTypes.Processor, connector) => {
  let connectorType =
    connector->String.toLowerCase->getConnectorNameTypeFromString(~connectorType, ())
  switch connectorType {
  | Processors(connector) => connector->getDisplayNameForProcessor
  | ThreeDsAuthenticator(threeDsAuthenticator) =>
    threeDsAuthenticator->getDisplayNameForThreedsAuthenticator
  | UnknownConnector(str) => str
  }
}

let getConnectorTypeArrayFromListConnectors = (
  ~connectorType=ConnectorTypes.Processor,
  connectorsList: array<ConnectorTypes.connectorPayload>,
) => {
  connectorsList->Array.map(connectorDetail =>
    connectorDetail.connector_name->getConnectorNameTypeFromString(~connectorType, ())
  )
}

let connectorTypeStringToTypeMapper = connector_type => {
  switch connector_type {
  | "payment_processor" => PaymentProcessor
  | "payment_vas" => PaymentVas
  | "payout_processor" => PayoutProcessor
  | "authentication_processor" => AuthenticationProcessor
  | _ => PaymentProcessor
  }
}

let sortByName = (c1, c2) => {
  open LogicUtils
  compareLogic(c2->getConnectorNameString, c1->getConnectorNameString)
}

let existsInArray = (element, connectorList) => {
  open ConnectorTypes
  connectorList->Array.some(e =>
    switch (e, element) {
    | (Processors(p1), Processors(p2)) => p1 == p2
    | (_, _) => false
    }
  )
}
