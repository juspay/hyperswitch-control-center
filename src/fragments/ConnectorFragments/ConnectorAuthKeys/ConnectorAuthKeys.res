@react.component
let make = (~initialValues, ~setInitialValues, ~showVertically=true) => {
  open LogicUtils
  open ConnectorAuthKeyUtils
  open ConnectorAuthKeysHelper
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let connectorTypeFromName = connector->ConnectorUtils.getConnectorNameTypeFromString
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
  }, [connector])
  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->ConnectorUtils.getConnectorInfo
  }, [connector])
  let (
    bodyType,
    connectorAccountFields,
    connectorMetaDataFields,
    isVerifyConnector,
    connectorWebHookDetails,
    connectorLabelDetailField,
    connectorAdditionalMerchantData,
  ) = getConnectorFields(connectorDetails)
  React.useEffect(() => {
    let updatedValues = initialValues->JSON.stringify->safeParse->getDictFromJsonObject
    let acc =
      [("auth_type", bodyType->JSON.Encode.string)]
      ->Dict.fromArray
      ->JSON.Encode.object

    let _ = updatedValues->Dict.set("connector_account_details", acc)
    setInitialValues(_ => updatedValues->Identity.genericTypeToJson)
    None
  }, [])

  <ConnectorConfigurationFields
    connector={connectorTypeFromName}
    connectorAccountFields
    selectedConnector
    connectorMetaDataFields
    connectorWebHookDetails
    connectorLabelDetailField
    connectorAdditionalMerchantData
    showVertically
  />
}
