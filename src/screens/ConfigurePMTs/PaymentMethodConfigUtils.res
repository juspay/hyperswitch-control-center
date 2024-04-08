let dropdownClassName = (options: array<SelectBox.dropdownOption>) =>
  options->Array.length > 5 ? "h-80" : "h-full"

let getAdvanceConfiguration = (
  advanceConfiguration: option<ConnectorTypes.advancedConfigurationList>,
) => {
  let config = switch advanceConfiguration {
  | Some(obj) => {
      let firstThree = obj.list->Array.slice(~start=0, ~end=3)->Array.toString
      let restCount = obj.list->Array.length - 3
      obj.list->Array.length > 3
        ? <div>
            {`${firstThree},`->React.string}
            <span className="text-blue-811">
              {`+${Int.toString(restCount)} more`->React.string}
            </span>
          </div>
        : <div> {firstThree->React.string} </div>
    }
  | None => "Default"->React.string
  }
  config
}

let encodeAdvanceConfig = (advanceConfig: option<ConnectorTypes.advancedConfigurationList>) => {
  switch advanceConfig {
  | Some(config) =>
    [
      ("type", JSON.Encode.string(config.type_)),
      ("list", JSON.Encode.array(config.list->Array.map(JSON.Encode.string))),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object
  | None => None->Option.map(JSON.Encode.object)->Option.getOr(JSON.Encode.null)
  }
}
let encodePaymentMethodConfig = (paymentMethodConfig: ConnectorTypes.paymentMethodConfigType) => {
  [
    ("payment_method_type", JSON.Encode.string(paymentMethodConfig.payment_method_type)),
    (
      "card_networks",
      JSON.Encode.array(paymentMethodConfig.card_networks->Array.map(JSON.Encode.string)),
    ),
    ("accepted_currencies", paymentMethodConfig.accepted_currencies->encodeAdvanceConfig),
    ("accepted_countries", paymentMethodConfig.accepted_countries->encodeAdvanceConfig),
    (
      "maximum_amount",
      paymentMethodConfig.maximum_amount
      ->Option.map(JSON.Encode.int)
      ->Option.getOr(JSON.Encode.null),
    ),
    (
      "minimum_amount",
      paymentMethodConfig.minimum_amount
      ->Option.map(JSON.Encode.int)
      ->Option.getOr(JSON.Encode.null),
    ),
    (
      "recurring_enabled",
      paymentMethodConfig.recurring_enabled
      ->Option.map(JSON.Encode.bool)
      ->Option.getOr(JSON.Encode.null),
    ),
    (
      "installment_payment_enabled",
      paymentMethodConfig.installment_payment_enabled
      ->Option.map(JSON.Encode.bool)
      ->Option.getOr(JSON.Encode.null),
    ),
    (
      "payment_experience",
      paymentMethodConfig.payment_experience
      ->Option.map(JSON.Encode.string)
      ->Option.getOr(JSON.Encode.null),
    ),
  ]->LogicUtils.getJsonFromArrayOfJson
}
let encodePaymentMethodEnabled = (paymentMethodRecord: ConnectorTypes.paymentMethodEnabledType) => {
  let paymentMethodConfig =
    paymentMethodRecord.payment_method_types
    ->Array.map(encodePaymentMethodConfig)
    ->JSON.Encode.array
  [
    ("payment_method", JSON.Encode.string(paymentMethodRecord.payment_method)),
    ("payment_method_types", paymentMethodConfig),
  ]->LogicUtils.getJsonFromArrayOfJson
}

let encodeConnectorPayload = (typedValue: ConnectorTypes.connectorPayload) => {
  let paymentMethodEnabled =
    typedValue.payment_methods_enabled->Array.map(encodePaymentMethodEnabled)->JSON.Encode.array
  [
    ("connector_type", JSON.Encode.string(typedValue.connector_type)),
    ("payment_methods_enabled", paymentMethodEnabled),
  ]->LogicUtils.getJsonFromArrayOfJson
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
  connectorPayload: ConnectorTypes.connectorPayload,
  pmIndex: int,
  pmtIndex: int,
  paymentMethod: string,
): PaymentMethodConfigTypes.paymentMethodConfiguration => {
  payment_method_index: pmIndex,
  payment_method_types_index: pmtIndex,
  merchant_connector_id: connectorPayload.merchant_connector_id,
  connector_name: connectorPayload.connector_name,
  profile_id: connectorPayload.profile_id,
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
  ~connectorPayload: ConnectorTypes.connectorPayload,
  ~mappedArr,
  ~pmIndex: int,
  ~filters=Dict.make()->pmtConfigFilter,
  (),
) => {
  let pm =
    connectorPayload.payment_methods_enabled[pmIndex]->Option.getOr(
      Dict.make()->ConnectorListMapper.getPaymentMethodsEnabled,
    )
  pm.payment_method_types->Array.forEachWithIndex((data, pmtIndex) => {
    let paymentMethod = pm.payment_method

    switch filters.paymentMethodType {
    | Some(pmtsType) =>
      if pmtsType->Array.includes(data.payment_method_type) {
        mappedArr->Array.push(
          data->mapPaymentMethodTypeValues(connectorPayload, pmIndex, pmtIndex, paymentMethod),
        )
      }
    | None =>
      mappedArr->Array.push(
        data->mapPaymentMethodTypeValues(connectorPayload, pmIndex, pmtIndex, paymentMethod),
      )
    }
  })
}

let paymentMethodFilter = (
  filters: PaymentMethodConfigTypes.paymentMethodConfigFilters,
  connectorPayload: ConnectorTypes.connectorPayload,
  mappedArr,
) => {
  connectorPayload.payment_methods_enabled->Array.forEachWithIndex((item, pmIndex) => {
    switch filters.paymentMethod {
    | Some(methods) =>
      if methods->Array.includes(item.payment_method) {
        mapPaymentMethodValues(~connectorPayload, ~mappedArr, ~pmIndex, ~filters, ())
      }
    | None => mapPaymentMethodValues(~connectorPayload, ~mappedArr, ~pmIndex, ~filters, ())
    }
  })
}

let connectorIdFilter = (
  filters: PaymentMethodConfigTypes.paymentMethodConfigFilters,
  connectorPayload: ConnectorTypes.connectorPayload,
  mappedArr,
) => {
  switch filters.connectorId {
  | Some(ids) =>
    if ids->Array.includes(connectorPayload.connector_name) {
      filters->paymentMethodFilter(connectorPayload, mappedArr)
    }
  | None => filters->paymentMethodFilter(connectorPayload, mappedArr)
  }
}

let filterItemObjMapper = (
  dict,
  mappedArr,
  filters: PaymentMethodConfigTypes.paymentMethodConfigFilters,
) => {
  open ConnectorListMapper
  let connectorPayload = dict->getProcessorPayloadType
  let {profile_id, connector_type} = connectorPayload

  if connector_type->ConnectorUtils.connectorTypeStringToTypeMapper === PaymentProcessor {
    switch filters.profileId {
    | Some(profileIds) =>
      if profileIds->Array.includes(profile_id) {
        filters->connectorIdFilter(connectorPayload, mappedArr)
      }
    | None => filters->connectorIdFilter(connectorPayload, mappedArr)
    }
  }
}

let initialFilters = (
  configuredConnectors: array<PaymentMethodConfigTypes.paymentMethodConfiguration>,
  businessProfiles,
): array<EntityType.initialFilters<'t>> => {
  open FormRenderer
  open LogicUtils

  [
    {
      field: makeFieldInfo(
        ~label="Prfofile",
        ~name="profileId",
        ~subHeading="",
        ~description="",
        ~customInput=InputFields.multiSelectInput(
          ~options={businessProfiles->MerchantAccountUtils.businessProfileNameDropDownOption},
          ~buttonText="Select Profile",
          ~showSelectionAsChips=false,
          (),
        ),
        (),
      ),
      localFilter: None,
    },
    {
      field: makeFieldInfo(
        ~label="Connector",
        ~name="connectorId",
        ~subHeading="",
        ~description="",
        ~customInput=InputFields.multiSelectInput(
          ~options=configuredConnectors
          ->Array.map(ele => ele.connector_name)
          ->getUniqueArray
          ->SelectBox.makeOptions,
          ~buttonText="Select Connector",
          ~showSelectionAsChips=false,
          (),
        ),
        (),
      ),
      localFilter: None,
    },
    {
      field: makeFieldInfo(
        ~label="Payment Method",
        ~name="paymentMethod",
        ~subHeading="",
        ~description="",
        ~customInput=InputFields.multiSelectInput(
          ~options=configuredConnectors
          ->Array.map(ele => ele.payment_method)
          ->getUniqueArray
          ->SelectBox.makeOptions,
          ~buttonText="Select Payment Method",
          ~showSelectionAsChips=false,
          (),
        ),
        (),
      ),
      localFilter: None,
    },
    {
      field: makeFieldInfo(
        ~label="Payment Method Type",
        ~name="paymentMethodType",
        ~subHeading="",
        ~description="",
        ~customInput=InputFields.multiSelectInput(
          ~options=configuredConnectors
          ->Array.map(ele => ele.payment_method_type)
          ->getUniqueArray
          ->SelectBox.makeOptions,
          ~buttonText="Select Payment Method Type",
          ~showSelectionAsChips=false,
          ~dropdownClassName={"h-72"},
          (),
        ),
        (),
      ),
      localFilter: None,
    },
  ]
}
