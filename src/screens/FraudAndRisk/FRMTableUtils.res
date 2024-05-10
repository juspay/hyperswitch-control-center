let getArrayDataFromJson = (json, itemToObjMapper) => {
  json
  ->JSON.Decode.array
  ->Option.getOr([])
  ->Belt.Array.keepMap(JSON.Decode.object)
  ->FRMUtils.filterList(~removeFromList=Connector, ())
  ->Array.map(itemToObjMapper)
}

let getPreviouslyConnectedList: JSON.t => array<ConnectorTypes.connectorPayload> = json => {
  getArrayDataFromJson(
    json,
    ConnectorListMapper.getProcessorPayloadType,
  )->ConnectorTableUtils.sortPreviouslyConnectedList
}

let connectorEntity = (path: string, ~permission: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getPreviouslyConnectedList,
    ~defaultColumns=ConnectorTableUtils.defaultColumns,
    ~getHeading=ConnectorTableUtils.getHeading,
    ~getCell=ConnectorTableUtils.getCell,
    ~dataKey="",
    ~getShowLink={
      connec =>
        PermissionUtils.linkForGetShowLinkViaAccess(
          ~url=HSwitchGlobalVars.appendDashboardPath(
            ~url=`/${path}/${connec.merchant_connector_id}?name=${connec.connector_name}`,
          ),
          ~permission,
        )
    },
    (),
  )
}
