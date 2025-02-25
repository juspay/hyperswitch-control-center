let getArrayDataFromJson = (json, itemToObjMapper) => {
  json
  ->JSON.Decode.array
  ->Option.getOr([])
  ->Belt.Array.keepMap(JSON.Decode.object)
  ->FRMUtils.filterList(~removeFromList=Connector)
  ->Array.map(itemToObjMapper)
}

let getPreviouslyConnectedList: JSON.t => array<ConnectorTypes.connectorPayload> = json => {
  json
  ->ConnectorInterface.getArrayOfConnectorListPayloadType
  ->ConnectorTableUtils.sortPreviouslyConnectedList
}

let connectorEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getPreviouslyConnectedList,
    ~defaultColumns=ConnectorTableUtils.defaultColumns,
    ~getHeading=ConnectorTableUtils.getHeading,
    ~getCell=ConnectorTableUtils.getTableCell(~connectorType=FRMPlayer),
    ~dataKey="",
    ~getShowLink={
      connec =>
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(
            ~url=`/${path}/${connec.merchant_connector_id}?name=${connec.connector_name}`,
          ),
          ~authorization,
        )
    },
  )
}
