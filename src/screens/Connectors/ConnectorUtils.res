open ConnectorTypes

type data = {code?: string, message?: string, type_?: string}
@scope("JSON") @val
external parseIntoMyData: string => data = "parse"

let payoutStepsArr = [IntegFields, PaymentMethods, SummaryAndTest]

let getStepName = step => {
  switch step {
  | IntegFields => "Credentials"
  | PaymentMethods => "Payment Methods"
  | SummaryAndTest => "Summary"
  | Preview => "Preview"
  | CustomMetadata => "Metadata"
  | AutomaticFlow => "AutomaticFlow"
  }
}

let payoutConnectorList: array<connectorTypes> = [
  PayoutProcessor(ADYEN),
  PayoutProcessor(ADYENPLATFORM),
  PayoutProcessor(CYBERSOURCE),
  PayoutProcessor(EBANX),
  PayoutProcessor(PAYPAL),
  PayoutProcessor(STRIPE),
  PayoutProcessor(WISE),
  PayoutProcessor(NOMUPAY),
]

let threedsAuthenticatorList: array<connectorTypes> = [
  ThreeDsAuthenticator(THREEDSECUREIO),
  ThreeDsAuthenticator(NETCETERA),
  ThreeDsAuthenticator(CLICK_TO_PAY_MASTERCARD),
  ThreeDsAuthenticator(JUSPAYTHREEDSSERVER),
  ThreeDsAuthenticator(CLICK_TO_PAY_VISA),
]

let threedsAuthenticatorListForLive: array<connectorTypes> = [ThreeDsAuthenticator(NETCETERA)]

let pmAuthenticationConnectorList: array<connectorTypes> = [PMAuthenticationProcessor(PLAID)]

let taxProcessorList: array<connectorTypes> = [TaxProcessor(TAXJAR)]

let connectorList: array<connectorTypes> = [
  Processors(STRIPE),
  Processors(PAYPAL),
  Processors(ACI),
  Processors(ADYEN),
  Processors(AFFIRM),
  Processors(AIRWALLEX),
  Processors(AUTHORIZEDOTNET),
  Processors(BANKOFAMERICA),
  Processors(BAMBORA),
  Processors(BILLWERK),
  Processors(BITPAY),
  Processors(BLACKHAWKNETWORK),
  Processors(BLUESNAP),
  Processors(BRAINTREE),
  Processors(CASHTOCODE),
  Processors(CHECKBOOK),
  Processors(CHECKOUT),
  Processors(COINBASE),
  Processors(COINGATE),
  Processors(CRYPTOPAY),
  Processors(CYBERSOURCE),
  Processors(DATATRANS),
  Processors(DLOCAL),
  Processors(DWOLLA),
  Processors(ELAVON),
  Processors(FISERV),
  Processors(FISERVIPG),
  Processors(FORTE),
  Processors(GLOBALPAY),
  Processors(GLOBEPAY),
  Processors(GOCARDLESS),
  Processors(HELCIM),
  Processors(IATAPAY),
  Processors(KLARNA),
  Processors(MIFINITY),
  Processors(MOLLIE),
  Processors(MULTISAFEPAY),
  Processors(NEXINETS),
  Processors(NMI),
  Processors(NOON),
  Processors(NUVEI),
  Processors(OPENNODE),
  Processors(PAYME),
  Processors(PAYU),
  Processors(PEACHPAYMENTS),
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
  Processors(WORLDPAYXML),
  Processors(ZEN),
  Processors(ZSL),
  Processors(PLACETOPAY),
  Processors(RAZORPAY),
  Processors(BAMBORA_APAC),
  Processors(ITAUBANK),
  Processors(PLAID),
  Processors(SQUARE),
  Processors(PAYBOX),
  Processors(FIUU),
  Processors(WELLSFARGO),
  Processors(NOVALNET),
  Processors(DEUTSCHEBANK),
  Processors(NEXIXPAY),
  Processors(NORDEA),
  Processors(JPMORGAN),
  Processors(XENDIT),
  Processors(INESPAY),
  Processors(MONERIS),
  Processors(REDSYS),
  Processors(HIPAY),
  Processors(PAYSTACK),
  Processors(FACILITAPAY),
  Processors(ARCHIPEL),
  Processors(AUTHIPAY),
  Processors(WORLDPAYVANTIV),
  Processors(BARCLAYCARD),
  Processors(SILVERFLOW),
  Processors(TOKENIO),
  Processors(PAYLOAD),
  Processors(PAYTM),
  Processors(PHONEPE),
  Processors(FLEXITI),
  Processors(BREADPAY),
  Processors(BLUECODE),
  Processors(PAYSAFE),
]

let connectorListForLive: array<connectorTypes> = [
  Processors(ADYEN),
  Processors(AUTHORIZEDOTNET),
  Processors(ARCHIPEL),
  Processors(BANKOFAMERICA),
  Processors(BLUESNAP),
  Processors(BAMBORA),
  Processors(BRAINTREE),
  Processors(CHECKOUT),
  Processors(CRYPTOPAY),
  Processors(CASHTOCODE),
  Processors(CYBERSOURCE),
  Processors(COINGATE),
  Processors(DATATRANS),
  Processors(FIUU),
  Processors(IATAPAY),
  Processors(KLARNA),
  Processors(MIFINITY),
  Processors(NEXIXPAY),
  Processors(NMI),
  Processors(NOVALNET),
  Processors(PAYPAL),
  Processors(PAYBOX),
  Processors(PAYME),
  Processors(REDSYS),
  Processors(STRIPE),
  Processors(TRUSTPAY),
  Processors(VOLT),
  Processors(WORLDPAY),
  Processors(ZSL),
  Processors(ZEN),
]

let connectorListWithAutomaticFlow = [PAYPAL]

