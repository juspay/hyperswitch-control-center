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
  inAmount: balanceType,
  outAmount: balanceType,
  inTxns: int,
  outTxns: int,
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

type reconciliationSeriesType =
  | MatchedSeries
  | ExceptionSeries
  | ExpectedSeries
  | MissingSeries
  | UnknownReconciliationSeriesType

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
  | @as("Matched Amount") MatchedAmountValue

type statCardData = {
  statCardTitle: statCardsTitle,
  statCardValue: valueType,
  statCardIcon: Button.iconType,
  statCardDescription: string,
  statCardType: statCardType,
  statCardPath: option<string>,
}

@unboxed
type connectedStatCardsTitle =
  | @as("Auto Match Rate") AutoMatchRate
  | @as("Missing") MissingTransactions
  | @as("Failed Transformations") FailedTransformations
  | @as("Failed Ingestions") FailedIngestions
  | @as("Manual Corrections") ManualCorrections
  | @as("Match Rate") MatchRate
  | @as("Open Exceptions") OpenExceptions
  | @as("Value at Risk") ValueAtRisk
  | @as("Expected Value") ExpectedValue
  | @as("Matched Amount") MatchedAmountValue

type connectedStatCardData = {
  connectedStatCardTitle: connectedStatCardsTitle,
  connectedStatCardValue: valueType,
  connectedStatCardType: statCardType,
  connectedStatCardPath: option<string>,
}

type overviewChartGranularity =
  | @as("hour") Hour
  | @as("day") Day
  | @as("week") Week
  | @as("month") Month

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

type exceptionAgingData = {
  label: string,
  color: string,
  total: int,
}

type exceptionTriageItem = {
  label: string,
  total: int,
}

type triageTab = Transactions | Staging

type ruleActivityItem = {
  overview_rule: ReconEngineTypes.overviewRulesResponse,
  volume: int,
  exceptions: int,
  matchRate: float,
}
