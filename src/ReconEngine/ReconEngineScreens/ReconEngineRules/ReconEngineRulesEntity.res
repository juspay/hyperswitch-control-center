open ReconEngineRulesTypes
open LogicUtils

let defaultColumns: array<ruleColType> = [RuleId, RuleName, RuleDescription, Status, Priority]

let allColumns: array<ruleColType> = [RuleId, RuleName, RuleDescription, Status, Priority]

let operatorMapper = dict => {
  {
    operator_version: dict->getString("operator_version", ""),
    value: dict->getString("value", ""),
  }
}

let triggerMapper = dict => {
  {
    trigger_version: dict->getString("trigger_version", ""),
    field: dict->getString("field", ""),
    operator: dict->getJsonObjectFromDict("operator")->getDictFromJsonObject->operatorMapper,
    value: dict->getString("value", ""),
  }
}

let sourceMapper = dict => {
  {
    id: dict->getString("id", ""),
    account_id: dict->getString("account_id", ""),
    trigger: dict->getJsonObjectFromDict("trigger")->getDictFromJsonObject->triggerMapper,
  }
}

let matchRuleMapper = dict => {
  {
    source_field: dict->getString("source_field", ""),
    target_field: dict->getString("target_field", ""),
    operator: dict->getString("operator", ""),
  }
}

let matchRulesMapper = dict => {
  {
    match_version: dict->getString("match_version", ""),
    rules: dict
    ->getArrayFromDict("rules", [])
    ->Array.map(item => item->JSON.Decode.object->Option.getOr(Dict.make())->matchRuleMapper),
  }
}

let searchIdentifierMapper = dict => {
  {
    search_version: dict->getString("search_version", ""),
    source_field: dict->getString("source_field", ""),
    target_field: dict->getString("target_field", ""),
  }
}

let targetMapper = dict => {
  {
    id: dict->getString("id", ""),
    account_id: dict->getString("account_id", ""),
    match_rules: dict
    ->getJsonObjectFromDict("match_rules")
    ->getDictFromJsonObject
    ->matchRulesMapper,
    search_identifier: dict
    ->getJsonObjectFromDict("search_identifier")
    ->getDictFromJsonObject
    ->searchIdentifierMapper,
  }
}

let ruleItemToObjMapper = dict => {
  {
    rule_id: dict->getString("rule_id", ""),
    rule_name: dict->getString("rule_name", ""),
    rule_description: dict->getString("rule_description", ""),
    priority: dict->getInt("priority", 0),
    is_active: dict->getBool("is_active", false),
    profile_id: dict->getString("profile_id", ""),
    sources: dict
    ->getArrayFromDict("sources", [])
    ->Array.map(item => item->JSON.Decode.object->Option.getOr(Dict.make())->sourceMapper),
    targets: dict
    ->getArrayFromDict("targets", [])
    ->Array.map(item => item->JSON.Decode.object->Option.getOr(Dict.make())->targetMapper),
  }
}

let getHeading = (colType: ruleColType) => {
  switch colType {
  | RuleId => Table.makeHeaderInfo(~key="rule_id", ~title="Rule ID")
  | RuleName => Table.makeHeaderInfo(~key="rule_name", ~title="Rule Name")
  | RuleDescription => Table.makeHeaderInfo(~key="rule_description", ~title="Description")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | Priority => Table.makeHeaderInfo(~key="priority", ~title="Priority")
  }
}

let getCell = (rule: rulePayload, colType: ruleColType): Table.cell => {
  switch colType {
  | RuleId => Text(rule.rule_id)
  | RuleName => Text(rule.rule_name)
  | RuleDescription => EllipsisText(rule.rule_description, "max-w-xs")
  | Status =>
    Label({
      title: rule.is_active ? "ACTIVE" : "INACTIVE",
      color: rule.is_active ? LabelGreen : LabelGray,
    })
  | Priority => Text(rule.priority->Int.toString)
  }
}

let rulesTableEntity = () => {
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=_ => [],
    ~defaultColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="",
  )
}

let rulesMapDefaultCols = (rawData: Nullable.t<rulePayload>) => {
  switch rawData->Nullable.toOption {
  | Some(rule) =>
    Dict.fromArray([
      ("rule_id", rule.rule_id->JSON.Encode.string),
      ("rule_name", rule.rule_name->JSON.Encode.string),
      ("rule_description", rule.rule_description->JSON.Encode.string),
      ("status", (rule.is_active ? "active" : "inactive")->JSON.Encode.string),
      ("priority", rule.priority->Int.toString->JSON.Encode.string),
    ])->JSON.Encode.object
  | None => Dict.make()->JSON.Encode.object
  }
}
