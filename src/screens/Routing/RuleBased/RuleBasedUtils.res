open LogicUtils
open RuleBasedTypes
open ConnectorInterfaceTableEntity

let emptyMetadata: JSON.t = Dict.make()->JSON.Encode.object

let defaultCondition: comparison = {
  lhs: "",
  comparison: Equal,
  value: EnumOne({value: ""}),
  metadata: emptyMetadata,
}

let defaultGroup: statement = {condition: [defaultCondition]}
let defaultConnectorSelection: connectorSelection = Priority({data: []})

let newDefaultRule = (): rule => {
  id: `rule_${LogicUtils.randomString(~length=6)}`,
  name: "",
  connectorSelection: defaultConnectorSelection,
  statements: [defaultGroup],
}
let defaultOperatorChoice: operatorChoice = {
  label: (IsOp :> string)->snakeToTitle,
  selectValue: IsOp,
  comparison: Equal,
  valueVariant: EnumOne({value: ""}),
}

let defaultConfig = (): config => {
  name: "",
  description: "",
  algorithm: {
    \"type": "advanced",
    data: {
      defaultSelection: defaultConnectorSelection,
      metadata: emptyMetadata,
      rules: [newDefaultRule()],
    },
  },
}

let cardBinFieldFromLhs = (lhs: string): option<cardBinField> =>
  switch lhs {
  | "card_bin" => Some(CardBin)
  | "extended_card_bin" => Some(ExtendedCardBin)
  | _ => None
  }

let isCardBinField = (lhs: string): bool => lhs->cardBinFieldFromLhs->Option.isSome

let cardBinMaxLength = (field: cardBinField): int =>
  switch field {
  | CardBin => 6
  | ExtendedCardBin => 8
  }

let variantTypeOfLhs = (lhs): value => {
  if lhs->isCardBinField {
    StrValue({value: ""})
  } else {
    let keyType = try {
      Window.getKeyType(lhs)
    } catch {
    | _ => ""
    }
    switch keyType {
    | "number" => Number({value: 0.0})
    | "fixed_number" => StrValue({value: ""})
    | "enum_variant" | "enum_variant_array" => EnumOne({value: ""})
    | "str_value" => StrValue({value: ""})
    | "metadata_value" => MetadataValue({value: {key: "", value: ""}})
    | _ => EnumOne({value: ""})
    }
  }
}

let isMetadataValue = (v: value): bool =>
  switch v {
  | MetadataValue(_) => true
  | _ => false
  }

let operatorToBEKey = (operator: operator): string =>
  operator->Identity.genericTypeToJson->getStringFromJson("")

let valueTypeKey = (v: value): string =>
  v->Identity.genericTypeToJson->getDictFromJsonObject->getString("type", "")

let operatorChoicesForVariant = (variantType: value): array<operatorChoice> =>
  switch variantType {
  | EnumOne(_) | EnumMany(_) => [
      {
        label: (IsOp :> string)->snakeToTitle,
        selectValue: IsOp,
        comparison: Equal,
        valueVariant: EnumOne({value: ""}),
      },
      {
        label: (IsNotOp :> string)->snakeToTitle,
        selectValue: IsNotOp,
        comparison: NotEqual,
        valueVariant: EnumOne({value: ""}),
      },
      {
        label: (ContainsOp :> string)->snakeToTitle,
        selectValue: ContainsOp,
        comparison: Equal,
        valueVariant: EnumMany({value: []}),
      },
      {
        label: (NotContainsOp :> string)->snakeToTitle,
        selectValue: NotContainsOp,
        comparison: NotEqual,
        valueVariant: EnumMany({value: []}),
      },
    ]
  | Number(_) => [
      {
        label: (EqualOp :> string)->snakeToTitle,
        selectValue: EqualOp,
        comparison: Equal,
        valueVariant: variantType,
      },
      {
        label: (GreaterThanOp :> string)->snakeToTitle,
        selectValue: GreaterThanOp,
        comparison: GreaterThan,
        valueVariant: variantType,
      },
      {
        label: (LessThanOp :> string)->snakeToTitle,
        selectValue: LessThanOp,
        comparison: LessThan,
        valueVariant: variantType,
      },
    ]
  | StrValue(_) => [
      {
        label: (EqualOp :> string)->snakeToTitle,
        selectValue: EqualOp,
        comparison: Equal,
        valueVariant: variantType,
      },
      {
        label: (NotEqualOp :> string)->snakeToTitle,
        selectValue: NotEqualOp,
        comparison: NotEqual,
        valueVariant: variantType,
      },
    ]
  | MetadataValue(_) => [
      {
        label: (EqualOp :> string)->snakeToTitle,
        selectValue: EqualOp,
        comparison: Equal,
        valueVariant: variantType,
      },
    ]
  }

