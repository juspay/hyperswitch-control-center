let generateRandomApiKey = (~prefix: string) => {
  prefix ++ "_" ++ LogicUtils.randomString(~length=24)
}

let connector_account_details = {
  "auth_type": "HeaderKey",
  "api_key": generateRandomApiKey(~prefix="sk"),
}->Identity.genericTypeToJson

let vantiv_connector_account_details = merchantId =>
  [
    ("auth_type", "SignatureKey"->JSON.Encode.string),
    ("api_key", generateRandomApiKey(~prefix="api")->JSON.Encode.string),
    ("key1", merchantId->JSON.Encode.string),
    ("api_secret", generateRandomApiKey(~prefix="secret")->JSON.Encode.string),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object

let payment_connector_webhook_details = {
  "merchant_secret": generateRandomApiKey(~prefix="secret"),
}->Identity.genericTypeToJson

let metadata = {
  "site": generateRandomApiKey(~prefix="site"),
}->Identity.genericTypeToJson

let vantiv_metaData =
  [
    ("report_group", "default"->JSON.Encode.string),
    ("merchant_config_currency", "USD"->JSON.Encode.string),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object

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

let fillDummyData = (
  ~connector,
  ~initialValuesToDict,
  ~merchantId,
  ~connectorID="",
  ~connectorType=ConnectorTypes.Processor,
) => {
  switch connector->ConnectorUtils.getConnectorNameTypeFromString(~connectorType) {
  | Processors(STRIPE) => {
      initialValuesToDict->Dict.set("connector_account_details", connector_account_details)
      initialValuesToDict->Dict.set("connector_webhook_details", payment_connector_webhook_details)
    }
  | Processors(WORLDPAYVANTIV) => {
      initialValuesToDict->Dict.set(
        "connector_account_details",
        vantiv_connector_account_details(merchantId),
      )
      initialValuesToDict->Dict.set("metadata", vantiv_metaData)
    }
  | BillingProcessor(CHARGEBEE) => {
      initialValuesToDict->Dict.set("connector_account_details", connector_account_details)
      initialValuesToDict->Dict.set("connector_webhook_details", connector_webhook_details)
      initialValuesToDict->Dict.set("feature_metadata", feature_metadata(~id=connectorID))
      initialValuesToDict->Dict.set("metadata", metadata)
    }
  | BillingProcessor(CUSTOMBILLING) => {
      initialValuesToDict->Dict.set("connector_account_details", connector_account_details)
      initialValuesToDict->Dict.set("feature_metadata", feature_metadata(~id=connectorID))
    }

  | _ => ()
  }
}
