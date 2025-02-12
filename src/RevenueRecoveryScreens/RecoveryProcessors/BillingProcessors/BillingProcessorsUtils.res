let getConnectorConfig = connector => {
  switch connector {
  | "chargebee" =>
    {
      "connector_auth": {
        "BodyKey": {
          "api_key": "Chargebee API Key",
          "key1": "Your site name",
        },
      },
      "connector_webhook_details": {
        "merchant_secret": "Username",
        "additional_secret": "Password",
      },
    }->Identity.genericTypeToJson
  | _ => JSON.Encode.null
  }
}