let operatorChoicesForLhs = (lhs: string): array<operatorChoice> =>
  lhs->isCardBinField
    ? [
        {
          label: (EqualOp :> string)->snakeToTitle,
          selectValue: EqualOp,
          comparison: Equal,
          valueVariant: StrValue({value: ""}),
        },
      ]
    : lhs->variantTypeOfLhs->operatorChoicesForVariant

let defaultOperatorChoiceForLhs = (lhs: string): operatorChoice =>
  lhs->operatorChoicesForLhs->getValueFromArray(0, defaultOperatorChoice)

let selectedOperatorValue = (
  ~choices: array<operatorChoice>,
  ~comparison: string,
  ~valueType: string,
): displayOperator =>
  choices
  ->Array.find(c =>
    c.comparison->operatorToBEKey === comparison && c.valueVariant->valueTypeKey === valueType
  )
  ->mapOptionOrDefault(UnknownDisplayOperator(""), c => c.selectValue)

let operatorLabelForStoredValue = (~lhs: string, ~comparison: string, ~valueType: string): string =>
  lhs
  ->operatorChoicesForLhs
  ->Array.find(c =>
    c.comparison->operatorToBEKey === comparison && c.valueVariant->valueTypeKey === valueType
  )
  ->mapOptionOrDefault((EqualOp :> string)->snakeToTitle, c => c.label)

let connectorRefFromId = (connectorList, mcaId): connectorRef => {
  let connectorObj = connectorList->getConnectorObjectFromListViaId(mcaId, ~version=V1)
  {connector: connectorObj.connector_name, merchant_connector_id: mcaId}
}

let connectorLabelFromId = (connectorList, mcaId): string =>
  (connectorList->getConnectorObjectFromListViaId(mcaId, ~version=V1)).connector_label

let equalSplitConnectors = (connectorList, ids: array<string>): array<weightedConnector> => {
  let count = ids->Array.length
  let equalSplit = count === 0 ? 0 : 100 / count
  ids->Array.mapWithIndex((id, i) => {
    connector: connectorList->connectorRefFromId(id),
    split: i === count - 1 ? 100 - equalSplit * (count - 1) : equalSplit,
  })
}

let connectorSelectionFromIds = (
  connectorList,
  ~isDistribute,
  ids: array<string>,
): connectorSelection =>
  isDistribute
    ? VolumeSplit({data: connectorList->equalSplitConnectors(ids)})
    : Priority({data: ids->Array.map(id => connectorList->connectorRefFromId(id))})

let idsFromConnectorSelection = (selection: connectorSelection): array<string> =>
  switch selection {
  | Priority({data}) => data->Array.map(c => c.merchant_connector_id)
  | VolumeSplit({data}) => data->Array.map(wc => wc.connector.merchant_connector_id)
  }

let connectorRefFromJson = (dict: Dict.t<JSON.t>): connectorRef => {
  connector: dict->getString("connector", ""),
  merchant_connector_id: dict->getString("merchant_connector_id", ""),
}

let weightedConnectorFromJson = (dict: Dict.t<JSON.t>): weightedConnector => {
  split: dict->getInt("split", 0),
  connector: dict->getDictfromDict("connector")->connectorRefFromJson,
}

let connectorSelectionFromJson = (json: JSON.t): connectorSelection => {
  let dict = json->getDictFromJsonObject
  let data = dict->getArrayFromDict("data", [])
  switch dict->getString("type", "") {
  | "priority" =>
    Priority({data: data->Array.map(item => item->getDictFromJsonObject->connectorRefFromJson)})
  | "volume_split" | "volume" =>
    VolumeSplit({
      data: data->Array.map(item => item->getDictFromJsonObject->weightedConnectorFromJson),
    })
  | _ => defaultConnectorSelection
  }
}

let ensureMetadataObject = (dict: Dict.t<JSON.t>) => {
  let metadata = dict->getJsonObjectFromDict("metadata")
  switch metadata->JSON.Classify.classify {
  | Object(_) => ()
  | _ => dict->Dict.set("metadata", emptyMetadata)
  }
}

let forEachCondition = (data: Dict.t<JSON.t>, fn: Dict.t<JSON.t> => unit) =>
  data
  ->getArrayFromDict("rules", [])
  ->Array.forEach(ruleJson =>
    ruleJson
    ->getDictFromJsonObject
    ->getArrayFromDict("statements", [])
    ->Array.forEach(statementJson =>
      statementJson
      ->getDictFromJsonObject
      ->getArrayFromDict("condition", [])
      ->Array.forEach(conditionJson => fn(conditionJson->getDictFromJsonObject))
    )
  )

let stringifyStrValueNumber = (conditionDict: Dict.t<JSON.t>) => {
  let valueDict = conditionDict->getDictfromDict("value")
  let rawValue = valueDict->getJsonObjectFromDict("value")
  switch (valueDict->getString("type", ""), rawValue->JSON.Classify.classify) {
  | ("str_value", Number(_)) => valueDict->Dict.set("value", rawValue->getIntStringFromJson)
  | _ => ()
  }
}

