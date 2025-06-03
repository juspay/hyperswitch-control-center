let operatorTypeToStringMapper = (operator: RoutingTypes.operator) => {
  switch operator {
  | CONTAINS => "CONTAINS"
  | NOT_CONTAINS => "NOT_CONTAINS"
  | IS => "IS"
  | IS_NOT => "IS_NOT"
  | GREATER_THAN => "GREATER THAN"
  | LESS_THAN => "LESS THAN"
  | EQUAL_TO => "EQUAL TO"
  | NOT_EQUAL_TO => "NOT EQUAL_TO"
  | UnknownOperator(str) => str
  }
}

let operatorMapper: string => RoutingTypes.operator = value => {
  switch value {
  | "CONTAINS" => CONTAINS
  | "NOT_CONTAINS" => NOT_CONTAINS
  | "IS" => IS
  | "IS_NOT" => IS_NOT
  | "GREATER_THAN"
  | "GREATER THAN" =>
    GREATER_THAN
  | "LESS_THAN"
  | "LESS THAN" =>
    LESS_THAN
  | "EQUAL TO" => EQUAL_TO
  | "NOT EQUAL_TO" => NOT_EQUAL_TO
  | _ => UnknownOperator("")
  }
}

let getRoutingTypeName = (routingType: RoutingTypes.routingType) => {
  switch routingType {
  | VOLUME_SPLIT => "volume"
  | ADVANCED => "rule"
  | DEFAULTFALLBACK => "default"
  | _ => ""
  }
}

let getRoutingNameString = (~routingType) => {
  open LogicUtils
  let routingText = routingType->getRoutingTypeName
  `${routingText->capitalizeString} Based Routing-${RoutingUtils.getCurrentUTCTime()}`
}

let getRoutingDescriptionString = (~routingType) => {
  let routingText = routingType->getRoutingTypeName
  `This is a ${routingText} based routing created at ${RoutingUtils.currentTimeInUTC}`
}

let getWasmKeyType = (wasm, value) => {
  try {
    switch wasm {
    | Some(res) => res.RoutingTypes.getKeyType(value)
    | None => ""
    }
  } catch {
  | _ => ""
  }
}

let getWasmVariantValues = (wasm, value) => {
  try {
    switch wasm {
    | Some(res) => res.RoutingTypes.getVariantValues(value)
    | None => []
    }
  } catch {
  | _ => []
  }
}

let getWasmPayoutVariantValues = (wasm, value) => {
  try {
    switch wasm {
    | Some(res) => res.RoutingTypes.getPayoutVariantValues(value)
    | None => []
    }
  } catch {
  | _ => []
  }
}

let variantTypeMapper: string => RoutingTypes.variantType = variantType => {
  switch variantType {
  | "number" => Number
  | "enum_variant" => Enum_variant
  | "metadata_value" => Metadata_value
  | "str_value" => String_value
  | _ => UnknownVariant("")
  }
}

let getStatementValue: Dict.t<JSON.t> => RoutingTypes.value = valueDict => {
  open LogicUtils
  {
    \"type": valueDict->getString("type", ""),
    value: valueDict->getJsonObjectFromDict("value"),
  }
}

let statementTypeMapper: Dict.t<JSON.t> => RoutingTypes.statement = dict => {
  open LogicUtils
  {
    lhs: dict->getString("lhs", ""),
    comparison: dict->getString("comparison", ""),
    value: getStatementValue(dict->getDictfromDict("value")),
    logical: dict->getString("logical", ""),
  }
}

let conditionTypeMapper = (statementArr: array<JSON.t>) => {
  open LogicUtils
  let statements = statementArr->Array.reduce([], (acc, statementJson) => {
    let conditionArray = statementJson->getDictFromJsonObject->getArrayFromDict("condition", [])

    let arr = conditionArray->Array.mapWithIndex((conditionJson, index) => {
      let statementDict = conditionJson->getDictFromJsonObject
      let returnValue: RoutingTypes.statement = {
        lhs: statementDict->getString("lhs", ""),
        comparison: statementDict->getString("comparison", ""),
        logical: index === 0 ? "OR" : "AND",
        value: getStatementValue(statementDict->getDictfromDict("value")),
      }
      returnValue
    })
    acc->Array.concat(arr)
  })

  statements
}

let volumeSplitConnectorSelectionDataMapper: Dict.t<
  JSON.t,
> => RoutingTypes.volumeSplitConnectorSelectionData = dict => {
  open LogicUtils
  {
    split: dict->getInt("split", 0),
    connector: {
      connector: dict->getDictfromDict("connector")->getString("connector", ""),
      merchant_connector_id: dict
      ->getDictfromDict("connector")
      ->getString("merchant_connector_id", ""),
    },
  }
}

