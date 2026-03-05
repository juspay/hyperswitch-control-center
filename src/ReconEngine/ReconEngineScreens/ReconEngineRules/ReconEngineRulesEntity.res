open ReconEngineRulesTypes
open LogicUtils
open ReconEngineRulesUtils

let defaultColumns: array<ruleColType> = [Priority, RuleName, RuleType, RuleDescription, Status]

let allColumns: array<ruleColType> = [Priority, RuleId, RuleName, RuleType, RuleDescription, Status]

let getHeading = (colType: ruleColType) => {
  switch colType {
  | Priority => Table.makeHeaderInfo(~key="priority", ~title="Priority")
  | RuleId => Table.makeHeaderInfo(~key="rule_id", ~title="Rule ID")
  | RuleName => Table.makeHeaderInfo(~key="rule_name", ~title="Rule Name")
  | RuleType => Table.makeHeaderInfo(~key="rule_type", ~title="Rule Type")
  | RuleDescription => Table.makeHeaderInfo(~key="rule_description", ~title="Description")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  }
}

let getCell = (rule: rulePayload, colType: ruleColType): Table.cell => {
  switch colType {
  | Priority => Text(rule.priority->Int.toString)
  | RuleId => DisplayCopyCell(rule.rule_id)
  | RuleName => Text(rule.rule_name)
  | RuleDescription => EllipsisText(rule.rule_description, "max-w-xs")
  | RuleType => Text(getReconStrategyDisplayName(rule.strategy))
  | Status =>
    Label({
      title: rule.is_active ? "ACTIVE" : "INACTIVE",
      color: rule.is_active ? LabelGreen : LabelGray,
    })
  }
}

let rulesTableEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=_ => [],
    ~defaultColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="",
    ~getShowLink={
      rule => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${rule.rule_id}`),
          ~authorization,
        )
      }
    },
  )
}

let rulesMapDefaultCols = (rawData: Nullable.t<rulePayload>) =>
  {
    switch rawData->Nullable.toOption {
    | Some(rule) => [
        ("rule_id", rule.rule_id->JSON.Encode.string),
        ("rule_name", rule.rule_name->JSON.Encode.string),
        ("rule_description", rule.rule_description->JSON.Encode.string),
        ("status", (rule.is_active ? "active" : "inactive")->JSON.Encode.string),
        ("priority", rule.priority->Int.toString->JSON.Encode.string),
      ]
    | None => []
    }
  }->getJsonFromArrayOfJson
