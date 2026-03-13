open LogicUtils

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
  | AUTH_RATE_ROUTING => "auth-rate"
  | NO_ROUTING => ""
  }
}

let getRoutingNameString = (~routingType, ~currentDate) => {
  let routingText = routingType->getRoutingTypeName
  `${routingText->capitalizeString} Based Routing-${currentDate}`
}

let getRoutingDescriptionString = (~routingType, ~currentTime) => {
  let routingText = routingType->getRoutingTypeName
  `This is a ${routingText} based routing created at ${currentTime}`
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

let stringToVariantType = (value: string): RoutingTypes.validationFields => {
  switch value {
  | "card_bin" => CARD_BIN
  | "extended_card_bin" => EXTENDED_CARD_BIN
  | _ => OTHER
  }
}

let variantTypeMapper: string => RoutingTypes.variantType = variantType => {
  switch variantType {
  | "number" => Number
  | "fixed_number" => FixedNumber
  | "enum_variant" => Enum_variant
  | "metadata_value" => Metadata_value
  | "str_value" => String_value
  | _ => UnknownVariant("")
  }
}

let variantToStringMapper = (variantType: RoutingTypes.variantType) => {
  switch variantType {
  | Number => "number"
  | FixedNumber => "fixed_number"
  | Enum_variant => "enum_variant"
  | Metadata_value => "metadata_value"
  | String_value => "str_value"
  | UnknownVariant(str) => str
  }
}

let getKeyTypeFromValueField: RoutingTypes.validationFields => RoutingTypes.variantType = valueField => {
  switch valueField {
  | CARD_BIN
  | EXTENDED_CARD_BIN =>
    FixedNumber
  | OTHER => UnknownVariant("")
  }
}

let getStatementValue: Dict.t<JSON.t> => RoutingTypes.value = valueDict => {
  let valueType = valueDict->getString("type", "")
  let rawValue = valueDict->getJsonObjectFromDict("value")
  let convertedValue =
    valueType->variantTypeMapper === String_value
      ? switch rawValue->JSON.Classify.classify {
        | Number(_) => rawValue->getIntStringFromJson
        | _ => rawValue
        }
      : rawValue

  {
    \"type": valueType,
    value: convertedValue,
  }
}

let statementTypeMapper: Dict.t<JSON.t> => RoutingTypes.statement = dict => {
  {
    lhs: dict->getString("lhs", ""),
    comparison: dict->getString("comparison", ""),
    value: getStatementValue(dict->getDictfromDict("value")),
    logical: dict->getString("logical", ""),
  }
}

let conditionTypeMapper = (statementArr: array<JSON.t>) => {
  statementArr->Array.reduceWithIndex([], (acc, statementJson, index) => {
    let statementDict = statementJson->getDictFromJsonObject
    let conditionArray = statementDict->getArrayFromDict("condition", [])

    if conditionArray->Array.length > 0 {
      let conditionStatements = conditionArray->Array.mapWithIndex((
        conditionJson,
        conditionIndex,
      ) => {
        let conditionDict = conditionJson->getDictFromJsonObject
        let singleStatement: RoutingTypes.statement = {
          lhs: conditionDict->getString("lhs", ""),
          comparison: conditionDict->getString("comparison", ""),
          logical: conditionIndex === 0 ? "OR" : "AND",
          value: getStatementValue(conditionDict->getDictfromDict("value")),
        }
        singleStatement
      })
      [...acc, ...conditionStatements]
    } else {
      let singleStatement: RoutingTypes.statement = {
        lhs: statementDict->getString("lhs", ""),
        comparison: statementDict->getString("comparison", ""),
        logical: statementDict->getString("logical", index === 0 ? "OR" : "AND"),
        value: getStatementValue(statementDict->getDictfromDict("value")),
      }
      [...acc, singleStatement]
    }
  })
}

let volumeSplitConnectorSelectionDataMapper: Dict.t<
  JSON.t,
> => RoutingTypes.volumeSplitConnectorSelectionData = dict => {
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
  {
    connector: dict->getString("connector", ""),
    merchant_connector_id: dict->getString("merchant_connector_id", ""),
  }
}

let connectorSelectionDataMapperFromJson: JSON.t => RoutingTypes.connectorSelectionData = json => {
  let split = json->getDictFromJsonObject->getOptionInt("split")
  let dict = json->getDictFromJsonObject
  switch split {
  | Some(_) => VolumeObject(dict->volumeSplitConnectorSelectionDataMapper)
  | None => PriorityObject(dict->priorityConnectorSelectionDataMapper)
  }
}

let getDefaultSelection = (defaultSelection: Dict.t<JSON.t>): RoutingTypes.connectorSelection => {
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

let getDefaultSelectionFor3dsExemption = (
  defaultSelection: Dict.t<JSON.t>,
): RoutingTypes.connectorSelection => {
  open RoutingTypes
  let override3dsValue = defaultSelection->getString("decision", "")
  {
    override_3ds: override3dsValue,
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

let ruleInfoTypeMapper = (json: Dict.t<JSON.t>): RoutingTypes.algorithmData => {
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

let ruleInfoTypeMapperForThreeDsExemption = (json: Dict.t<JSON.t>): RoutingTypes.algorithmData => {
  let rulesArray = json->getArrayFromDict("rules", [])

  let defaultSelection = json->getDictfromDict("defaultSelection")

  let rulesModifiedArray = rulesArray->Array.map(rule => {
    let ruleDict = rule->getDictFromJsonObject
    let connectorsDict = ruleDict->getDictfromDict("connectorSelection")

    let connectorSelection = getDefaultSelectionFor3dsExemption(connectorsDict)
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
    defaultSelection: getDefaultSelectionFor3dsExemption(defaultSelection),
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

let validateStringNumericField = (str, field) => {
  //** Custom validation for card_bin and extended_card_bin when value is stored as string */
  let fieldType = field->stringToVariantType
  switch fieldType {
  | CARD_BIN | EXTENDED_CARD_BIN =>
    let requiredLength = fieldType == CARD_BIN ? 6 : 8
    let isValidNumeric =
      str->isNonEmptyString &&
        str
        ->String.split("")
        ->Array.every(char => {
          char >= "0" && char <= "9"
        })
    let hasCorrectLength = str->String.length == requiredLength
    isValidNumeric && hasCorrectLength
  | OTHER => str->isNonEmptyString
  }
}

let isStatementMandatoryFieldsPresent = (statement: RoutingTypes.statement) => {
  let fieldType = statement.lhs->stringToVariantType
  let statementValue = switch statement.value.value->JSON.Classify.classify {
  | Array(ele) => ele->Array.length > 0
  | String(str) =>
    switch fieldType {
    | CARD_BIN | EXTENDED_CARD_BIN => validateStringNumericField(str, statement.lhs)
    | OTHER => str->isNonEmptyString
    }
  | Number(num) => num >= 0.0
  | Object(objectValue) => {
      let key = objectValue->getString("key", "")
      let value = objectValue->getString("value", "")
      key->isNonEmptyString && value->isNonEmptyString
    }
  | _ => false
  }

  statement.lhs->isNonEmptyString && (statement.value.\"type"->isNonEmptyString && statementValue)
}

let algorithmTypeMapper = (values: Dict.t<JSON.t>): RoutingTypes.algorithm => {
  {
    data: values->getDictfromDict("data")->ruleInfoTypeMapper,
    \"type": values->getString("type", ""),
  }
}

let algorithmTypeMapperFor3DsExemption = (values: Dict.t<JSON.t>): RoutingTypes.algorithm => {
  {
    data: values->getDictfromDict("data")->ruleInfoTypeMapperForThreeDsExemption,
    \"type": values->getString("type", ""),
  }
}

let getRoutingTypesFromJson = (values: JSON.t): RoutingTypes.advancedRouting => {
  let valuesDict = values->getDictFromJsonObject

  {
    name: valuesDict->getString("name", ""),
    description: valuesDict->getString("description", ""),
    algorithm: valuesDict
    ->getDictfromDict("algorithm")
    ->algorithmTypeMapper,
  }
}

let getRoutingTypesFromJsonForThreeDsExemption = (values: JSON.t): RoutingTypes.advancedRouting => {
  let valuesDict = values->getDictFromJsonObject

  {
    name: valuesDict->getString("name", ""),
    description: valuesDict->getString("description", ""),
    algorithm: valuesDict
    ->getDictfromDict("algorithm")
    ->algorithmTypeMapperFor3DsExemption,
  }
}

let validateStatements = statementsArray => {
  statementsArray->Array.every(isStatementMandatoryFieldsPresent)
}

let generateStatements = statements => {
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

    let filteredAcc = newAcc->Array.filter(item => {
      item.condition->Array.length > 0
    })

    filteredAcc
  })
}

let generateRule = rulesDict => {
  let modifiedRules = rulesDict->Array.map(ruleJson => {
    let ruleDict = ruleJson->getDictFromJsonObject
    let statements = ruleDict->getArrayFromDict("statements", [])

    let modifiedStatements = statements->generateStatements

    let connectorSelection = ruleDict->getJsonObjectFromDict("connectorSelection")

    {
      "name": ruleDict->getString("name", ""),
      "connectorSelection": connectorSelection,
      "statements": modifiedStatements->Array.map(Identity.genericTypeToJson)->JSON.Encode.array,
    }
  })
  modifiedRules
}

let generateRuleForThreeDsExemption = rulesDict => {
  let modifiedRules = rulesDict->Array.map(ruleJson => {
    let ruleDict = ruleJson->getDictFromJsonObject
    let statements = ruleDict->getArrayFromDict("statements", [])

    let modifiedStatements = statements->generateStatements

    let connectorSelection = {
      let connectorSelectionJson = ruleDict->getJsonObjectFromDict("connectorSelection")
      let connectorSelectionDict = connectorSelectionJson->getDictFromJsonObject
      let decision = connectorSelectionDict->getString("override_3ds", "")
      [("decision", decision->JSON.Encode.string)]->getJsonFromArrayOfJson
    }

    {
      "name": ruleDict->getString("name", ""),
      "connectorSelection": connectorSelection,
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

let getInitialValues = (~currentDate, ~currentTime): RoutingTypes.advancedRouting => {
  name: getRoutingNameString(~routingType=ADVANCED, ~currentDate),
  description: getRoutingDescriptionString(~routingType=ADVANCED, ~currentTime),
  algorithm: {
    data: defaultAlgorithmData,
    \"type": "",
  },
}

let validateNameAndDescription = (
  ~dict,
  ~errors,
  ~validateFields: array<RoutingTypes.basicDetails>,
) => {
  validateFields->Array.forEach(field => {
    let fieldString = (field :> string)
    let fieldValue = dict->getString(fieldString, "")->String.trim

    let fieldMaxLength = switch field {
    | Name => 64
    | Description => 256
    }

    if fieldValue->String.length > fieldMaxLength {
      errors->Dict.set(
        fieldString,
        `${fieldString} cannot exceed ${fieldMaxLength->Int.toString} characters`->JSON.Encode.string,
      )
    }

    if fieldValue->isEmptyString {
      errors->Dict.set(fieldString, `Please provide ${fieldString} field`->JSON.Encode.string)
    }
  })
}
