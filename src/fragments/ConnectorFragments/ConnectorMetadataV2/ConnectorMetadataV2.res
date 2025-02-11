@react.component
let make = (~labelTextStyleClass="", ~labelClass="font-semibold !text-hyperswitch_black") => {
  open LogicUtils
  open ConnectorMetaDataUtils
  open ConnectorFragmentUtils

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

      <div key={index->Int.toString}>
        <FormRenderer.FieldRenderer
          labelClass
          field={ConnectorHelperV2.connectorMetaDataValueInput(~connectorMetaDataFields={fields})}
          labelTextStyleClass
        />
      </div>
    })
    ->React.array}
  </>
}
