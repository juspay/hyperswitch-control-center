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
  ->Array.filterMap(item => {
    let itemToType = ConnectorUtils.getConnectorNameTypeFromString(~connectorType, item)
    itemToType != UnknownConnector("Not known") ? Some(itemToType) : None
  })
}

let getConnectorListForLive = (
  list: JSON.t,
): ConnectorListForLiveFromConfigTypes.connectorListForLive => {
  open LogicUtils
  open ConnectorUtils
  let connectorDict = list->getDictFromJsonObject->getDictfromDict("connector_list_for_live")
  let paymentsProcessorListForLiveFromConfig = extractTypedConnectorValueFromConfig(
    ~connectorDict,
    ~key="paymentProcessors",
    ~connectorType=Processor,
  )

  let payoutProcessorListForLiveFromConfig = extractTypedConnectorValueFromConfig(
    ~connectorDict,
    ~key="payoutProcessors",
    ~connectorType=PayoutProcessor,
  )
  let threeDsAuthenticatorProcessorsForLiveFromConfig = extractTypedConnectorValueFromConfig(
    ~connectorDict,
    ~key="threedsAuthProcessors",
    ~connectorType=ThreeDsAuthenticator,
  )

  let vaultProcessorListForLiveFromConfig = extractTypedConnectorValueFromConfig(
    ~connectorDict,
    ~key="vaultProcessors",
    ~connectorType=VaultProcessor,
  )

  {
    paymentProcessorsLiveList: paymentsProcessorListForLiveFromConfig->Array.length > 0
      ? paymentsProcessorListForLiveFromConfig
      : connectorListForLive,
    payoutProcessorsLiveList: payoutProcessorListForLiveFromConfig->Array.length > 0
      ? payoutProcessorListForLiveFromConfig
      : payoutConnectorListForLive,
    threeDsAuthenticatorProcessorsLiveList: threeDsAuthenticatorProcessorsForLiveFromConfig->Array.length > 0
      ? threeDsAuthenticatorProcessorsForLiveFromConfig
      : threedsAuthenticatorListForLive,
    vaultProcessorsLiveList: vaultProcessorListForLiveFromConfig->Array.length > 0
      ? vaultProcessorListForLiveFromConfig
      : vaultProcessorList,
  }
}