let priorityConnectorSelectionDataMapper: Dict.t<JSON.t> => RoutingTypes.connector = dict => {
  open LogicUtils
  {
    connector: dict->getString("connector", ""),
    merchant_connector_id: dict->getString("merchant_connector_id", ""),
  }
}

let connectorSelectionDataMapperFromJson: JSON.t => RoutingTypes.connectorSelectionData = json => {
  open LogicUtils
  let split = json->getDictFromJsonObject->getOptionInt("split")
  let dict = json->getDictFromJsonObject
  switch split {
  | Some(_) => VolumeObject(dict->volumeSplitConnectorSelectionDataMapper)
  | None => PriorityObject(dict->priorityConnectorSelectionDataMapper)
  }
}

let getDefaultSelection: Dict.t<JSON.t> => RoutingTypes.connectorSelection = defaultSelection => {
  open LogicUtils
  open RoutingTypes
  let override3dsValue = defaultSelection->getString("override_3ds", "")
  let surchargeDetailsOptionalValue = defaultSelection->Dict.get("surcharge_details")
  let surchargeDetailsValue = defaultSelection->getDictfromDict("surcharge_details")

  if override3dsValue->isNonEmptyString {
    {
      override_3ds: override3dsValue,
    }
  } else if surchargeDetailsOptionalValue->Option.isSome {
    let surchargeValue = surchargeDetailsValue->getDictfromDict("surcharge")

    {
      surcharge_details: {
        surcharge: {
          \"type": surchargeValue->getString("type", "rate"),
          value: {
            percentage: surchargeValue->getDictfromDict("value")->getFloat("percentage", 0.0),
            amount: surchargeValue->getDictfromDict("value")->getFloat("amount", 0.0),
          },
        },
        tax_on_surcharge: {
          percentage: surchargeDetailsValue
          ->getDictfromDict("tax_on_surcharge")
          ->getFloat("percentage", 0.0),
        },
      }->Nullable.make,
    }
  } else {
    {
      \"type": defaultSelection->getString("type", ""),
      data: defaultSelection
      ->getArrayFromDict("data", [])
      ->Array.map(ele => ele->connectorSelectionDataMapperFromJson),
    }
  }
}

let getConnectorStringFromConnectorSelectionData = connectorSelectionData => {
  open RoutingTypes
  switch connectorSelectionData {
  | VolumeObject(obj) => {
      merchant_connector_id: obj.connector.merchant_connector_id,
      connector: obj.connector.connector,
    }
  | PriorityObject(obj) => {
      merchant_connector_id: obj.merchant_connector_id,
      connector: obj.connector,
    }
  }
}

let getSplitFromConnectorSelectionData = connectorSelectionData => {
  open RoutingTypes
  switch connectorSelectionData {
  | VolumeObject(obj) => obj.split
  | _ => 0
  }
}

let ruleInfoTypeMapper: Dict.t<JSON.t> => RoutingTypes.algorithmData = json => {
  open LogicUtils
  let rulesArray = json->getArrayFromDict("rules", [])

  let defaultSelection = json->getDictfromDict("defaultSelection")

  let rulesModifiedArray = rulesArray->Array.map(rule => {
    let ruleDict = rule->getDictFromJsonObject
    let connectorsDict = ruleDict->getDictfromDict("connectorSelection")

    let connectorSelection = getDefaultSelection(connectorsDict)
    let ruleName = ruleDict->getString("name", "")

    let eachRule: RoutingTypes.rule = {
      name: ruleName,
      connectorSelection,
      statements: conditionTypeMapper(ruleDict->getArrayFromDict("statements", [])),
    }
    eachRule
  })

  {
    rules: rulesModifiedArray,
    defaultSelection: getDefaultSelection(defaultSelection),
    metadata: json->getJsonObjectFromDict("metadata"),
  }
}

let getOperatorFromComparisonType = (comparison, variantType) => {
  switch comparison {
  | "equal" =>
    switch variantType {
    | "number" => "EQUAL TO"
    | "enum_variant" => "IS"
    | "enum_variant_array" => "CONTAINS"
    | "str_value" => "EQUAL TO"
    | "metadata_variant" => "EQUAL TO"
    | _ => "IS"
    }
  | "not_equal" =>
    switch variantType {
    | "enum_variant_array" => "NOT_CONTAINS"
    | "enum_variant" => "IS_NOT"
    | "str_value" => "NOT EQUAL_TO"
    | _ => "IS_NOT"
    }
  | "greater_than" => "GREATER_THAN"
  | "less_than" => "LESS_THAN"
  | _ => ""
  }
}

