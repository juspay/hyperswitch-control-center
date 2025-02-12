@react.component
let make = (~initialValues, ~setInitialValues, ~showVertically=true) => {
  open LogicUtils
  open ConnectorAuthKeyUtils
  open ConnectorAuthKeysHelper

  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let connectorTypeFromName = connector->ConnectorUtils.getConnectorNameTypeFromString

  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->ConnectorUtils.getConnectorInfo
  }, [connector])

  let connectorDetails = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let dict = BillingProcessorsUtils.getConnectorConfig(connector)
        dict
      } else {
        Dict.make()->JSON.Encode.object
      }
    } catch {
    | Exn.Error(_e) => Dict.make()->JSON.Encode.object
    }
  }, [selectedConnector])

  let (
    bodyType,
    connectorAccountFields,
    connectorMetaDataFields,
    _isVerifyConnector,
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
  }, [connector])

  <div>
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
  </div>
}
