type connectorListForLive = {
  paymentProcessorsLiveList: array<ConnectorTypes.connectorTypes>,
  payoutProcessorsLiveList: array<ConnectorTypes.connectorTypes>,
  threeDsAuthenticatorProcessorsLiveList: array<ConnectorTypes.connectorTypes>,
  vaultProcessorsLiveList: array<ConnectorTypes.connectorTypes>,
}

type connectorListForSandbox = {
  paymentProcessorsSandboxList: array<ConnectorTypes.connectorTypes>,
  payoutProcessorsSandboxList: array<ConnectorTypes.connectorTypes>,
  threeDsAuthenticatorProcessorsSandboxList: array<ConnectorTypes.connectorTypes>,
  vaultProcessorsSandboxList: array<ConnectorTypes.connectorTypes>,
  pmAuthProcessorsSandboxList: array<ConnectorTypes.connectorTypes>,
  billingProcessorsSandboxList: array<ConnectorTypes.connectorTypes>,
  surchargeProcessorsSandboxList: array<ConnectorTypes.connectorTypes>,
  taxProcessorsSandboxList: array<ConnectorTypes.connectorTypes>,
}
