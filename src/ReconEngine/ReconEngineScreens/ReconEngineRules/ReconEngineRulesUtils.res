open LogicUtils
open ReconEngineRulesTypes

let getFieldDisplayName = (field: string): string => {
  if field->String.startsWith("metadata.") {
    field->String.replace("metadata.", "")->getTitle
  } else {
    field->getTitle
  }
}

let getAccountName = (
  accountId: string,
  accountData: array<ReconEngineTypes.accountType>,
): string => {
  accountData
  ->Array.find(account => account.account_id === accountId)
  ->Option.map(account => account.account_name)
  ->Option.getOr("Unknown Account")
}

let getSearchIdentifiersWithAccounts = (
  strategy: reconStrategyType,
  accountData: array<ReconEngineTypes.accountType>,
) => {
  switch strategy {
  | OneToOne(oneToOne) =>
    switch oneToOne {
    | SingleSingle(data) => [
        {
          search_identifier: data.search_identifier,
          target_account_id: data.target_account.account_id,
          source_account_name: getAccountName(data.source_account.account_id, accountData),
          target_account_name: getAccountName(data.target_account.account_id, accountData),
        },
      ]
    | SingleMany(data) => [
        {
          search_identifier: data.search_identifier,
          target_account_id: data.target_account.account_id,
          source_account_name: getAccountName(data.source_account.account_id, accountData),
          target_account_name: getAccountName(data.target_account.account_id, accountData),
        },
      ]
    | ManySingle(data) => [
        {
          search_identifier: data.search_identifier,
          target_account_id: data.target_account.account_id,
          source_account_name: getAccountName(data.source_account.account_id, accountData),
          target_account_name: getAccountName(data.target_account.account_id, accountData),
        },
      ]
    | ManyMany(data) => [
        {
          search_identifier: data.search_identifier,
          target_account_id: data.target_account.account_id,
          source_account_name: getAccountName(data.source_account.account_id, accountData),
          target_account_name: getAccountName(data.target_account.account_id, accountData),
        },
      ]
    | UnknownOneToOneStrategy => []
    }
  | OneToMany(oneToMany) =>
    switch oneToMany {
    | SingleSingle(data) =>
      switch data.target_accounts {
      | Percentage({targets})
      | Fixed({targets}) =>
        targets->Array.map(((target, _)) => {
          search_identifier: target.search_identifier,
          target_account_id: target.account_id,
          source_account_name: getAccountName(data.source_account.account_id, accountData),
          target_account_name: getAccountName(target.account_id, accountData),
        })
      | UnknownTargetsType => []
      }
    | UnknownOneToManyStrategy => []
    }
  | UnknownReconStrategy => []
  }
}

let getMappingRulesWithAccounts = (
  strategy: reconStrategyType,
  accountData: array<ReconEngineTypes.accountType>,
): array<mappingRulesWithAccount> => {
  switch strategy {
  | OneToOne(oneToOne) =>
    switch oneToOne {
    | SingleSingle(data) => [
        {
          match_rules: data.match_rules.rules,
          target_account_id: data.target_account.account_id,
          source_account_name: getAccountName(data.source_account.account_id, accountData),
          target_account_name: getAccountName(data.target_account.account_id, accountData),
        },
      ]
    | SingleMany(data) => [
        {
          match_rules: data.match_rules.rules,
          target_account_id: data.target_account.account_id,
          source_account_name: getAccountName(data.source_account.account_id, accountData),
          target_account_name: getAccountName(data.target_account.account_id, accountData),
        },
      ]
    | ManySingle(data) => [
        {
          match_rules: data.match_rules.rules,
          target_account_id: data.target_account.account_id,
          source_account_name: getAccountName(data.source_account.account_id, accountData),
          target_account_name: getAccountName(data.target_account.account_id, accountData),
        },
      ]
    | ManyMany(data) => [
        {
          match_rules: data.match_rules.rules,
          target_account_id: data.target_account.account_id,
          source_account_name: getAccountName(data.source_account.account_id, accountData),
          target_account_name: getAccountName(data.target_account.account_id, accountData),
        },
      ]
    | UnknownOneToOneStrategy => []
    }
  | OneToMany(oneToMany) =>
    switch oneToMany {
    | SingleSingle(data) =>
      switch data.target_accounts {
      | Percentage({targets})
      | Fixed({targets}) =>
        targets->Array.map(((target, _)) => {
          match_rules: target.match_rules.rules,
          target_account_id: target.account_id,
          source_account_name: getAccountName(data.source_account.account_id, accountData),
          target_account_name: getAccountName(target.account_id, accountData),
        })
      | UnknownTargetsType => []
      }
    | UnknownOneToManyStrategy => []
    }
  | UnknownReconStrategy => []
  }
}

