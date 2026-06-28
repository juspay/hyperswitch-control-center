open LogicUtils
open RuleBasedTypes
open ConnectorInterfaceTableEntity

let emptyMetadata = (): JSON.t => Dict.make()->JSON.Encode.object

let defaultCondition: comparison = {
  lhs: "",
  comparison: Equal,
  value: EnumOne({value: ""}),
  metadata: emptyMetadata(),
}
let defaultGroup: statement = {condition: [defaultCondition]}
let defaultConnectorSelection: connectorSelection = Priority({data: []})

let defaultRule = (): rule => {
  id: `rule_${LogicUtils.randomString(~length=6)}`,
  name: "",
  connectorSelection: defaultConnectorSelection,
  statements: [defaultGroup],
}

let isCardBinField = (lhs: string): bool => lhs === "card_bin" || lhs === "extended_card_bin"

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

let operatorToBEKey = (operator: operator): string =>
  switch operator {
  | Equal => "equal"
  | NotEqual => "not_equal"
  | GreaterThan => "greater_than"
  | LessThan => "less_than"
  | UnknownOperator(str) => str
  }

let valueVariantFromType = (typeStr: string): value =>
  switch typeStr {
  | "number" => Number({value: 0.0})
  | "enum_variant_array" => EnumMany({value: []})
  | "str_value" => StrValue({value: ""})
  | "metadata_value" | "metadata_variant" => MetadataValue({value: {key: "", value: ""}})
  | _ => EnumOne({value: ""})
  }

let valueTypeKey = (v: value): string =>
  v->Identity.genericTypeToJson->getDictFromJsonObject->getString("type", "")

let defaultOperatorChoice: operatorChoice = {
  label: "Is",
  selectValue: "is",
  comparison: Equal,
  valueVariant: EnumOne({value: ""}),
}

let operatorChoicesForVariant = (variantType: value): array<operatorChoice> =>
  switch variantType {
  | EnumOne(_) | EnumMany(_) => [
      {
        label: "Is",
        selectValue: "is",
        comparison: Equal,
        valueVariant: EnumOne({value: ""}),
      },
      {
        label: "Is not",
        selectValue: "is_not",
        comparison: NotEqual,
        valueVariant: EnumOne({value: ""}),
      },
      {
        label: "Contains",
        selectValue: "contains",
        comparison: Equal,
        valueVariant: EnumMany({value: []}),
      },
      {
        label: "Does not contain",
        selectValue: "not_contains",
        comparison: NotEqual,
        valueVariant: EnumMany({value: []}),
      },
    ]
  | Number(_) => [
      {label: "Equal to", selectValue: "equal", comparison: Equal, valueVariant: variantType},
      {
        label: "Greater than",
        selectValue: "greater_than",
        comparison: GreaterThan,
        valueVariant: variantType,
      },
      {
        label: "Less than",
        selectValue: "less_than",
        comparison: LessThan,
        valueVariant: variantType,
      },
    ]
  | StrValue(_) => [
      {label: "Equal to", selectValue: "equal", comparison: Equal, valueVariant: variantType},
      {
        label: "Not equal to",
        selectValue: "not_equal",
        comparison: NotEqual,
        valueVariant: variantType,
      },
    ]
  | MetadataValue(_) => [
      {label: "Equal to", selectValue: "equal", comparison: Equal, valueVariant: variantType},
    ]
  }

