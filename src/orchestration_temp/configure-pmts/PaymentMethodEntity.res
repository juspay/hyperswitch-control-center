open PaymentMethodConfigTypes
type colType =
  | Processor
  | PaymentMethodType
  | PaymentMethod
  | CardNetwork
  | CountriesAllowed
  | CurrenciesAllowed

let defaultColumns = [
  Processor,
  PaymentMethodType,
  PaymentMethod,
  CountriesAllowed,
  CurrenciesAllowed,
  CardNetwork,
]

let getHeading = colType => {
  switch colType {
  | Processor => Table.makeHeaderInfo(~key="connector_name", ~title="Processor")
  | PaymentMethod => Table.makeHeaderInfo(~key="payment_method", ~title="Payment Method")
  | PaymentMethodType =>
    Table.makeHeaderInfo(~key="payment_method_type", ~title="Payment Method Type")

  | CountriesAllowed => Table.makeHeaderInfo(~key="accepted_countries", ~title="Countries Allowed")
  | CurrenciesAllowed =>
    Table.makeHeaderInfo(~key="accepted_currencies", ~title="Currencies Allowed")
  | CardNetwork => Table.makeHeaderInfo(~key="card_network", ~title="Card Network")
  }
}
let getCell = (~setReferesh) => {
  let getPaymentMethodConfigCell = (
    paymentMethodConfig: paymentMethodConfiguration,
    colType,
  ): Table.cell => {
    open PaymentMethodConfigUtils
    switch colType {
    | Processor =>
      Table.CustomCell(
        <PaymentMethodConfig
          paymentMethodConfig config={paymentMethodConfig.connector_name} setReferesh
        />,
        "",
      )
    | PaymentMethod =>
      Table.CustomCell(
        <PaymentMethodConfig
          paymentMethodConfig config={paymentMethodConfig.payment_method} setReferesh
        />,
        "",
      )
    | PaymentMethodType =>
      Table.CustomCell(
        <PaymentMethodConfig
          paymentMethodConfig config={paymentMethodConfig.payment_method_type} setReferesh
        />,
        "",
      )

    | CountriesAllowed =>
      Table.CustomCell(
        <PaymentMethodConfig
          paymentMethodConfig
          element={paymentMethodConfig.accepted_countries->getAdvanceConfiguration}
          setReferesh
        />,
        "",
      )
    | CurrenciesAllowed =>
      Table.CustomCell(
        <PaymentMethodConfig
          paymentMethodConfig
          element={paymentMethodConfig.accepted_currencies->getAdvanceConfiguration}
          setReferesh
        />,
        "",
      )
    | CardNetwork =>
      Table.CustomCell(
        <PaymentMethodConfig
          paymentMethodConfig config={paymentMethodConfig.card_networks->Array.toString} setReferesh
        />,
        "",
      )
    }
  }
  getPaymentMethodConfigCell
}

let itemObjMapper = (list: ConnectorTypes.connectorPayloadCommonType, mappedArr) => {
  let paymentMethod = list.payment_methods_enabled

  if list.connector_type === PaymentProcessor {
    paymentMethod->Array.forEachWithIndex((_, pmIndex) => {
      PaymentMethodConfigUtils.mapPaymentMethodValues(~connectorPayload=list, ~mappedArr, ~pmIndex)
    })
  }
}

let getFilterdConnectorList = (
  list: array<ConnectorTypes.connectorPayloadCommonType>,
  filters: PaymentMethodConfigTypes.paymentMethodConfigFilters,
): array<paymentMethodConfiguration> => {
  let mappedArr = []
  let _ =
    list->Array.forEach(item =>
      item->PaymentMethodConfigUtils.filterItemObjMapper(mappedArr, filters)
    )
  mappedArr
}

let getConnectedList: array<ConnectorTypes.connectorPayloadCommonType> => array<
  paymentMethodConfiguration,
> = list => {
  let mappedArr = []
  list->Array.forEach(item => itemObjMapper(item, mappedArr))
  mappedArr
}

let getObjects: JSON.t => array<'t> = _ => {
  []
}

let paymentMethodEntity = (~setReferesh: unit => promise<unit>) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects,
    ~defaultColumns,
    ~getHeading,
    ~getCell=getCell(~setReferesh),
    ~dataKey="",
  )
}
