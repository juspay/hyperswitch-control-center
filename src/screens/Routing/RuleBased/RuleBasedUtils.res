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

let defaultRule: rule = {
  id: `rule_${LogicUtils.randomString(~length=6)}`,
  name: "",
  connectorSelection: defaultConnectorSelection,
  statements: [defaultGroup],
}
let defaultOperatorChoice: operatorChoice = {
  label: "Is",
  selectValue: "is",
  comparison: Equal,
  valueVariant: EnumOne({value: ""}),
}

let defaultConfig: config = {
  name: "",
  description: "",
  algorithm: {
    \"type": "advanced",
    data: {
      defaultSelection: defaultConnectorSelection,
      metadata: emptyMetadata(),
      rules: [defaultRule],
    },
  },
}

let defaultInitialValues = (): JSON.t => defaultConfig->Identity.genericTypeToJson

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

let operatorLabelForStoredValue = (~lhs: string, ~comparison: string, ~valueType: string): string =>
  lhs
  ->operatorChoicesForLhs
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
  | _ => dict->Dict.set("metadata", emptyMetadata())
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

let isConditionComplete = (conditionJson: JSON.t) => {
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

let connectorSelectionError = (selectionJson: JSON.t) => {
  let dict = selectionJson->getDictFromJsonObject
  let data = dict->getArrayFromDict("data", [])
  let splitOf = item => item->getDictFromJsonObject->getInt("split", 0)
  if data->isEmptyArray {
    Some("Need at least 1 processor")
  } else if dict->getString("type", "") === "volume_split" {
    let sum = data->Array.reduce(0, (acc, item) => acc + item->splitOf)
    let hasZero = data->Array.some(item => item->splitOf === 0)
    sum !== 100 || hasZero ? Some("Distribution percent not correct") : None
  } else {
    None
  }
}

let validate = (values: JSON.t): JSON.t => {
  let errors = Dict.make()
  let dict = values->getDictFromJsonObject

  let name = dict->getString("name", "")->String.trim
  if name->isEmptyString {
    errors->Dict.set("name", "Please provide Configuration Name"->JSON.Encode.string)
  } else if name->String.length > 64 {
    errors->Dict.set("name", "Configuration Name cannot exceed 64 characters"->JSON.Encode.string)
  }

  let description = dict->getString("description", "")->String.trim
  if description->isEmptyString {
    errors->Dict.set("description", "Please provide Description"->JSON.Encode.string)
  } else if description->String.length > 256 {
    errors->Dict.set("description", "Description cannot exceed 256 characters"->JSON.Encode.string)
  }

  let rules = dict->getDictFromNestedDict("algorithm", "data")->getArrayFromDict("rules", [])
  if rules->isEmptyArray {
    errors->Dict.set("rules", "Minimum 1 rule needed"->JSON.Encode.string)
  } else {
    rules->Array.forEachWithIndex((ruleJson, i) => {
      let n = (i + 1)->Int.toString
      let ruleDict = ruleJson->getDictFromJsonObject
      switch ruleDict->getJsonObjectFromDict("connectorSelection")->connectorSelectionError {
      | Some(err) => errors->Dict.set(`rule_${n}_processors`, err->JSON.Encode.string)
      | None => ()
      }
      let allComplete =
        ruleDict
        ->getArrayFromDict("statements", [])
        ->Array.every(statementJson =>
          statementJson
          ->getDictFromJsonObject
          ->getArrayFromDict("condition", [])
          ->Array.every(isConditionComplete)
        )
      if !allComplete {
        errors->Dict.set(`rule_${n}_conditions`, "Invalid condition"->JSON.Encode.string)
      }
    })
  }
  errors->JSON.Encode.object
}
