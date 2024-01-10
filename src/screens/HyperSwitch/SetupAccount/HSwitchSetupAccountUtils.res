type stepCounterTypes = [
  | #INITIALIZE
  | #CONNECTORS_CONFIGURED
  | #ROUTING_ENABLED
  | #GENERATE_SAMPLE_DATA
  | #COMPLETED
]

let delayTime = 2000

let listOfStepCounter: array<stepCounterTypes> = [
  #INITIALIZE,
  #CONNECTORS_CONFIGURED,
  #ROUTING_ENABLED,
  #GENERATE_SAMPLE_DATA,
  #COMPLETED,
]

let constructBody = (~connectorName, ~json, ~profileId) => {
  open LogicUtils
  open ConnectorUtils
  let connectorAccountDict = json->getDictFromJsonObject->getDictfromDict("connector_auth")
  let bodyType =
    connectorAccountDict->Dict.keysToArray->Belt.Array.get(0)->Belt.Option.getWithDefault("")

  let connectorAccountDetails =
    [("auth_type", bodyType->Js.Json.string), ("api_key", "test"->Js.Json.string)]
    ->Dict.fromArray
    ->Js.Json.object_

  let initialValueForPayload = ConnectorUtils.generateInitialValuesDict(
    ~values=[
      ("profile_id", profileId->Js.Json.string),
      ("connector_account_details", connectorAccountDetails),
      ("connector_label", `${connectorName}_default`->Js.Json.string),
    ]
    ->Dict.fromArray
    ->Js.Json.object_,
    ~connector=connectorName,
    ~bodyType,
    (),
  )

  let creditCardNetworkArray =
    json
    ->getDictFromJsonObject
    ->getArrayFromDict("credit", [])
    ->Js.Json.array
    ->getPaymentMethodMapper
  let debitCardNetworkArray =
    json
    ->getDictFromJsonObject
    ->getArrayFromDict("debit", [])
    ->Js.Json.array
    ->getPaymentMethodMapper

  let payLaterArray =
    json
    ->getDictFromJsonObject
    ->getArrayFromDict("pay_later", [])
    ->Js.Json.array
    ->getPaymentMethodMapper
  let walletArray =
    json
    ->getDictFromJsonObject
    ->getArrayFromDict("wallet", [])
    ->Js.Json.array
    ->getPaymentMethodMapper

  let paymentMethodsEnabledArray: array<ConnectorTypes.paymentMethodEnabled> = [
    {
      payment_method: "card",
      payment_method_type: "credit",
      provider: [],
      card_provider: creditCardNetworkArray,
    },
    {
      payment_method: "card",
      payment_method_type: "debit",
      provider: [],
      card_provider: debitCardNetworkArray,
    },
    {
      payment_method: "pay_later",
      payment_method_type: "pay_later",
      provider: payLaterArray,
      card_provider: [],
    },
    {
      payment_method: "wallet",
      payment_method_type: "wallet",
      provider: walletArray,
      card_provider: [],
    },
  ]

  let requestPayload: ConnectorTypes.wasmRequest = {
    payment_methods_enabled: paymentMethodsEnabledArray,
    connector: connectorName,
    metadata: Dict.make()->Js.Json.object_,
  }

  let requestPayloadDict =
    requestPayload->ConnectorUtils.constructConnectorRequestBody(initialValueForPayload)

  requestPayloadDict
}

type routingData = {
  connector_name: string,
  merchant_connector_id: string,
}
let constructRoutingPayload = (routingData: routingData) => {
  let innerRoutingDict =
    [
      ("connector", routingData.connector_name->Js.Json.string),
      ("merchant_connector_id", routingData.merchant_connector_id->Js.Json.string),
    ]
    ->Dict.fromArray
    ->Js.Json.object_
  [("split", 50.0->Js.Json.number), ("connector", innerRoutingDict)]
  ->Dict.fromArray
  ->Js.Json.object_
}

let routingPayload = (profileId, routingData1: routingData, routingData2: routingData) => {
  let payload = [constructRoutingPayload(routingData1), constructRoutingPayload(routingData2)]
  RoutingUtils.getRoutingPayload(
    payload,
    "volume_split",
    "Initial volume based routing setup",
    "Volume based routing pre-configured by Hyperswitch",
    profileId,
  )->Js.Json.object_
}
