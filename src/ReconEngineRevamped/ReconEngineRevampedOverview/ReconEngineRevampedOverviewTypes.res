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

@unboxed
type connectedStatCardsTitle =
  | @as("Auto Match Rate") AutoMatchRate
  | @as("Missing") Missing
  | @as("Failed Transformations") FailedTransformations
  | @as("Failed Ingestions") FailedIngestions
  | @as("Manual Corrections") ManualCorrections

type statCardData = {
  title: statCardsTitle,
  value: valueType,
  icon: Button.iconType,
  description: string,
  cardType: statCardType,
}

type connectedStatCardData = {
  title: connectedStatCardsTitle,
  value: valueType,
}

type overviewRuleStatusType =
  | Expected
  | Missing
  | OverAmountExpected
  | OverAmountMismatch
  | UnderAmountExpected
  | UnderAmountMismatch
  | DataMismatch
  | CurrencyMismatch
  | SplitMismatch
  | Archived
  | Void
  | PartiallyReconciled
  | MatchedAuto
  | MatchedManual
  | MatchedForce
  | MatchedWithTolerance
  | PostedManual
  | UnknownStatus(string)

type overviewRuleStatus = {
  status: overviewRuleStatusType,
  count: int,
  credit_sum: float,
  debit_sum: float,
  currency: string,
}

type overviewRulesResponse = {
  rule_id: string,
  rule_name: string,
  statuses: array<overviewRuleStatus>,
}

type overviewChartGranularity =
  | FifteenMinutes
  | Hourly
  | Daily
  | Weekly

type overviewChartBucket = {
  startTime: string,
  endTime: string,
  label: string,
  tooltipLabel: string,
}

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

type overviewStatusDistributionItem = {
  name: string,
  count: int,
  color: string,
}

type overviewIngestionHistoryResponse = {
  id: string,
  ingestion_id: string,
  ingestion_history_id: string,
  file_name: string,
  account_id: string,
  status: string,
  upload_type: string,
  created_at: string,
  ingestion_name: string,
  version: int,
  discarded_at: string,
  discarded_status: string,
}

type transformationData = {
  transformation_result: string,
  total_count: int,
  transformed_count: int,
  ignored_count: int,
  staging_entry_ids: array<string>,
  errors: array<string>,
}

type overviewTransformationHistoryResponse = {
  transformation_history_id: string,
  transformation_id: string,
  transformation_name: string,
  ingestion_history_id: string,
  account_id: string,
  status: string,
  data: transformationData,
  processed_at: string,
  created_at: string,
}

type accountRefType = {
  account_id: string,
  account_name: string,
}

type processingEntryDataType = {
  status: string,
  needs_manual_review_type: string,
}

type processingEntryDiscardedDataType = {
  status: string,
  reason: string,
}

type overviewStagingEntryResponse = {
  id: string,
  staging_entry_id: string,
  account: accountRefType,
  entry_type: string,
  amount: float,
  currency: string,
  status: string,
  processing_mode: string,
  metadata: Js.Json.t,
  transformation_id: string,
  transformation_history_id: string,
  effective_at: string,
  order_id: string,
  version: int,
  discarded_status: option<string>,
  data: processingEntryDataType,
  discarded_data: option<processingEntryDiscardedDataType>,
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
  count: int,
}

type exceptionTriageItem = {
  label: string,
  count: int,
}

type overviewAccountStatusCounts = {
  matched: int,
  mismatched: int,
  pending: int,
  expected: int,
  archived: int,
  void: int,
}

type overviewAccountStatusAmounts = {
  matched_credit: float,
  matched_debit: float,
  mismatched_credit: float,
  mismatched_debit: float,
  pending_credit: float,
  pending_debit: float,
  currency: string,
}

type overviewAccountEntry = {
  account_id: string,
  account_name: string,
  account_type: string,
  status_counts: overviewAccountStatusCounts,
  status_amounts: overviewAccountStatusAmounts,
}
