@react.component
let make = () => {
  open LogicUtils
  open ConnectorMetaDataUtils
  open ConnectorAuthKeyUtils

  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let connectorTypeFromName = connector->ConnectorUtils.getConnectorNameTypeFromString

  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->ConnectorUtils.getConnectorInfo
  }, [connector])

  let getConnectorFields = connectorDetails => {
    let connectorAccountDict =
      connectorDetails->getDictFromJsonObject->getDictfromDict("connector_auth")
    let bodyType = connectorAccountDict->Dict.keysToArray->Array.get(0)->Option.getOr("")
    let connectorAccountFields = connectorAccountDict->getDictfromDict(bodyType)
    let connectorMetaDataFields =
      connectorDetails->getDictFromJsonObject->getDictfromDict("metadata")
    let isVerifyConnector = connectorDetails->getDictFromJsonObject->getBool("is_verifiable", false)
    let connectorWebHookDetails =
      connectorDetails->getDictFromJsonObject->getDictfromDict("connector_webhook_details")
    let connectorAdditionalMerchantData =
      connectorDetails
      ->getDictFromJsonObject
      ->getDictfromDict("additional_merchant_data")
    (
      bodyType,
      connectorAccountFields,
      connectorMetaDataFields,
      isVerifyConnector,
      connectorWebHookDetails,
      connectorLabelDetailField,
      connectorAdditionalMerchantData,
    )
  }
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
          labelClass="font-semibold !text-hyperswitch_black"
          field={ConnectorHelperV2.connectorMetaDataValueInput(~connectorMetaDataFields={fields})}
        />
      </div>
    })
    ->React.array}
  </>
}
