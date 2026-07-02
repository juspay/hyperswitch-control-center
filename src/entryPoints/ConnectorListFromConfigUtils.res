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

// Reads one connector category from the config dict, falling back to the
// provided default list when the config has no (valid) entries for it.
let resolveConnectorListFromConfig = (~connectorDict, ~key, ~connectorType, ~fallback) => {
  let fromConfig = extractTypedConnectorValueFromConfig(~connectorDict, ~key, ~connectorType)
  fromConfig->Array.length > 0 ? fromConfig : fallback
}

let getConnectorListForLive = (list: JSON.t): ConnectorListFromConfigTypes.connectorListForLive => {
  open LogicUtils
  open ConnectorUtils
  let connectorDict = list->getDictFromJsonObject->getDictfromDict("connector_list_for_live")
  {
    paymentProcessorsLiveList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="paymentProcessors",
      ~connectorType=Processor,
      ~fallback=connectorListForLive,
    ),
    payoutProcessorsLiveList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="payoutProcessors",
      ~connectorType=PayoutProcessor,
      ~fallback=payoutConnectorListForLive,
    ),
    threeDsAuthenticatorProcessorsLiveList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="threedsAuthProcessors",
      ~connectorType=ThreeDsAuthenticator,
      ~fallback=threedsAuthenticatorListForLive,
    ),
    vaultProcessorsLiveList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="vaultProcessors",
      ~connectorType=VaultProcessor,
      ~fallback=vaultProcessorList,
    ),
  }
}

let getConnectorListForSandbox = (
  list: JSON.t,
): ConnectorListFromConfigTypes.connectorListForSandbox => {
  open LogicUtils
  open ConnectorUtils
  let connectorDict = list->getDictFromJsonObject->getDictfromDict("connector_list_for_sandbox")
  {
    paymentProcessorsSandboxList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="paymentProcessors",
      ~connectorType=Processor,
      ~fallback=connectorList,
    ),
    payoutProcessorsSandboxList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="payoutProcessors",
      ~connectorType=PayoutProcessor,
      ~fallback=payoutConnectorList,
    ),
    threeDsAuthenticatorProcessorsSandboxList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="threedsAuthProcessors",
      ~connectorType=ThreeDsAuthenticator,
      ~fallback=threedsAuthenticatorList,
    ),
    vaultProcessorsSandboxList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="vaultProcessors",
      ~connectorType=VaultProcessor,
      ~fallback=vaultProcessorList,
    ),
    pmAuthProcessorsSandboxList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="pmAuthProcessors",
      ~connectorType=PMAuthenticationProcessor,
      ~fallback=pmAuthenticationConnectorList,
    ),
    billingProcessorsSandboxList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="billingProcessors",
      ~connectorType=BillingProcessor,
      ~fallback=billingProcessorList,
    ),
    surchargeProcessorsSandboxList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="surchargeProcessors",
      ~connectorType=SurchargeProcessor,
      ~fallback=surchargeProcessorList,
    ),
    taxProcessorsSandboxList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="taxProcessors",
      ~connectorType=TaxProcessor,
      ~fallback=taxProcessorList,
    ),
  }
}
