let generateRandomApiKey = (~prefix: string) => {
  prefix ++ "_" ++ LogicUtils.randomString(~length=24)
}

let connector_account_details = {
  "auth_type": "HeaderKey",
  "api_key": generateRandomApiKey(~prefix="sk"),
}->Identity.genericTypeToJson

let payment_connector_webhook_details = {
  "merchant_secret": generateRandomApiKey(~prefix="secret"),
}->Identity.genericTypeToJson

let metadata = {
  "site": generateRandomApiKey(~prefix="site"),
}->Identity.genericTypeToJson

let connector_webhook_details = {
  "merchant_secret": generateRandomApiKey(~prefix="secret"),
  "additional_secret": generateRandomApiKey(~prefix="secret"),
}->Identity.genericTypeToJson

let feature_metadata = (~id) => {
  let billing_account_reference =
    [(id, generateRandomApiKey(~prefix="acct")->JSON.Encode.string)]->Dict.fromArray

  {
    "revenue_recovery": {
      "billing_connector_retry_threshold": 3,
      "max_retry_count": 15,
      "billing_account_reference": billing_account_reference->Identity.genericTypeToJson,
    },
  }->Identity.genericTypeToJson
}
