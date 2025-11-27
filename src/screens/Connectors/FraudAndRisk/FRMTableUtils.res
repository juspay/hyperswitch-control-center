let connectorEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns=ConnectorInterfaceTableEntity.defaultColumns,
    ~getHeading=ConnectorInterfaceTableEntity.getHeading,
    ~getCell=ConnectorInterfaceTableEntity.getTableCell(~connectorType=FRMPlayer),
    ~dataKey="",
    ~getShowLink={
      connector =>
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(
            ~url=`/${path}/${connector.id}?name=${connector.connector_name}`,
          ),
          ~authorization,
        )
    },
  )
}
