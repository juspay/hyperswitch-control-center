open ConnectorTypes

type colType =
  | Name
  | TestMode
  | Status
  | Disabled

  | ProfileId
  | ProfileName
  | ConnectorLabel

let defaultColumns = [Name, ProfileId, ProfileName, ConnectorLabel, Status, Disabled, TestMode]

let getHeading = colType => {
  switch colType {
  | Name => Table.makeHeaderInfo(~key="connector_name", ~title="Processor", ~showSort=false, ())
  | TestMode => Table.makeHeaderInfo(~key="test_mode", ~title="Test Mode", ~showSort=false, ())
  | Status => Table.makeHeaderInfo(~key="status", ~title="Integration status", ~showSort=false, ())
  | Disabled => Table.makeHeaderInfo(~key="disabled", ~title="Disabled", ~showSort=false, ())
  | ProfileId => Table.makeHeaderInfo(~key="profile_id", ~title="Profile Id", ~showSort=false, ())
  | ProfileName =>
    Table.makeHeaderInfo(~key="profile_name", ~title="Profile Name", ~showSort=false, ())
  | ConnectorLabel =>
    Table.makeHeaderInfo(~key="connector_label", ~title="Connector Label", ~showSort=false, ())
  }
}
let connectorStatusStyle = connectorStatus =>
  switch connectorStatus->String.toLowerCase {
  | "active" => "text-green-700"
  | _ => "text-grey-800 opacity-50"
  }

let getCell = (connector: connectorPayload, colType): Table.cell => {
  switch colType {
  | Name => Text(connector.connector_name)
  | TestMode => Text(connector.test_mode ? "True" : "False")
  | Disabled =>
    Label({
      title: connector.disabled ? "DISABLED" : "ENABLED",
      color: connector.disabled ? LabelRed : LabelGreen,
    })

  | Status =>
    Table.CustomCell(
      <div className={`font-semibold ${connector.status->connectorStatusStyle}`}>
        {connector.status->String.toUpperCase->React.string}
      </div>,
      "",
    )
  | ProfileId => Text(connector.profile_id)
  | ProfileName =>
    Table.CustomCell(
      <HelperComponents.BusinessProfileComponent profile_id={connector.profile_id} />,
      "",
    )
  | ConnectorLabel => Text(connector.connector_label)
  }
}

let comparatorFunction = (connector1: connectorPayload, connector2: connectorPayload) => {
  connector1.connector_name->String.localeCompare(connector2.connector_name)
}

let sortPreviouslyConnectedList = arr => {
  Array.toSorted(arr, comparatorFunction)
}

let getPreviouslyConnectedList: JSON.t => array<connectorPayload> = json => {
  LogicUtils.getArrayDataFromJson(json, ConnectorListMapper.getProcessorPayloadType)
}

let threeDsAuthenticatorEntity = (path: string, ~permission: AuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getPreviouslyConnectedList,
    ~defaultColumns,
    ~getHeading,
    ~getCell,
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
