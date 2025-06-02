module DummyKeyGen = {
  let randomString = (~length) => {
    let text =
      Array.make(~length, "")
      ->Array.map(_ => {
        let min = 65.0
        let max = 122.0
        let index = Math.floor(Math.random() *. (max -. min) +. min)->Int.fromFloat

        String.fromCharCode(index)
      })
      ->Array.joinWith("")

    text
  }

  let apiKey = (~prefix: string) => {
    prefix ++ "_" ++ randomString(~length=24)
  }
}

let connector_account_details = {
  "auth_type": "HeaderKey",
  "api_key": DummyKeyGen.apiKey(~prefix="sk"),
}->Identity.genericTypeToJson

let payment_connector_webhook_details = {
  "merchant_secret": DummyKeyGen.apiKey(~prefix="secret"),
}->Identity.genericTypeToJson

let metadata = {
  "site": DummyKeyGen.apiKey(~prefix="site"),
}->Identity.genericTypeToJson

let connector_webhook_details = {
  "merchant_secret": DummyKeyGen.apiKey(~prefix="secret"),
  "additional_secret": DummyKeyGen.apiKey(~prefix="secret"),
}->Identity.genericTypeToJson

let feature_metadata = (~id) => {
  let billing_account_reference =
    [(id, DummyKeyGen.apiKey(~prefix="acct")->JSON.Encode.string)]->Dict.fromArray

  {
    "revenue_recovery": {
      "billing_connector_retry_threshold": 3,
      "max_retry_count": 15,
      "billing_account_reference": billing_account_reference->Identity.genericTypeToJson,
    },
  }->Identity.genericTypeToJson
}

