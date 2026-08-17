type connectorDisplayList = {
  paymentProcessorsList: array<ConnectorTypes.connectorTypes>,
  payoutProcessorsList: array<ConnectorTypes.connectorTypes>,
  threeDsAuthenticatorProcessorsList: array<ConnectorTypes.connectorTypes>,
  vaultProcessorsList: array<ConnectorTypes.connectorTypes>,
  pmAuthProcessorsList: array<ConnectorTypes.connectorTypes>,
  billingProcessorsList: array<ConnectorTypes.connectorTypes>,
  surchargeProcessorsList: array<ConnectorTypes.connectorTypes>,
  taxProcessorsList: array<ConnectorTypes.connectorTypes>,
}
