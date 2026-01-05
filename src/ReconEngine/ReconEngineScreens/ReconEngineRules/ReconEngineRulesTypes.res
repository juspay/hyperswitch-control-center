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

type matchRulesType = {
  match_version: string,
  rules: array<matchRuleType>,
}

type searchIdentifierType = {
  search_version: string,
  source_field: string,
  target_field: string,
}

type entryFieldType =
  | Field(string)
  | MetadataField({key: string})

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
  grouping_field: entryFieldType,
}

type oneToOneManySingleTargetType = {account_id: string}

type oneToOneManySingleType = {
  search_identifier: searchIdentifierType,
  match_rules: matchRulesType,
  source_account: oneToOneManySingleSourceType,
  target_account: oneToOneManySingleTargetType,
}

type oneToOneStrategyType =
  | SingleSingle(oneToOneSingleSingleType)
  | SingleMany(oneToOneSingleManyType)
  | ManySingle(oneToOneManySingleType)

type reconStrategyType = OneToOne(oneToOneStrategyType)

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
}

type ruleColType =
  | RuleId
  | RuleName
  | RuleDescription
  | Status
  | Priority
