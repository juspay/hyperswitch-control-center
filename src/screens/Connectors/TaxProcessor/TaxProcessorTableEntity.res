open ConnectorTypes

type colType =
  | Name
  | TestMode
  | Status
  | Disabled
  | MerchantConnectorId
  | ConnectorLabel

let defaultColumns = [Name, MerchantConnectorId, ConnectorLabel, Status, Disabled]

let getHeading = colType => {
  switch colType {
  | Name => Table.makeHeaderInfo(~key="connector_name", ~title="Processor")
  | TestMode => Table.makeHeaderInfo(~key="test_mode", ~title="Test Mode")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Integration status")
  | Disabled => Table.makeHeaderInfo(~key="disabled", ~title="Disabled")
  | ConnectorLabel => Table.makeHeaderInfo(~key="connector_label", ~title="Connector Label")
  | MerchantConnectorId =>
    Table.makeHeaderInfo(~key="merchant_connector_id", ~title="Merchant Connector Id")
  }
}
let connectorStatusStyle = connectorStatus =>
  switch connectorStatus->String.toLowerCase {
  | "active" => "text-green-700"
  | _ => "text-grey-800 opacity-50"
  }

let getCell = (connector: connectorPayloadCommonType, colType): Table.cell => {
  switch colType {
  | Name =>
    CustomCell(
      <HelperComponents.ConnectorCustomCell
        connectorName=connector.connector_name connectorType={TaxProcessor}
      />,
      "",
    )
  | TestMode => Text(connector.test_mode->Option.getOr(false) ? "True" : "False")
  | Disabled =>
    Label({
      title: connector.disabled ? "DISABLED" : "ENABLED",
      color: connector.disabled ? LabelGray : LabelGreen,
    })

  | Status =>
    Table.CustomCell(
      <div className={`font-semibold ${connector.status->connectorStatusStyle}`}>
        {connector.status->String.toUpperCase->React.string}
      </div>,
      "",
    )
  | ConnectorLabel => Text(connector.connector_label)
  | MerchantConnectorId =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customTextCss="w-36 truncate whitespace-nowrap" displayValue=Some(connector.id)
      />,
      "",
    )
  }
}

let taxProcessorEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns,
    ~getHeading,
    ~getCell,
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
