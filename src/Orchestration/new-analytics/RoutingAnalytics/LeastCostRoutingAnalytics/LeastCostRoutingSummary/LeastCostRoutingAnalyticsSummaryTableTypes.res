type summaryMain = {
  signature_network: string,
  card_network: string,
  traffic_percentage: float,
  debit_routed_transaction_count: int,
  regulated_transaction_percentage: float,
  unregulated_transaction_percentage: float,
  debit_routing_savings: float,
}

type summaryColType =
  | SignatureBrand
  | CardNetwork
  | TrafficPercentage
  | DebitRoutedTransactionCount
  | RegulatedTransactionPercentage
  | UnregulatedTransactionPercentage
  | DebitRoutingSavings
