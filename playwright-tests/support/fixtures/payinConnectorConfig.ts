export interface ConnectorFieldConfig {
  default: string;
  overrides: Record<string, string>;
  fieldLabels: string[];
}

export interface PaymentSection {
  label: string;
  methods: string[];
}

export interface ConnectorConfig {
  label: string;
  fields: ConnectorFieldConfig;
  paymentSections: Record<string, PaymentSection>;
}

export const connectorConfig: Record<string, ConnectorConfig> = {
  adyen: {
    label: "adyen",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "adyen_default",
      },
      fieldLabels: [
        "Adyen API Key *",
        "Adyen Account Id *",
        "Source verification key *",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Nyce",
          "Pulse",
          "Star",
          "Accel",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      BankTransfer: {
        label: "Bank Transfer",
        methods: [
          "Permata Bank Transfer",
          "Bca Bank Transfer",
          "Bni Va",
          "Bri Va",
          "Cimb Va",
          "Danamon Va",
          "Mandiri Va",
          "pix",
        ],
      },
      BankRedirect: {
        label: "Bank Redirect",
        methods: [
          "ideal",
          "eps",
          "blik",
          "trustly",
          "Online Banking Czech Republic",
          "Online Banking Finland",
          "Online Banking Poland",
          "Online Banking Slovakia",
          "Bancontact Card",
          "Online Banking Fpx",
          "Online Banking Thailand",
          "bizum",
          "Open Banking Uk",
        ],
      },
      BankDebit: {
        label: "Bank Debit",
        methods: ["ach", "bacs", "sepa"],
      },
      PayLater: {
        label: "Pay Later",
        methods: [
          "klarna",
          "affirm",
          "Afterpay Clearpay",
          "Pay Bright",
          "walley",
          "alma",
          "atome",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: [
          "Apple Pay",
          "Google Pay",
          "paypal",
          "We Chat Pay",
          "Ali Pay",
          "Mb Way",
          "Ali Pay Hk",
          "Go Pay",
          "Kakao Pay",
          "twint",
          "gcash",
          "vipps",
          "dana",
          "momo",
          "swish",
          "Touch N Go",
        ],
      },
      Voucher: {
        label: "Voucher",
        methods: [
          "boleto",
          "alfamart",
          "indomaret",
          "oxxo",
          "Seven Eleven",
          "lawson",
          "Mini Stop",
          "Family Mart",
          "seicomart",
          "Pay Easy",
        ],
      },
      GiftCard: {
        label: "Gift Card",
        methods: ["Pay Safe Card", "givex"],
      },
      CardRedirect: {
        label: "Card Redirect",
        methods: ["benefit", "knet", "Momo Atm"],
      },
    },
  },

  authorizedotnet: {
    label: "authorizedotnet",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "authorizedotnet_default",
      },
      fieldLabels: [
        "API Login ID *",
        "Transaction Key *",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Apple Pay", "Google Pay", "paypal"],
      },
    },
  },

  archipel: {
    label: "archipel",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "archipel_default",
      },
      fieldLabels: [
        "Enter CA Certificate PEM *",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "AmericanExpress",
          "DinersClub",
          "Discover",
          "CartesBancaires",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "AmericanExpress",
          "DinersClub",
          "Discover",
          "CartesBancaires",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Apple Pay"],
      },
    },
  },

  airwallex: {
    label: "airwallex",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "airwallex_default",
      },
      fieldLabels: [
        "API Key *",
        "Client ID *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Google Pay", "paypal", "skrill"],
      },
      BankRedirect: {
        label: "Bank Redirect",
        methods: ["trustly", "blik", "ideal"],
      },
      PayLater: {
        label: "Pay Later",
        methods: ["klarna", "atome"],
      },
    },
  },

  bankofamerica: {
    label: "bankofamerica",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "bankofamerica_default",
      },
      fieldLabels: [
        "Key *",
        "Merchant ID *",
        "Shared Secret *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Apple Pay", "Google Pay", "Samsung Pay"],
      },
    },
  },

  bluesnap: {
    label: "bluesnap",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "bluesnap_default",
      },
      fieldLabels: [
        "Password *",
        "Username *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Google Pay", "Apple Pay"],
      },
    },
  },

  bambora: {
    label: "bambora",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "bambora_default",
      },
      fieldLabels: [
        "Passcode *",
        "Merchant Id *",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  calida: {
    label: "calida",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "calida_default",
      },
      fieldLabels: [
        "E-Order Token *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Wallet: {
        label: "Wallet",
        methods: ["bluecode"],
      },
    },
  },

  checkout: {
    label: "checkout",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "checkout_default",
      },
      fieldLabels: [
        "Checkout API Public Key *",
        "Processing Channel ID *",
        "Checkout API Secret Key *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Apple Pay", "Google Pay"],
      },
    },
  },

  cryptopay: {
    label: "cryptopay",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "cryptopay_default",
      },
      fieldLabels: [
        "API Key *",
        "Secret Key *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {},
  },

  cybersource: {
    label: "cybersource",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "cybersource_default",
      },
      fieldLabels: [
        "Key *",
        "Merchant ID *",
        "Shared Secret *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Apple Pay", "Google Pay", "paze", "Samsung Pay"],
      },
    },
  },

  datatrans: {
    label: "datatrans",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "datatrans_default",
      },
      fieldLabels: [
        "Passcode *",
        "datatrans MerchantId *",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  fiuu: {
    label: "fiuu",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "fiuu_default",
      },
      fieldLabels: [
        "Verify Key *",
        "Merchant ID *",
        "Secret Key *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Google Pay", "Apple Pay"],
      },
      BankRedirect: {
        label: "Bank Redirect",
        methods: ["Online Banking Fpx"],
      },
    },
  },

  gigadat: {
    label: "gigadat",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "gigadat_default",
      },
      fieldLabels: [
        "Access Token *",
        "Campaign ID *",
        "Security Token *",
        "Connector label *",
      ],
    },
    paymentSections: {
      BankRedirect: {
        label: "Bank Redirect",
        methods: ["interac"],
      },
    },
  },

  iatapay: {
    label: "iatapay",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "iatapay_default",
      },
      fieldLabels: [
        "Client ID *",
        "Airline ID *",
        "Client Secret *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {},
  },

  loonio: {
    label: "loonio",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "loonio_default",
      },
      fieldLabels: [
        "Merchant ID *",
        "Merchant Token *",
        "Connector label *",
      ],
    },
    paymentSections: {
      BankRedirect: {
        label: "Bank Redirect",
        methods: ["interac"],
      },
    },
  },

  mifinity: {
    label: "mifinity",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "mifinity_default",
      },
      fieldLabels: [
        "key *",
        "Connector label *",
      ],
    },
    paymentSections: {
      Wallet: {
        label: "Wallet",
        methods: ["mifinity"],
      },
    },
  },

  mollie: {
    label: "mollie",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "mollie_default",
      },
      fieldLabels: [
        "API Key *",
        "Profile Token *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["paypal"],
      },
      BankRedirect: {
        label: "Bank Redirect",
        methods: [
          "ideal",
          "giropay",
          "sofort",
          "eps",
          "przelewy24",
          "Bancontact Card",
        ],
      },
      PayLater: {
        label: "Pay Later",
        methods: ["klarna"],
      },
    },
  },

  nexixpay: {
    label: "nexixpay",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "nexixpay_default",
      },
      fieldLabels: [
        "API Key *",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "AmericanExpress",
          "JCB",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "AmericanExpress",
          "JCB",
        ],
      },
    },
  },

  nmi: {
    label: "nmi",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "nmi_default",
      },
      fieldLabels: [
        "API Key *",
        "Public Key *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Apple Pay", "Google Pay"],
      },
      BankRedirect: {
        label: "Bank Redirect",
        methods: ["ideal"],
      },
    },
  },

  novalnet: {
    label: "novalnet",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "novalnet_default",
      },
      fieldLabels: [
        "Product Activation Key *",
        "Payment Access Key *",
        "Tariff ID *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Google Pay", "paypal", "Apple Pay"],
      },
      BankDebit: {
        label: "Bank Debit",
        methods: ["sepa", "Sepa Guarenteed Debit"],
      },
    },
  },

  nuvei: {
    label: "nuvei",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "nuvei_default",
      },
      fieldLabels: [
        "Merchant ID *",
        "Merchant Site ID *",
        "Merchant Secret *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Apple Pay", "Google Pay", "paypal"],
      },
      BankRedirect: {
        label: "Bank Redirect",
        methods: ["ideal", "giropay", "sofort", "eps"],
      },
      PayLater: {
        label: "Pay Later",
        methods: ["klarna", "Afterpay Clearpay"],
      },
    },
  },

  paypal: {
    label: "paypal",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "paypal_default",
      },
      fieldLabels: [
        "Client Secret *",
        "Client ID",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["paypal", "paypal"],
      },
      BankRedirect: {
        label: "Bank Redirect",
        methods: ["ideal", "giropay", "sofort", "eps"],
      },
    },
  },

  paybox: {
    label: "paybox",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "paybox_default",
      },
      fieldLabels: [
        "SITE Key *",
        "Rang Identifier *",
        "CLE Secret *",
        "Merchant Id *",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
        ],
      },
    },
  },

  payme: {
    label: "payme",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "payme_default",
      },
      fieldLabels: [
        "Seller Payme Id *",
        "Payme Public Key *",
        "Payme Client Secret",
        "Payme Client Key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  peachpayments: {
    label: "peachpayments",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "peachpayments_default",
      },
      fieldLabels: [
        "API Key *",
        "Tenant ID *",
        "Webhook Secret",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: ["Mastercard", "Visa", "AmericanExpress"],
      },
      Debit: {
        label: "Debit",
        methods: ["Mastercard", "Visa", "AmericanExpress"],
      },
    },
  },

  redsys: {
    label: "redsys",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "redsys_default",
      },
      fieldLabels: [
        "Merchant ID *",
        "Terminal ID *",
        "Secret Key *",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "UnionPay",
        ],
      },
    },
  },

  stripe: {
    label: "stripe",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "stripe_default",
      },
      fieldLabels: [
        "Secret Key *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: [
          "Amazon Pay",
          "Apple Pay",
          "Google Pay",
          "We Chat Pay",
          "Ali Pay",
          "cashapp",
          "Revolut Pay",
        ],
      },
      BankTransfer: {
        label: "Bank Transfer",
        methods: ["ach", "bacs", "sepa", "multibanco"],
      },
      BankRedirect: {
        label: "Bank Redirect",
        methods: [
          "ideal",
          "giropay",
          "eps",
          "Bancontact Card",
          "przelewy24",
        ],
      },
      BankDebit: {
        label: "Bank Debit",
        methods: ["ach", "bacs", "becs", "sepa"],
      },
      PayLater: {
        label: "Pay Later",
        methods: ["klarna", "affirm", "Afterpay Clearpay"],
      },
    },
  },

  trustpay: {
    label: "trustpay",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "trustpay_default",
      },
      fieldLabels: [
        "API Key *",
        "Project ID *",
        "Secret Key *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Apple Pay", "Google Pay"],
      },
      BankTransfer: {
        label: "Bank Transfer",
        methods: [
          "Sepa Bank Transfer",
          "Instant Bank Transfer",
          "Instant Bank Transfer Finland",
          "Instant Bank Transfer Poland",
        ],
      },
      BankRedirect: {
        label: "Bank Redirect",
        methods: ["ideal", "giropay", "sofort", "eps", "blik"],
      },
    },
  },

  volt: {
    label: "volt",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "volt_default",
      },
      fieldLabels: [
        "Username *",
        "Client ID *",
        "Password *",
        "Client Secret *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      BankRedirect: {
        label: "Bank Redirect",
        methods: ["Open Banking Uk", "Open Banking"],
      },
    },
  },

  worldpay: {
    label: "worldpay",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "worldpay_default",
      },
      fieldLabels: [
        "Password *",
        "Username *",
        "Merchant Identifier *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Google Pay", "Apple Pay"],
      },
    },
  },

  worldpayxml: {
    label: "worldpayxml",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "worldpayxml_default",
      },
      fieldLabels: [
        "API Username *",
        "API Password *",
        "Merchant Code *",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Google Pay", "Apple Pay"],
      },
    },
  },

  zift: {
    label: "zift",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "zift_default",
      },
      fieldLabels: [
        "Username *",
        "Account ID *",
        "Password *",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  zsl: {
    label: "zsl",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "zsl_default",
      },
      fieldLabels: [
        "Key *",
        "Merchant ID *",
        "Connector label *",
      ],
    },
    paymentSections: {
      BankTransfer: {
        label: "Bank Transfer",
        methods: ["Local Bank Transfer"],
      },
    },
  },

  zen: {
    label: "zen",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "zen_default",
      },
      fieldLabels: [
        "API Key *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Apple Pay", "Google Pay"],
      },
      BankTransfer: {
        label: "Bank Transfer",
        methods: ["pix", "pse"],
      },
      Voucher: {
        label: "Voucher",
        methods: [
          "boleto",
          "efecty",
          "Pago Efectivo",
          "Red Compra",
          "Red Pagos",
        ],
      },
    },
  },

  worldpaymodular: {
    label: "worldpaymodular",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "worldpaymodular_default",
      },
      fieldLabels: [
        "Password *",
        "Username *",
        "Merchant Identifier *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Wallet: {
        label: "Wallet",
        methods: ["Google Pay", "Apple Pay"],
      },
    },
  },

  payjustnow: {
    label: "payjustnow",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "payjustnow_default",
      },
      fieldLabels: [
        "Signing Key *",
        "Merchant Account Id *",
        "Connector label *",
      ],
    },
    paymentSections: {
      PayLater: {
        label: "Pay Later",
        methods: ["payjustnow"],
      },
    },
  },

  payjustnowinstore: {
    label: "payjustnowinstore",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "payjustnowinstore_default",
      },
      fieldLabels: [
        "Merchant API Key *",
        "Merchant Terminal Id *",
        "Connector label *",
      ],
    },
    paymentSections: {
      PayLater: {
        label: "Pay Later",
        methods: ["payjustnow"],
      },
    },
  },

  finix: {
    label: "finix",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "finix_default",
      },
      fieldLabels: [
        "Username *",
        "Merchant Id *",
        "Password *",
        "Merchant Identity Id *",
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "AmericanExpress",
          "Discover",
          "JCB",
          "DinersClub",
          "UnionPay",
          "Interac",
          "Maestro",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "AmericanExpress",
          "Discover",
          "JCB",
          "DinersClub",
          "UnionPay",
          "Interac",
          "Maestro",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Google Pay", "Apple Pay"],
      },
    },
  },

  aci: {
    label: "aci",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "aci_default",
      },
      fieldLabels: [
        "API Key *",
        "Entity ID *",
        "Source verification key",
      ],
    },
    paymentSections: {
      BankRedirect: {
        label: "Bank Redirect",
        methods: [
          "ideal",
          "giropay",
          "sofort",
          "eps",
          "przelewy24",
          "trustly",
          "interac",
        ],
      },
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: [
          "ali_pay",
          "mb_way",
        ],
      },
    },
  },

  affirm: {
    label: "affirm",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "affirm_default",
      },
      fieldLabels: [
        "Public Key *",
        "Private Key *",
      ],
    },
    paymentSections: {
      PayLater: {
        label: "Pay Later",
        methods: [
          "affirm",
        ],
      },
    },
  },

  billwerk: {
    label: "billwerk",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "billwerk_default",
      },
      fieldLabels: [
        "Private Api Key *",
        "Public Api Key *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  bitpay: {
    label: "bitpay",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "bitpay_default",
      },
      fieldLabels: [
        "API Key *",
        "Source verification key",
      ],
    },
    paymentSections: {},
  },

  blackhawknetwork: {
    label: "blackhawknetwork",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "blackhawknetwork_default",
      },
      fieldLabels: [
        "Client Id *",
        "Product Line Id *",
        "Client Secret *",
      ],
    },
    paymentSections: {
      GiftCard: {
        label: "Gift Card",
        methods: [
          "bhn_card_network",
        ],
      },
    },
  },

  checkbook: {
    label: "checkbook",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "checkbook_default",
      },
      fieldLabels: [
        "Checkbook API Secret key *",
        "Checkbook Publishable key *",
        "Source verification key",
      ],
    },
    paymentSections: {
      BankTransfer: {
        label: "Bank Transfer",
        methods: [
          "ach",
        ],
      },
    },
  },

  dlocal: {
    label: "dlocal",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "dlocal_default",
      },
      fieldLabels: [
        "X Login *",
        "X Trans Key *",
        "Secret Key *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Voucher: {
        label: "Voucher",
        methods: [
          "oxxo",
        ],
      },
    },
  },

  dwolla: {
    label: "dwolla",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "dwolla_default",
      },
      fieldLabels: [
        "Client ID *",
        "Client Secret *",
        "Source verification key",
      ],
    },
    paymentSections: {
      BankDebit: {
        label: "Bank Debit",
        methods: [
          "ach",
        ],
      },
    },
  },

  elavon: {
    label: "elavon",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "elavon_default",
      },
      fieldLabels: [
        "Account Id *",
        "User ID *",
        "Pin *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  fiserv: {
    label: "fiserv",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "fiserv_default",
      },
      fieldLabels: [
        "API Key *",
        "Merchant ID *",
        "API Secret *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: [
          "google_pay",
          "paypal",
          "apple_pay",
        ],
      },
    },
  },

  forte: {
    label: "forte",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "forte_default",
      },
      fieldLabels: [
        "API Access ID *",
        "Organization ID *",
        "API Secure Key *",
        "Location ID *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  globalpay: {
    label: "globalpay",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "globalpay_default",
      },
      fieldLabels: [
        "Global App Key *",
        "Global App ID *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      BankRedirect: {
        label: "Bank Redirect",
        methods: [
          "ideal",
          "giropay",
          "sofort",
          "eps",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: [
          "google_pay",
          "paypal",
        ],
      },
    },
  },

  globepay: {
    label: "globepay",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "globepay_default",
      },
      fieldLabels: [
        "Partner Code *",
        "Credential Code *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Wallet: {
        label: "Wallet",
        methods: [
          "we_chat_pay",
          "ali_pay",
        ],
      },
    },
  },

  gocardless: {
    label: "gocardless",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "gocardless_default",
      },
      fieldLabels: [
        "Access Token *",
        "Source verification key",
      ],
    },
    paymentSections: {
      BankDebit: {
        label: "Bank Debit",
        methods: [
          "ach",
          "becs",
          "sepa",
        ],
      },
    },
  },

  helcim: {
    label: "helcim",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "helcim_default",
      },
      fieldLabels: [
        "Api Key *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  multisafepay: {
    label: "multisafepay",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "multisafepay_default",
      },
      fieldLabels: [
        "Enter API Key *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      BankRedirect: {
        label: "Bank Redirect",
        methods: [
          "trustly",
          "eps",
          "sofort",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: [
          "google_pay",
          "paypal",
          "ali_pay",
          "we_chat_pay",
          "mb_way",
        ],
      },
    },
  },

  nexinets: {
    label: "nexinets",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "nexinets_default",
      },
      fieldLabels: [
        "API Key *",
        "Merchant ID *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      BankRedirect: {
        label: "Bank Redirect",
        methods: [
          "ideal",
          "giropay",
          "sofort",
          "eps",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: [
          "apple_pay",
          "paypal",
        ],
      },
    },
  },

  noon: {
    label: "noon",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "noon_default",
      },
      fieldLabels: [
        "API Key *",
        "Business Identifier *",
        "Application Identifier *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: [
          "apple_pay",
          "google_pay",
          "paypal",
        ],
      },
    },
  },

  opennode: {
    label: "opennode",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "opennode_default",
      },
      fieldLabels: [
        "API Key *",
        "Source verification key",
      ],
    },
    paymentSections: {},
  },

  payu: {
    label: "payu",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "payu_default",
      },
      fieldLabels: [
        "API Key *",
        "Merchant POS ID *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: [
          "google_pay",
        ],
      },
    },
  },

  powertranz: {
    label: "powertranz",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "powertranz_default",
      },
      fieldLabels: [
        "PowerTranz Password *",
        "PowerTranz Id *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  rapyd: {
    label: "rapyd",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "rapyd_default",
      },
      fieldLabels: [
        "Access Key *",
        "API Secret *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: [
          "apple_pay",
        ],
      },
    },
  },

  shift4: {
    label: "shift4",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "shift4_default",
      },
      fieldLabels: [
        "API Key *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      BankRedirect: {
        label: "Bank Redirect",
        methods: [
          "ideal",
          "giropay",
          "sofort",
          "eps",
          "trustly",
          "blik",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: [
          "ali_pay",
          "we_chat_pay",
          "paysera",
          "skrill",
        ],
      },
      PayLater: {
        label: "Pay Later",
        methods: [
          "klarna",
        ],
      },
      Voucher: {
        label: "Voucher",
        methods: [
          "boleto",
        ],
      },
    },
  },

  stax: {
    label: "stax",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "stax_default",
      },
      fieldLabels: [
        "Api Key *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      BankDebit: {
        label: "Bank Debit",
        methods: [
          "ach",
        ],
      },
    },
  },

  tsys: {
    label: "tsys",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "tsys_default",
      },
      fieldLabels: [
        "Device Id *",
        "Transaction Key *",
        "Developer Id *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  worldline: {
    label: "worldline",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "worldline_default",
      },
      fieldLabels: [
        "API Key ID *",
        "Merchant ID *",
        "Secret API Key *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      BankRedirect: {
        label: "Bank Redirect",
        methods: [
          "ideal",
          "giropay",
        ],
      },
    },
  },

  placetopay: {
    label: "placetopay",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "placetopay_default",
      },
      fieldLabels: [
        "Login *",
        "Trankey *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  razorpay: {
    label: "razorpay",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "razorpay_default",
      },
      fieldLabels: [
        "Razorpay Id *",
        "Razorpay Secret *",
      ],
    },
    paymentSections: {},
  },

  itaubank: {
    label: "itaubank",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "itaubank_default",
      },
      fieldLabels: [
        "Client Secret *",
        "Client Id *",
        "Certificates *",
        "Certificate Key *",
      ],
    },
    paymentSections: {
      BankTransfer: {
        label: "Bank Transfer",
        methods: [
          "pix",
        ],
      },
    },
  },

  plaid: {
    label: "plaid",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "plaid_default",
      },
      fieldLabels: [
        "client_id *",
        "secret *",
      ],
    },
    paymentSections: {},
  },

  square: {
    label: "square",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "square_default",
      },
      fieldLabels: [
        "Square API Key *",
        "Square Client Id *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  wellsfargo: {
    label: "wellsfargo",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "wellsfargo_default",
      },
      fieldLabels: [
        "Key *",
        "Merchant ID *",
        "Shared Secret *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  deutschebank: {
    label: "deutschebank",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "deutschebank_default",
      },
      fieldLabels: [
        "Client ID *",
        "Merchant ID *",
        "Client Key *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Visa",
          "Mastercard",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Visa",
          "Mastercard",
        ],
      },
      BankDebit: {
        label: "Bank Debit",
        methods: [
          "sepa",
        ],
      },
    },
  },

  nordea: {
    label: "nordea",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "nordea_default",
      },
      fieldLabels: [
        "Client Secret *",
        "Client ID *",
        "eIDAS Private Key *",
      ],
    },
    paymentSections: {
      BankDebit: {
        label: "Bank Debit",
        methods: [
          "sepa",
        ],
      },
    },
  },

  jpmorgan: {
    label: "jpmorgan",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "jpmorgan_default",
      },
      fieldLabels: [
        "Client ID *",
        "Client Secret *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "AmericanExpress",
          "DinersClub",
          "Discover",
          "JCB",
          "Mastercard",
          "Discover",
          "UnionPay",
          "Visa",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "AmericanExpress",
          "DinersClub",
          "Discover",
          "JCB",
          "Mastercard",
          "Discover",
          "UnionPay",
          "Visa",
        ],
      },
    },
  },

  xendit: {
    label: "xendit",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "xendit_default",
      },
      fieldLabels: [
        "API Key *",
        "Webhook Verification Token",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  inespay: {
    label: "inespay",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "inespay_default",
      },
      fieldLabels: [
        "API Key *",
        "API Token *",
      ],
    },
    paymentSections: {
      BankDebit: {
        label: "Bank Debit",
        methods: [
          "sepa",
        ],
      },
    },
  },

  moneris: {
    label: "moneris",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "moneris_default",
      },
      fieldLabels: [
        "Client Secret *",
        "Client Id *",
        "Merchant Id *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  hipay: {
    label: "hipay",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "hipay_default",
      },
      fieldLabels: [
        "API Login ID *",
        "API password *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  paystack: {
    label: "paystack",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "paystack_default",
      },
      fieldLabels: [
        "API Key *",
      ],
    },
    paymentSections: {
      BankRedirect: {
        label: "Bank Redirect",
        methods: [
          "eft",
        ],
      },
    },
  },

  facilitapay: {
    label: "facilitapay",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "facilitapay_default",
      },
      fieldLabels: [
        "Password *",
        "Username *",
      ],
    },
    paymentSections: {
      BankTransfer: {
        label: "Bank Transfer",
        methods: [
          "pix",
        ],
      },
    },
  },

  barclaycard: {
    label: "barclaycard",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "barclaycard_default",
      },
      fieldLabels: [
        "Key *",
        "Merchant ID *",
        "Shared Secret *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "AmericanExpress",
          "JCB",
          "Discover",
          "Maestro",
          "Interac",
          "DinersClub",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "AmericanExpress",
          "JCB",
          "Discover",
          "Maestro",
          "Interac",
          "DinersClub",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: [
          "google_pay",
          "apple_pay",
        ],
      },
    },
  },

  silverflow: {
    label: "silverflow",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "silverflow_default",
      },
      fieldLabels: [
        "API Key *",
        "Merchant Acceptor Key *",
        "API Secret *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
        ],
      },
    },
  },

  paytm: {
    label: "paytm",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "paytm_default",
      },
      fieldLabels: [
        "Signing key *",
        "merchant_id *",
        "website name *",
      ],
    },
    paymentSections: {},
  },

  phonepe: {
    label: "phonepe",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "phonepe_default",
      },
      fieldLabels: [
        "merchant_id *",
        "salt_key *",
        "key_index *",
      ],
    },
    paymentSections: {},
  },

  flexiti: {
    label: "flexiti",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "flexiti_default",
      },
      fieldLabels: [
        "Client id *",
        "Client secret *",
      ],
    },
    paymentSections: {
      PayLater: {
        label: "Pay Later",
        methods: [
          "flexiti",
        ],
      },
    },
  },

  breadpay: {
    label: "breadpay",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "breadpay_default",
      },
      fieldLabels: [
        "API Key *",
        "API Secret *",
      ],
    },
    paymentSections: {
      PayLater: {
        label: "Pay Later",
        methods: [
          "breadpay",
        ],
      },
    },
  },

  tesouro: {
    label: "tesouro",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "tesouro_default",
      },
      fieldLabels: [
        "Client ID *",
        "Acceptor ID *",
        "Client Secret *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "AmericanExpress",
          "Discover",
          "DinersClub",
          "JCB",
          "Maestro",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "AmericanExpress",
          "Discover",
          "DinersClub",
          "JCB",
          "Maestro",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: [
          "apple_pay",
          "google_pay",
        ],
      },
    },
  },

  fiservcommercehub: {
    label: "fiservcommercehub",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "fiservcommercehub_default",
      },
      fieldLabels: [
        "API Key *",
        "Merchant ID *",
        "API Secret *",
        "Terminal ID *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  amazonpay: {
    label: "amazonpay",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "amazonpay_default",
      },
      fieldLabels: [
        "Public Key *",
        "Private Key *",
      ],
    },
    paymentSections: {
      Wallet: {
        label: "Wallet",
        methods: [
          "amazon_pay",
        ],
      },
    },
  },

  revolv3: {
    label: "revolv3",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "revolv3_default",
      },
      fieldLabels: [
        "Static Tokens *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  truelayer: {
    label: "truelayer",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "truelayer_default",
      },
      fieldLabels: [
        "Client ID *",
        "Client Secret *",
      ],
    },
    paymentSections: {
      BankRedirect: {
        label: "Bank Redirect",
        methods: [
          "open_banking",
        ],
      },
    },
  },

  trustly: {
    label: "trustly",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "trustly_default",
      },
      fieldLabels: [
        "Username *",
        "Password *",
        "Private Key(Base64 encoded) *",
        "Trustly's public key",
      ],
    },
    paymentSections: {
      BankRedirect: {
        label: "Bank Redirect",
        methods: [
          "trustly",
        ],
      },
    },
  },

  bambora_apac: {
    label: "bambora",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "bambora_apac_default",
      },
      fieldLabels: [
        "Passcode *",
        "Merchant Id *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
    },
  },

  fiservipg: {
    label: "fiserv",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "fiservipg_default",
      },
      fieldLabels: [
        "API Key *",
        "Merchant ID *",
        "API Secret *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "Interac",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: [
          "google_pay",
          "paypal",
          "apple_pay",
        ],
      },
    },
  },

  imerchantsolutions: {
    label: "imerchantsolutions",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "imerchantsolutions_default",
      },
      fieldLabels: [
        "API Key *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "AmericanExpress",
          "JCB",
          "Discover",
          "UnionPay",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "AmericanExpress",
          "JCB",
          "Discover",
          "UnionPay",
        ],
      },
    },
  },
};