let normalizeStrValueNumbers = (data: Dict.t<JSON.t>) =>
  data->forEachCondition(stringifyStrValueNumber)

let normalizeRulePayload = (json: JSON.t): JSON.t => {
  let data = json->getDictFromJsonObject->getDictFromNestedDict("algorithm", "data")
  data->ensureMetadataObject
  data->normalizeStrValueNumbers
  json
}

let forDuplicate = (values: JSON.t): JSON.t => {
  let dict = values->getDictFromJsonObject
  dict->Dict.set("name", ""->JSON.Encode.string)
  dict->JSON.Encode.object
}

let idOfRule = (ruleJson: JSON.t): string => {ruleJson->getDictFromJsonObject->getString("id", "")}

let addRule = (~rules: array<JSON.t>, ~setRules) => {
  setRules(rules->Array.concat([newDefaultRule()->Identity.genericTypeToJson]))
}

let copyRule = (~rules: array<JSON.t>, ~setRules, ~id) => {
  rules
  ->Array.find(ruleJson => ruleJson->idOfRule === id)
  ->mapOptionOrDefault((), ruleJson => {
    let dict = ruleJson->getDictFromJsonObject->Dict.copy
    dict->Dict.set("id", `rule_${randomString(~length=6)}`->JSON.Encode.string)
    setRules(rules->Array.concat([dict->JSON.Encode.object]))
  })
}

let removeRule = (~rules: array<JSON.t>, ~setRules, ~id) => {
  setRules(rules->Array.filter(ruleJson => ruleJson->idOfRule !== id))
}

let isConditionValid = (conditionJson: JSON.t) => {
  let dict = conditionJson->getDictFromJsonObject
  let lhs = dict->getString("lhs", "")
  let valueJson = dict->getDictfromDict("value")->getJsonObjectFromDict("value")
  let valueOk = switch valueJson->JSON.Classify.classify {
  | Array(arr) => arr->isNonEmptyArray
  | String(str) => AdvancedRoutingUtils.validateStringNumericField(str, lhs)
  | Number(num) => num >= 0.0
  | Object(obj) =>
    obj->getString("key", "")->isNonEmptyString && obj->getString("value", "")->isNonEmptyString
  | _ => false
  }
  lhs->isNonEmptyString && valueOk
}

let connectorSelectionError = (selectionJson: JSON.t) =>
  switch selectionJson->connectorSelectionFromJson {
  | Priority({data}) => data->isEmptyArray ? Some("Need at least 1 processor") : None
  | VolumeSplit({data}) =>
    if data->isEmptyArray {
      Some("Need at least 1 processor")
    } else if data->Array.some(wc => wc.split === 0) {
      Some("All processors must have at least 1% allocation")
    } else if data->Array.reduce(0, (acc, wc) => acc + wc.split) !== 100 {
      Some("Total distribution must equal 100%")
    } else {
      None
    }
  }

let requiredTextError = (value: string, ~label: string, ~maxLength: int): option<string> => {
  let trimmed = value->String.trim
  if trimmed->isEmptyString {
    Some(`Please provide ${label}`)
  } else if trimmed->String.length > maxLength {
    Some(`${label} cannot exceed ${maxLength->Int.toString} characters`)
  } else {
    None
  }
}

let setErrorIfPresent = (errors, key, errorOpt) =>
  switch errorOpt {
  | Some(err) => errors->Dict.set(key, err->JSON.Encode.string)
  | None => ()
  }

let validate = (values: JSON.t): JSON.t => {
  let errors = Dict.make()
  let dict = values->getDictFromJsonObject

  errors->setErrorIfPresent(
    "name",
    dict->getString("name", "")->requiredTextError(~label="Configuration Name", ~maxLength=64),
  )
  errors->setErrorIfPresent(
    "description",
    dict->getString("description", "")->requiredTextError(~label="Description", ~maxLength=256),
  )

  let rules = dict->getDictFromNestedDict("algorithm", "data")->getArrayFromDict("rules", [])
  if rules->isEmptyArray {
    errors->Dict.set("rules", "Minimum 1 rule needed"->JSON.Encode.string)
  } else {
    rules->Array.forEachWithIndex((ruleJson, i) => {
      let n = (i + 1)->Int.toString
      let ruleDict = ruleJson->getDictFromJsonObject
      errors->setErrorIfPresent(
        `rule_${n}_processors`,
        ruleDict->getJsonObjectFromDict("connectorSelection")->connectorSelectionError,
      )
      let allComplete =
        ruleDict
        ->getArrayFromDict("statements", [])
        ->Array.every(statementJson =>
          statementJson
          ->getDictFromJsonObject
          ->getArrayFromDict("condition", [])
          ->Array.every(isConditionValid)
        )
      if !allComplete {
        errors->Dict.set(`rule_${n}_conditions`, "Invalid condition"->JSON.Encode.string)
      }
    })
  }
  errors->JSON.Encode.object
}
