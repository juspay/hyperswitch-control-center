// RoutingApproach enum
type routingApproach =
  | SuccessRateExploitation
  | SuccessRateExploration
  | ContractBasedRouting
  | DebitRouting
  | RuleBasedRouting
  | VolumeBasedRouting
  | DefaultFallback

// Summary stats type
type summaryStats = {
  overallAuthRate: float,
  firstAttemptAuthRate: float,
  totalSuccessful: int,
  totalFailure: int,
}

// Distribution data type (for donut charts)
type distributionData = {
  name: string,
  y: float,
}

// Table row type
type tableRow = {
  routingLogic: routingApproach,
  trafficPercent: float,
  paymentCount: int,
  authRatePercent: float,
  processedAmount: float,
}

// Time series data type (for line charts)
type timeSeriesData = {
  timestamp: string,
  value: float,
  metric: string,
  routingApproach: routingApproach,
}
