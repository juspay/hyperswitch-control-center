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

export const payoutConnectorConfig: Record<string, ConnectorConfig> = {
  adyen: {
    label: "adyen",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "adyen_default",
      },
      fieldLabels: [
        "Adyen API Key (Payout creation) *",
        "Adyen Account Id *",
        "Adyen Key (Payout submission) *",
      ],
    },
    paymentSections: {
      BankTransfer: {
        label: "Bank Transfer",
        methods: [
          "sepa_bank_transfer",
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
          "paypal",
        ],
      },
    },
  },

  adyenplatform: {
    label: "adyenplatform",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "adyenplatform_default",
      },
      fieldLabels: [
        "Adyen platform's API Key *",
        "Source verification key",
      ],
    },
    paymentSections: {
      BankTransfer: {
        label: "Bank Transfer",
        methods: [
          "sepa_bank_transfer",
        ],
      },
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

  ebanx: {
    label: "ebanx",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "ebanx_default",
      },
      fieldLabels: [
        "Integration Key *",
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

  envoy: {
    label: "envoy",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "envoy_default",
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
          "sepa_bank_transfer",
        ],
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
      ],
    },
    paymentSections: {
      BankRedirect: {
        label: "Bank Redirect",
        methods: [
          "interac",
        ],
      },
    },
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
      ],
    },
    paymentSections: {
      BankRedirect: {
        label: "Bank Redirect",
        methods: [
          "interac",
        ],
      },
    },
  },

  nomupay: {
    label: "nomupay",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "nomupay_default",
      },
      fieldLabels: [
        "Nomupay kid *",
        "Nomupay eid *",
      ],
    },
    paymentSections: {
      BankTransfer: {
        label: "Bank Transfer",
        methods: [
          "sepa_bank_transfer",
        ],
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

  paypal: {
    label: "paypal",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "paypal_default",
      },
      fieldLabels: [
        "Client Secret *",
        "Client ID *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Wallet: {
        label: "Wallet",
        methods: [
          "paypal",
          "venmo",
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
        "Stripe API Key *",
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
          "open_banking_uk",
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
      BankTransfer: {
        label: "Bank Transfer",
        methods: [
          "trustly",
        ],
      },
    },
  },

  wise: {
    label: "wise",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "wise_default",
      },
      fieldLabels: [
        "Wise API Key *",
        "Wise Account Id *",
        "Source verification key",
      ],
    },
    paymentSections: {
      BankTransfer: {
        label: "Bank Transfer",
        methods: [
          "ach",
          "bacs",
          "sepa_bank_transfer",
        ],
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
      ],
    },
    paymentSections: {
      Wallet: {
        label: "Wallet",
        methods: [
          "apple_pay",
        ],
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
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: [
          "Visa",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Visa",
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
};
