open LogicUtils
open ReconEngineRulesTypes

let getFieldDisplayName = (field: string): string => {
  if field->String.startsWith("metadata.") {
    field->String.replace("metadata.", "")->getTitle
  } else {
    field->getTitle
  }
}

let createFormInput = (~name, ~value): ReactFinalForm.fieldRenderPropsInput => {
  name,
  onBlur: _ => (),
  onChange: _ => (),
  onFocus: _ => (),
  value: value->JSON.Encode.string,
  checked: true,
}

let createDropdownOption = (~label, ~value) => {
  SelectBox.label,
  value,
}

let operatorMapper: Dict.t<JSON.t> => operatorType = dict => {
  {
    operator_version: dict->getString("operator_version", ""),
    value: dict->getString("value", ""),
  }
}

let triggerMapper: Dict.t<JSON.t> => triggerType = dict => {
  {
    trigger_version: dict->getString("trigger_version", ""),
    field: dict->getString("field", ""),
    operator: dict->getJsonObjectFromDict("operator")->getDictFromJsonObject->operatorMapper,
    value: dict->getString("value", ""),
  }
}

let sourceMapper = dict => {
  {
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

let searchIdentifierMapper: Dict.t<JSON.t> => searchIdentifierType = dict => {
  {
    search_version: dict->getString("search_version", ""),
    source_field: dict->getString("source_field", ""),
    target_field: dict->getString("target_field", ""),
  }
}

let targetMapper = dict => {
  {
    account_id: dict->getString("account_id", ""),
  }
}

let entryFieldMapper: Dict.t<JSON.t> => entryFieldType = dict => {
  switch dict->getString("field", "") {
  | "" => Field(dict->getString("value", ""))
  | "metadata" => MetadataField({key: dict->getString("key", "")})
  | _ => Field(dict->getString("value", ""))
  }
}

let oneToOneSingleSingleSourceMapper: Dict.t<JSON.t> => oneToOneSingleSingleSourceType = dict => {
  {
    account_id: dict->getString("account_id", ""),
    trigger: dict->getJsonObjectFromDict("trigger")->getDictFromJsonObject->triggerMapper,
  }
}

let oneToOneSingleSingleTargetMapper: Dict.t<JSON.t> => oneToOneSingleSingleTargetType = dict => {
  {
    account_id: dict->getString("account_id", ""),
  }
}

let oneToOneSingleSingleMapper: Dict.t<JSON.t> => oneToOneSingleSingleType = dict => {
  {
    search_identifier: dict
    ->getJsonObjectFromDict("search_identifier")
    ->getDictFromJsonObject
    ->searchIdentifierMapper,
    match_rules: dict
    ->getJsonObjectFromDict("match_rules")
    ->getDictFromJsonObject
    ->matchRulesMapper,
    source_account: dict
    ->getJsonObjectFromDict("source_account")
    ->getDictFromJsonObject
    ->oneToOneSingleSingleSourceMapper,
    target_account: dict
    ->getJsonObjectFromDict("target_account")
    ->getDictFromJsonObject
    ->oneToOneSingleSingleTargetMapper,
  }
}

let oneToOneSingleManySourceMapper: Dict.t<JSON.t> => oneToOneSingleManySourceType = dict => {
  {
    account_id: dict->getString("account_id", ""),
    trigger: dict->getJsonObjectFromDict("trigger")->getDictFromJsonObject->triggerMapper,
  }
}

let oneToOneSingleManyTargetMapper: Dict.t<JSON.t> => oneToOneSingleManyTargetType = dict => {
  {
    account_id: dict->getString("account_id", ""),
  }
}

let oneToOneSingleManyMapper: Dict.t<JSON.t> => oneToOneSingleManyType = dict => {
  {
    search_identifier: dict
    ->getJsonObjectFromDict("search_identifier")
    ->getDictFromJsonObject
    ->searchIdentifierMapper,
    match_rules: dict
    ->getJsonObjectFromDict("match_rules")
    ->getDictFromJsonObject
    ->matchRulesMapper,
    source_account: dict
    ->getJsonObjectFromDict("source_account")
    ->getDictFromJsonObject
    ->oneToOneSingleManySourceMapper,
    target_account: dict
    ->getJsonObjectFromDict("target_account")
    ->getDictFromJsonObject
    ->oneToOneSingleManyTargetMapper,
  }
}

let oneToOneManySingleSourceMapper: Dict.t<JSON.t> => oneToOneManySingleSourceType = dict => {
  {
    account_id: dict->getString("account_id", ""),
    trigger: dict->getJsonObjectFromDict("trigger")->getDictFromJsonObject->triggerMapper,
    grouping_field: dict
    ->getJsonObjectFromDict("grouping_field")
    ->getDictFromJsonObject
    ->entryFieldMapper,
  }
}

let oneToOneManySingleTargetMapper: Dict.t<JSON.t> => oneToOneManySingleTargetType = dict => {
  {
    account_id: dict->getString("account_id", ""),
  }
}

let oneToOneManySingleMapper: Dict.t<JSON.t> => oneToOneManySingleType = dict => {
  {
    search_identifier: dict
    ->getJsonObjectFromDict("search_identifier")
    ->getDictFromJsonObject
    ->searchIdentifierMapper,
    match_rules: dict
    ->getJsonObjectFromDict("match_rules")
    ->getDictFromJsonObject
    ->matchRulesMapper,
    source_account: dict
    ->getJsonObjectFromDict("source_account")
    ->getDictFromJsonObject
    ->oneToOneManySingleSourceMapper,
    target_account: dict
    ->getJsonObjectFromDict("target_account")
    ->getDictFromJsonObject
    ->oneToOneManySingleTargetMapper,
  }
}

let oneToOneStrategyMapper: Dict.t<JSON.t> => oneToOneStrategyType = dict => {
  switch dict->getString("one_to_one_type", "") {
  | "single_single" => SingleSingle(dict->oneToOneSingleSingleMapper)
  | "single_many" => SingleMany(dict->oneToOneSingleManyMapper)
  | "many_single" => ManySingle(dict->oneToOneManySingleMapper)
  | _ =>
    SingleSingle(
      dict
      ->getJsonObjectFromDict("single_single")
      ->getDictFromJsonObject
      ->oneToOneSingleSingleMapper,
    )
  }
}

let reconStrategyMapper: Dict.t<JSON.t> => reconStrategyType = dict => {
  switch dict->getString("recon_strategy_type", "") {
  | "one_to_one" => OneToOne(dict->oneToOneStrategyMapper)
  | _ =>
    OneToOne(
      dict->getJsonObjectFromDict("one_to_one")->getDictFromJsonObject->oneToOneStrategyMapper,
    )
  }
}

let ruleItemToObjMapper: Dict.t<JSON.t> => rulePayload = dict => {
  {
    rule_id: dict->getString("rule_id", ""),
    rule_name: dict->getString("rule_name", ""),
    rule_description: dict->getString("rule_description", ""),
    priority: dict->getInt("priority", 0),
    is_active: dict->getBool("is_active", false),
    profile_id: dict->getString("profile_id", ""),
    strategy: dict
    ->getJsonObjectFromDict("strategy")
    ->getDictFromJsonObject
    ->reconStrategyMapper,
    created_at: dict->getString("created_at", ""),
    last_modified_at: dict->getString("last_modified_at", ""),
  }
}
