open ConnectorTypes

type colType =
  | Name
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
  Actions,
  PaymentMethods,
]
let getHeading = colType => {
  switch colType {
  | Name => Table.makeHeaderInfo(~key="connector_name", ~title="Processor")
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

let getAllPaymentMethods = (paymentMethodsArray: array<paymentMethodEnabledTypeCommon>) => {
  let paymentMethods = paymentMethodsArray->Array.reduce([], (acc, item) => {
    acc->Array.concat([item.payment_method_type->LogicUtils.capitalizeString])
  })
  paymentMethods
}
let getTableCell = (~connectorType: connector=Processor) => {
  let getCell = (connector: connectorPayloadCommonType, colType): Table.cell => {
    switch colType {
    | Name =>
      CustomCell(
        <HelperComponents.ConnectorCustomCell
          connectorName=connector.connector_name connectorType
        />,
        "",
      )
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
    | ProfileId => DisplayCopyCell(connector.profile_id)
    | ProfileName =>
      Table.CustomCell(
        <HelperComponents.ProfileNameComponent profile_id={connector.profile_id} />,
        "",
      )
    | ConnectorLabel => Text(connector.connector_label)
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
    | MerchantConnectorId => DisplayCopyCell(connector.id)
    }
  }
  getCell
}

let connectorEntity = (
  path: string,
  ~authorization: CommonAuthTypes.authorization,
  ~sendMixpanelEvent,
) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns,
    ~getHeading,
    ~getCell=getTableCell(~connectorType=Processor),
    ~dataKey="",
    ~getShowLink={
      connec => {
        sendMixpanelEvent()
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(
            ~url=`/${path}/${connec.id}?name=${connec.connector_name}`,
          ),
          ~authorization,
        )
      }
    },
  )
}
