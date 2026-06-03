let connectorEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns=ConnectorInterfaceTableEntity.defaultColumns,
    ~getHeading=ConnectorInterfaceTableEntity.getHeading,
    ~getCell=ConnectorInterfaceTableEntity.getTableCell(~connectorType=FRMPlayer),
    ~dataKey="",
    ~getShowLink={
      connectorObj =>
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(
            ~url=`/${path}/${connectorObj.id}?name=${connectorObj.connector_name}`,
          ),
          ~authorization,
        )
    },
  )
}
