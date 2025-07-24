open ConnectorTypes

type colType =
  | Name
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

let getHeading = colType => {
  switch colType {
  | Name => Table.makeHeaderInfo(~key="connector_name", ~title="Processor")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Integration status")
  | Disabled => Table.makeHeaderInfo(~key="disabled", ~title="Disabled")
  | Actions => Table.makeHeaderInfo(~key="actions", ~title="")
  | MerchantConnectorId =>
    Table.makeHeaderInfo(~key="merchant_connector_id", ~title="Merchant Connector Id")
  | ConnectorLabel => Table.makeHeaderInfo(~key="connector_label", ~title="Connector Label")
  | PaymentMethods => Table.makeHeaderInfo(~key="payment_methods", ~title="Payment Methods")
  }
}

let getAllPaymentMethods = (paymentMethodsArray: array<paymentMethodEnabledTypeCommon>) => {
  let paymentMethods = paymentMethodsArray->Array.reduce([], (acc, item) => {
    acc->Array.concat([item.payment_method_type->LogicUtils.capitalizeString])
  })
  paymentMethods
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

let getConnectorObjectFromListViaId = (
  connectorList: array<ConnectorTypes.connectorPayloadCommonType>,
  mca_id: string,
  ~version: UserInfoTypes.version,
) => {
  let interface = switch version {
  | V1 => ConnectorListInterface.connectorInterfaceV1
  | V2 => ConnectorListInterface.connectorInterfaceV2
  }
  connectorList
  ->Array.find(ele => {ele.id == mca_id})
  ->Option.getOr(ConnectorListInterface.mapDictToConnectorPayload(interface, Dict.make())) //interface
}