let operatorChoicesForLhs = (lhs: string): array<operatorChoice> =>
  lhs->isCardBinField
    ? [
        {
          label: "Equal to",
          selectValue: "equal",
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
) =>
  choices
  ->Array.find(c =>
    c.comparison->operatorToBEKey === comparison && c.valueVariant->valueTypeKey === valueType
  )
  ->mapOptionOrDefault("", c => c.selectValue)

let operatorLabelForStoredValue = (~comparison: string, ~valueType: string): string =>
  valueType
  ->valueVariantFromType
  ->operatorChoicesForVariant
  ->Array.find(c =>
    c.comparison->operatorToBEKey === comparison && c.valueVariant->valueTypeKey === valueType
  )
  ->mapOptionOrDefault("Equal to", c => c.label)

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

let ensureMetadataObject = (dict: Dict.t<JSON.t>) => {
  let metadata = dict->Dict.get("metadata")->Option.getOr(emptyMetadata())
  switch metadata->JSON.Classify.classify {
  | Object(_) => ()
  | _ => dict->Dict.set("metadata", emptyMetadata())
  }
}

let normalizeRuleConditionMetadata = (data: Dict.t<JSON.t>) => {
  data
  ->getArrayFromDict("rules", [])
  ->Array.forEach(ruleJson => {
    ruleJson
    ->getDictFromJsonObject
    ->getArrayFromDict("statements", [])
    ->Array.forEach(statementJson => {
      statementJson
      ->getDictFromJsonObject
      ->getArrayFromDict("condition", [])
      ->Array.forEach(conditionJson => conditionJson->getDictFromJsonObject->ensureMetadataObject)
    })
  })
}


let normalizeStrValueNumbers = (data: Dict.t<JSON.t>) => {
  data
  ->getArrayFromDict("rules", [])
  ->Array.forEach(ruleJson => {
    ruleJson
    ->getDictFromJsonObject
    ->getArrayFromDict("statements", [])
    ->Array.forEach(statementJson => {
      statementJson
      ->getDictFromJsonObject
      ->getArrayFromDict("condition", [])
      ->Array.forEach(
        conditionJson => {
          let valueDict = conditionJson->getDictFromJsonObject->getDictfromDict("value")
          let rawValue = valueDict->getJsonObjectFromDict("value")
          switch (valueDict->getString("type", ""), rawValue->JSON.Classify.classify) {
          | ("str_value", Number(_)) => valueDict->Dict.set("value", rawValue->getIntStringFromJson)
          | _ => ()
          }
        },
      )
    })
  })
}

let normalizeRulePayload = (json: JSON.t): JSON.t => {
  let data = json->getDictFromJsonObject->getDictfromDict("algorithm")->getDictfromDict("data")
  data->ensureMetadataObject
  data->normalizeStrValueNumbers
  json
}

let defaultConfig: config = {
  name: "",
  description: "",
  algorithm: {
    \"type": "advanced",
    data: {
      defaultSelection: defaultConnectorSelection,
      metadata: emptyMetadata(),
      rules: [defaultRule()],
    },
  },
}

let defaultInitialValues = (): JSON.t => defaultConfig->Identity.genericTypeToJson

let loadInitialValues = (json: JSON.t): JSON.t => json->normalizeRulePayload
let toWirePayload = (values: JSON.t): JSON.t => values->normalizeRulePayload

let forDuplicate = (values: JSON.t): JSON.t => {
  let dict = values->getDictFromJsonObject
  dict->Dict.set("name", ""->JSON.Encode.string)
  dict->JSON.Encode.object
}

let isConditionComplete = (c: comparison) => {
  let valueJson =
    c.value
    ->Identity.genericTypeToJson
    ->getDictFromJsonObject
    ->Dict.get("value")
    ->Option.getOr(JSON.Encode.null)
  let valueOk = switch valueJson->JSON.Classify.classify {
  | Array(arr) => arr->Array.length > 0
  | String(str) => AdvancedRoutingUtils.validateStringNumericField(str, c.lhs)
  | Number(num) => num >= 0.0
  | Object(obj) =>
    obj->getString("key", "")->isNonEmptyString && obj->getString("value", "")->isNonEmptyString
  | _ => false
  }
  c.lhs->isNonEmptyString && valueOk
}

let connectorSelectionError = (selection: connectorSelection) =>
  switch selection {
  | Priority({data}) => data->isEmptyArray ? Some("Need at least 1 processor") : None
  | VolumeSplit({data}) =>
    if data->isEmptyArray {
      Some("Need at least 1 processor")
    } else {
      let sum = data->Array.reduce(0, (acc, w) => acc + w.split)
      let hasZero = data->Array.some(w => w.split === 0)
      sum !== 100 || hasZero ? Some("Distribution percent not correct") : None
    }
  }

let validate = (values: JSON.t): JSON.t => {
  let errors = Dict.make()
  let config: config = values->Identity.jsonToAnyType

  let name = config.name->String.trim
  if name->isEmptyString {
    errors->Dict.set("name", "Please provide Configuration Name"->JSON.Encode.string)
  } else if name->String.length > 64 {
    errors->Dict.set("name", "Configuration Name cannot exceed 64 characters"->JSON.Encode.string)
  }

  let description = config.description->String.trim
  if description->isEmptyString {
    errors->Dict.set("description", "Please provide Description"->JSON.Encode.string)
  } else if description->String.length > 256 {
    errors->Dict.set("description", "Description cannot exceed 256 characters"->JSON.Encode.string)
  }

  let rules = config.algorithm.data.rules
  if rules->isEmptyArray {
    errors->Dict.set("rules", "Minimum 1 rule needed"->JSON.Encode.string)
  } else {
    rules->Array.forEachWithIndex((rule, i) => {
      let n = (i + 1)->Int.toString
      switch rule.connectorSelection->connectorSelectionError {
      | Some(err) => errors->Dict.set(`rule_${n}_processors`, err->JSON.Encode.string)
      | None => ()
      }
      let allComplete =
        rule.statements->Array.every(s => s.condition->Array.every(isConditionComplete))
      if !allComplete {
        errors->Dict.set(`rule_${n}_conditions`, "Invalid condition"->JSON.Encode.string)
      }
    })
  }
  errors->JSON.Encode.object
}
