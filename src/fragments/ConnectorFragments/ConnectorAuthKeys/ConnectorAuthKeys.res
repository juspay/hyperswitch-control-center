@react.component
let make = (~initialValues, ~setInitialValues, ~showVertically=true) => {
  open LogicUtils
  open ConnectorFragmentUtils
  open ConnectorAuthKeysHelper
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  Js.log2("connectorconnectorconnectorconnector", connector)

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

  let (bodyType, connectorAccountFields, _, _, _, _, _) = getConnectorFields(connectorDetails)

  React.useEffect(() => {
    let updatedValues = initialValues->JSON.stringify->safeParse->getDictFromJsonObject
    let acc =
      [("auth_type", bodyType->JSON.Encode.string)]
      ->Dict.fromArray
      ->JSON.Encode.object

    let _ = updatedValues->Dict.set("connector_account_details", acc)
    setInitialValues(_ => updatedValues->Identity.genericTypeToJson)
    None
  }, [connector])

  <ConnectorConfigurationFields
    connector={connectorTypeFromName} connectorAccountFields selectedConnector showVertically
  />
}
