module SubHeading = {
  @react.component
  let make = (~title, ~subTitle) => {
    <div className="flex flex-col gap-1">
      <p className="text-lg font-semibold text-grey-800"> {title->React.string} </p>
      <p className="text-sm text-gray-500"> {subTitle->React.string} </p>
    </div>
  }
}

let getConnectorDetails = (connectorList: array<ConnectorTypes.connectorPayloadV2>) => {
  let (mca, name) = switch connectorList->Array.get(0) {
  | Some(connectorDetails) => (connectorDetails.id, connectorDetails.connector_name)
  | _ => ("", "")
  }

  (mca, name)
}

let getConnectorConfig = connector => {
  switch connector {
  | "chargebee" =>
    {
      "connector_auth": {
        "HeaderKey": {
          "api_key": "Chargebee API Key",
        },
      },
      "connector_webhook_details": {
        "merchant_secret": "Username",
        "additional_secret": "Password",
      },
      "metadata": {
        "site": [
          ("name", "site"),
          ("label", "Site"),
          ("placeholder", "Enter chargebee site"),
          ("required", "true"),
          ("type", "Text"),
        ]->Map.fromArray,
      },
    }->Identity.genericTypeToJson
  | _ => JSON.Encode.null
  }
}
