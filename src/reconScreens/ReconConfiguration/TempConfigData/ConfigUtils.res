let reportConfig =
  [
    {
      "custom_alerts": {
        "dashboard": false,
        "email": true,
        "mailing_list": {
          "Bcc": [],
          "Cc": [],
          "To": ["recon_dev@juspay.in"],
        },
        "slack": true,
        "slack_channel": "reconciliation_slack_channel",
      },
      "custom_reports": {
        "mappings": {
          "gateway": "Connector",
          "merchant_id": "Merchant",
          "payment_entity_txn_id": "Connector Id",
          "recon_id": "Recon Id",
          "recon_status": "Recon status",
          "recon_sub_status": "Recon Sub Status",
          "reconciled_at": "Reconciled At",
          "settlement_amount": "Settlement Amount",
          "settlement_id": "Settlement Id",
          "txn_amount": "Txn Amount",
          "txn_currency": "Txn Currency",
          "txn_type": "Txn Type",
        },
      },
    },
  ]
  ->Identity.genericTypeToJson
  ->JSON.stringify

let baseFIUUConfig = (merchantId: string) =>
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

let reconConfig = (merchantId: string, pspType: string) =>
  {
    "historical_check": "30 days",
    "probable_match": false,
    "recon": [
      {
        "allowed_buffer": 0,
        "buffer_columns": [],
        "deciders": [
          {
            "alias": "amount",
            "system_1_decider": "txn_amount",
            "system_2_decider": "txn_amount",
          },
        ],
        "primary_lookup": {
          "system_1_key": "payment_entity_txn_id",
          "system_2_key": "payment_entity_txn_id",
        },
      },
    ],
    "recon_observations": {
      "columns": {
        "recon1_status": "status",
        "recon1_sub_status": "sub_status",
        "recon_id": "recon_id",
        "reconciled_at": "reconciled_at",
        "remarks": "remarks",
        "system_a_file_id": "system_a_uuid",
        "system_a_id": "system_a_identifier",
        "system_a_name": "system_a",
        "system_b_file_id": "system_b_uuid",
        "system_b_id": "system_b_identifier",
        "system_b_name": "system_b",
      },
      "table": "reconciliation",
    },
    "system_a": {
      "aggregated": false,
      "aggregation_info": null,
      "file_id": "uuid",
      "filters": [
        {
          "fixed": false,
          "value": "uuid IN (SELECT file_uuid FROM {schema}.files_metadata WHERE batch_id IN (system_a_uuid))",
        },
      ],
      "identifier": "payment_entity_txn_id",
      "name": merchantId,
      "secondary_lookups": null,
      "selection_columns": [
        "txn_id",
        "txn_type",
        "payment_entity_txn_id",
        "txn_amount",
        "txn_status",
        "uuid",
      ],
      "table": "entity_transactions",
    },
    "system_b": {
      "aggregated": false,
      "aggregation_info": null,
      "file_id": "uuid",
      "filters": [
        {
          "fixed": false,
          "value": "uuid IN (SELECT file_uuid FROM {schema}.files_metadata WHERE batch_id IN (system_b_uuid))",
        },
      ],
      "identifier": "payment_entity_txn_id",
      "name": pspType,
      "secondary_lookups": null,
      "selection_columns": [
        "payment_entity_txn_id",
        "txn_type",
        "txn_amount",
        "settlement_id",
        "settlement_amount",
        "uuid",
      ],
      "table": "payment_entity_transactions",
    },
    "system_c": null,
    "three_way": false,
  }
  ->Identity.genericTypeToJson
  ->JSON.stringify

let baseProcessMetadata =
  {
    "Transformer": null,
  }
  ->Identity.genericTypeToJson
  ->JSON.stringify

let getTodayDate = () => {
  let currentDate = Date.getTime(Date.make())
  let date = Js.Date.fromFloat(currentDate)->Date.toISOString
  // return in YYYY-MM-DD format
  date->TimeZoneHook.formattedISOString("YYYY-MM-DDTHH:mm:ss[Z]")->String.slice(~start=0, ~end=10)
}

let getTomorrowDate = () => {
  let currentDate = Date.getTime(Date.make())
  let tomorrowDateMilliseconds = currentDate +. 86400000.0
  let tomorrowDate = Js.Date.fromFloat(tomorrowDateMilliseconds)->Date.toISOString
  // return in YYYY-MM-DD format
  tomorrowDate
  ->TimeZoneHook.formattedISOString("YYYY-MM-DDTHH:mm:ss[Z]")
  ->String.slice(~start=0, ~end=10)
}
