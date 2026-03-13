export const payoutConnectorConfig = {
  adyen: {
    label: "adyen",

    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "adyen_payout_default",
      },
      fieldLabels: [
        "Adyen API Key (Payout creation) *",
        "Adyen Account Id *",
        "Adyen Key (Payout submission) *",
        "Connector label *",
        "Live endpoint prefix *",
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
        methods: ["Sepa Bank Transfer"],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Paypal"],
      },
    },
  },
};
