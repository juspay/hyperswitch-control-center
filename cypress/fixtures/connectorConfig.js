export const connectorConfig = {
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
        "Connector label *",
        "Live endpoint prefix *",
        "Source verification key *",
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
          "Pix",
        ],
      },
      BankRedirect: {
        label: "Bank Redirect",
        methods: [
          "Ideal",
          "Eps",
          "Blik",
          "Trustly",
          "Online Banking Czech Republic",
          "Online Banking Finland",
          "Online Banking Poland",
          "Online Banking Slovakia",
          "Bancontact Card",
          "Online Banking Fpx",
          "Online Banking Thailand",
          "Bizum",
          "Open Banking Uk",
        ],
      },
      BankDebit: {
        label: "Bank Debit",
        methods: ["Ach", "Bacs", "Sepa"],
      },
      PayLater: {
        label: "Pay Later",
        methods: [
          "Klarna",
          "Affirm",
          "Afterpay Clearpay",
          "Pay Bright",
          "Walley",
          "Alma",
          "Atome",
        ],
      },
      Wallet: {
        label: "Wallet",
        methods: [
          "Apple Pay",
          "Google Pay",
          "Paypal",
          "We Chat Pay",
          "Ali Pay",
          "Mb Way",
          "Ali Pay Hk",
          "Go Pay",
          "Kakao Pay",
          "Twint",
          "Gcash",
          "Vipps",
          "Dana",
          "Momo",
          "Swish",
          "Touch N Go",
        ],
      },
      Voucher: {
        label: "Voucher",
        methods: [
          "Boleto",
          "Alfamart",
          "Indomaret",
          "Oxxo",
          "Seven Eleven",
          "Lawson",
          "Mini Stop",
          "Family Mart",
          "Seicomart",
          "Pay Easy",
        ],
      },
      GiftCard: {
        label: "Gift Card",
        methods: ["Pay Safe Card", "Givex"],
      },
      CardRedirect: {
        label: "Card Redirect",
        methods: ["Benefit", "Knet", "Momo Atm"],
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
      fieldLabels: ["API Login ID *", "Transaction Key *", "Connector label *"],
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
        methods: ["Apple Pay", "Google Pay", "Paypal"],
      },
    },
  },
};
