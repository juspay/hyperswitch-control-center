open LogicUtils
open ConnectorListFromConfigTypes

let extractTypedConnectorValueFromConfig = (
  ~connectorDict,
  ~key,
  ~connectorType: ConnectorTypes.connector,
) => {
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
  fromConfig->isNonEmptyArray ? fromConfig : fallback
}

// Single source of truth for the connectors shown across the app. The config
// table is read as-is; `isLiveMode` only decides which hardcoded list stands in
// when a category is absent or has no valid entries in the config.
let getConnectorDisplayList = (~isLiveMode, list: JSON.t): connectorDisplayList => {
  open ConnectorUtils
  let connectorDict = list->getDictFromJsonObject->getDictfromDict("connector_list_for_live")
  {
    paymentProcessorsList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="paymentProcessors",
      ~connectorType=Processor,
      ~fallback=isLiveMode ? connectorListForLive : connectorList,
    ),
    payoutProcessorsList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="payoutProcessors",
      ~connectorType=PayoutProcessor,
      ~fallback=isLiveMode ? payoutConnectorListForLive : payoutConnectorList,
    ),
    threeDsAuthenticatorProcessorsList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="threedsAuthProcessors",
      ~connectorType=ThreeDsAuthenticator,
      ~fallback=isLiveMode ? threedsAuthenticatorListForLive : threedsAuthenticatorList,
    ),
    vaultProcessorsList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="vaultProcessors",
      ~connectorType=VaultProcessor,
      ~fallback=vaultProcessorList,
    ),
    pmAuthProcessorsList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="pmAuthProcessors",
      ~connectorType=PMAuthenticationProcessor,
      ~fallback=pmAuthenticationConnectorList,
    ),
    billingProcessorsList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="billingProcessors",
      ~connectorType=BillingProcessor,
      ~fallback=billingProcessorList,
    ),
    surchargeProcessorsList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="surchargeProcessors",
      ~connectorType=SurchargeProcessor,
      ~fallback=surchargeProcessorList,
    ),
    taxProcessorsList: resolveConnectorListFromConfig(
      ~connectorDict,
      ~key="taxProcessors",
      ~connectorType=TaxProcessor,
      ~fallback=taxProcessorList,
    ),
  }
}
