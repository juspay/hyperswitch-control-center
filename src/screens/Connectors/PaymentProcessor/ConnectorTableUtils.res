open ConnectorTypes

type colType =
  | Name
  | TestMode
  | Status
  | Disabled
  | Actions
  | ConnectorLabel
  | PaymentMethods
  | MerchantConnectorId

let defaultColumns = [
  Name,
  MerchantConnectorId,
  ConnectorLabel,
  Status,
  Disabled,
  Actions,
  PaymentMethods,
]

let getConnectorObjectFromListViaId = (
  connectorList: array<ConnectorTypes.connectorPayloadCommonType>,
  mca_id: string,
) => {
  connectorList
  ->Array.find(ele => {ele.id == mca_id})
  ->Option.getOr(
    ConnectorListInterface.mapDictToConnectorPayload(
      ConnectorListInterface.connectorInterfaceV1,
      Dict.make(),
    ),
  )
}

let getAllPaymentMethods = (paymentMethodsArray: array<paymentMethodEnabledTypeCommon>) => {
  let paymentMethods = paymentMethodsArray->Array.reduce([], (acc, item) => {
    acc->Array.concat([item.payment_method_type->LogicUtils.capitalizeString])
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
  | MerchantConnectorId =>
    Table.makeHeaderInfo(~key="merchant_connector_id", ~title="Merchant Connector Id")
  | ConnectorLabel => Table.makeHeaderInfo(~key="connector_label", ~title="Connector Label")
  | PaymentMethods => Table.makeHeaderInfo(~key="payment_methods", ~title="Payment Methods")
  }
}
let connectorStatusStyle = connectorStatus =>
  switch connectorStatus->String.toLowerCase {
  | "active" => "text-green-700"
  | _ => "text-grey-800 opacity-50"
  }

let getTableCell = (~connectorType: ConnectorTypes.connector=Processor) => {
  let getCell = (connector: connectorPayloadCommonType, colType): Table.cell => {
    switch colType {
    | Name =>
      CustomCell(
        <HelperComponents.ConnectorCustomCell
          connectorName=connector.connector_name connectorType
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
          customTextCss="w-36 truncate whitespace-nowrap" displayValue=Some(connector.id)
        />,
        "",
      )
    }
  }
  getCell
}

let connectorEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns,
    ~getHeading,
    ~getCell=getTableCell(~connectorType=Processor),
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