let getPaymentMethodFromString = paymentMethod => {
  switch paymentMethod->String.toLowerCase {
  | "card" => Card
  | "debit" | "credit" => Card
  | "pay_later" => PayLater
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
  | "paypal" => PayPal
  | "klarna" => Klarna
  | "open_banking_pis" => OpenBankingPIS
  | "samsung_pay" => SamsungPay
  | "paze" => Paze
  | "alipay" => AliPay
  | "wechatpay" => WeChatPay
  | "directcarrierbilling" => DirectCarrierBilling
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
  if isTestProcessorsEnabled {
    switch connectorName {
    | Processors(STRIPE_TEST)
    | Processors(PAYPAL_TEST)
    | Processors(FAUXPAY)
    | Processors(PRETENDPAY) => true
    | _ => false
    }
  } else {
    false
  }

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

let adyenPlatformInfo = {
  description: "Send payout to third parties with Adyen's Balance Platform!",
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

let worldpayxmlInfo = {
  description: "Worldpay XML connector enables payment processing through Worldpay’s XML API, allowing seamless transaction requests and responses using structured XML messages.",
}

let cybersourceInfo = {
  description: "Reliable processor providing fraud management tools, secure payment processing, and a variety of payment methods.",
}

let coingateInfo = {
  description: "CoinGate is a cryptocurrency payment gateway that enables businesses to accept Bitcoin, Ethereum, and other cryptocurrencies as payment. It provides APIs, plugins, and point-of-sale solutions for merchants, supporting features like automatic conversion to fiat, payouts, and payment processing for various blockchain networks.",
}

let ebanxInfo = {
  description: "Ebanx enables global organizations to grow exponentially in Rising Markets by leveraging a platform of end-to-end localized payment and financial solutions.",
}

let elavonInfo = {
  description: "Elavon is a global payment processing company that provides businesses with secure and reliable payment solutions. As a subsidiary of U.S. Bank, Elavon serves merchants in various industries, offering services such as credit card processing, mobile payments, e-commerce solutions, and fraud prevention tools.",
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

let fiservIPGInfo = {
  description: "Internet Payment Gateway(IPG) is an application from Fiserv which offers Internet payment services in Europe, Middle East and Africa.",
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
let jpmorganInfo = {
  description: "JPMorgan Connector is a payment integration module that supports businesses in regions like the United States (US), United Kingdom (UK), European Union (EU), and Canada (CA). It streamlines payment operations by enabling seamless processing of authorizations, captures, and refunds through JPMorgan’s payment gateway. This robust solution helps businesses manage transactions efficiently, ensuring secure and compliant payment processing across these regions.",
}

let xenditInfo = {
  description: "Xendit is a financial technology company that provides payment infrastructure across Southeast Asia. Its platform enables businesses to accept payments, disburse funds, manage accounts, and streamline financial operations",
}

let inespayInfo = {
  description: "Inespay is an online bank transfer payment gateway that operates in three simple steps without the need for prior registration. It is registered as a payment institution authorized by the Bank of Spain with number 6902. Specializing in integrating bank transfer as an online payment method on all kinds of web platforms, especially in B2B environments. It collaborates with leaders in various economic sectors, offering a real-time bank transfer income service and automatic reconciliation.",
}
let monerisInfo = {
  description: "Unify your retail operations with the combined power of Moneris and Wix, in an all-in-one omnichannel POS solution.",
}

let redsysInfo = {
  description: "Redsys is a Spanish payment gateway offering secure and innovative payment solutions for merchants and banks.",
}
let hipayInfo = {
  description: "HiPay is a global payment service provider offering a range of solutions for online, mobile, and in-store payments. It supports multiple payment methods, including credit cards, e-wallets, and local payment options, with a focus on fraud prevention and data-driven insights.",
}

let paystackInfo = {
  description: "Paystack is a technology company solving payments problems for ambitious businesses. Paystack builds technology to help Africa's best businesses grow - from new startups, to market leaders launching new business models.",
}

let facilitapayInfo = {
  description: "Facilitapay is a payment provider for international businesses.Their all-in-one payment hub encompasses all payment methods,pay-ins and pay-outs.",
}

let barclaycardInfo = {
  description: "Barclaycard, part of Barclays Bank UK PLC, is a leading global payment business that helps consumers, retailers and businesses to make and take payments flexibly, and to access short-term credit and point of sale finance.",
}
let tokenioInfo = {
  description: "Token.io is a fintech company that provides open banking-based, account-to-account (A2A) payment infrastructure—essentially enabling “Pay by Bank” solutions for banks, fintechs, platforms, and payment service providers.",
}

let payloadInfo = {
  description: "Payload is an embedded finance solution for modern platforms and businesses, automating inbound and outbound payments with an industry-leading platform and driving innovation into the future.",
}

let paysafeInfo = {
  description: "Paysafe gives ambitious businesses a launchpad with safe, secure online payment solutions, and gives consumers the ability to turn their transactions into meaningful experiences.",
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

let clickToPayInfo = {
  description: "Secure online payment method that allows customers to make purchases without manually entering their card details or reaching for their card",
}
let clickToPayVisaInfo = {
  description: "Secure online payment method that allows customers to make purchases without manually entering their card details or reaching for their card",
}

let juspayThreeDsServerInfo = {
  description: "Juspay's cost-effective 3DS platform, ensures security, compliance, and seamless checkout—reducing fraud, boosting conversions, and enhancing customer trust with frictionless authentication.",
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
let mifinityInfo = {
  description: "Empowering you to pay online, receive funds, and send money globally, the MiFinity eWallet supports super-low fees, offering infinite possibilities to do more of the things you love.",
}

let zslInfo = {
  description: "It is a payment processor that enables businesses to accept payments securely through local bank transfers.",
}

let razorpayInfo = {
  description: "Razorpay helps you accept online payments from customers across Desktop, Mobile web, Android & iOS. Additionally by using Razorpay Payment Links, you can collect payments across multiple channels like SMS, Email, Whatsapp, Chatbots & Messenger.",
}

let bamboraApacInfo = {
  description: "Bambora offers the ability to securely and efficiently process online, real-time transactions via an API, our user-friendly interface. The API web service accepts and processes SOAP requests from a remote location over TCP/IP. Transaction results are returned in real-time via the API.",
}

let itauBankInfo = {
  description: "The Banking as a Service (BaaS) solution allows non-financial companies to offer services with the ecosystem that banking institutions have. Itaú as a Service (IaaS) is the ideal tool for your company to improve your customers' experience, offering a whole new portfolio of products, with Itaú's technology and security.",
}
let dataTransInfo = {
  description: "Datatrans is a Swiss payment service provider offering secure online, mobile, and in-store payment processing. Key features include support for multiple payment methods, fraud prevention, multi-currency transactions, and integration options for websites and apps.",
}

let plaidInfo = {
  description: "Plaid Link makes it easy for users to connect their financial accounts securely and quickly, giving you the best growth for your business.",
}

let squareInfo = {
  description: "Powering all the ways you do business. Work smarter, automate for efficiency, and open up new revenue streams on the software and hardware platform millions of businesses trust.",
}

let payboxInfo = {
  description: "Paybox, operated by Verifone, offers secure online payment solutions for e-commerce businesses. It supports a wide range of payment methods and provides features like one-click payments, recurring payments, and omnichannel payment processing. Their services cater to merchants, web agencies, integrators, and financial institutions, helping them accept various forms of payment",
}

let wellsfargoInfo = {
  description: "WellsFargo is a leading American financial services company providing a comprehensive range of banking, investment, and mortgage products. With a focus on personal, small business, and commercial banking, Wells Fargo offers services such as checking and savings accounts, loans, credit cards, wealth management, and payment processing solutions.",
}

let fiuuInfo = {
  description: "Fiuu has been the premier merchant service provider in Southeast Asia since 2005, connecting international brands to consumers across the region. The company helps its clients establish a foothold in Southeast Asia's market by offering a full range of alternative payment methods, such as online banking, cash at 7-Eleven (Fiuu Cash), e-wallets, and more. Fiuu provides comprehensive payment solutions to facilitate market entry and expansion for businesses looking to reach Southeast Asian consumers.",
}

let novalnetInfo = {
  description: "Novalnet is a global payment service provider and financial technology company based in Germany. It offers a wide range of payment processing solutions and services to merchants and businesses, enabling them to accept various forms of payments online, in-store, or through mobile platforms.",
}

let deutscheBankInfo = {
  description: "Deutsche Bank is a German multinational investment bank and financial services company.",
}

let taxJarInfo = {
  description: "TaxJar is reimagining how businesses manage sales tax compliance. Its cloud-based platform automates the entire sales tax life cycle across all sales channels — from calculations and nexus tracking to reporting and filing.",
}

let chargebeeInfo = {
  description: "Chargebee is a subscription management and billing platform that integrates with multiple payment gateways, allowing businesses to accept payments across various geographies and currencies.",
}

let stripeBillingInfo = {
  description: "Stripe Billing connector enables automated subscription management, invoicing, and recurring payments using Stripe's billing infrastructure.",
}

let customBillingInfo = {
  description: "Stripe Billing connector enables automated subscription management, invoicing, and recurring payments using Stripe's billing infrastructure.",
}

let nexixpayInfo = {
  description: "Nexi's latest generation virtual POS is designed for those who, through a website, want to sell goods or services by managing payments online.",
}

let nordeaInfo = {
  description: "Nordea is a leading Nordic universal bank - we are a strong and personal financial partner with financial solutions that best meet your needs so you can achieve your goals and realise your dreams.",
}

let authipayInfo = {
  description: "Authipay is a convenient and cost-effective way to process payments online. It combines a payment gateway with merchant account services in one handy service. Request your demo today.",
}

let silverflowInfo = {
  description: "Silverflow provides a direct connection to the card networks that is always up to date. Enabling PSPs, payfacs, merchants and acquirers to innovate.",
}

let checkbookInfo = {
  description: "Checkbook offers businesses a versatile and embeddable way to scale their payouts. As a leading provider of both paper and digital options, we're uniquely positioned to enable the speed, flexibility, and cost savings of modern payments, with the familiarity and simplicity of paper checks.",
}

let affirmInfo = {
  description: "Affirm connector is a payment gateway integration that processes Affirm's buy now, pay later financing by managing payment authorization, capture, refunds, and transaction sync via Affirm's API.",
}
let nomupayInfo = {
  description: "A payment processing and software provider, that offers solutions such as e-commerce solutions, subscription billing services, payment gateways, and merchant accounts, to businesses of all sizes.",
}

let signifydInfo = {
  description: "One platform to protect the entire shopper journey end-to-end",
  validate: [
    {
      placeholder: "Enter API Key",
      label: "API Key",
      name: "connector_account_details.api_key",
      isRequired: true,
      encodeToBase64: false,
    },
  ],
}

let riskifyedInfo = {
  description: "Frictionless fraud management for eCommerce",
  validate: [
    {
      placeholder: "Enter Secret token",
      label: "Secret token",
      name: "connector_account_details.api_key",
      isRequired: true,
      encodeToBase64: false,
    },
    {
      placeholder: "Enter Domain name",
      label: "Domain name",
      name: "connector_account_details.key1",
      isRequired: true,
      encodeToBase64: false,
    },
  ],
}
let archipelInfo = {
  description: "Full-service processor offering secure payment solutions and innovative banking technologies for businesses of all sizes.",
}

let worldpayVantivInfo = {
  description: "Worldpay Vantiv, also known as the Worldpay CNP API, is a robust XML-based interface used to process online (card-not-present) transactions such as e-commerce purchases, subscription billing, and digital payments.",
}
let paytmInfo = {
  description: "Paytm is an Indian multinational fintech company specializing in digital payments and financial services. Initially known for its mobile wallet, it has expanded to include a payment bank, e-commerce, ticketing, and wealth management services.",
}

let phonepeInfo = {
  description: "PhonePe is a digital payments and financial services platform built on the UPI system. It allows users to make instant payments, recharge mobiles, pay bills, and access financial services like investments and insurance.",
}

let flexitiInfo = {
  description: "Flexiti is a comprehensive point-of-sale financing platform for modern retailers and businesses, automating consumer credit applications and payment processing with an industry-leading omni-channel solution and driving innovation into the future of retail financing.",
}

let breadpayInfo = {
  description: "Bread Pay is an intuitive, omni-channel Pay Over Time lending platform from a financial partner you can count on, offering flexible installment loans and SplitPay solutions with real-time credit decisions and transparent terms.",
}

let bluecodeInfo = {
  description: "Bluecode is building a global payment network that combines Alipay+, Discover and EMPSA and enables seamless payments in 75 countries. With over 160 million acceptance points, payments are processed according to the highest European security and data protection standards to make Europe less dependent on international players.",
}

let blackhawknetworkInfo = {
  description: "Blackhawk Network Holdings, Inc. is an American financial technology company that specializes in branded payments, prepaid cards, gift cards, and incentive solutions.",
}

let dwollaInfo = {
  description: "Dwolla offers a white labeled product experience powered by an API that enables you to embed account-to-account payments into a web or mobile application.",
}

let peachpaymentsInfo = {
  description: "The secure African payment gateway with easy integrations, 365-day support, and advanced orchestration.",
}

let getConnectorNameString = (connector: processorTypes) =>
  switch connector {
  | ADYEN => "adyen"
  | AFFIRM => "affirm"
  | CHECKOUT => "checkout"
  | BRAINTREE => "braintree"
  | AUTHORIZEDOTNET => "authorizedotnet"
  | STRIPE => "stripe"
  | KLARNA => "klarna"
  | GLOBALPAY => "globalpay"
  | BLUESNAP => "bluesnap"
  | AIRWALLEX => "airwallex"
  | WORLDPAY => "worldpay"
  | WORLDPAYXML => "worldpayxml"
  | CYBERSOURCE => "cybersource"
  | COINGATE => "coingate"
  | ELAVON => "elavon"
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
  | CHECKBOOK => "checkbook"
  | PAYME => "payme"
  | GLOBEPAY => "globepay"
  | POWERTRANZ => "powertranz"
  | TSYS => "tsys"
  | NOON => "noon"
  | STRIPE_TEST => "stripe_test"
  | PAYPAL_TEST => "paypal_test"
  | STAX => "stax"
  | GOCARDLESS => "gocardless"
  | VOLT => "volt"
  | PROPHETPAY => "prophetpay"
  | BANKOFAMERICA => "bankofamerica"
  | HELCIM => "helcim"
  | PLACETOPAY => "placetopay"
  | BILLWERK => "billwerk"
  | MIFINITY => "mifinity"
  | ZSL => "zsl"
  | RAZORPAY => "razorpay"
  | BAMBORA_APAC => "bamboraapac"
  | ITAUBANK => "itaubank"
  | DATATRANS => "datatrans"
  | PLAID => "plaid"
  | SQUARE => "square"
  | PAYBOX => "paybox"
  | WELLSFARGO => "wellsfargo"
  | FISERVIPG => "fiservemea"
  | FIUU => "fiuu"
  | NOVALNET => "novalnet"
  | DEUTSCHEBANK => "deutschebank"
  | NEXIXPAY => "nexixpay"
  | NORDEA => "nordea"
  | JPMORGAN => "jpmorgan"
  | XENDIT => "xendit"
  | INESPAY => "inespay"
  | MONERIS => "moneris"
  | REDSYS => "redsys"
  | HIPAY => "hipay"
  | PAYSTACK => "paystack"
  | FACILITAPAY => "facilitapay"
  | ARCHIPEL => "archipel"
  | AUTHIPAY => "authipay"
  | WORLDPAYVANTIV => "worldpayvantiv"
  | BARCLAYCARD => "barclaycard"
  | SILVERFLOW => "silverflow"
  | TOKENIO => "tokenio"
  | PAYLOAD => "payload"
  | PAYTM => "paytm"
  | PHONEPE => "phonepe"
  | FLEXITI => "flexiti"
  | BREADPAY => "breadpay"
  | BLUECODE => "bluecode"
  | BLACKHAWKNETWORK => "blackhawknetwork"
  | DWOLLA => "dwolla"
  | PAYSAFE => "paysafe"
  | PEACHPAYMENTS => "peachpayments"
  }

let getPayoutProcessorNameString = (payoutProcessor: payoutProcessorTypes) =>
  switch payoutProcessor {
  | ADYEN => "adyen"
  | ADYENPLATFORM => "adyenplatform"
  | CYBERSOURCE => "cybersource"
  | EBANX => "ebanx"
  | PAYPAL => "paypal"
  | STRIPE => "stripe"
  | WISE => "wise"
  | NOMUPAY => "nomupay"
  }

let getThreeDsAuthenticatorNameString = (threeDsAuthenticator: threeDsAuthenticatorTypes) =>
  switch threeDsAuthenticator {
  | THREEDSECUREIO => "threedsecureio"
  | NETCETERA => "netcetera"
  | CLICK_TO_PAY_MASTERCARD => "ctp_mastercard"
  | JUSPAYTHREEDSSERVER => "juspaythreedsserver"
  | CLICK_TO_PAY_VISA => "ctp_visa"
  }

let getFRMNameString = (frm: frmTypes) => {
  switch frm {
  | Signifyd => "signifyd"
  | Riskifyed => "riskified"
  }
}

let getPMAuthenticationConnectorNameString = (
  pmAuthenticationConnector: pmAuthenticationProcessorTypes,
) => {
  switch pmAuthenticationConnector {
  | PLAID => "plaid"
  }
}

let getTaxProcessorNameString = (taxProcessor: taxProcessorTypes) => {
  switch taxProcessor {
  | TAXJAR => "taxjar"
  }
}

let getBillingProcessorNameString = (billingProcessor: billingProcessorTypes) => {
  switch billingProcessor {
  | CHARGEBEE => "chargebee"
  | STRIPE_BILLING => "stripebilling"
  | CUSTOMBILLING => "custombilling"
  }
}

let getConnectorNameString = (connector: connectorTypes) => {
  switch connector {
  | Processors(connector) => connector->getConnectorNameString
  | PayoutProcessor(connector) => connector->getPayoutProcessorNameString
  | ThreeDsAuthenticator(threeDsAuthenticator) =>
    threeDsAuthenticator->getThreeDsAuthenticatorNameString
  | FRM(frmConnector) => frmConnector->getFRMNameString
  | PMAuthenticationProcessor(pmAuthenticationConnector) =>
    pmAuthenticationConnector->getPMAuthenticationConnectorNameString
  | TaxProcessor(taxProcessor) => taxProcessor->getTaxProcessorNameString
  | BillingProcessor(billingProcessor) => billingProcessor->getBillingProcessorNameString
  | UnknownConnector(str) => str
  }
}

let getConnectorNameTypeFromString = (connector, ~connectorType=ConnectorTypes.Processor) => {
  switch connectorType {
  | Processor =>
    switch connector {
    | "adyen" => Processors(ADYEN)
    | "affirm" => Processors(AFFIRM)
    | "checkout" => Processors(CHECKOUT)
    | "braintree" => Processors(BRAINTREE)
    | "authorizedotnet" => Processors(AUTHORIZEDOTNET)
    | "stripe" => Processors(STRIPE)
    | "klarna" => Processors(KLARNA)
    | "globalpay" => Processors(GLOBALPAY)
    | "bluesnap" => Processors(BLUESNAP)
    | "airwallex" => Processors(AIRWALLEX)
    | "worldpay" => Processors(WORLDPAY)
    | "worldpayxml" => Processors(WORLDPAYXML)
    | "cybersource" => Processors(CYBERSOURCE)
    | "elavon" => Processors(ELAVON)
    | "coingate" => Processors(COINGATE)
    | "aci" => Processors(ACI)
    | "worldline" => Processors(WORLDLINE)
    | "fiserv" => Processors(FISERV)
    | "fiservemea" => Processors(FISERVIPG)
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
    | "checkbook" => Processors(CHECKBOOK)
    | "payme" => Processors(PAYME)
    | "globepay" => Processors(GLOBEPAY)
    | "powertranz" => Processors(POWERTRANZ)
    | "tsys" => Processors(TSYS)
    | "noon" => Processors(NOON)
    | "stax" => Processors(STAX)
    | "cryptopay" => Processors(CRYPTOPAY)
    | "gocardless" => Processors(GOCARDLESS)
    | "volt" => Processors(VOLT)
    | "bankofamerica" => Processors(BANKOFAMERICA)
    | "prophetpay" => Processors(PROPHETPAY)
    | "helcim" => Processors(HELCIM)
    | "placetopay" => Processors(PLACETOPAY)
    | "billwerk" => Processors(BILLWERK)
    | "mifinity" => Processors(MIFINITY)
    | "zsl" => Processors(ZSL)
    | "razorpay" => Processors(RAZORPAY)
    | "bamboraapac" => Processors(BAMBORA_APAC)
    | "itaubank" => Processors(ITAUBANK)
    | "datatrans" => Processors(DATATRANS)
    | "plaid" => Processors(PLAID)
    | "square" => Processors(SQUARE)
    | "paybox" => Processors(PAYBOX)
    | "wellsfargo" => Processors(WELLSFARGO)
    | "fiuu" => Processors(FIUU)
    | "novalnet" => Processors(NOVALNET)
    | "deutschebank" => Processors(DEUTSCHEBANK)
    | "nexixpay" => Processors(NEXIXPAY)
    | "nordea" => Processors(NORDEA)
    | "jpmorgan" => Processors(JPMORGAN)
    | "xendit" => Processors(XENDIT)
    | "inespay" => Processors(INESPAY)
    | "moneris" => Processors(MONERIS)
    | "redsys" => Processors(REDSYS)
    | "hipay" => Processors(HIPAY)
    | "paystack" => Processors(PAYSTACK)
    | "facilitapay" => Processors(FACILITAPAY)
    | "archipel" => Processors(ARCHIPEL)
    | "authipay" => Processors(AUTHIPAY)
    | "worldpayvantiv" => Processors(WORLDPAYVANTIV)
    | "barclaycard" => Processors(BARCLAYCARD)
    | "silverflow" => Processors(SILVERFLOW)
    | "tokenio" => Processors(TOKENIO)
    | "payload" => Processors(PAYLOAD)
    | "paytm" => Processors(PAYTM)
    | "phonepe" => Processors(PHONEPE)
    | "flexiti" => Processors(FLEXITI)
    | "breadpay" => Processors(BREADPAY)
    | "bluecode" => Processors(BLUECODE)
    | "blackhawknetwork" => Processors(BLACKHAWKNETWORK)
    | "dwolla" => Processors(DWOLLA)
    | "paysafe" => Processors(PAYSAFE)
    | "peachpayments" => Processors(PEACHPAYMENTS)
    | _ => UnknownConnector("Not known")
    }
  | PayoutProcessor =>
    switch connector {
    | "adyen" => PayoutProcessor(ADYEN)
    | "adyenplatform" => PayoutProcessor(ADYENPLATFORM)
    | "cybersource" => PayoutProcessor(CYBERSOURCE)
    | "ebanx" => PayoutProcessor(EBANX)
    | "paypal" => PayoutProcessor(PAYPAL)
    | "stripe" => PayoutProcessor(STRIPE)
    | "wise" => PayoutProcessor(WISE)
    | "nomupay" => PayoutProcessor(NOMUPAY)
    | _ => UnknownConnector("Not known")
    }
  | ThreeDsAuthenticator =>
    switch connector {
    | "threedsecureio" => ThreeDsAuthenticator(THREEDSECUREIO)
    | "netcetera" => ThreeDsAuthenticator(NETCETERA)
    | "ctp_mastercard" => ThreeDsAuthenticator(CLICK_TO_PAY_MASTERCARD)
    | "juspaythreedsserver" => ThreeDsAuthenticator(JUSPAYTHREEDSSERVER)
    | "ctp_visa" => ThreeDsAuthenticator(CLICK_TO_PAY_VISA)
    | _ => UnknownConnector("Not known")
    }
  | FRMPlayer =>
    switch connector {
    | "riskified" => FRM(Riskifyed)
    | "signifyd" => FRM(Signifyd)
    | _ => UnknownConnector("Not known")
    }
  | PMAuthenticationProcessor =>
    switch connector {
    | "plaid" => PMAuthenticationProcessor(PLAID)
    | _ => UnknownConnector("Not known")
    }
  | TaxProcessor =>
    switch connector {
    | "taxjar" => TaxProcessor(TAXJAR)
    | _ => UnknownConnector("Not known")
    }
  | BillingProcessor =>
    switch connector {
    | "chargebee" => BillingProcessor(CHARGEBEE)
    | "stripebilling" => BillingProcessor(STRIPE_BILLING)
    | "custombilling" => BillingProcessor(CUSTOMBILLING)
    | _ => UnknownConnector("Not known")
    }
  }
}

let getProcessorInfo = (connector: ConnectorTypes.processorTypes) => {
  switch connector {
  | STRIPE => stripeInfo
  | ADYEN => adyenInfo
  | AFFIRM => affirmInfo
  | GOCARDLESS => goCardLessInfo
  | CHECKOUT => checkoutInfo
  | BRAINTREE => braintreeInfo
  | AUTHORIZEDOTNET => authorizedotnetInfo
  | KLARNA => klarnaInfo
  | GLOBALPAY => globalpayInfo
  | BLUESNAP => bluesnapInfo
  | AIRWALLEX => airwallexInfo
  | WORLDPAY => worldpayInfo
  | WORLDPAYXML => worldpayxmlInfo
  | CYBERSOURCE => cybersourceInfo
  | COINGATE => coingateInfo
  | ELAVON => elavonInfo
  | ACI => aciInfo
  | WORLDLINE => worldlineInfo
  | FISERV => fiservInfo
  | FISERVIPG => fiservInfo
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
  | CHECKBOOK => checkbookInfo
  | PHONYPAY => phonypayInfo
  | FAUXPAY => fauxpayInfo
  | PRETENDPAY => pretendpayInfo
  | PAYME => paymeInfo
  | GLOBEPAY => globepayInfo
  | POWERTRANZ => powertranzInfo
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
  | MIFINITY => mifinityInfo
  | ZSL => zslInfo
  | RAZORPAY => razorpayInfo
  | BAMBORA_APAC => bamboraApacInfo
  | ITAUBANK => itauBankInfo
  | DATATRANS => dataTransInfo
  | PLAID => plaidInfo
  | SQUARE => squareInfo
  | PAYBOX => payboxInfo
  | WELLSFARGO => wellsfargoInfo
  | FIUU => fiuuInfo
  | NOVALNET => novalnetInfo
  | DEUTSCHEBANK => deutscheBankInfo
  | NEXIXPAY => nexixpayInfo
  | NORDEA => nordeaInfo
  | JPMORGAN => jpmorganInfo
  | XENDIT => xenditInfo
  | INESPAY => inespayInfo
  | MONERIS => monerisInfo
  | REDSYS => redsysInfo
  | HIPAY => hipayInfo
  | PAYSTACK => paystackInfo
  | FACILITAPAY => facilitapayInfo
  | ARCHIPEL => archipelInfo
  | AUTHIPAY => authipayInfo
  | WORLDPAYVANTIV => worldpayVantivInfo
  | BARCLAYCARD => barclaycardInfo
  | SILVERFLOW => silverflowInfo
  | PAYLOAD => payloadInfo
  | TOKENIO => tokenioInfo
  | PAYTM => paytmInfo
  | PHONEPE => phonepeInfo
  | FLEXITI => flexitiInfo
  | BREADPAY => breadpayInfo
  | BLUECODE => bluecodeInfo
  | BLACKHAWKNETWORK => blackhawknetworkInfo
  | DWOLLA => dwollaInfo
  | PAYSAFE => paysafeInfo
  | PEACHPAYMENTS => peachpaymentsInfo
  }
}

let getPayoutProcessorInfo = (payoutconnector: ConnectorTypes.payoutProcessorTypes) => {
  switch payoutconnector {
  | ADYEN => adyenInfo
  | ADYENPLATFORM => adyenPlatformInfo
  | CYBERSOURCE => cybersourceInfo
  | EBANX => ebanxInfo
  | PAYPAL => paypalInfo
  | STRIPE => stripeInfo
  | WISE => wiseInfo
  | NOMUPAY => nomupayInfo
  }
}

let getThreedsAuthenticatorInfo = threeDsAuthenticator =>
  switch threeDsAuthenticator {
  | THREEDSECUREIO => threedsecuredotioInfo
  | NETCETERA => netceteraInfo
  | CLICK_TO_PAY_MASTERCARD => clickToPayInfo
  | JUSPAYTHREEDSSERVER => juspayThreeDsServerInfo
  | CLICK_TO_PAY_VISA => clickToPayVisaInfo
  }
let getFrmInfo = frm =>
  switch frm {
  | Signifyd => signifydInfo
  | Riskifyed => riskifyedInfo
  }

let getOpenBankingProcessorInfo = (
  pmAuthenticationConnector: ConnectorTypes.pmAuthenticationProcessorTypes,
) => {
  switch pmAuthenticationConnector {
  | PLAID => plaidInfo
  }
}

let getTaxProcessorInfo = (taxProcessor: ConnectorTypes.taxProcessorTypes) => {
  switch taxProcessor {
  | TAXJAR => taxJarInfo
  }
}

let getBillingProcessorInfo = (billingProcessor: ConnectorTypes.billingProcessorTypes) => {
  switch billingProcessor {
  | CHARGEBEE => chargebeeInfo
  | STRIPE_BILLING => stripeBillingInfo
  | CUSTOMBILLING => customBillingInfo
  }
}

let getConnectorInfo = connector => {
  switch connector {
  | Processors(connector) => connector->getProcessorInfo
  | PayoutProcessor(connector) => connector->getPayoutProcessorInfo
  | ThreeDsAuthenticator(threeDsAuthenticator) => threeDsAuthenticator->getThreedsAuthenticatorInfo
  | FRM(frm) => frm->getFrmInfo
  | PMAuthenticationProcessor(pmAuthenticationConnector) =>
    pmAuthenticationConnector->getOpenBankingProcessorInfo
  | TaxProcessor(taxProcessor) => taxProcessor->getTaxProcessorInfo
  | BillingProcessor(billingProcessor) => billingProcessor->getBillingProcessorInfo
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

let itemProviderMapper: dict<JSON.t> => ConnectorTypes.paymentMethodConfigType = dict => {
  open LogicUtils
  {
    payment_method_type: dict->getString("payment_method_type", ""),
    accepted_countries: dict->getDictfromDict("accepted_countries")->acceptedValues,
    accepted_currencies: dict->getDictfromDict("accepted_currencies")->acceptedValues,
    minimum_amount: dict->getOptionInt("minimum_amount"),
    maximum_amount: dict->getOptionInt("maximum_amount"),
    recurring_enabled: dict->getOptionBool("recurring_enabled"),
    installment_payment_enabled: dict->getOptionBool("installment_payment_enabled"),
    payment_experience: dict->getOptionString("payment_experience"),
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
  "connector_account_details",
]

let configKeysToIgnore = [
  "connector_auth",
  "is_verifiable",
  "metadata",
  "connector_webhook_details",
  "additional_merchant_data",
  "connector_wallets_details",
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

let getConnectorType = (connector: ConnectorTypes.connectorTypes) => {
  switch connector {
  | Processors(_) => "payment_processor"
  | PayoutProcessor(_) => "payout_processor"
  | ThreeDsAuthenticator(_) => "authentication_processor"
  | PMAuthenticationProcessor(_) => "payment_method_auth"
  | TaxProcessor(_) => "tax_processor"
  | FRM(_) => "payment_vas"
  | BillingProcessor(_) => "billing_processor"
  | UnknownConnector(str) => str
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

let removeMethod = (
  paymentMethodsEnabled,
  paymentMethod,
  method: paymentMethodConfigType,
  connector,
) => {
  let pmts = paymentMethodsEnabled->Array.copy
  switch (
    method.payment_method_type->getPaymentMethodTypeFromString,
    paymentMethod->getPaymentMethodFromString,
    connector->getConnectorNameTypeFromString,
  ) {
  | (PayPal, Wallet, Processors(PAYPAL)) =>
    pmts->Array.forEach((val: paymentMethodEnabled) => {
      if val.payment_method_type->String.toLowerCase === paymentMethod->String.toLowerCase {
        let indexOfRemovalItem =
          val.provider
          ->Option.getOr([]->JSON.Encode.array->getPaymentMethodMapper)
          ->Array.map(ele => ele.payment_experience)
          ->Array.indexOf(method.payment_experience)
        val.provider
        ->Option.getOr([]->JSON.Encode.array->getPaymentMethodMapper)
        ->Array.splice(
          ~start=indexOfRemovalItem,
          ~remove=1,
          ~insert=[]->JSON.Encode.array->getPaymentMethodMapper,
        )
      }
    })
  | (_, Card, _) =>
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
  ~isLiveMode=false,
  ~connectorType: ConnectorTypes.connector=ConnectorTypes.Processor,
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
    getConnectorType(connector->getConnectorNameTypeFromString(~connectorType))->JSON.Encode.string,
  )
  dict->Dict.set("disabled", dict->getBool("disabled", false)->JSON.Encode.bool)
  dict->Dict.set("test_mode", (isLiveMode ? false : true)->JSON.Encode.bool)
  dict->Dict.set("connector_label", dict->getString("connector_label", "")->JSON.Encode.string)

  let connectorWebHookDetails =
    dict->getJsonObjectFromDict("connector_webhook_details")->getDictFromJsonObject
  let hasMerchantSecret = connectorWebHookDetails->getOptionString("merchant_secret")->Option.isSome
  let hasAdditionalSecret =
    connectorWebHookDetails->getOptionString("additional_secret")->Option.isSome
  let connectorWebhookDict = switch (hasMerchantSecret, hasAdditionalSecret) {
  | (true, _) => connectorWebHookDetails->JSON.Encode.object
  | (false, true) => {
      connectorWebHookDetails->Dict.set("merchant_secret", ""->JSON.Encode.string)
      connectorWebHookDetails->JSON.Encode.object
    }
  | _ => JSON.Encode.null
  }
  dict->Dict.set("connector_webhook_details", connectorWebhookDict)

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
  | (BillingProcessor(CHARGEBEE) | BillingProcessor(STRIPE_BILLING), "merchant_secret") => true
  | (BillingProcessor(CHARGEBEE) | BillingProcessor(STRIPE_BILLING), "additional_secret") => true
  | _ => false
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

let checkPayloadFields = (dict, country, valuesFlattenJson) => {
  open LogicUtils
  let keys = dict->getDictfromDict(country)->Dict.keysToArray

  keys->Array.every(field => {
    let key = `connector_account_details.auth_key_map.${country}.${field}`
    let value = valuesFlattenJson->getString(key, "")
    value->String.trim->String.length > 0
  })
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

      Js.Vector.filterInPlace(val => val, vector)
      if vector->Js.Vector.length === 0 {
        Dict.set(newDict, "Currency", `Please enter currency`->JSON.Encode.string)
      }
    }

  | Processors(PAYLOAD) => {
      let dict = connectorAccountFields->getAuthKeyMapFromConnectorAccountFields

      let indexLength = dict->Dict.keysToArray->Array.length
      let vector = Js.Vector.make(indexLength, false)

      dict
      ->Dict.keysToArray
      ->Array.forEachWithIndex((country, index) => {
        let res = checkPayloadFields(dict, country, valuesFlattenJson)
        vector->Js.Vector.set(index, res)
      })

      Js.Vector.filterInPlace(val => val, vector)
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

  let keys =
    connectorMetaDataFields
    ->Dict.keysToArray
    ->Array.filter(ele => !Array.includes(ConnectorMetaDataUtils.metaDataInputKeysToIgnore, ele))

  {
    keys->Array.forEach(field => {
      let {\"type", name, required, label} =
        connectorMetaDataFields
        ->getDictfromDict(field)
        ->JSON.Encode.object
        ->convertMapObjectToDict
        ->CommonConnectorUtils.inputFieldMapper
      let key = `metadata.${name}`
      let value = switch \"type" {
      | Text | Select => valuesFlattenJson->getString(`${key}`, "")
      | Toggle => valuesFlattenJson->getBool(`${key}`, false)->getStringFromBool
      | _ => ""
      }

      let multiSelectValue = switch \"type" {
      | MultiSelect => valuesFlattenJson->getArrayFromDict(key, [])
      | _ => []
      }

      switch \"type" {
      | Text | Select | Toggle =>
        if value->isEmptyString && required {
          Dict.set(newDict, key, `Please enter ${label}`->JSON.Encode.string)
        }
      | MultiSelect =>
        if multiSelectValue->Array.length === 0 && required {
          Dict.set(newDict, key, `Please enter ${label}`->JSON.Encode.string)
        }
      | _ => ()
      }
    })
  }

  connectorWebHookDetails
  ->Dict.keysToArray
  ->Array.forEach(fieldName => {
    let key = `connector_webhook_details.${fieldName}`
    let errorKey = connectorWebHookDetails->getString(fieldName, "")
    let value = valuesFlattenJson->getString(key, "")
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

let getPlaceHolder = label => {
  `Enter ${label->LogicUtils.snakeToTitle}`
}

let connectorLabelDetailField = Dict.fromArray([
  ("connector_label", "Connector label"->JSON.Encode.string),
])
let getConnectorFields = connectorDetails => {
  open LogicUtils
  let connectorAccountDict =
    connectorDetails->getDictFromJsonObject->getJsonObjectFromDict("connector_auth")
  let bodyType = switch connectorAccountDict->JSON.Classify.classify {
  | Object(dict) => dict->Dict.keysToArray->getValueFromArray(0, "NoKey")
  | String(_) => "NoKey"
  | _ => ""
  }
  let connectorAccountFields = switch bodyType {
  | "NoKey" => Dict.make()
  | _ => connectorAccountDict->getDictFromJsonObject->getDictfromDict(bodyType)
  }
  let connectorMetaDataFields = connectorDetails->getDictFromJsonObject->getDictfromDict("metadata")
  let isVerifyConnector = connectorDetails->getDictFromJsonObject->getBool("is_verifiable", false)
  let connectorWebHookDetails =
    connectorDetails->getDictFromJsonObject->getDictfromDict("connector_webhook_details")
  let connectorAdditionalMerchantData =
    connectorDetails
    ->getDictFromJsonObject
    ->getDictfromDict("additional_merchant_data")

  {
    bodyType,
    connectorAccountFields,
    connectorMetaDataFields,
    isVerifyConnector,
    connectorWebHookDetails,
    connectorLabelDetailField,
    connectorAdditionalMerchantData,
  }
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

let validate = (~selectedConnector, ~dict, ~fieldName, ~isLiveMode) => values => {
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
    | Some(regex) => regex->RegExp.fromString->RegExp.test(value)
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
    switch connector->getConnectorNameTypeFromString {
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

let itemToPMAuthMapper = dict => {
  open LogicUtils
  {
    payment_method: dict->getString("payment_method", ""),
    payment_method_type: dict->getString("payment_method_type", ""),
    connector_name: dict->getString("connector_name", ""),
    mca_id: dict->getString("mca_id", ""),
  }
}

let constructConnectorRequestBody = (wasmRequest: wasmRequest, payload: JSON.t) => {
  open LogicUtils
  let dict = payload->getDictFromJsonObject
  let connectorAccountDetails =
    dict->getDictfromDict("connector_account_details")->JSON.Encode.object
  let connectorAdditionalMerchantData = dict->getDictfromDict("additional_merchant_data")
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
    (
      "additional_merchant_data",
      connectorAdditionalMerchantData->isEmptyDict
        ? JSON.Encode.null
        : connectorAdditionalMerchantData->JSON.Encode.object,
    ),
    ("connector_label", dict->getString("connector_label", "")->JSON.Encode.string),
    ("status", dict->getString("status", "active")->JSON.Encode.string),
    (
      "pm_auth_config",
      dict->getDictfromDict("pm_auth_config")->isEmptyDict
        ? JSON.Encode.null
        : dict->getDictfromDict("pm_auth_config")->JSON.Encode.object,
    ),
    (
      "connector_wallets_details",
      dict->getDictfromDict("connector_wallets_details")->isEmptyDict
        ? JSON.Encode.null
        : dict->getDictfromDict("connector_wallets_details")->JSON.Encode.object,
    ),
    (
      "metadata",
      dict->getDictfromDict("metadata")->isEmptyDict
        ? Dict.make()->JSON.Encode.object
        : dict->getDictfromDict("metadata")->JSON.Encode.object,
    ),
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

let connectorTypeToListMapper = connector => {
  switch connector {
  | Processor => connectorList
  | ThreeDsAuthenticator => threedsAuthenticatorList
  | PayoutProcessor => payoutConnectorList
  | TaxProcessor => taxProcessorList
  | PMAuthenticationProcessor => pmAuthenticationConnectorList
  | _ => []
  }
}

let getConnectorPaymentMethodDetails = async (
  ~initialValues,
  ~setPaymentMethods,
  ~setMetaData,
  ~isUpdateFlow,
  ~isPayoutFlow,
  ~connector,
  ~updateDetails,
) => {
  open LogicUtils
  try {
    let json = Window.getResponsePayload(initialValues)
    let metaData = initialValues->getDictFromJsonObject->getJsonObjectFromDict("metadata")
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

let getDisplayNameForProcessor = (connector: ConnectorTypes.processorTypes) =>
  switch connector {
  | ADYEN => "Adyen"
  | AFFIRM => "Affirm"
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
  | WORLDPAYXML => "Worldpay WPG"
  | CYBERSOURCE => "Cybersource"
  | COINGATE => "CoinGate"
  | ELAVON => "Elavon"
  | ACI => "ACI Worldwide"
  | WORLDLINE => "Worldline"
  | FISERV => "Fiserv Commerce Hub"
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
  | CHECKBOOK => "Checkbook"
  | PAYME => "PayMe"
  | GLOBEPAY => "GlobePay"
  | POWERTRANZ => "Powertranz"
  | TSYS => "TSYS"
  | NOON => "Noon"
  | STRIPE_TEST => "Stripe Dummy"
  | PAYPAL_TEST => "Paypal Dummy"
  | STAX => "Stax"
  | GOCARDLESS => "GoCardless"
  | VOLT => "Volt"
  | PROPHETPAY => "Prophet Pay"
  | BANKOFAMERICA => "Bank of America"
  | HELCIM => "Helcim"
  | PLACETOPAY => "Placetopay"
  | MIFINITY => "MiFinity"
  | ZSL => "ZSL"
  | RAZORPAY => "Razorpay"
  | BAMBORA_APAC => "Bambora Apac"
  | ITAUBANK => "Itaubank"
  | DATATRANS => "Datatrans"
  | PLAID => "Plaid"
  | SQUARE => "Square"
  | PAYBOX => "Paybox"
  | WELLSFARGO => "Wells Fargo"
  | FISERVIPG => "Fiserv IPG"
  | FIUU => "Fiuu"
  | NOVALNET => "Novalnet"
  | DEUTSCHEBANK => "Deutsche Bank"
  | NEXIXPAY => "Nexixpay"
  | NORDEA => "Nordea"
  | JPMORGAN => "JP Morgan"
  | XENDIT => "Xendit"
  | INESPAY => "Inespay"
  | MONERIS => "Moneris"
  | REDSYS => "Redsys"
  | HIPAY => "HiPay"
  | PAYSTACK => "Paystack"
  | FACILITAPAY => "Facilitapay"
  | ARCHIPEL => "ArchiPEL"
  | AUTHIPAY => "Authipay"
  | WORLDPAYVANTIV => "Worldpay Vantiv"
  | BARCLAYCARD => "BarclayCard SmartPay Fuse"
  | SILVERFLOW => "Silverflow"
  | PAYLOAD => "Payload"
  | TOKENIO => "Token.io"
  | PAYTM => "Paytm"
  | PHONEPE => "PhonePe"
  | FLEXITI => "Flexiti"
  | BREADPAY => "Breadpay"
  | BLUECODE => "Bluecode"
  | BLACKHAWKNETWORK => "BlackhawkNetwork"
  | DWOLLA => "Dwolla"
  | PAYSAFE => "Paysafe"
  | PEACHPAYMENTS => "PeachPayments"
  }

let getDisplayNameForPayoutProcessor = (payoutProcessor: ConnectorTypes.payoutProcessorTypes) =>
  switch payoutProcessor {
  | ADYEN => "Adyen"
  | ADYENPLATFORM => "Adyen Platform"
  | CYBERSOURCE => "Cybersource"
  | EBANX => "Ebanx"
  | PAYPAL => "PayPal"
  | STRIPE => "Stripe"
  | WISE => "Wise"
  | NOMUPAY => "Nomupay"
  }

let getDisplayNameForThreedsAuthenticator = threeDsAuthenticator =>
  switch threeDsAuthenticator {
  | THREEDSECUREIO => "3dsecure.io"
  | NETCETERA => "Netcetera"
  | CLICK_TO_PAY_MASTERCARD => "Mastercard Unified Click to Pay"
  | JUSPAYTHREEDSSERVER => "Juspay 3DS Server"
  | CLICK_TO_PAY_VISA => "Visa Unified Click to Pay"
  }

let getDisplayNameForFRMConnector = frmConnector =>
  switch frmConnector {
  | Signifyd => "Signifyd"
  | Riskifyed => "Riskified"
  }

let getDisplayNameForOpenBankingProcessor = pmAuthenticationConnector => {
  switch pmAuthenticationConnector {
  | PLAID => "Plaid"
  }
}

let getDisplayNameForTaxProcessor = taxProcessor => {
  switch taxProcessor {
  | TAXJAR => "Tax Jar"
  }
}

let getDisplayNameForBillingProcessor = billingProcessor => {
  switch billingProcessor {
  | CHARGEBEE => "Chargebee"
  | STRIPE_BILLING => "Stripe Billing"
  | CUSTOMBILLING => "Custom"
  }
}

let getDisplayNameForConnector = (~connectorType=ConnectorTypes.Processor, connector) => {
  let connectorType = connector->String.toLowerCase->getConnectorNameTypeFromString(~connectorType)
  switch connectorType {
  | Processors(connector) => connector->getDisplayNameForProcessor
  | PayoutProcessor(payoutProcessor) => payoutProcessor->getDisplayNameForPayoutProcessor
  | ThreeDsAuthenticator(threeDsAuthenticator) =>
    threeDsAuthenticator->getDisplayNameForThreedsAuthenticator
  | FRM(frmConnector) => frmConnector->getDisplayNameForFRMConnector
  | PMAuthenticationProcessor(pmAuthenticationConnector) =>
    pmAuthenticationConnector->getDisplayNameForOpenBankingProcessor
  | TaxProcessor(taxProcessor) => taxProcessor->getDisplayNameForTaxProcessor
  | BillingProcessor(billingProcessor) => billingProcessor->getDisplayNameForBillingProcessor
  | UnknownConnector(str) => str
  }
}

// Need to remove connector and merge connector and connectorTypeVariants
let connectorTypeTuple = connectorType => {
  switch connectorType {
  | "payment_processor" => (PaymentProcessor, Processor)
  | "payment_vas" => (PaymentVas, FRMPlayer)
  | "payout_processor" => (PayoutProcessor, PayoutProcessor)
  | "authentication_processor" => (AuthenticationProcessor, ThreeDsAuthenticator)
  | "payment_method_auth" => (PMAuthProcessor, PMAuthenticationProcessor)
  | "tax_processor" => (TaxProcessor, TaxProcessor)
  | "billing_processor" => (BillingProcessor, BillingProcessor)
  | _ => (PaymentProcessor, Processor)
  }
}

let connectorTypeStringToTypeMapper = connector_type => {
  switch connector_type {
  | "payment_vas" => PaymentVas
  | "payout_processor" => PayoutProcessor
  | "authentication_processor" => AuthenticationProcessor
  | "payment_method_auth" => PMAuthProcessor
  | "tax_processor" => TaxProcessor
  | "billing_processor" => BillingProcessor
  | "payment_processor"
  | _ =>
    PaymentProcessor
  }
}

let connectorTypeTypedValueToStringMapper = val => {
  switch val {
  | PaymentVas => "payment_vas"
  | PayoutProcessor => "payout_processor"
  | AuthenticationProcessor => "authentication_processor"
  | PMAuthProcessor => "payment_method_auth"
  | TaxProcessor => "tax_processor"
  | PaymentProcessor => "payment_processor"
  | BillingProcessor => "billing_processor"
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

// Need to refactor

let updateMetaData = (~metaData) => {
  open LogicUtils
  let apple_pay_combined = metaData->getDictFromJsonObject->getDictfromDict("apple_pay_combined")
  let manual = apple_pay_combined->getDictfromDict("manual")
  switch manual->Dict.keysToArray->Array.length > 0 {
  | true => {
      let applepay =
        manual
        ->getDictfromDict("session_token_data")
        ->JSON.Encode.object
        ->Identity.jsonToAnyType
        ->convertMapObjectToDict
      manual->Dict.set("session_token_data", applepay->JSON.Encode.object)
    }
  | false => ()
  }
}

let sortByDisableField = (arr: array<'a>, getDisabledStatus: 'a => bool) => {
  arr->Array.sort((a, b) =>
    LogicUtils.numericArraySortComperator(
      getDisabledStatus(a) ? 1.0 : 0.0,
      getDisabledStatus(b) ? 1.0 : 0.0,
    )
  )
}

let connectorTypeFromConnectorName: string => connector = connectorName =>
  switch connectorName {
  | "juspaythreedsserver"
  | "threedsecureio" =>
    ThreeDsAuthenticator
  | _ => Processor
  }

let stepsArr = (~connector) => {
  switch connector->getConnectorNameTypeFromString {
  | Processors(PAYSAFE) => [IntegFields, PaymentMethods, CustomMetadata, SummaryAndTest]
  | _ => [IntegFields, PaymentMethods, SummaryAndTest]
  }
}