let getTriggerData = (strategy: reconStrategyType): option<triggerType> => {
  switch strategy {
  | OneToOne(oneToOne) =>
    switch oneToOne {
    | SingleSingle(data) => Some(data.source_account.trigger)
    | SingleMany(data) => Some(data.source_account.trigger)
    | ManySingle(data) => Some(data.source_account.trigger)
    | ManyMany(data) => Some(data.source_account.trigger)
    | UnknownOneToOneStrategy => None
    }
  | OneToMany(oneToMany) =>
    switch oneToMany {
    | SingleSingle(data) => Some(data.source_account.trigger)
    | UnknownOneToManyStrategy => None
    }
  | UnknownReconStrategy => None
  }
}

let getGroupingField = (strategy: reconStrategyType): option<string> => {
  switch strategy {
  | OneToOne(oneToOne) =>
    switch oneToOne {
    | ManySingle(data) => Some(data.source_account.grouping_field)
    | ManyMany(data) => Some(data.source_account.grouping_field)
    | _ => None
    }
  | _ => None
  }
}

let getSourceAndTargetAccountDetails = (strategy: reconStrategyType): (
  string,
  array<ReconEngineRulesTypes.targetAccountInfo>,
) => {
  switch strategy {
  | OneToOne(oneToOne) =>
    switch oneToOne {
    | SingleSingle(data) => (
        data.source_account.account_id,
        [{account_id: data.target_account.account_id, split_value: None, split_type: None}],
      )
    | SingleMany(data) => (
        data.source_account.account_id,
        [{account_id: data.target_account.account_id, split_value: None, split_type: None}],
      )
    | ManySingle(data) => (
        data.source_account.account_id,
        [{account_id: data.target_account.account_id, split_value: None, split_type: None}],
      )
    | ManyMany(data) => (
        data.source_account.account_id,
        [{account_id: data.target_account.account_id, split_value: None, split_type: None}],
      )
    | UnknownOneToOneStrategy => ("", [])
    }
  | OneToMany(oneToMany) =>
    switch oneToMany {
    | SingleSingle(data) => {
        let targets = switch data.target_accounts {
        | Percentage({targets}) =>
          targets->Array.map(((target, splitVal)) => {
            account_id: target.account_id,
            split_value: Some(splitVal.value),
            split_type: Some("percentage"),
          })
        | Fixed({targets}) =>
          targets->Array.map(((target, splitVal)) => {
            account_id: target.account_id,
            split_value: Some(splitVal.value),
            split_type: Some("fixed"),
          })
        | UnknownTargetsType => []
        }
        (data.source_account.account_id, targets)
      }
    | UnknownOneToManyStrategy => ("", [])
    }
  | UnknownReconStrategy => ("", [])
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
    ->Array.map(item => item->getDictFromJsonObject->matchRuleMapper),
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
    grouping_field: dict->getString("grouping_field", ""),
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

let oneToOneManyManySourceMapper: Dict.t<JSON.t> => oneToOneManyManySourceType = dict => {
  {
    account_id: dict->getString("account_id", ""),
    trigger: dict->getJsonObjectFromDict("trigger")->getDictFromJsonObject->triggerMapper,
    grouping_field: dict->getString("grouping_field", ""),
  }
}

let oneToOneManyManyTargetMapper: Dict.t<JSON.t> => oneToOneManyManyTargetType = dict => {
  {
    account_id: dict->getString("account_id", ""),
  }
}

let oneToOneManyManyMapper: Dict.t<JSON.t> => oneToOneManyManyType = dict => {
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
    ->oneToOneManyManySourceMapper,
    target_account: dict
    ->getJsonObjectFromDict("target_account")
    ->getDictFromJsonObject
    ->oneToOneManyManyTargetMapper,
  }
}

let getReconStrategyDisplayName = (strategy: reconStrategyType): string => {
  switch strategy {
  | OneToOne(SingleSingle(_)) => "One to One Account + Single Single Transaction"
  | OneToOne(SingleMany(_)) => "One to One Account + Single Many Transaction"
  | OneToOne(ManySingle(_)) => "One to One Account + Many Single Transaction"
  | OneToOne(ManyMany(_)) => "One to One Account + Many Many Transaction"
  | OneToMany(SingleSingle(_)) => "One to Many Account + Single Single Transaction"
  | UnknownReconStrategy
  | OneToOne(UnknownOneToOneStrategy)
  | OneToMany(UnknownOneToManyStrategy) => "Unknown"
  }
}

let getReconAgingConfigDisplayName = (agingConfig: agingConfigType): string => {
  switch agingConfig.aging_config_type {
  | WithThreshold(threshold) =>
    `${threshold.value->Int.toString} ${threshold.threshold_type->snakeToTitle}`
  | NoAging => "No Aging"
  | UnknownAgingConfigType => "Unknown"
  }
}

let oneToOneStrategyMapper: Dict.t<JSON.t> => oneToOneStrategyType = dict => {
  switch dict->getString("one_to_one_type", "") {
  | "single_single" => SingleSingle(dict->oneToOneSingleSingleMapper)
  | "single_many" => SingleMany(dict->oneToOneSingleManyMapper)
  | "many_single" => ManySingle(dict->oneToOneManySingleMapper)
  | "many_many" => ManyMany(dict->oneToOneManyManyMapper)
  | _ => UnknownOneToOneStrategy
  }
}

let splitValueMapper: Dict.t<JSON.t> => splitValueType = dict => {
  {
    value: dict->getFloat("value", 0.0),
  }
}

let oneToManySingleSingleSourceMapper: Dict.t<JSON.t> => oneToManySingleSingleSourceType = dict => {
  {
    account_id: dict->getString("account_id", ""),
    trigger: dict->getJsonObjectFromDict("trigger")->getDictFromJsonObject->triggerMapper,
  }
}

let oneToManySingleSingleTargetMapper: Dict.t<JSON.t> => oneToManySingleSingleTargetType = dict => {
  {
    account_id: dict->getString("account_id", ""),
    search_identifier: dict
    ->getJsonObjectFromDict("search_identifier")
    ->getDictFromJsonObject
    ->searchIdentifierMapper,
    match_rules: dict
    ->getJsonObjectFromDict("match_rules")
    ->getDictFromJsonObject
    ->matchRulesMapper,
  }
}

let oneToManySingleSingleTargetsMapper: Dict.t<
  JSON.t,
> => oneToManySingleSingleTargetsType = dict => {
  switch dict->getString("split_type", "") {
  | "percentage" =>
    Percentage({
      targets: dict
      ->getArrayFromDict("targets", [])
      ->Array.map(item => {
        let arr = item->getArrayFromJson([])
        let targetConfig =
          arr
          ->getValueFromArray(0, JSON.Encode.null)
          ->getDictFromJsonObject
        let splitValue = arr->getValueFromArray(1, JSON.Encode.null)->getDictFromJsonObject
        (targetConfig->oneToManySingleSingleTargetMapper, splitValue->splitValueMapper)
      }),
    })
  | "fixed" =>
    Fixed({
      targets: dict
      ->getArrayFromDict("targets", [])
      ->Array.map(item => {
        let arr = item->getArrayFromJson([])
        let targetConfig = arr->getValueFromArray(0, JSON.Encode.null)->getDictFromJsonObject
        let splitValue = arr->getValueFromArray(1, JSON.Encode.null)->getDictFromJsonObject
        (targetConfig->oneToManySingleSingleTargetMapper, splitValue->splitValueMapper)
      }),
    })
  | _ => UnknownTargetsType
  }
}

let oneToManySingleSingleMapper: Dict.t<JSON.t> => oneToManySingleSingleType = dict => {
  {
    source_account: dict
    ->getJsonObjectFromDict("source_account")
    ->getDictFromJsonObject
    ->oneToManySingleSingleSourceMapper,
    target_accounts: dict
    ->getJsonObjectFromDict("target_accounts")
    ->getDictFromJsonObject
    ->oneToManySingleSingleTargetsMapper,
  }
}

let oneToManyStrategyMapper: Dict.t<JSON.t> => oneToManyStrategyType = dict => {
  switch dict->getString("one_to_many_type", "") {
  | "single_single" => SingleSingle(dict->oneToManySingleSingleMapper)
  | _ => UnknownOneToManyStrategy
  }
}

let reconStrategyMapper: Dict.t<JSON.t> => reconStrategyType = dict => {
  switch dict->getString("recon_strategy_type", "") {
  | "one_to_one" => OneToOne(dict->oneToOneStrategyMapper)
  | "one_to_many" => OneToMany(dict->oneToManyStrategyMapper)
  | _ => UnknownReconStrategy
  }
}

let agingConfigWithThresholdMapper: Dict.t<JSON.t> => agingConfigWithThreshold = dict => {
  {
    threshold_type: dict->getString("threshold_type", ""),
    value: dict->getInt("value", 0),
  }
}

let agingConfigMapper: Dict.t<JSON.t> => agingConfigType = dict => {
  switch dict->getString("aging_config_type", "") {
  | "with_threshold" => {
      aging_config_type: WithThreshold(
        dict
        ->getJsonObjectFromDict("threshold")
        ->getDictFromJsonObject
        ->agingConfigWithThresholdMapper,
      ),
    }
  | "no_aging" => {aging_config_type: NoAging}
  | _ => {aging_config_type: UnknownAgingConfigType}
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
    ->getDictfromDict("strategy")
    ->reconStrategyMapper,
    created_at: dict->getString("created_at", ""),
    last_modified_at: dict->getString("last_modified_at", ""),
    aging_config: dict
    ->getDictfromDict("aging_config")
    ->agingConfigMapper,
  }
}
