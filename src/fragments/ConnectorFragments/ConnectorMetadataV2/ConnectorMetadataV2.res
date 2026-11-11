@react.component
let make = (
  ~labelTextStyleClass="",
  ~labelClass="font-semibold !text-hyperswitch_black",
  ~isInEditState,
  ~connectorInfo: ConnectorTypes.connectorPayloadV2,
  ~processorType=ConnectorTypes.Processor,
) => {
  open LogicUtils
  open ConnectorMetaDataUtils
  open ConnectorHelperV2

  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let connectorTypeFromName =
    connector->ConnectorUtils.getConnectorNameTypeFromString(~connectorType=processorType)

  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->ConnectorUtils.getConnectorInfo
  }, [connector])

  let connectorMetaDataFields = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let dict = switch processorType {
        | Processor => Window.getConnectorConfig(connector)
        | PayoutProcessor => Window.getPayoutConnectorConfig(connector)
        | ThreeDsAuthenticator => Window.getAuthenticationConnectorConfig(connector)
        | PMAuthenticationProcessor => Window.getPMAuthenticationProcessorConfig(connector)
        | TaxProcessor => Window.getTaxProcessorConfig(connector)
        | BillingProcessor =>
          BillingProcessorsUtils.getConnectorConfig(
            connector,
            ~wasmConfig=Window.getBillingConnectorConfig(connector->LogicUtils.capitalizeString),
          )
        | VaultProcessor => Window.getConnectorConfig(connector)
        | SurchargeProcessor => Window.getSurchargeProcessorConfig(connector)
        | FRMPlayer => JSON.Encode.null
        }

        dict->getDictFromJsonObject->getDictfromDict("metadata")
      } else {
        Dict.make()
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR METADATA CONFIG", e)
        Dict.make()
      }
    }
  }, [selectedConnector])

  let metadataValues = connectorInfo.metadata->JsonFlattenUtils.flattenObject(true)
  <>
    {connectorMetaDataFields
    ->getMetadataInputFields
    ->Array.mapWithIndex((fields, index) => {
      let {\"type", name, label} = fields

      let value = switch \"type" {
      | Text | Select | Toggle => metadataValues->getString(name, "")
      | _ => ""
      }

      {
        if isInEditState {
          <FormRenderer.FieldRenderer
            key={index->Int.toString}
            labelClass
            field={ConnectorHelperV2.connectorMetaDataValueInput(~connectorMetaDataFields={fields})}
            labelTextStyleClass
          />
        } else {
          <RenderIf key={index->Int.toString} condition={value->isNonEmptyString}>
            <InfoField label str=value />
          </RenderIf>
        }
      }
    })
    ->React.array}
  </>
}
