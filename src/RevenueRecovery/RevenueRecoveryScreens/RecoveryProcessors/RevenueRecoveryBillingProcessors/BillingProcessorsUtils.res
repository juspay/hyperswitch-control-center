module SubHeading = {
  @react.component
  let make = (~title, ~subTitle) => {
    <div className="flex flex-col gap-1">
      <p className="text-lg font-semibold text-grey-800"> {title->React.string} </p>
      <p className="text-sm text-gray-500"> {subTitle->React.string} </p>
    </div>
  }
}

let getConnectorDetails = (connectorList: array<ConnectorTypes.connectorPayloadCommonType>) => {
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
  | "stripebilling" =>
    {
      "connector_auth": {
        "HeaderKey": {
          "api_key": "Stripe billing API Key",
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

type optionType = {
  name: string,
  icon: string,
}

module ReadOnlyOptionsList = {
  @react.component
  let make = (~list: array<optionType>, ~headerText, ~customWrapperStyle="") => {
    <div
      className={`flex flex-col items-start gap-3.5 font-medium  px-3.5 py-3 ${customWrapperStyle}`}>
      <p className=" text-nd_gray-500 font-semibold leading-3 text-fs-12 tracking-wider bg-white">
        {headerText->React.string}
      </p>
      <div className="flex flex-col gap-2.5 overflow-scroll cursor-not-allowed w-full">
        {list
        ->Array.mapWithIndex((option, _) => {
          let size = "w-4 h-4 rounded-sm"

          <div className="flex flex-row gap-3 items-center">
            <img alt="image" src=option.icon className=size />
            <p className="text-sm font-medium normal-case text-nd_gray-600/40">
              {option.name->React.string}
            </p>
          </div>
        })
        ->React.array}
      </div>
    </div>
  }
}
