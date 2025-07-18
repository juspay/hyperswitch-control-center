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

type sourceType = {
  id: string,
  account_id: string,
  trigger: triggerType,
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

type targetType = {
  id: string,
  account_id: string,
  match_rules: matchRulesType,
  search_identifier: searchIdentifierType,
}

type rulePayload = {
  rule_id: string,
  rule_name: string,
  rule_description: string,
  priority: int,
  is_active: bool,
  profile_id: string,
  sources: array<sourceType>,
  targets: array<targetType>,
}

type ruleColType =
  | RuleId
  | RuleName
  | RuleDescription
  | Status
  | Priority
