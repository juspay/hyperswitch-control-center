open LogicUtils

let getArrayOfConnectorListPayloadType = (json, retainInList) => {
  json
  ->getArrayFromJson([])
  ->Array.map(connectorJson => {
    let data = connectorJson->getDictFromJsonObject->ConnectorInterfaceUtils.getProcessorPayloadType
    data
  })
  ->ConnectorInterfaceUtils.filterConnectorList(retainInList)
}

let getArrayOfConnectorListPayloadTypeV2 = (json, retainInList) => {
  json
  ->getArrayFromJson([])
  ->Array.map(connectorJson => {
    let data =
      connectorJson->getDictFromJsonObject->ConnectorInterfaceUtils.getProcessorPayloadTypeV2
    data
  })
  ->ConnectorInterfaceUtils.filterConnectorListV2(retainInList)
}
