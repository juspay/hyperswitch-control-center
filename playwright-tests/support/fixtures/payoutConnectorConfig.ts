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
        "Adyen API Key (Payout creation)": "adyen_api_key",
        "Adyen Account Id": "adyen_account_id",
        "Adyen Key (Payout submission)": "adyen_key",
      },
      fieldLabels: [
        "Adyen API Key (Payout creation) *",
        "Adyen Account Id *",
        "Adyen Key (Payout submission) *",
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
      BankTransfer: {
        label: "Bank Transfer",
        methods: ["sepa"],
      },
      Wallet: {
        label: "Wallet",
        methods: ["paypal"],
      },
    },
  },

  adyenplatform: {
    label: "adyenplatform",
    fields: {
      default: "test_value",
      overrides: {
        "Adyen platform's API Key": "adyenplatform_api_key",
        "Source verification key": "adyenplatform_webhook",
      },
      fieldLabels: [
        "Adyen platform's API Key *",
        "Source verification key",
      ],
    },
    paymentSections: {
      Credit: {
        label: "Credit",
        methods: ["Mastercard", "Visa"],
      },
      Debit: {
        label: "Debit",
        methods: ["Mastercard", "Visa"],
      },
      BankTransfer: {
        label: "Bank Transfer",
        methods: ["sepa"],
      },
    },
  },

  cybersource: {
    label: "cybersource",
    fields: {
      default: "test_value",
      overrides: {
        "Key": "cybersource_key",
        "Merchant ID": "cybersource_merchant_id",
        "Shared Secret": "cybersource_secret",
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
        "Integration Key": "ebanx_integration_key",
      },
      fieldLabels: [
        "Integration Key *",
      ],
    },
    paymentSections: {
      BankTransfer: {
        label: "Bank Transfer",
        methods: ["pix"],
      },
    },
  },

  paypal: {
    label: "paypal",
    fields: {
      default: "test_value",
      overrides: {
        "Client Secret": "paypal_client_secret",
        "Client ID": "paypal_client_id",
        "Source verification key": "paypal_webhook",
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
        methods: ["paypal", "venmo"],
      },
    },
  },

  stripe: {
    label: "stripe",
    fields: {
      default: "test_value",
      overrides: {
        "Stripe API Key": "stripe_api_key",
      },
      fieldLabels: [
        "Stripe API Key *",
      ],
    },
    paymentSections: {
      BankTransfer: {
        label: "Bank Transfer",
        methods: ["ach"],
      },
    },
  },

  wise: {
    label: "wise",
    fields: {
      default: "test_value",
      overrides: {
        "Wise API Key": "wise_api_key",
        "Wise Account Id": "wise_account_id",
        "Source verification key": "wise_webhook",
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
        methods: ["ach", "bacs", "sepa"],
      },
    },
  },

  nomupay: {
    label: "nomupay",
    fields: {
      default: "test_value",
      overrides: {
        "Nomupay kid": "nomupay_kid",
        "Nomupay eid": "nomupay_eid",
      },
      fieldLabels: [
        "Nomupay kid *",
        "Nomupay eid *",
      ],
    },
    paymentSections: {
      BankTransfer: {
        label: "Bank Transfer",
        methods: ["sepa"],
      },
    },
  },

  nuvei: {
    label: "nuvei",
    fields: {
      default: "test_value",
      overrides: {
        "Merchant ID": "nuvei_merchant_id",
        "Merchant Site ID": "nuvei_merchant_site_id",
        "Merchant Secret": "nuvei_secret",
        "Source verification key": "nuvei_webhook",
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

  gigadat: {
    label: "gigadat",
    fields: {
      default: "test_value",
      overrides: {
        "Access Token": "gigadat_access_token",
        "Campaign ID": "gigadat_campaign_id",
        "Security Token": "gigadat_security_token",
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
        methods: ["interac"],
      },
    },
  },

  loonio: {
    label: "loonio",
    fields: {
      default: "test_value",
      overrides: {
        "Merchant ID": "loonio_merchant_id",
        "Merchant Token": "loonio_merchant_token",
      },
      fieldLabels: [
        "Merchant ID *",
        "Merchant Token *",
      ],
    },
    paymentSections: {
      BankRedirect: {
        label: "Bank Redirect",
        methods: ["interac"],
      },
    },
  },

  worldpay: {
    label: "worldpay",
    fields: {
      default: "test_value",
      overrides: {
        "Password": "worldpay_password",
        "Username": "worldpay_username",
        "Merchant Identifier": "worldpay_merchant_id",
        "Source verification key": "worldpay_webhook",
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
        methods: ["Apple Pay"],
      },
    },
  },

  worldpayxml: {
    label: "worldpayxml",
    fields: {
      default: "test_value",
      overrides: {
        "API Username": "worldpayxml_api_username",
        "API Password": "worldpayxml_api_password",
        "Merchant Code": "worldpayxml_merchant_code",
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
        methods: ["Visa"],
      },
      Debit: {
        label: "Debit",
        methods: ["Visa"],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Apple Pay"],
      },
    },
  },
};
