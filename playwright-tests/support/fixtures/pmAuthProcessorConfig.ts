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

export const pmAuthProcessorConfig: Record<string, ConnectorConfig> = {
  plaid: {
    label: "plaid",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "plaid_default",
      },
      fieldLabels: ["client_id *", "secret *"],
    },
    paymentSections: {
      OpenBanking: {
        label: "Open Banking",
        methods: ["open_banking_pis"],
      },
    },
  },
};
