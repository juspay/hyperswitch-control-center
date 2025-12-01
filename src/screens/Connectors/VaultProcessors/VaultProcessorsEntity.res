open ConnectorTypes
open Typography

type colType =
  | Name
  | TestMode
  | Status
  | Disabled
  | MerchantConnectorId
  | ConnectorLabel

let defaultColumns = [Name, MerchantConnectorId, ConnectorLabel, Status]

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
  connectorStatus->String.toLowerCase == "active" ? "text-green-700" : "text-grey-800 opacity-50"

let getCell = (
  connector: connectorPayloadCommonType,
  colType,
  external_vault_connector_details: option<
    BusinessProfileInterfaceTypes.externalVaultConnectorDetails,
  >,
): Table.cell => {
  let vault_connector_id =
    external_vault_connector_details
    ->Option.map(details => details.vault_connector_id)
    ->Option.getOr("")

  switch colType {
  | Name =>
    CustomCell(
      <HelperComponents.ConnectorCustomCell
        connectorName=connector.connector_name
        connectorType=VaultProcessor
        showDefaultTag={connector.id == vault_connector_id}
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
      <div className={`${body.xs.semibold} ${connector.status->connectorStatusStyle}`}>
        {connector.status->String.toUpperCase->React.string}
      </div>,
      "",
    )
  | ConnectorLabel => Text(connector.connector_label)
  | MerchantConnectorId => DisplayCopyCell(connector.id)
  }
}

let vaultProcessorEntity = (
  path: string,
  ~authorization: CommonAuthTypes.authorization,
  ~external_vault_connector_details: option<
    BusinessProfileInterfaceTypes.externalVaultConnectorDetails,
  >,
) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns,
    ~getHeading,
    ~getCell=(connectorPayloadCommonType, colType) => {
      getCell(connectorPayloadCommonType, colType, external_vault_connector_details)
    },
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
