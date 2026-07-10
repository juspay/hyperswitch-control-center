type operatorType = {
  operator_version: string,
  value: string,
}

type triggerConditionType = {
  field: string,
  operator: operatorType,
  value: string,
}

@unboxed
type triggerLogicType =
  | @as("all") All
  | @as("any") Any
  | @as("unknown") UnknownTriggerLogic

type triggerV2Type = {
  logic: triggerLogicType,
  conditions: array<triggerConditionType>,
}

type triggerType =
  | V1(triggerConditionType)
  | V2(triggerV2Type)
  | UnknownTrigger

@unboxed
type compositeDelimiterType =
  | @as("pipe") Pipe
  | @as("unknown") UnknownCompositeDelimiter

type singleGroupingFieldType = {field: string}

type compositeGroupingFieldType = {
  fields: array<string>,
  delimiter: compositeDelimiterType,
}

type groupingFieldV1Type =
  | Single(singleGroupingFieldType)
  | Composite(compositeGroupingFieldType)
  | UnknownGroupingFieldV1

type groupingFieldType =
  | V1(groupingFieldV1Type)
  | UnknownGroupingField

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

type searchKeyType = {
  source_field: string,
  target_field: string,
}

type singleSearchIdentifierType = {key: searchKeyType}

type compositeSearchIdentifierType = {
  keys: array<searchKeyType>,
  delimiter: compositeDelimiterType,
}

type searchIdentifierV2Type =
  | Single(singleSearchIdentifierType)
  | Composite(compositeSearchIdentifierType)
  | UnknownSearchIdentifierV2

type searchIdentifierType =
  | V1(searchKeyType)
  | V2(searchIdentifierV2Type)
  | UnknownSearchIdentifier

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
  grouping_field: groupingFieldType,
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
  grouping_field: groupingFieldType,
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

type agingConfigType = NoAging | WithThreshold(agingConfigWithThreshold) | UnknownAgingConfigType

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
