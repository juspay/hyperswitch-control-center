export interface ConnectorFieldConfig {
  default: string;
  overrides: Record<string, string>;
  fieldLabels: string[];
}

export interface ConnectorConfig {
  label: string;
  fields: ConnectorFieldConfig;
}

export const billingProcessorConfig: Record<string, ConnectorConfig> = {
  chargebee: {
    label: "chargebee",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "chargebee_default",
      },
      fieldLabels: [
        "Chargebee API Key *",
        "Webhook URL Username *",
        "Webhook URL Password *",
      ],
    },
  },
};
