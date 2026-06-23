export interface ConnectorFieldConfig {
  default: string;
  overrides: Record<string, string>;
  fieldLabels: string[];
}

export interface ConnectorConfig {
  label: string;
  fields: ConnectorFieldConfig;
}

export const vaultProcessorConfig: Record<string, ConnectorConfig> = {
  vgs: {
    label: "vgs",
    fields: {
      default: "test_value",
      overrides: {
        "Enter Connector label": "vgs_default",
      },
      fieldLabels: ["Client Id *", "Client Secret *", "Vault Id *"],
    },
  },
};
