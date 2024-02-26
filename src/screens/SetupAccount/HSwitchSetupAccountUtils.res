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
  let bodyType = connectorAccountDict->Dict.keysToArray->Array.get(0)->Option.getOr("")

  let connectorAccountDetails =
    [
      ("auth_type", bodyType->JSON.Encode.string),
      ("api_key", "test"->JSON.Encode.string),
    ]->getJsonFromArrayOfJson

  let initialValueForPayload = generateInitialValuesDict(
    ~values=[
      ("profile_id", profileId->JSON.Encode.string),
      ("connector_account_details", connectorAccountDetails),
      ("connector_label", `${connectorName}_default`->JSON.Encode.string),
    ]->getJsonFromArrayOfJson,
    ~connector=connectorName,
    ~bodyType,
    (),
  )

  let creditCardNetworkArray =
    json
    ->getDictFromJsonObject
    ->getArrayFromDict("credit", [])
    ->JSON.Encode.array
    ->getPaymentMethodMapper
  let debitCardNetworkArray =
    json
    ->getDictFromJsonObject
    ->getArrayFromDict("debit", [])
    ->JSON.Encode.array
    ->getPaymentMethodMapper

  let payLaterArray =
    json
    ->getDictFromJsonObject
    ->getArrayFromDict("pay_later", [])
    ->JSON.Encode.array
    ->getPaymentMethodMapper
  let walletArray =
    json
    ->getDictFromJsonObject
    ->getArrayFromDict("wallet", [])
    ->JSON.Encode.array
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
    metadata: Dict.make()->JSON.Encode.object,
  }

  let requestPayloadDict = requestPayload->constructConnectorRequestBody(initialValueForPayload)

  requestPayloadDict
}

type routingData = {
  connector_name: string,
  merchant_connector_id: string,
}
let constructRoutingPayload = (routingData: routingData) => {
  let innerRoutingDict =
    [
      ("connector", routingData.connector_name->JSON.Encode.string),
      ("merchant_connector_id", routingData.merchant_connector_id->JSON.Encode.string),
    ]->LogicUtils.getJsonFromArrayOfJson
  [("split", 50.0->JSON.Encode.float), ("connector", innerRoutingDict)]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let routingPayload = (profileId, routingData1: routingData, routingData2: routingData) => {
  let payload = [constructRoutingPayload(routingData1), constructRoutingPayload(routingData2)]
  RoutingUtils.getRoutingPayload(
    payload,
    "volume_split",
    "Initial volume based routing setup",
    "Volume based routing pre-configured by Hyperswitch",
    profileId,
  )->JSON.Encode.object
}
