@react.component
let make = (
  ~labelTextStyleClass="",
  ~labelClass="font-semibold !text-hyperswitch_black",
  ~isInEditState,
  ~connectorInfo: ConnectorTypes.connectorPayload,
) => {
  open LogicUtils
  open ConnectorMetaDataUtils
  open ConnectorFragmentUtils
  open ConnectorHelperV2

  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
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

  let (_, _, connectorMetaDataFields, _, _, _, _) = getConnectorFields(connectorDetails)

  let keys =
    connectorMetaDataFields
    ->Dict.keysToArray
    ->Array.filter(ele => !Array.includes(metaDataInputKeysToIgnore, ele))
  <>
    {keys
    ->Array.mapWithIndex((field, index) => {
      let fields =
        connectorMetaDataFields
        ->getDictfromDict(field)
        ->JSON.Encode.object
        ->convertMapObjectToDict
        ->CommonConnectorUtils.inputFieldMapper

      let {\"type", name, label} = fields

      let value = switch \"type" {
      | Text | Select | Toggle => connectorInfo.metadata->getDictFromJsonObject->getString(name, "")
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
