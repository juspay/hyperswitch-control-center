let getAdvanceConfiguration = (
  advanceConfiguration: option<ConnectorTypes.advancedConfigurationList>,
) => {
  let config = switch advanceConfiguration {
  | Some(obj) => obj.list->Array.toString
  | None => ""
  }
  config
}

let encodeAdvanceConfig = (advanceConfig: option<ConnectorTypes.advancedConfigurationList>) => {
  switch advanceConfig {
  | Some(config) =>
    [
      ("type", JSON.Encode.string(config.type_)),
      ("list", JSON.Encode.array(config.list->Array.map(Js.Json.string))),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object
  | None => None->Option.map(JSON.Encode.object)->Option.getOr(Js.Json.null)
  }
}
let encodePaymentMethodConfig = (paymentMethodConfig: ConnectorTypes.paymentMethodConfigType) => {
  [
    ("payment_method_type", JSON.Encode.string(paymentMethodConfig.payment_method_type)),
    (
      "card_networks",
      JSON.Encode.array(paymentMethodConfig.card_networks->Array.map(Js.Json.string)),
    ),
    ("accepted_currencies", paymentMethodConfig.accepted_currencies->encodeAdvanceConfig),
    ("accepted_countries", paymentMethodConfig.accepted_countries->encodeAdvanceConfig),
    (
      "maximum_amount",
      paymentMethodConfig.maximum_amount->Option.map(JSON.Encode.int)->Option.getOr(Js.Json.null),
    ),
    (
      "minimum_amount",
      paymentMethodConfig.minimum_amount->Option.map(JSON.Encode.int)->Option.getOr(Js.Json.null),
    ),
    (
      "recurring_enabled",
      paymentMethodConfig.recurring_enabled
      ->Option.map(JSON.Encode.bool)
      ->Option.getOr(Js.Json.null),
    ),
    (
      "installment_payment_enabled",
      paymentMethodConfig.installment_payment_enabled
      ->Option.map(JSON.Encode.bool)
      ->Option.getOr(Js.Json.null),
    ),
    (
      "payment_experience",
      paymentMethodConfig.payment_experience
      ->Option.map(JSON.Encode.string)
      ->Option.getOr(Js.Json.null),
    ),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}
let encodePaymentMethodEnabled = (
  paymentMethodRecord: ConnectorTypes.paymentMethodEnabledType,
): Js.Json.t => {
  let paymentMethodConfig =
    paymentMethodRecord.payment_method_types
    ->Array.map(encodePaymentMethodConfig)
    ->JSON.Encode.array
  [
    ("payment_method", JSON.Encode.string(paymentMethodRecord.payment_method)),
    ("payment_method_types", paymentMethodConfig),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let encodeConnectorPayload = (myTypedValue: ConnectorTypes.connectorPayload): Js.Json.t => {
  let paymentMethodEnabled =
    myTypedValue.payment_methods_enabled->Array.map(encodePaymentMethodEnabled)->JSON.Encode.array
  let dict =
    [
      ("connector_type", JSON.Encode.string(myTypedValue.connector_type)),
      ("payment_methods_enabled", paymentMethodEnabled),
    ]->Dict.fromArray
  dict->JSON.Encode.object
}
