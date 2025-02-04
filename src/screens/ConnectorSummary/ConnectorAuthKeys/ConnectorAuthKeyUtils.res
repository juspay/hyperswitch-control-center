let connectorLabelDetailField = Dict.fromArray([
  ("connector_label", "Connector label"->JSON.Encode.string),
])
let getConnectorFields = connectorDetails => {
  open LogicUtils
  let connectorAccountDict =
    connectorDetails->getDictFromJsonObject->getDictfromDict("connector_auth")
  let bodyType = connectorAccountDict->Dict.keysToArray->Array.get(0)->Option.getOr("")
  let connectorAccountFields = connectorAccountDict->getDictfromDict(bodyType)
  let connectorMetaDataFields = connectorDetails->getDictFromJsonObject->getDictfromDict("metadata")
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
