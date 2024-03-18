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

let pmtConfigFilter = (dict): PaymentMethodConfigTypes.paymentMethodConfigFilters => {
  open LogicUtils
  {
    profileId: dict->getOptionStrArrayFromDict("profileId"),
    connectorId: dict->getOptionStrArrayFromDict("connectorId"),
    paymentMethod: dict->getOptionStrArrayFromDict("paymentMethod"),
    paymentMethodType: dict->getOptionStrArrayFromDict("paymentMethodType"),
  }
}

let mapPaymentMethodTypeValues = (
  paymentMethodType: ConnectorTypes.paymentMethodConfigType,
  dict,
  pmIndex: int,
  pmtIndex: int,
  paymentMethod: string,
): PaymentMethodConfigTypes.paymentMethodConfiguration => {
  payment_method_index: pmIndex,
  payment_method_types_index: pmtIndex,
  merchant_connector_id: dict->LogicUtils.getString("merchant_connector_id", ""),
  connector_name: dict->LogicUtils.getString("connector_name", ""),
  profile_id: dict->LogicUtils.getString("profile_id", ""),
  payment_method: paymentMethod,
  payment_method_type: paymentMethodType.payment_method_type,
  card_networks: paymentMethodType.card_networks,
  accepted_currencies: paymentMethodType.accepted_currencies,
  accepted_countries: paymentMethodType.accepted_countries,
  minimum_amount: paymentMethodType.minimum_amount,
  maximum_amount: paymentMethodType.maximum_amount,
  recurring_enabled: paymentMethodType.recurring_enabled,
  installment_payment_enabled: paymentMethodType.installment_payment_enabled,
  payment_experience: paymentMethodType.payment_experience,
}

let mapPaymentMethodValues = (
  ~paymentMethod: ConnectorTypes.paymentMethodEnabledType,
  ~dict,
  ~mappedArr,
  ~pmIndex: int,
  ~filters=Dict.make()->pmtConfigFilter,
  (),
) => {
  paymentMethod.payment_method_types->Array.forEachWithIndex((data, pmtIndex) => {
    let paymentMethod = paymentMethod.payment_method

    switch filters.paymentMethodType {
    | Some(pmtsType) =>
      if pmtsType->Array.includes(data.payment_method_type) {
        mappedArr->Array.push(
          data->mapPaymentMethodTypeValues(dict, pmIndex, pmtIndex, paymentMethod),
        )
      }
    | None =>
      mappedArr->Array.push(
        data->mapPaymentMethodTypeValues(dict, pmIndex, pmtIndex, paymentMethod),
      )
    }
  })
}

let filterItemObjMapper = (
  dict,
  mappedArr,
  filters: PaymentMethodConfigTypes.paymentMethodConfigFilters,
) => {
  open ConnectorListMapper
  open LogicUtils
  let paymentMethod =
    dict
    ->Dict.get("payment_methods_enabled")
    ->Option.getOr(Dict.make()->JSON.Encode.object)
    ->getArrayDataFromJson(getPaymentMethodsEnabled)
  let merchantConnectorId = dict->getString("merchant_connector_id", "")
  let profileId = dict->getString("profile_id", "")

  if dict->getString("connector_type", "") === "payment_processor" {
    switch filters.profileId {
    | Some(profileIds) =>
      if profileIds->Array.includes(profileId) {
        switch filters.connectorId {
        | Some(ids) =>
          if ids->Array.includes(merchantConnectorId) {
            paymentMethod->Array.forEachWithIndex((item, pmIndex) => {
              switch filters.paymentMethod {
              | Some(methods) =>
                if methods->Array.includes(item.payment_method) {
                  mapPaymentMethodValues(
                    ~paymentMethod=item,
                    ~dict,
                    ~mappedArr,
                    ~pmIndex,
                    ~filters,
                    (),
                  )
                }
              | None =>
                mapPaymentMethodValues(
                  ~paymentMethod=item,
                  ~dict,
                  ~mappedArr,
                  ~pmIndex,
                  ~filters,
                  (),
                )
              }
            })
          }
        | None =>
          paymentMethod->Array.forEachWithIndex((item, pmIndex) => {
            switch filters.paymentMethod {
            | Some(methods) =>
              if methods->Array.includes(item.payment_method) {
                mapPaymentMethodValues(
                  ~paymentMethod=item,
                  ~dict,
                  ~mappedArr,
                  ~pmIndex,
                  ~filters,
                  (),
                )
              }
            | None =>
              mapPaymentMethodValues(~paymentMethod=item, ~dict, ~mappedArr, ~pmIndex, ~filters, ())
            }
          })
        }
      }
    | None =>
      switch filters.connectorId {
      | Some(ids) =>
        if ids->Array.includes(merchantConnectorId) {
          paymentMethod->Array.forEachWithIndex((item, pmIndex) => {
            switch filters.paymentMethod {
            | Some(methods) =>
              if methods->Array.includes(item.payment_method) {
                mapPaymentMethodValues(
                  ~paymentMethod=item,
                  ~dict,
                  ~mappedArr,
                  ~pmIndex,
                  ~filters,
                  (),
                )
              }
            | None =>
              mapPaymentMethodValues(~paymentMethod=item, ~dict, ~mappedArr, ~pmIndex, ~filters, ())
            }
          })
        }
      | None =>
        paymentMethod->Array.forEachWithIndex((item, pmIndex) => {
          switch filters.paymentMethod {
          | Some(methods) =>
            if methods->Array.includes(item.payment_method) {
              mapPaymentMethodValues(~paymentMethod=item, ~dict, ~mappedArr, ~pmIndex, ~filters, ())
            }
          | None =>
            mapPaymentMethodValues(~paymentMethod=item, ~dict, ~mappedArr, ~pmIndex, ~filters, ())
          }
        })
      }
    }
  }
}
