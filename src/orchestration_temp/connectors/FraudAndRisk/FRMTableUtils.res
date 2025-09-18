let connectorEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns=ConnectorInterfaceTableEntity.defaultColumns,
    ~getHeading=ConnectorInterfaceTableEntity.getHeading,
    ~getCell=ConnectorInterfaceTableEntity.getTableCell(~connectorType=FRMPlayer),
    ~dataKey="",
    ~getShowLink={
      connec =>
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(
            ~url=`/${path}/${connec.id}?name=${connec.connector_name}`,
          ),
          ~authorization,
        )
    },
  )
}
