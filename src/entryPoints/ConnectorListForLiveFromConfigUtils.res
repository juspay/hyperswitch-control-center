type connectorListForLive = {
  paymentProcessorsLiveListFromConfig: array<ConnectorTypes.connectorTypes>,
  payoutProcessorsLiveListFromConfig: array<ConnectorTypes.connectorTypes>,
  threeDsAuthenticatorProcessorsLiveListFromConfig: array<ConnectorTypes.connectorTypes>,
  vaultProcessorsLiveListFromConfig: array<ConnectorTypes.connectorTypes>,
}

let extractTypedConnectorValueFromConfig = (
  ~connectorDict,
  ~key,
  ~connectorType: ConnectorTypes.connector,
) => {
  open LogicUtils

  connectorDict
  ->getArrayFromDict(key, [])
  ->Array.map(item =>
    item
    ->getStringFromJson("")
    ->String.toLowerCase
  )
  ->removeDuplicate
  ->Array.map(item => ConnectorUtils.getConnectorNameTypeFromString(~connectorType, item))
  ->Array.filter(item => item != UnknownConnector("Not known"))
}

let connectorListForLive = (list: JSON.t) => {
  open LogicUtils
  let connectorDict = list->getDictFromJsonObject->getDictfromDict("connector_list_for_live")
  let paymentsProcessorListForLive = extractTypedConnectorValueFromConfig(
    ~connectorDict,
    ~key="paymentProcessors",
    ~connectorType=Processor,
  )

  let payoutProcessorListForLive = extractTypedConnectorValueFromConfig(
    ~connectorDict,
    ~key="payoutProcessors",
    ~connectorType=PayoutProcessor,
  )
  let threeDsAuthenticatorProcessorsForLive = extractTypedConnectorValueFromConfig(
    ~connectorDict,
    ~key="threedsAuthProcessors",
    ~connectorType=ThreeDsAuthenticator,
  )

  let vaultProcessorListForLive = extractTypedConnectorValueFromConfig(
    ~connectorDict,
    ~key="vaultProcessors",
    ~connectorType=VaultProcessor,
  )

  {
    paymentProcessorsLiveListFromConfig: paymentsProcessorListForLive,
    payoutProcessorsLiveListFromConfig: payoutProcessorListForLive,
    threeDsAuthenticatorProcessorsLiveListFromConfig: threeDsAuthenticatorProcessorsForLive,
    vaultProcessorsLiveListFromConfig: vaultProcessorListForLive,
  }
}
