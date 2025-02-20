module SubHeading = {
  @react.component
  let make = (~title, ~subTitle) => {
    <div className="flex flex-col gap-1">
      <p className="text-lg font-semibold text-grey-800"> {title->React.string} </p>
      <p className="text-sm text-gray-500"> {subTitle->React.string} </p>
    </div>
  }
}

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

let getOptions: array<ConnectorTypes.connectorTypes> => array<
  SelectBox.dropdownOption,
> = dropdownList => {
  open ConnectorUtils
  open ConnectorTypes

  let options: array<SelectBox.dropdownOption> = dropdownList->Array.map((
    connector
  ): SelectBox.dropdownOption => {
    let connectorValue = connector->getConnectorNameString
    let connectorName = switch connector {
    | BillingProcessor(processor) => processor->getDisplayNameForBillingProcessor
    | _ => ""
    }

    {
      label: connectorName,
      value: connectorValue,
    }
  })
  options
}
