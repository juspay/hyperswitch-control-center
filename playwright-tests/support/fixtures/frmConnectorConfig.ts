export interface ConnectorFieldConfig {
  default: string;
  overrides: Record<string, string>;
  fieldLabels: string[];
}

export interface MetadataField {
  label: string;
  required: boolean;
}

export interface ConnectorConfig {
  label: string;
  fields: ConnectorFieldConfig;
  metadata: Record<string, MetadataField>;
}

export const frmConnectorConfig: Record<string, ConnectorConfig> = {
  signifyd: {
    label: "signifyd",
    fields: {
      default: "test_value",
      overrides: {},
      fieldLabels: [],
    },
    metadata: {},
  },

  riskified: {
    label: "riskified",
    fields: {
      default: "test_value",
      overrides: {},
      fieldLabels: [],
    },
    metadata: {},
  },

  cybersource_decision_manager: {
    label: "cybersource_decision_manager",
    fields: {
      default: "test_value",
      overrides: {},
      fieldLabels: [],
    },
    metadata: {},
  },
};
