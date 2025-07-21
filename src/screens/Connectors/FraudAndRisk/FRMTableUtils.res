let connectorEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => {
      []
    },
    ~defaultColumns=ConnectorTableUtils.defaultColumns,
    ~getHeading=ConnectorTableUtils.getHeading,
    ~getCell=ConnectorTableUtils.getTableCell(~connectorType=FRMPlayer),
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
