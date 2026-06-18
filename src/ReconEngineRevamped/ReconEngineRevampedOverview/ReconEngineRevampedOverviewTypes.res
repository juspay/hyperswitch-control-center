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
  | @as("Unreconciled Value") UnreconciledValue

@unboxed
type connectedStatCardsTitle =
  | @as("Auto Match Rate") AutoMatchRate
  | @as("Aged") Aged
  | @as("Sources Healthy") SourcesHealthy
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

type overviewRulesStatusCountItemType = {
  count: int,
  credit_sum: float,
  debit_sum: float,
}

type overviewRulesStatusCountType = {
  partially_reconciled: overviewRulesStatusCountItemType,
  matched_force: overviewRulesStatusCountItemType,
  expected: overviewRulesStatusCountItemType,
  matched_auto: overviewRulesStatusCountItemType,
  matched_manual: overviewRulesStatusCountItemType,
  under_amount_expected: overviewRulesStatusCountItemType,
  under_amount_mismatch: overviewRulesStatusCountItemType,
  data_mismatch: overviewRulesStatusCountItemType,
  void: overviewRulesStatusCountItemType,
  over_amount_expected: overviewRulesStatusCountItemType,
  over_amount_mismatch: overviewRulesStatusCountItemType,
  posted_manual: overviewRulesStatusCountItemType,
  currency_mismatch: overviewRulesStatusCountItemType,
  matched_with_tolerance: overviewRulesStatusCountItemType,
  archived: overviewRulesStatusCountItemType,
  split_mismatch: overviewRulesStatusCountItemType,
}

type overviewRulesResponse = {
  rule_id: string,
  rule_name: string,
  status_counts: overviewRulesStatusCountType,
}
