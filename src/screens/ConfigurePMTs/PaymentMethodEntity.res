open PaymentMethodConfigTypes
type colType =
  | Profile
  | Processor
  | PaymentMethodType
  | PaymentMethod
  | CardNetwork
  | CountriesAllowed
  | CurrenciesAllowed

let defaultColumns = [
  Profile,
  Processor,
  PaymentMethodType,
  PaymentMethod,
  CountriesAllowed,
  CurrenciesAllowed,
  CardNetwork,
]

let getHeading = colType => {
  switch colType {
  | Profile => Table.makeHeaderInfo(~key="profile_id", ~title="Profile", ~showSort=false, ())
  | Processor =>
    Table.makeHeaderInfo(~key="connector_name", ~title="Processor", ~showSort=false, ())
  | PaymentMethod =>
    Table.makeHeaderInfo(~key="payment_method", ~title="Payment Method", ~showSort=false, ())
  | PaymentMethodType =>
    Table.makeHeaderInfo(
      ~key="payment_method_type",
      ~title="Payment Method Type",
      ~showSort=false,
      (),
    )

  | CountriesAllowed =>
    Table.makeHeaderInfo(~key="accepted_countries", ~title="Countries Allowed", ~showSort=false, ())
  | CurrenciesAllowed =>
    Table.makeHeaderInfo(
      ~key="accepted_currencies",
      ~title="Currencies Allowed",
      ~showSort=false,
      (),
    )
  | CardNetwork =>
    Table.makeHeaderInfo(~key="card_network", ~title="Card Network", ~showSort=false, ())
  }
}
let getCell = (~setReferesh) => {
  let getPaymentMethodConfigCell = (
    paymentMethodConfig: paymentMethodConfiguration,
    colType,
  ): Table.cell => {
    open PaymentMethodConfigUtils
    switch colType {
    | Profile =>
      Table.CustomCell(
        <PaymentMethodConfig
          paymentMethodConfig
          element={<HelperComponents.BusinessProfileComponent
            profile_id={paymentMethodConfig.profile_id}
          />}
          setReferesh
        />,
        "",
      )
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

let itemObjMapper = (dict, mappedArr) => {
  open ConnectorListMapper
  open LogicUtils
  let connectorPayload = dict->getProcessorPayloadType
  let paymentMethod =
    dict
    ->Dict.get("payment_methods_enabled")
    ->Option.getOr(Dict.make()->JSON.Encode.object)
    ->getArrayDataFromJson(getPaymentMethodsEnabled)
  if dict->getString("connector_type", "") === "payment_processor" {
    paymentMethod->Array.forEachWithIndex((_, pmIndex) => {
      PaymentMethodConfigUtils.mapPaymentMethodValues(~connectorPayload, ~mappedArr, ~pmIndex, ())
    })
  }
}

let getFilterdConnectorList = (
  json: JSON.t,
  filters: PaymentMethodConfigTypes.paymentMethodConfigFilters,
): array<paymentMethodConfiguration> => {
  let mappedArr = []
  let _ =
    json
    ->JSON.Decode.array
    ->Option.getOr([])
    ->Belt.Array.keepMap(JSON.Decode.object)
    ->Array.map(dict => dict->PaymentMethodConfigUtils.filterItemObjMapper(mappedArr, filters))
  mappedArr
}

let getConnectedList: JSON.t => array<paymentMethodConfiguration> = json => {
  let mappedArr = []
  let _ =
    json
    ->JSON.Decode.array
    ->Option.getOr([])
    ->Belt.Array.keepMap(JSON.Decode.object)
    ->Array.map(dict => dict->itemObjMapper(mappedArr))
  mappedArr
}
let paymentMethodEntity = (~setReferesh: unit => promise<unit>) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getConnectedList,
    ~defaultColumns,
    ~getHeading,
    ~getCell=getCell(~setReferesh),
    ~dataKey="",
    (),
  )
}
