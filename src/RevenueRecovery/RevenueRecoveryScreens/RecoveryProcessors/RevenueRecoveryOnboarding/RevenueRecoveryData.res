let connector_account_details = {
  "auth_type": "HeaderKey",
  "api_key": "sk_51HfYdZK8b3X9qLmW
",
}->Identity.genericTypeToJson

let payment_connector_webhook_details = {
  "merchant_secret": "secret_9FvX2YtL7KqW4",
}->Identity.genericTypeToJson

let metadata = {
  "site": "site_9FvX2YtL7KqW4",
}->Identity.genericTypeToJson

let connector_webhook_details = {
  "merchant_secret": "secret_9FvX2YtL7KqW4",
  "additional_secret": "secret_A7XgT5L2Yt9F",
}->Identity.genericTypeToJson

let feature_metadata = (~id) => {
  let billing_account_reference =
    [(id, "acct_12Xy9KqW4RmJ0P5vN6ZC3XgTLM8S2A7"->JSON.Encode.string)]->Dict.fromArray

  {
    "revenue_recovery": {
      "billing_connector_retry_threshold": 3,
      "max_retry_count": 15,
      "billing_account_reference": billing_account_reference->Identity.genericTypeToJson,
    },
  }->Identity.genericTypeToJson
}
