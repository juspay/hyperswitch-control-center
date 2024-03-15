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
        <HelperComponents.BusinessProfileComponent profile_id={paymentMethodConfig.profile_id} />,
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
          config={paymentMethodConfig.accepted_countries->getAdvanceConfiguration}
          setReferesh
        />,
        "",
      )
    | CurrenciesAllowed =>
      Table.CustomCell(
        <PaymentMethodConfig
          paymentMethodConfig
          config={paymentMethodConfig.accepted_currencies->getAdvanceConfiguration}
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

  let paymentMethod =
    dict
    ->Dict.get("payment_methods_enabled")
    ->Option.getOr(Dict.make()->JSON.Encode.object)
    ->getArrayDataFromJson(getPaymentMethodsEnabled)
  let connectorType = dict->getString("connector_type", "")
  if connectorType === "payment_processor" {
    paymentMethod->Array.forEachWithIndex((item, pmIndex) => {
      item.payment_method_types->Array.forEachWithIndex((data, pmtIndex) => {
        let paymentMethodrecord: paymentMethodConfiguration = {
          payment_method_index: pmIndex,
          payment_method_types_index: pmtIndex,
          merchant_connector_id: dict->getString("merchant_connector_id", ""),
          connector_name: dict->getString("connector_name", ""),
          profile_id: dict->getString("profile_id", ""),
          payment_method: item.payment_method,
          payment_method_type: data.payment_method_type,
          card_networks: data.card_networks,
          accepted_currencies: data.accepted_currencies,
          accepted_countries: data.accepted_countries,
          minimum_amount: data.minimum_amount,
          maximum_amount: data.maximum_amount,
          recurring_enabled: data.recurring_enabled,
          installment_payment_enabled: data.installment_payment_enabled,
          payment_experience: data.payment_experience,
        }
        mappedArr->Array.push(paymentMethodrecord)
      })
    })
  }
}
let getPreviouslyConnectedList: JSON.t => array<paymentMethodConfiguration> = json => {
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
    ~getObjects=getPreviouslyConnectedList,
    ~defaultColumns,
    ~getHeading,
    ~getCell=getCell(~setReferesh),
    ~dataKey="",
    (),
  )
}
