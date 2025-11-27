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
let getCell = (~setRefresh) => {
  let getPaymentMethodConfigCell = (
    paymentMethodConfig: paymentMethodConfiguration,
    colType,
  ): Table.cell => {
    open PaymentMethodConfigUtils
    switch colType {
    | Processor =>
      Table.CustomCell(
        <PaymentMethodConfig
          paymentMethodConfig config={paymentMethodConfig.connector_name} setRefresh
        />,
        "",
      )
    | PaymentMethod =>
      Table.CustomCell(
        <PaymentMethodConfig
          paymentMethodConfig config={paymentMethodConfig.payment_method} setRefresh
        />,
        "",
      )
    | PaymentMethodType =>
      Table.CustomCell(
        <PaymentMethodConfig
          paymentMethodConfig config={paymentMethodConfig.payment_method_type} setRefresh
        />,
        "",
      )

    | CountriesAllowed =>
      Table.CustomCell(
        <PaymentMethodConfig
          paymentMethodConfig
          element={paymentMethodConfig.accepted_countries->getAdvanceConfiguration}
          setRefresh
        />,
        "",
      )
    | CurrenciesAllowed =>
      Table.CustomCell(
        <PaymentMethodConfig
          paymentMethodConfig
          element={paymentMethodConfig.accepted_currencies->getAdvanceConfiguration}
          setRefresh
        />,
        "",
      )
    | CardNetwork =>
      Table.CustomCell(
        <PaymentMethodConfig
          paymentMethodConfig config={paymentMethodConfig.card_networks->Array.toString} setRefresh
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

let getFilteredConnectorList = (
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

let paymentMethodEntity = (~setRefresh: unit => promise<unit>) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects,
    ~defaultColumns,
    ~getHeading,
    ~getCell=getCell(~setRefresh),
    ~dataKey="",
  )
}
