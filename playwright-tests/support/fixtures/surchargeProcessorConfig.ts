export interface ConnectorFieldConfig {
  default: string;
  overrides: Record<string, string>;
  fieldLabels: string[];
}

export interface ConnectorConfig {
  label: string;
  fields: ConnectorFieldConfig;
}

export const surchargeProcessorConfig: Record<string, ConnectorConfig> = {
  interpayments: {
    label: "interpayments",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "interpayments_default",
      },
      fieldLabels: ["API Key"],
    },
  },
};
