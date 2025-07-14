// TODO: This sample data will be removed
let rules = {
  [
    {
      "rule_id": "rule_Cb64cR5ikD",
      "rule_name": "Life3_Adyen_Reconciliation",
      "rule_description": "Reconciles Life3 files with Adyen data using Connector ID and Payment ID.",
      "priority": 1,
      "is_active": true,
      "profile_id": "pro_SLv8NAnWxZ83HgZR5MKv",
      "sources": [
        {
          "id": "src_OBcNm1mG4e",
          "account_id": "account_V3AuIg3UwC",
          "trigger": {
            "trigger_version": "v1",
            "field": "metadata.card_type",
            "operator": {
              "operator_version": "v1",
              "value": "equals",
            },
            "value": "J",
          },
        },
      ],
      "targets": [
        {
          "id": "tgt_f57CTg9nSS",
          "account_id": "account_BHoCexbS_4",
          "match_rules": {
            "match_version": "v1",
            "rules": [
              {
                "source_field": "metadata.merchant_new",
                "target_field": "metadata.merchant_account",
                "operator": "equals",
              },
              {
                "source_field": "amount",
                "target_field": "amount",
                "operator": "equals",
              },
              {
                "source_field": "currency",
                "target_field": "currency",
                "operator": "equals",
              },
            ],
          },
          "search_identifier": {
            "search_version": "v1",
            "source_field": "metadata.trans_desc",
            "target_field": "metadata.merchant_reference",
          },
        },
      ],
    },
    {
      "rule_id": "rule_Abc123XyZ",
      "rule_name": "PayPal_Transaction_Match",
      "rule_description": "Matches PayPal transactions with internal payment records.",
      "priority": 2,
      "is_active": false,
      "profile_id": "pro_ABC123XYZ789",
      "sources": [
        {
          "id": "src_PayPal123",
          "account_id": "account_PayPal456",
          "trigger": {
            "trigger_version": "v1",
            "field": "transaction.type",
            "operator": {
              "operator_version": "v1",
              "value": "equals",
            },
            "value": "payment",
          },
        },
      ],
      "targets": [
        {
          "id": "tgt_PayPal789",
          "account_id": "account_Internal123",
          "match_rules": {
            "match_version": "v1",
            "rules": [
              {
                "source_field": "transaction.id",
                "target_field": "payment.external_id",
                "operator": "equals",
              },
            ],
          },
          "search_identifier": {
            "search_version": "v1",
            "source_field": "transaction.reference",
            "target_field": "payment.reference",
          },
        },
      ],
    },
  ]
}->Identity.genericTypeToJson
