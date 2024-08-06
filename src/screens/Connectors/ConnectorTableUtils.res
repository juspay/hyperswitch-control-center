open ConnectorTypes

type colType =
  | Name
  | TestMode
  | Status
  | Disabled
  | Actions
  | ProfileId
  | ProfileName
  | ConnectorLabel
  | PaymentMethods

let defaultColumns = [
  Name,
  ProfileId,
  ProfileName,
  ConnectorLabel,
  Status,
  Disabled,
  TestMode,
  Actions,
  PaymentMethods,
]

let getConnectorObjectFromListViaId = (
  connectorList: array<ConnectorTypes.connectorPayload>,
  mca_id: string,
) => {
  connectorList
  ->Array.find(ele => {ele.merchant_connector_id == mca_id})
  ->Option.getOr(Dict.make()->ConnectorListMapper.getProcessorPayloadType)
}

let getAllPaymentMethods = (paymentMethodsArray: array<paymentMethodEnabledType>) => {
  let paymentMethods = paymentMethodsArray->Array.reduce([], (acc, item) => {
    acc->Array.concat([item.payment_method->LogicUtils.capitalizeString])
  })
  paymentMethods
}

let getHeading = colType => {
  switch colType {
  | Name => Table.makeHeaderInfo(~key="connector_name", ~title="Processor", ())
  | TestMode => Table.makeHeaderInfo(~key="test_mode", ~title="Test Mode", ())
  | Status => Table.makeHeaderInfo(~key="status", ~title="Integration status", ())
  | Disabled => Table.makeHeaderInfo(~key="disabled", ~title="Disabled", ())
  | Actions => Table.makeHeaderInfo(~key="actions", ~title="", ())
  | ProfileId => Table.makeHeaderInfo(~key="profile_id", ~title="Profile Id", ())
  | ProfileName => Table.makeHeaderInfo(~key="profile_name", ~title="Profile Name", ())
  | ConnectorLabel => Table.makeHeaderInfo(~key="connector_label", ~title="Connector Label", ())
  | PaymentMethods => Table.makeHeaderInfo(~key="payment_methods", ~title="Payment Methods", ())
  }
}
let connectorStatusStyle = connectorStatus =>
  switch connectorStatus->String.toLowerCase {
  | "active" => "text-green-700"
  | _ => "text-grey-800 opacity-50"
  }

let getTableCell = (~connectorType: ConnectorTypes.connector=Processor, ()) => {
  let getCell = (connector: connectorPayload, colType): Table.cell => {
    switch colType {
    | Name =>
      CustomCell(
        <HelperComponents.ConnectorCustomCell
          connectorName=connector.connector_name connectorType
        />,
        "",
      )
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
    | ProfileId => DisplayCopyCell(connector.profile_id)
    | ProfileName =>
      Table.CustomCell(
        <HelperComponents.BusinessProfileComponent profile_id={connector.profile_id} />,
        "",
      )
    | ConnectorLabel => Text(connector.connector_label)

    // | Actions =>
    //   Table.CustomCell(<ConnectorActions connector_id={connector.merchant_connector_id} />, "")
    | Actions => Table.CustomCell(<div />, "")
    | PaymentMethods =>
      Table.CustomCell(
        <div>
          {connector.payment_methods_enabled
          ->getAllPaymentMethods
          ->Array.joinWithUnsafe(", ")
          ->React.string}
        </div>,
        "",
      )
    }
  }
  getCell
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

let connectorEntity = (path: string, ~permission: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getPreviouslyConnectedList,
    ~defaultColumns,
    ~getHeading,
    ~getCell=getTableCell(~connectorType=Processor, ()),
    ~dataKey="",
    ~getShowLink={
      connec =>
        PermissionUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(
            ~url=`/${path}/${connec.merchant_connector_id}?name=${connec.connector_name}`,
          ),
          ~permission,
        )
    },
    (),
  )
}