let orderData = {
  "count": 20,
  "total_count": 20,
  "data": [
    {
      "id": "12345_pay_001",
      "status": "processing",
      "amount": {
        "order_amount": 100,
        "currency": "INR",
        "net_amount": 100,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_001",
      "created": "2025-03-19T10:01:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "bhim",
      "attempts": [
        {
          "id": "12345_att_001_01",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_001_02",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_001_03",
          "status": "failure",
          "error": "Fraud suspicion",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_001_04",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_001_05",
          "status": "failure",
          "error": "Decline due to daily cutoff being in progress",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_001_06",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_001_07",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_001_08",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_001_09",
          "status": "failure",
          "error": "Decline due to daily cutoff being in progress",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_001_10",
          "status": "upcoming_attempt",
          "error": "",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_002",
      "status": "processing",
      "amount": {
        "order_amount": 200,
        "currency": "INR",
        "net_amount": 200,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_002",
      "created": "2025-03-18T10:02:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "credit",
      "attempts": [
        {
          "id": "12345_att_002_01",
          "status": "failure",
          "error": "Card expired",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_002_02",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_002_03",
          "status": "failure",
          "error": "Transaction limit exceeded",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_002_04",
          "status": "failure",
          "error": "Card expired",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_002_05",
          "status": "failure",
          "error": "Fraud suspicion",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_002_06",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_002_07",
          "status": "upcoming_attempt",
          "error": "",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_003",
      "status": "failed",
      "amount": {
        "order_amount": 300,
        "currency": "INR",
        "net_amount": 300,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_003",
      "created": "2025-03-17T10:03:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "bhim",
      "attempts": [
        {
          "id": "12345_att_003_01",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_003_02",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_003_03",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_003_04",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_003_05",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_003_06",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_003_07",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_003_08",
          "status": "failure",
          "error": "Decline due to daily cutoff being in progress",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_003_09",
          "status": "failure",
          "error": "Decline due to daily cutoff being in progress",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_003_10",
          "status": "failure",
          "error": "3D Secure authentication failed",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_003_11",
          "status": "failure",
          "error": "Decline due to daily cutoff being in progress",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_003_12",
          "status": "failure",
          "error": "3D Secure authentication failed",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_003_13",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_003_14",
          "status": "failure",
          "error": "Insufficient funds",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_003_15",
          "status": "failure",
          "error": "Decline due to daily cutoff being in progress",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_004",
      "status": "succeeded",
      "amount": {
        "order_amount": 400,
        "currency": "INR",
        "net_amount": 400,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_004",
      "created": "2025-03-16T10:04:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "credit",
      "attempts": [
        {
          "id": "12345_att_004_01",
          "status": "failure",
          "error": "Transaction limit exceeded",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_004_02",
          "status": "failure",
          "error": "Transaction limit exceeded",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_004_03",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_004_04",
          "status": "failure",
          "error": "Bank server unavailable",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_004_05",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_004_06",
          "status": "failure",
          "error": "Bank server unavailable",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_004_07",
          "status": "failure",
          "error": "Fraud suspicion",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_004_08",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_004_09",
          "status": "charged",
          "error": "",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_005",
      "status": "processing",
      "amount": {
        "order_amount": 500,
        "currency": "INR",
        "net_amount": 500,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_005",
      "created": "2025-03-15T10:05:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "bhim",
      "attempts": [
        {
          "id": "12345_att_005_01",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_005_02",
          "status": "failure",
          "error": "Decline due to daily cutoff being in progress",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_005_03",
          "status": "failure",
          "error": "Decline due to daily cutoff being in progress",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_005_04",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_005_05",
          "status": "failure",
          "error": "Card expired",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_005_06",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_005_07",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_005_08",
          "status": "failure",
          "error": "Fraud suspicion",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_005_09",
          "status": "failure",
          "error": "Insufficient funds",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_005_10",
          "status": "upcoming_attempt",
          "error": "",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_006",
      "status": "failed",
      "amount": {
        "order_amount": 600,
        "currency": "INR",
        "net_amount": 600,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_006",
      "created": "2025-03-14T10:06:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "credit",
      "attempts": [
        {
          "id": "12345_att_006_01",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_006_02",
          "status": "failure",
          "error": "Transaction limit exceeded",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_006_03",
          "status": "failure",
          "error": "Bank server unavailable",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_006_04",
          "status": "failure",
          "error": "Transaction limit exceeded",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_006_05",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_006_06",
          "status": "failure",
          "error": "Fraud suspicion",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_006_07",
          "status": "failure",
          "error": "Bank server unavailable",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_006_08",
          "status": "failure",
          "error": "Insufficient funds",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_006_09",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_006_10",
          "status": "failure",
          "error": "Card expired",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_006_11",
          "status": "failure",
          "error": "Insufficient funds",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_006_12",
          "status": "failure",
          "error": "Insufficient funds",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_006_13",
          "status": "failure",
          "error": "3D Secure authentication failed",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_006_14",
          "status": "failure",
          "error": "Decline due to daily cutoff being in progress",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_006_15",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_007",
      "status": "processing",
      "amount": {
        "order_amount": 700,
        "currency": "INR",
        "net_amount": 700,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_007",
      "created": "2025-03-13T10:07:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "bhim",
      "attempts": [
        {
          "id": "12345_att_007_01",
          "status": "failure",
          "error": "Decline due to daily cutoff being in progress",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_007_02",
          "status": "failure",
          "error": "Decline due to daily cutoff being in progress",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_007_03",
          "status": "failure",
          "error": "Bank server unavailable",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_007_04",
          "status": "failure",
          "error": "Fraud suspicion",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_007_05",
          "status": "failure",
          "error": "Transaction limit exceeded",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_007_06",
          "status": "failure",
          "error": "Fraud suspicion",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_007_07",
          "status": "failure",
          "error": "Decline due to daily cutoff being in progress",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_007_08",
          "status": "failure",
          "error": "Fraud suspicion",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_007_09",
          "status": "upcoming_attempt",
          "error": "",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_008",
      "status": "succeeded",
      "amount": {
        "order_amount": 800,
        "currency": "INR",
        "net_amount": 800,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_008",
      "created": "2025-03-12T10:08:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "credit",
      "attempts": [
        {
          "id": "12345_att_008_01",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_008_02",
          "status": "charged",
          "error": "",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_009",
      "status": "failed",
      "amount": {
        "order_amount": 900,
        "currency": "INR",
        "net_amount": 900,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_009",
      "created": "2025-03-11T10:09:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "bhim",
      "attempts": [
        {
          "id": "12345_att_009_01",
          "status": "failure",
          "error": "Transaction limit exceeded",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_009_02",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_009_03",
          "status": "failure",
          "error": "Bank server unavailable",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_009_04",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_009_05",
          "status": "failure",
          "error": "3D Secure authentication failed",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_009_06",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_009_07",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_009_08",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_009_09",
          "status": "failure",
          "error": "Bank server unavailable",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_009_10",
          "status": "failure",
          "error": "Fraud suspicion",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_009_11",
          "status": "failure",
          "error": "3D Secure authentication failed",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_009_12",
          "status": "failure",
          "error": "Insufficient funds",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_009_13",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_009_14",
          "status": "failure",
          "error": "Bank server unavailable",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_009_15",
          "status": "failure",
          "error": "Transaction limit exceeded",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_010",
      "status": "processing",
      "amount": {
        "order_amount": 1000,
        "currency": "INR",
        "net_amount": 1000,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_010",
      "created": "2025-03-10T10:10:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "credit",
      "attempts": [
        {
          "id": "12345_att_010_01",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_010_02",
          "status": "failure",
          "error": "3D Secure authentication failed",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_010_03",
          "status": "failure",
          "error": "Card expired",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_010_04",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_010_05",
          "status": "failure",
          "error": "Bank server unavailable",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_010_06",
          "status": "failure",
          "error": "Card expired",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_010_07",
          "status": "upcoming_attempt",
          "error": "",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_011",
      "status": "processing",
      "amount": {
        "order_amount": 1100,
        "currency": "INR",
        "net_amount": 1100,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_011",
      "created": "2025-03-9T10:11:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "bhim",
      "attempts": [
        {
          "id": "12345_att_011_01",
          "status": "failure",
          "error": "Bank server unavailable",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_011_02",
          "status": "failure",
          "error": "Transaction limit exceeded",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_011_03",
          "status": "failure",
          "error": "Decline due to daily cutoff being in progress",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_011_04",
          "status": "failure",
          "error": "Insufficient funds",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_011_05",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_011_06",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_011_07",
          "status": "failure",
          "error": "Fraud suspicion",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_011_08",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_011_09",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_011_10",
          "status": "upcoming_attempt",
          "error": "",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_012",
      "status": "succeeded",
      "amount": {
        "order_amount": 1200,
        "currency": "INR",
        "net_amount": 1200,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_012",
      "created": "2025-03-8T10:12:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "credit",
      "attempts": [
        {
          "id": "12345_att_012_01",
          "status": "charged",
          "error": "",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_013",
      "status": "processing",
      "amount": {
        "order_amount": 1300,
        "currency": "INR",
        "net_amount": 1300,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_013",
      "created": "2025-03-7T10:13:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "bhim",
      "attempts": [
        {
          "id": "12345_att_013_01",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_013_02",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_013_03",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_013_04",
          "status": "failure",
          "error": "Fraud suspicion",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_013_05",
          "status": "failure",
          "error": "Transaction limit exceeded",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_013_06",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_013_07",
          "status": "failure",
          "error": "Card expired",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_013_08",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_013_09",
          "status": "upcoming_attempt",
          "error": "",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_014",
      "status": "processing",
      "amount": {
        "order_amount": 1400,
        "currency": "INR",
        "net_amount": 1400,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_014",
      "created": "2025-03-6T10:14:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "credit",
      "attempts": [
        {
          "id": "12345_att_014_01",
          "status": "failure",
          "error": "3D Secure authentication failed",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_014_02",
          "status": "failure",
          "error": "Fraud suspicion",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_014_03",
          "status": "failure",
          "error": "Card expired",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_014_04",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_014_05",
          "status": "failure",
          "error": "Bank server unavailable",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_014_06",
          "status": "failure",
          "error": "Card expired",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_014_07",
          "status": "failure",
          "error": "Bank server unavailable",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_014_08",
          "status": "upcoming_attempt",
          "error": "",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_015",
      "status": "failed",
      "amount": {
        "order_amount": 1500,
        "currency": "INR",
        "net_amount": 1500,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_015",
      "created": "2025-03-5T10:15:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "bhim",
      "attempts": [
        {
          "id": "12345_att_015_01",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_015_02",
          "status": "failure",
          "error": "Card expired",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_015_03",
          "status": "failure",
          "error": "3D Secure authentication failed",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_015_04",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_015_05",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_015_06",
          "status": "failure",
          "error": "Fraud suspicion",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_015_07",
          "status": "failure",
          "error": "Transaction limit exceeded",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_015_08",
          "status": "failure",
          "error": "Fraud suspicion",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_015_09",
          "status": "failure",
          "error": "Transaction limit exceeded",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_015_10",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_015_11",
          "status": "failure",
          "error": "Insufficient funds",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_015_12",
          "status": "failure",
          "error": "Bank server unavailable",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_015_13",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_015_14",
          "status": "failure",
          "error": "Insufficient funds",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_015_15",
          "status": "failure",
          "error": "Decline due to daily cutoff being in progress",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_016",
      "status": "succeeded",
      "amount": {
        "order_amount": 1600,
        "currency": "INR",
        "net_amount": 1600,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_016",
      "created": "2025-03-4T10:16:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "credit",
      "attempts": [
        {
          "id": "12345_att_016_01",
          "status": "failure",
          "error": "Insufficient funds",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_016_02",
          "status": "failure",
          "error": "Transaction limit exceeded",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_016_03",
          "status": "failure",
          "error": "Insufficient funds",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_016_04",
          "status": "charged",
          "error": "",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_017",
      "status": "processing",
      "amount": {
        "order_amount": 1700,
        "currency": "INR",
        "net_amount": 1700,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_017",
      "created": "2025-03-3T10:17:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "bhim",
      "attempts": [
        {
          "id": "12345_att_017_01",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_017_02",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_017_03",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_017_04",
          "status": "failure",
          "error": "Transaction limit exceeded",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_017_05",
          "status": "failure",
          "error": "Card expired",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_017_06",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_017_07",
          "status": "failure",
          "error": "Bank server unavailable",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_017_08",
          "status": "upcoming_attempt",
          "error": "",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_018",
      "status": "failed",
      "amount": {
        "order_amount": 1800,
        "currency": "INR",
        "net_amount": 1800,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_018",
      "created": "2025-03-2T10:18:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "credit",
      "attempts": [
        {
          "id": "12345_att_018_01",
          "status": "failure",
          "error": "3D Secure authentication failed",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_018_02",
          "status": "failure",
          "error": "Bank server unavailable",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_018_03",
          "status": "failure",
          "error": "Transaction limit exceeded",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_018_04",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_018_05",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_018_06",
          "status": "failure",
          "error": "Fraud suspicion",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_018_07",
          "status": "failure",
          "error": "Decline due to daily cutoff being in progress",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_018_08",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_018_09",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_018_10",
          "status": "failure",
          "error": "Card expired",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_018_11",
          "status": "failure",
          "error": "Bank server unavailable",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_018_12",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_018_13",
          "status": "failure",
          "error": "Fraud suspicion",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_018_14",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_018_15",
          "status": "failure",
          "error": "Insufficient funds",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_019",
      "status": "processing",
      "amount": {
        "order_amount": 1900,
        "currency": "INR",
        "net_amount": 1900,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_019",
      "created": "2025-03-1T10:19:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "bhim",
      "attempts": [
        {
          "id": "12345_att_019_01",
          "status": "failure",
          "error": "3D Secure authentication failed",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_019_02",
          "status": "failure",
          "error": "Insufficient funds",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_019_03",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_019_04",
          "status": "failure",
          "error": "Bank server unavailable",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_019_05",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_019_06",
          "status": "failure",
          "error": "Decline due to daily cutoff being in progress",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_019_07",
          "status": "failure",
          "error": "3D Secure authentication failed",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_019_08",
          "status": "failure",
          "error": "Insufficient funds",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_019_09",
          "status": "failure",
          "error": "Transaction limit exceeded",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_019_10",
          "status": "upcoming_attempt",
          "error": "",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
    {
      "id": "12345_pay_020",
      "status": "succeeded",
      "amount": {
        "order_amount": 2000,
        "currency": "INR",
        "net_amount": 2000,
      },
      "connector": "stripe",
      "client_secret": "12345_secret_020",
      "created": "2025-03-0T10:20:03.000Z",
      "payment_method_type": "card",
      "payment_method_subtype": "credit",
      "attempts": [
        {
          "id": "12345_att_020_01",
          "status": "failure",
          "error": "Invalid payment method",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_020_02",
          "status": "failure",
          "error": "Invalid CVV",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_020_03",
          "status": "failure",
          "error": "Bank server unavailable",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_020_04",
          "status": "failure",
          "error": "Account restricted",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_020_05",
          "status": "failure",
          "error": "3D Secure authentication failed",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
        {
          "id": "12345_att_020_06",
          "status": "charged",
          "error": "",
          "feature_metadata": {
            "revenue_recovery": {
              "attempt_triggered_by": "internal",
            },
          },
          "created": "2025-03-17T13:20:12.000Z",
        },
      ],
    },
  ],
}->Identity.genericTypeToJson
