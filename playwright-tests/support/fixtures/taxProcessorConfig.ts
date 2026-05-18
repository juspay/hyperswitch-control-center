export interface ConnectorFieldConfig {
  default: string;
  overrides: Record<string, string>;
  fieldLabels: string[];
}

export interface ConnectorConfig {
  label: string;
  fields: ConnectorFieldConfig;
}

export const taxProcessorConfig: Record<string, ConnectorConfig> = {
  taxjar: {
    label: "taxjar",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "taxjar_default",
      },
      fieldLabels: [
        "Sandbox Token *",
      ],
    },
  },
};
