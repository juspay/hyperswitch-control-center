let getArrayDataFromJson = (json, itemToObjMapper) => {
  open Belt.Option
  json
  ->Js.Json.decodeArray
  ->getWithDefault([])
  ->Belt.Array.keepMap(Js.Json.decodeObject)
  ->FRMUtils.filterList(~removeFromList=Connector, ())
  ->Array.map(itemToObjMapper)
}

let getPreviouslyConnectedList: Js.Json.t => array<ConnectorTypes.connectorPayload> = json => {
  getArrayDataFromJson(
    json,
    ConnectorTableUtils.getProcessorPayloadType,
  )->ConnectorTableUtils.sortPreviouslyConnectedList
}

let connectorEntity = (path: string) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getPreviouslyConnectedList,
    ~defaultColumns=ConnectorTableUtils.defaultColumns,
    ~getHeading=ConnectorTableUtils.getHeading,
    ~getCell=ConnectorTableUtils.getCell,
    ~dataKey="",
    ~getShowLink={
      connec => `/${path}/${connec.merchant_connector_id}?name=${connec.connector_name}`
    },
    (),
  )
}
