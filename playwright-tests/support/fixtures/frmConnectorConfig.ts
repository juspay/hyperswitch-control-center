import type { DummyPaymentMethod } from "../commands";

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
  // The name the dashboard shows for this player, both on its card and in the
  // Connected Processors table once it is set up.
  display_name: string;
  fields: ConnectorFieldConfig;
  metadata: Record<string, MetadataField>;
  card_locator: string;
  // The payment method the already-configured connector has to expose before this
  // player is offered anything to screen, and how that method is labelled on the
  // payment methods step.
  screened_payment_method: DummyPaymentMethod;
  screened_payment_method_label: string;
  // Restriction shown on the payment methods step, where the player only works with
  // particular connectors. The backend owns the enforcement, the dashboard only says so.
  compatibility_note?: string;
}

export const frmConnectorConfig: Record<string, ConnectorConfig> = {
  cybersource_decision_manager: {
    label: "cybersource_decision_manager",
    display_name: "Cybersource Decision Manager",
    fields: {
      default: "test_value",
      overrides: {},
      fieldLabels: [],
    },
    metadata: {},
    card_locator:
      "Cybersource Decision ManagerComprehensive fraud management solution for",
    screened_payment_method: "card",
    screened_payment_method_label: "Card",
  },

  signifyd: {
    label: "signifyd",
    display_name: "Signifyd",
    fields: {
      default: "test_value",
      overrides: {},
      fieldLabels: [],
    },
    metadata: {},
    card_locator: "SignifydOne platform to",
    screened_payment_method: "card",
    screened_payment_method_label: "Card",
  },

  riskified: {
    label: "riskified",
    display_name: "Riskified",
    fields: {
      default: "test_value",
      overrides: {},
      fieldLabels: [],
    },
    metadata: {},
    card_locator: "RiskifiedFrictionless fraud",
    screened_payment_method: "card",
    screened_payment_method_label: "Card",
  },

  sanlam_payshield: {
    label: "sanlam_payshield",
    display_name: "Sanlam Payshield",
    fields: {
      default: "test_value",
      overrides: {},
      fieldLabels: ["API Key *"],
    },
    metadata: {},
    card_locator: "Sanlam PayshieldSanlam Payshield is a Fraud",
    screened_payment_method: "bank_debit",
    screened_payment_method_label: "Bank Debit",
    compatibility_note:
      "Sanlam Payshield screens bank debit payments and bank transfer payouts. It is only compatible with the Absa payment connector and the GoTyme payout connector.",
  },
};
