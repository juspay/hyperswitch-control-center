open ReconEngineTypes

@unboxed
type amountType =
  | MatchedAmount
  | PendingAmount
  | MismatchedAmount

type accountTransactionCounts = {
  matched_confirmation_count: int,
  pending_confirmation_count: int,
  mismatched_confirmation_count: int,
  matched_transaction_count: int,
  pending_transaction_count: int,
  mismatched_transaction_count: int,
}

type accountTransactionData = {
  matched_confirmation_count: int,
  pending_confirmation_count: int,
  mismatched_confirmation_count: int,
  matched_transaction_count: int,
  pending_transaction_count: int,
  mismatched_transaction_count: int,
  matched_confirmation_amount: balanceType,
  pending_confirmation_amount: balanceType,
  mismatched_confirmation_amount: balanceType,
  matched_transaction_amount: balanceType,
  pending_transaction_amount: balanceType,
  mismatched_transaction_amount: balanceType,
}

@unboxed
type subHeaderType =
  | DebitAmount
  | CreditAmount

type reconData = {
  inAmount: string,
  outAmount: string,
  inTxns: string,
  outTxns: string,
}

type reconStatusData = {
  statusType: amountType,
  reconStatusData: reconData,
}

type nodeData = {
  label: string,
  accountType: accountTypeVariant,
  statusData: array<reconStatusData>,
  selected: bool,
  onNodeClick: option<unit => unit>,
}

type nodePositionType = {
  x: float,
  y: float,
}

type nodeType = {
  id: string,
  @as("type") nodeType: string,
  sourcePosition?: string,
  targetPosition?: string,
  position: nodePositionType,
  data: nodeData,
}

type edgeStyleType = {
  stroke: string,
  strokeWidth: float,
}

type edgeMarkerType = {@as("type") edgeMarkerType: string}

type edgeData = {
  ruleType: string,
  percentageLabel: string,
}

type edgeType = {
  id: string,
  source: string,
  target: string,
  @as("type") edgeType: string,
  animated?: bool,
  data: edgeData,
  markerEnd?: edgeMarkerType,
  style?: edgeStyleType,
}

type viewType =
  | Graph
  | Table

type seriesType =
  ReconciledSeriesType | MismatchedSeriesType | ExpectedSeriesType | UnknownSeriesType

type valueType =
  | Percentage(float)
  | Float(float)
  | Number(int)
  | Amount(float, string)
  | OutOf(int, int)
  | SlashOutOf(int, int)

type statCardType =
  | Info
  | Attention

@unboxed
type statCardsTitle =
  | @as("Match Rate") MatchRate
  | @as("Open Exceptions") OpenExceptions
  | @as("Value at Risk") ValueAtRisk
  | @as("Expected Value") ExpectedValue

type statCardData = {
  statCardTitle: statCardsTitle,
  statCardValue: valueType,
  statCardIcon: Button.iconType,
  statCardDescription: string,
  statCardType: statCardType,
  onStatCardClick: unit => unit,
}

@unboxed
type connectedStatCardsTitle =
  | @as("Auto Match Rate") AutoMatchRate
  | @as("Missing") MissingTransactions
  | @as("Failed Transformations") FailedTransformations
  | @as("Failed Ingestions") FailedIngestions
  | @as("Manual Corrections") ManualCorrections

type connectedStatCardData = {
  connectedStatCardTitle: connectedStatCardsTitle,
  connectedStatCardValue: valueType,
}

type overviewChartGranularity =
  | Hourly
  | Daily
  | Weekly
  | Monthly

type overviewChartPoint = {
  label: string,
  tooltipLabel: string,
  totalCount: float,
  matchedCount: float,
  exceptionCount: float,
  expectedCount: float,
  missingCount: float,
  matchRate: float,
}

type exceptionAgingBucket = {
  label: string,
  color: string,
  startTime: string,
  endTime: string,
}

type exceptionAgingData = {
  label: string,
  color: string,
  total: int,
}

type exceptionTriageItem = {
  label: string,
  total: int,
}

type ruleActivityItem = {
  overview_rule: ReconEngineTypes.overviewRulesResponse,
  volume: int,
  exceptions: int,
  matchRate: float,
}
