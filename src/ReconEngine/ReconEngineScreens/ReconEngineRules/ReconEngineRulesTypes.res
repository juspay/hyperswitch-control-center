type operatorType = {
  operator_version: string,
  value: string,
}

type triggerType = {
  trigger_version: string,
  field: string,
  operator: operatorType,
  value: string,
}

type matchRuleType = {
  source_field: string,
  target_field: string,
  operator: string,
}

type mappingRulesWithAccount = {
  match_rules: array<matchRuleType>,
  target_account_id: string,
  source_account_name: string,
  target_account_name: string,
}

type matchRulesType = {
  match_version: string,
  rules: array<matchRuleType>,
}

type searchIdentifierType = {
  search_version: string,
  source_field: string,
  target_field: string,
}

type targetAccountInfo = {
  account_id: string,
  split_value: option<float>,
  split_type: option<string>,
}

type searchIdentifierWithAccount = {
  search_identifier: searchIdentifierType,
  target_account_id: string,
  source_account_name: string,
  target_account_name: string,
}

type oneToOneSingleSingleSourceType = {
  account_id: string,
  trigger: triggerType,
}

type oneToOneSingleSingleTargetType = {account_id: string}

type oneToOneSingleSingleType = {
  search_identifier: searchIdentifierType,
  match_rules: matchRulesType,
  source_account: oneToOneSingleSingleSourceType,
  target_account: oneToOneSingleSingleTargetType,
}

type oneToOneSingleManySourceType = {
  account_id: string,
  trigger: triggerType,
}

type oneToOneSingleManyTargetType = {account_id: string}

type oneToOneSingleManyType = {
  search_identifier: searchIdentifierType,
  match_rules: matchRulesType,
  source_account: oneToOneSingleManySourceType,
  target_account: oneToOneSingleManyTargetType,
}

type oneToOneManySingleSourceType = {
  account_id: string,
  trigger: triggerType,
  grouping_field: string,
}

type oneToOneManySingleTargetType = {account_id: string}

type oneToOneManySingleType = {
  search_identifier: searchIdentifierType,
  match_rules: matchRulesType,
  source_account: oneToOneManySingleSourceType,
  target_account: oneToOneManySingleTargetType,
}

type oneToOneManyManySourceType = {
  account_id: string,
  trigger: triggerType,
  grouping_field: string,
}

type oneToOneManyManyTargetType = {account_id: string}

type oneToOneManyManyType = {
  search_identifier: searchIdentifierType,
  match_rules: matchRulesType,
  source_account: oneToOneManyManySourceType,
  target_account: oneToOneManyManyTargetType,
}

type oneToOneStrategyType =
  | SingleSingle(oneToOneSingleSingleType)
  | SingleMany(oneToOneSingleManyType)
  | ManySingle(oneToOneManySingleType)
  | ManyMany(oneToOneManyManyType)
  | UnknownOneToOneStrategy

type oneToManySingleSingleSourceType = {
  account_id: string,
  trigger: triggerType,
}

type oneToManySingleSingleTargetType = {
  account_id: string,
  search_identifier: searchIdentifierType,
  match_rules: matchRulesType,
}

type splitValueType = {value: float}

type oneToManySingleSingleTargetsType =
  | Percentage({targets: array<(oneToManySingleSingleTargetType, splitValueType)>})
  | Fixed({targets: array<(oneToManySingleSingleTargetType, splitValueType)>})
  | UnknownTargetsType

type oneToManySingleSingleType = {
  source_account: oneToManySingleSingleSourceType,
  target_accounts: oneToManySingleSingleTargetsType,
}

type oneToManyStrategyType = SingleSingle(oneToManySingleSingleType) | UnknownOneToManyStrategy

type reconStrategyType =
  | OneToOne(oneToOneStrategyType)
  | OneToMany(oneToManyStrategyType)
  | UnknownReconStrategy

type agingConfigWithThreshold = {threshold_type: string, value: int}

type agingConfigTypeVariant =
  NoAging | WithThreshold(agingConfigWithThreshold) | UnknownAgingConfigType

type agingConfigType = {aging_config_type: agingConfigTypeVariant}

type rulePayload = {
  rule_id: string,
  rule_name: string,
  rule_description: string,
  priority: int,
  is_active: bool,
  profile_id: string,
  strategy: reconStrategyType,
  created_at: string,
  last_modified_at: string,
  aging_config: agingConfigType,
}

type ruleColType =
  | RuleId
  | RuleName
  | RuleType
  | RuleDescription
  | Status
  | Priority
