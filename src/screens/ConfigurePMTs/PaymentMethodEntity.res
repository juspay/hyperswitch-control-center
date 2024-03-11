type colType =
  | Profile
  | Processor
  | PaymentMethodType
  | PaymentMethod
  | CountriesAllowed
  | CurrenciesAllowed

let defaultColumns = [
  Profile,
  Processor,
  PaymentMethodType,
  PaymentMethod,
  CountriesAllowed,
  CurrenciesAllowed,
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
  }
}
type paymentMethodConfiguration = {
  connector_name: string,
  profile_id: string,
  payment_method: string,
  payment_method_type: string,
  card_networks: array<string>,
  accepted_currencies: option<ConnectorTypes.advancedConfigurationList>,
  accepted_countries: option<ConnectorTypes.advancedConfigurationList>,
  minimum_amount: option<int>,
  maximum_amount: option<int>,
  recurring_enabled: option<bool>,
  installment_payment_enabled: option<bool>,
  payment_experience: option<string>,
}

let getAdvanceConfiguration = (
  advanceConfiguration: option<ConnectorTypes.advancedConfigurationList>,
) => {
  let config = switch advanceConfiguration {
  | Some(obj) => obj.list->Array.toString
  | None => ""
  }
  config
}
let getCell = (paymentMethodConfig: paymentMethodConfiguration, colType): Table.cell => {
  switch colType {
  | Profile =>
    Table.CustomCell(
      <HelperComponents.BusinessProfileComponent profile_id={paymentMethodConfig.profile_id} />,
      "",
    )
  | Processor => Text(paymentMethodConfig.connector_name)
  | PaymentMethod => Text(paymentMethodConfig.payment_method)
  | PaymentMethodType => Text(paymentMethodConfig.payment_method_type)
  | CountriesAllowed =>
    Table.CustomCell(
      <div> {paymentMethodConfig.accepted_countries->getAdvanceConfiguration->React.string} </div>,
      "",
    )
  | CurrenciesAllowed =>
    Table.CustomCell(
      <div> {paymentMethodConfig.accepted_currencies->getAdvanceConfiguration->React.string} </div>,
      "",
    )
  }
}

let map = (dict, arr) => {
  open ConnectorListMapper
  open LogicUtils
  let paymentMethod =
    dict
    ->Dict.get("payment_methods_enabled")
    ->Option.getOr(Dict.make()->JSON.Encode.object)
    ->getArrayDataFromJson(getPaymentMethodsEnabled)
  paymentMethod->Array.forEach(item => {
    item.payment_method_types->Array.forEach(data => {
      let obj: paymentMethodConfiguration = {
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
      arr->Array.push(obj)
    })
  })
}
let getPreviouslyConnectedList: JSON.t => array<paymentMethodConfiguration> = json => {
  let arr = []

  let _ =
    json
    ->JSON.Decode.array
    ->Option.getOr([])
    ->Belt.Array.keepMap(JSON.Decode.object)
    ->Array.map(dict => dict->map(arr))

  arr
}
let paymentMethodEntity = (path: string) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getPreviouslyConnectedList,
    ~defaultColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="",
    // ~getShowLink={
    //   connec =>
    //     PermissionUtils.linkForGetShowLinkViaAccess(
    //       ~url=`/${path}/${connec.merchant_connector_id}?name=${connec.connector_name}`,
    //       ~permission,
    //     )
    // },
    (),
  )
}
