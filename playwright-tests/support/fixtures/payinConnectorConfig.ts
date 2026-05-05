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

  braintree: {
    label: "braintree",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "braintree_default",
      },
      fieldLabels: [
        "Public Key *",
        "Merchant Id *",
        "Private Key *",
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
          "UnionPay",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Apple Pay", "Google Pay", "paypal"],
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

  cashtocode: {
    label: "cashtocode",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "cashtocode_default",
      },
      fieldLabels: [
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

  coingate: {
    label: "coingate",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "coingate_default",
      },
      fieldLabels: [
        "API Key *",
        "Merchant Token *",
        "Connector label *",
      ],
    },
    paymentSections: {},
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

  klarna: {
    label: "klarna",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "klarna_default",
      },
      fieldLabels: [
        "Klarna Merchant ID Password *",
        "Klarna Merchant Username *",
        "Connector label *",
      ],
    },
    paymentSections: {
      PayLater: {
        label: "Pay Later",
        methods: ["klarna", "klarna"],
      },
    },
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

  payload: {
    label: "payload",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "payload_default",
      },
      fieldLabels: [
        "Source verification key",
        "Connector label *",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: ["AmericanExpress", "Discover", "Mastercard", "Visa"],
      },
      Debit: {
        label: "Debit",
        methods: ["AmericanExpress", "Discover", "Mastercard", "Visa"],
      },
      BankDebit: {
        label: "Bank Debit",
        methods: ["ach"],
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

  santander: {
    label: "santander",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "santander_default",
      },
      fieldLabels: [
        "Base64 encoded PEM formatted certificate chain *",
        "Base64 encoded PEM formatted private key *",
        "Connector label *",
      ],
    },
    paymentSections: {
      BankTransfer: {
        label: "Bank Transfer",
        methods: ["pix", "Pix Automatico Push", "Pix Automatico Qr"],
      },
      Voucher: {
        label: "Voucher",
        methods: ["boleto"],
      },
    },
  },
};
