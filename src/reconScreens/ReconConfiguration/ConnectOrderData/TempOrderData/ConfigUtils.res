let reportConfig = [
  {
    "custom_alerts": {
      "dashboard": false,
      "email": true,
      "mailing_list": {
        "Bcc": [],
        "Cc": [],
        "To": [],
      },
      "slack": true,
      "slack_channel": "reconciliation_slack_channel",
    },
    "custom_reports": {
      "mappings": {
        "convenience_fees": "Convenience Fees",
        "fee": "Fee",
        "gateway": "Connector",
        "mdr": "MDR",
        "merchant_id": "Merchant",
        "payment_entity_txn_id": "Connector Id",
        "payment_method": "Payment Method",
        "payment_method_type": "Payment Method Type",
        "platform_fees": "Platform Fees",
        "recon_id": "Recon Id",
        "recon_secondary_status": "ConnectorvsBank Status",
        "recon_secondary_sub_status": "ConnectorvsBank Sub Status",
        "recon_status": "MerchantvsConnector status",
        "recon_sub_status": "MerchantvsConnector Sub Status",
        "reconciled_at": "Reconciled At",
        "settlement_amount": "Settlement Amount",
        "settlement_id": "Settlement Id",
        "tax": "Tax",
        "txn_amount": "Txn Amount",
        "txn_currency": "Txn Currency",
        "txn_date": "Txn Date",
        "txn_id": "Merchant Id",
        "txn_type": "Txn Type",
      },
    },
  },
]->Identity.genericTypeToJson

let baseHyperswitchConfig = (merchantId: string) =>
  {
    "global_configuration": {
      "mutations": {
        "computations": [],
        "mutations": [
          {
            "mutation_col": "merchant_id",
            "replacement": [
              {
                "filters": [],
                "value": merchantId,
              },
            ],
          },
        ],
      },
    },
    "local_configuration": [
      {
        "filters": [
          {
            "condition": "GTE",
            "field": "amount",
            "value": "0",
          },
        ],
        "mappings": {
          "payment_entity_txn_id": "epg_txn_id",
          "txn_amount": "effective_amount",
          "txn_currency": "ord_currency",
          "txn_date": "order_date_created",
          "txn_id": "juspay_txn_id",
          "txn_status": "actual_payment_status",
          "udf1": "amount",
          "udf2": "offer_deduction_amount",
          "udf3": "order_ids",
        },
        "mutations": {
          "computations": [],
          "mutations": [
            {
              "mutation_col": "txn_type",
              "replacement": [
                {
                  "filters": [],
                  "value": "ORDER",
                },
              ],
            },
          ],
        },
        "type": "ORDER",
      },
      {
        "filters": [
          {
            "condition": "LT",
            "field": "amount",
            "value": "0",
          },
        ],
        "mappings": {
          "payment_entity_txn_id": "epg_txn_id",
          "txn_amount": "effective_amount",
          "txn_currency": "ord_currency",
          "txn_date": "order_date_created",
          "txn_id": "juspay_txn_id",
          "txn_status": "actual_payment_status",
          "udf1": "amount",
          "udf2": "offer_deduction_amount",
          "udf3": "order_ids",
        },
        "mutations": {
          "computations": [],
          "mutations": [
            {
              "mutation_col": "txn_type",
              "replacement": [
                {
                  "filters": [],
                  "value": "REFUND",
                },
              ],
            },
          ],
        },
        "type": "REFUND",
      },
    ],
    "preprocessing": false,
    "validation": {
      "check_fields": {
        "date_format_check": {
          "txn_date": "%m/%d/%Y",
        },
        "duplicate_records_check": ["txn_id", "payment_entity_txn_id", "txn_amount", "txn_date"],
        "nan_value_check": ["txn_id", "payment_entity_txn_id", "txn_amount", "txn_date"],
        "numeric_dtype_check": ["txn_amount"],
        "pkey_check": ["txn_id", "payment_entity_txn_id"],
        "scientific_value_check": ["txn_id", "payment_entity_txn_id", "txn_amount"],
      },
      "checks": [
        "check_fields",
        "date_format_check",
        "nan_value_check",
        "numeric_dtype_check",
        "duplicate_records_check",
        "scientific_value_check",
      ],
    },
  }->Identity.genericTypeToJson

let pspConfig = (merchantId: string, pspType: string) =>
  {
    "global_configuration": {
      "mutations": {
        "computations": [],
        "mutations": [],
      },
    },
    "local_configuration": [
      {
        "filters": [
          {
            "condition": "EQ",
            "field": "requestaction",
            "value": "capture",
          },
        ],
        "mappings": {
          "fee": "mer_service_fee",
          "payment_entity_txn_id": "payuid",
          "payment_method": "mode",
          "payment_method_type": "PG_TYPE",
          "settlement_amount": "mer_net_amount",
          "settlement_id": "txnid",
          "tax": "mer_service_tax",
          "txn_amount": "amount",
          "txn_date": "txndate",
          "udf1": "requestaction",
          "utr": "mer_utr",
        },
        "mutations": {
          "computations": [],
          "mutations": [
            {
              "mutation_col": "txn_type",
              "replacement": [
                {
                  "filters": [],
                  "value": "ORDER",
                },
              ],
            },
            {
              "mutation_col": "gateway",
              "replacement": [
                {
                  "filters": [],
                  "value": pspType,
                },
              ],
            },
            {
              "mutation_col": "merchant_id",
              "replacement": [
                {
                  "filters": [],
                  "value": merchantId,
                },
              ],
            },
          ],
        },
        "type": "ORDER",
      },
      {
        "filters": [
          {
            "condition": "EQ",
            "field": "requestaction",
            "value": "refund",
          },
        ],
        "mappings": {
          "fee": "mer_service_fee",
          "payment_entity_txn_id": "payuid",
          "payment_method": "mode",
          "payment_method_type": "PG_TYPE",
          "settlement_amount": "mer_net_amount",
          "settlement_id": "txnid",
          "tax": "mer_service_tax",
          "txn_amount": "amount",
          "txn_date": "txndate",
          "udf1": "requestaction",
          "utr": "mer_utr",
        },
        "mutations": {
          "computations": [],
          "mutations": [
            {
              "mutation_col": "txn_type",
              "replacement": [
                {
                  "filters": [],
                  "value": "REFUND",
                },
              ],
            },
            {
              "mutation_col": "gateway",
              "replacement": [
                {
                  "filters": [],
                  "value": pspType,
                },
              ],
            },
            {
              "mutation_col": "merchant_id",
              "replacement": [
                {
                  "filters": [],
                  "value": merchantId,
                },
              ],
            },
          ],
        },
        "type": "REFUND",
      },
    ],
    "preprocessing": false,
    "validation": {
      "check_fields": {
        "date_format_check": {
          "txn_date": "%Y-%m-%d %H:%M:%S",
        },
        "duplicate_records_check": [
          "payment_entity_txn_id",
          "txn_amount",
          "txn_date",
          "settlement_amount",
        ],
        "nan_value_check": ["payment_entity_txn_id", "txn_amount", "txn_date", "settlement_amount"],
        "numeric_dtype_check": ["txn_amount"],
        "pkey_check": ["payment_entity_txn_id"],
        "scientific_value_check": ["payment_entity_txn_id", "txn_amount"],
      },
      "checks": [
        "check_fields",
        "date_format_check",
        "nan_value_check",
        "numeric_dtype_check",
        "duplicate_records_check",
        "scientific_value_check",
      ],
    },
  }->Identity.genericTypeToJson
