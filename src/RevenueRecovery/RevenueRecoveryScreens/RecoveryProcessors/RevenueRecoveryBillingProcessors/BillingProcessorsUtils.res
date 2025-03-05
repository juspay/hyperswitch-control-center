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
        "HeaderKey": {
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
