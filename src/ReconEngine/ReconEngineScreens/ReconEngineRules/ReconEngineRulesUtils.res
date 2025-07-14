open LogicUtils
open ReconEngineRulesTypes

let ruleItemToObjMapper = dict => {
  {
    rule_id: dict->getString("rule_id", ""),
    rule_name: dict->getString("rule_name", ""),
    rule_description: dict->getString("rule_description", ""),
    priority: dict->getInt("priority", 0),
    is_active: dict->getBool("is_active", false),
    profile_id: dict->getString("profile_id", ""),
    sources: [],
    targets: [],
  }
}

let getArrayOfRulesPayloadType = json => {
  json->Array.map(reportJson => {
    reportJson->getDictFromJsonObject->ReconEngineRulesEntity.ruleItemToObjMapper
  })
}
