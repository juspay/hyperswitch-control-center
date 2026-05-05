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

export const threedsAuthProcessorConfig: Record<string, ConnectorConfig> = {
  netcetera: {
    label: "netcetera",
    fields: {
      default: "test_value",
      overrides: {
        "Base64 encoded PEM formatted certificate chain": "netcetera_cert",
        "Base64 encoded PEM formatted private key": "netcetera_key",
      },
      fieldLabels: [
        "Base64 encoded PEM formatted certificate chain *",
        "Base64 encoded PEM formatted private key *",
      ],
    },
    metadata: {
      endpoint_prefix: { label: "Endpoint Prefix", required: false },
      mcc: { label: "Merchant Category Code", required: false },
      merchant_country_code: { label: "Merchant Country Code", required: false },
      merchant_name: { label: "Merchant Name", required: false },
      three_ds_requestor_name: { label: "3DS Requestor Name", required: false },
      three_ds_requestor_id: { label: "3DS Requestor ID", required: false },
      merchant_configuration_id: { label: "Merchant Configuration ID", required: false },
    },
  },

  juspaythreedsserver: {
    label: "juspaythreedsserver",
    fields: {
      default: "test_value",
      overrides: {},
      fieldLabels: [],
    },
    metadata: {
      merchant_country_code: { label: "Merchant Country Code", required: false },
      merchant_name: { label: "Merchant Name", required: false },
      three_ds_requestor_name: { label: "3DS Requestor Name", required: false },
      three_ds_requestor_id: { label: "3DS Requestor ID", required: false },
      pull_mechanism_for_external_3ds_enabled: {
        label: "Pull Mechanism for External 3DS Enabled",
        required: false,
      },
      merchant_category_code: { label: "Merchant Category Code", required: false },
    },
  },

  ctp_visa: {
    label: "ctp_visa",
    fields: {
      default: "test_value",
      overrides: {},
      fieldLabels: [],
    },
    metadata: {
      merchant_country_code: { label: "Merchant Country Code", required: false },
      acquirer_bin: { label: "Acquirer BIN", required: false },
      acquirer_merchant_id: { label: "Acquirer Merchant ID", required: false },
      dpa_id: { label: "DPA ID", required: false },
      dpa_name: { label: "DPA Name", required: false },
      locale: { label: "Locale", required: false },
      merchant_category_code: { label: "Merchant Category Code", required: false },
    },
  },
};