let isStatementMandatoryFieldsPresent = (statement: RoutingTypes.statement) => {
  open LogicUtils

  let statementValue = switch statement.value.value->JSON.Classify.classify {
  | Array(ele) => ele->Array.length > 0
  | String(str) => str->isNonEmptyString
  | Number(_) => true
  | Object(objectValue) => {
      let key = objectValue->getString("key", "")
      let value = objectValue->getString("value", "")
      key->isNonEmptyString && value->isNonEmptyString
    }
  | _ => false
  }

  statement.lhs->isNonEmptyString && (statement.value.\"type"->isNonEmptyString && statementValue)
}

let algorithmTypeMapper: Dict.t<JSON.t> => RoutingTypes.algorithm = values => {
  open LogicUtils
  {
    data: values->getDictfromDict("data")->ruleInfoTypeMapper,
    \"type": values->getString("type", ""),
  }
}

let getRoutingTypesFromJson: JSON.t => RoutingTypes.advancedRouting = values => {
  open LogicUtils
  let valuesDict = values->getDictFromJsonObject

  {
    name: valuesDict->getString("name", ""),
    description: valuesDict->getString("description", ""),
    algorithm: valuesDict->getDictfromDict("algorithm")->algorithmTypeMapper,
  }
}

let validateStatements = statementsArray => {
  statementsArray->Array.every(isStatementMandatoryFieldsPresent)
}

let generateStatements = statements => {
  open LogicUtils

  let initialValueForStatement: RoutingTypes.statementSendType = {
    condition: [],
  }

  statements->Array.reduce([initialValueForStatement], (acc, statement) => {
    let statementDict = statement->getDictFromJsonObject
    let logicalOperator = statementDict->getString("logical", "")->String.toLowerCase

    let lastItem = acc->Array.get(acc->Array.length - 1)->Option.getOr({condition: []})

    let condition: RoutingTypes.statement = {
      lhs: statementDict->getString("lhs", ""),
      comparison: switch statementDict->getString("comparison", "")->operatorMapper {
      | IS
      | EQUAL_TO
      | CONTAINS => "equal"
      | IS_NOT
      | NOT_CONTAINS
      | NOT_EQUAL_TO => "not_equal"
      | GREATER_THAN => "greater_than"
      | LESS_THAN => "less_than"
      | UnknownOperator(str) => str
      },
      value: statementDict->getDictfromDict("value")->getStatementValue,
      metadata: statementDict->getJsonObjectFromDict("metadata"),
    }

    let newAcc = if logicalOperator === "or" {
      acc->Array.concat([
        {
          condition: [condition],
        },
      ])
    } else {
      lastItem.condition->Array.push(condition)
      let filteredArr = acc->Array.filterWithIndex((_, i) => i !== acc->Array.length - 1)
      filteredArr->Array.push(lastItem)
      filteredArr
    }

    newAcc
  })
}

let generateRule = rulesDict => {
  let modifiedRules = rulesDict->Array.map(ruleJson => {
    open LogicUtils
    let ruleDict = ruleJson->getDictFromJsonObject
    let statements = ruleDict->getArrayFromDict("statements", [])

    let modifiedStatements = statements->generateStatements

    {
      "name": ruleDict->getString("name", ""),
      "connectorSelection": ruleDict->getJsonObjectFromDict("connectorSelection"),
      "statements": modifiedStatements->Array.map(Identity.genericTypeToJson)->JSON.Encode.array,
    }
  })
  modifiedRules
}

let defaultRule: RoutingTypes.rule = {
  name: "rule_1",
  connectorSelection: {
    \"type": "priority",
  },
  statements: [
    {
      lhs: "",
      comparison: "",
      value: {
        \"type": "number",
        value: ""->JSON.Encode.string,
      },
    },
  ],
}

let defaultAlgorithmData: RoutingTypes.algorithmData = {
  rules: [defaultRule],
  metadata: Dict.make()->JSON.Encode.object,
  defaultSelection: {
    \"type": "",
    data: [],
  },
}

let initialValues: RoutingTypes.advancedRouting = {
  name: getRoutingNameString(~routingType=ADVANCED),
  description: getRoutingDescriptionString(~routingType=ADVANCED),
  algorithm: {
    data: defaultAlgorithmData,
    \"type": "",
  },
}

let validateNameAndDescription = (~dict, ~errors, ~validateFields) => {
  open LogicUtils

  validateFields->Array.forEach(field => {
    if dict->getString(field, "")->String.trim->isEmptyString {
      errors->Dict.set(field, `Please provide ${field} field`->JSON.Encode.string)
    }
  })
}
