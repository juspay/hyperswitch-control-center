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
  | MerchantConnectorId

let defaultColumns = [
  Name,
  MerchantConnectorId,
  ProfileId,
  ProfileName,
  ConnectorLabel,
  Status,
  Disabled,
  TestMode,
  Actions,
  PaymentMethods,
]

let getAllPaymentMethods = (paymentMethodsArray: array<paymentMethodEnabledType>) => {
  let paymentMethods = paymentMethodsArray->Array.reduce([], (acc, item) => {
    acc->Array.concat([item.payment_method->LogicUtils.capitalizeString])
  })
  paymentMethods
}

let getHeading = colType => {
  switch colType {
  | Name => Table.makeHeaderInfo(~key="connector_name", ~title="Processor")
  | TestMode => Table.makeHeaderInfo(~key="test_mode", ~title="Test Mode")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Integration status")
  | Disabled => Table.makeHeaderInfo(~key="disabled", ~title="Disabled")
  | Actions => Table.makeHeaderInfo(~key="actions", ~title="")
  | ProfileId => Table.makeHeaderInfo(~key="profile_id", ~title="Profile Id")
  | MerchantConnectorId =>
    Table.makeHeaderInfo(~key="merchant_connector_id", ~title="Merchant Connector Id")
  | ProfileName => Table.makeHeaderInfo(~key="profile_name", ~title="Profile Name")
  | ConnectorLabel => Table.makeHeaderInfo(~key="connector_label", ~title="Connector Label")
  | PaymentMethods => Table.makeHeaderInfo(~key="payment_methods", ~title="Payment Methods")
  }
}
let connectorStatusStyle = connectorStatus =>
  switch connectorStatus->String.toLowerCase {
  | "active" => "text-green-700"
  | _ => "text-grey-800 opacity-50"
  }

let getCell = (connector: connectorPayload, colType): Table.cell => {
  switch colType {
  | Name =>
    CustomCell(
      <HelperComponents.ConnectorCustomCell
        connectorName=connector.connector_name connectorType={PayoutProcessor}
      />,
      "",
    )
  | TestMode => Text(connector.test_mode ? "True" : "False")
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
  | ProfileId =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customTextCss="w-36 truncate whitespace-nowrap" displayValue=Some(connector.profile_id)
      />,
      "",
    )
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
        ->Array.joinWith(", ")
        ->React.string}
      </div>,
      "",
    )
  | MerchantConnectorId =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customTextCss="w-36 truncate whitespace-nowrap"
        displayValue=Some(connector.merchant_connector_id)
      />,
      "",
    )
  }
}

let comparatorFunction = (connector1: connectorPayload, connector2: connectorPayload) => {
  connector1.connector_name->String.localeCompare(connector2.connector_name)
}

let sortPreviouslyConnectedList = arr => {
  Array.toSorted(arr, comparatorFunction)
}

let getPreviouslyConnectedList: JSON.t => array<connectorPayload> = json => {
  let data = ConnectorInterface.mapJsonArrayToConnectorPayloads(
    ConnectorInterface.connectorInterfaceV1,
    json,
    PayoutProcessor,
  )
  data
}

let payoutProcessorEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getPreviouslyConnectedList,
    ~defaultColumns,
    ~getHeading,
    ~getCell,
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
