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
  card_locator: string;
}

export const frmConnectorConfig: Record<string, ConnectorConfig> = {
  cybersource_decision_manager: {
    label: "cybersource_decision_manager",
    fields: {
      default: "test_value",
      overrides: {},
      fieldLabels: [],
    },
    metadata: {},
    card_locator: "Cybersource Decision ManagerComprehensive fraud management solution for"
  },

  signifyd: {
    label: "signifyd",
    fields: {
      default: "test_value",
      overrides: {},
      fieldLabels: [],
    },
    metadata: {},
    card_locator: "SignifydOne platform to"
  },

  riskified: {
    label: "riskified",
    fields: {
      default: "test_value",
      overrides: {},
      fieldLabels: [],
    },
    metadata: {},
    card_locator: "RiskifiedFrictionless fraud"
  },
};
