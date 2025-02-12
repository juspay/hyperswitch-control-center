@react.component
let make = (
  ~showVertically=true,
  ~labelTextStyleClass="",
  ~labelClass="font-semibold !text-hyperswitch_black",
) => {
  open LogicUtils
  open ConnectorFragmentUtils
  open ConnectorAuthKeysHelper
  let connector = UrlUtils.useGetFilterDictFromUrl("")->getString("name", "")

  let connectorTypeFromName = connector->ConnectorUtils.getConnectorNameTypeFromString

  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->ConnectorUtils.getConnectorInfo
  }, [connector])

  let connectorDetails = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let dict = Window.getConnectorConfig(connector)

        dict
      } else {
        Dict.make()->JSON.Encode.object
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        Dict.make()->JSON.Encode.object
      }
    }
  }, [selectedConnector])

  let (_, _, _, _, connectorWebHookDetails, _, _) = getConnectorFields(connectorDetails)

  <RenderConnectorInputFields
    details={connectorWebHookDetails}
    name={"connector_webhook_details"}
    checkRequiredFields={ConnectorUtils.getWebHookRequiredFields}
    connector={connectorTypeFromName}
    selectedConnector
    labelTextStyleClass
    labelClass
  />
}
