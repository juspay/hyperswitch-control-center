type connectorDetails = {
  connector_name: string,
  traffic_percentage: float,
  no_of_payments: int,
  authorization_rate: float,
  processed_amount: float,
}
type summaryMain = {
  routing_logic: string,
  traffic_percentage: float,
  no_of_payments: int,
  authorization_rate: float,
  processed_amount: float,
  connectors: array<connectorDetails>,
}
type summaryColType =
  | RoutingLogic
  | TrafficPercentage
  | NoOfPayments
  | AuthorizationRate
  | ProcessedAmount

type connectorColType =
  | ConnectorName
  | TrafficPercentage
  | NoOfPayments
  | AuthorizationRate
  | ProcessedAmount
