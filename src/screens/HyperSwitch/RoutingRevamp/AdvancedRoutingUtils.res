external toJson: 'a => Js.Json.t = "%identity"

let getCurrentDetailedUTCTime = () => {
  Js.Date.fromFloat(Js.Date.now())->Js.Date.toUTCString
}

let defaultThreeDsObjectValue: AdvancedRoutingTypes.connectorSelection = {
  override_3ds: "three_ds",
}

let getCurrentShortUTCTime = () => {
  let currentDate = Js.Date.now()->Js.Date.fromFloat
  let currMonth = currentDate->Js.Date.getUTCMonth->Belt.Float.toString
  let currDay = currentDate->Js.Date.getUTCDate->Belt.Float.toString
  let currYear = currentDate->Js.Date.getUTCFullYear->Belt.Float.toString

  `${currYear}-${currMonth}-${currDay}`
}

let operatorMapper: string => AdvancedRoutingTypes.operator = value => {
  switch value {
  | "CONTAINS" => CONTAINS
  | "NOT_CONTAINS" => NOT_CONTAINS
  | "IS" => IS
  | "IS_NOT" => IS_NOT
  | "GREATER THAN" => GREATER_THAN
  | "LESS THAN" => LESS_THAN
  | "EQUAL TO" => EQUAL_TO
  | "NOT EQUAL_TO" => NOT_EQUAL_TO
  | _ => UnknownOperator("")
  }
}

let getRoutingTypeName = (routingType: AdvancedRoutingTypes.routing) => {
  switch routingType {
  | SINGLE => "single"
  | VOLUME_SPLIT => "volume"
  | ADVANCED => "rule"
  | COST => "cost"
  | PRIORITY => "rank"
  | DEFAULTFALLBACK => "default"
  | NO_ROUTING => ""
  }
}

let getRoutingNameString = (~routingType) => {
  open LogicUtils
  let routingText = routingType->getRoutingTypeName
  `${routingText->capitalizeString} Based Routing-${getCurrentShortUTCTime()}`
}

let getRoutingDescriptionString = (~routingType) => {
  let routingText = routingType->getRoutingTypeName
  `This is a ${routingText} based routing created at ${getCurrentDetailedUTCTime()}`
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

let getWasmGateway = wasm => {
  try {
    switch wasm {
    | Some(res) => res.RoutingTypes.getAllConnectors()
    | None => []
    }
  } catch {
  | _ => []
  }
}

let variantTypeMapper: string => AdvancedRoutingTypes.variantType = variantType => {
  switch variantType {
  | "number" => Number
  | "enum_variant" => Enum_variant
  | "metadata_value" => Metadata_value
  | "str_value" => String_value
  | _ => UnknownVariant("")
  }
}

let getStatementValue: Js.Dict.t<Js.Json.t> => AdvancedRoutingTypes.value = valueDict => {
  open LogicUtils
  {
    \"type": valueDict->getString("type", ""),
    value: valueDict->getJsonObjectFromDict("value"),
  }
}

let statementTypeMapper: Js.Dict.t<Js.Json.t> => AdvancedRoutingTypes.statement = dict => {
  open LogicUtils
  {
    lhs: dict->getString("lhs", ""),
    comparison: dict->getString("comparison", ""),
    value: getStatementValue(dict->getDictfromDict("value")),
    logical: dict->getString("logical", ""),
  }
}

let conditionTypeMapper = (statementArr: array<Js.Json.t>) => {
  open LogicUtils
  let statements = statementArr->Array.reduce([], (acc, statementJson) => {
    let conditionArray = statementJson->getDictFromJsonObject->getArrayFromDict("condition", [])

    let arr = conditionArray->Js.Array2.mapi((conditionJson, index) => {
      let statementDict = conditionJson->getDictFromJsonObject
      let returnValue: AdvancedRoutingTypes.statement = {
        lhs: statementDict->getString("lhs", ""),
        comparison: statementDict->getString("comparison", ""),
        logical: index === 0 ? "OR" : "AND",
        value: getStatementValue(statementDict->getDictfromDict("value")),
      }
      returnValue
    })
    acc->Js.Array2.concat(arr)
  })

  statements
}

let routingTypeMapper = (str: string) => {
  open AdvancedRoutingTypes
  switch str->Js.String2.toLowerCase {
  | "priority" => PRIORITY
  | "volume_split" => VOLUME_SPLIT
  | _ => NO_ROUTING
  }
}

let volumeSplitConnectorSelectionDataMapper: Js.Dict.t<
  Js.Json.t,
> => AdvancedRoutingTypes.volumeSplitConnectorSelectionData = dict => {
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

let priorityConnectorSelectionDataMapper: Js.Dict.t<
  Js.Json.t,
> => AdvancedRoutingTypes.connector = dict => {
  open LogicUtils
  {
    connector: dict->getString("connector", ""),
    merchant_connector_id: dict->getString("merchant_connector_id", ""),
  }
}

let connectorSelectionDataMapperFromJson: Js.Json.t => AdvancedRoutingTypes.connectorSelectionData = json => {
  open LogicUtils
  let split = json->getDictFromJsonObject->getOptionInt("split")
  let dict = json->getDictFromJsonObject
  switch split {
  | Some(_) => VolumeObject(dict->volumeSplitConnectorSelectionDataMapper)
  | None => PriorityObject(dict->priorityConnectorSelectionDataMapper)
  }
}

let getDefaultSelection: Js.Dict.t<
  Js.Json.t,
> => AdvancedRoutingTypes.connectorSelection = defaultSelection => {
  open LogicUtils
  let override3dsValue = defaultSelection->getString("override_3ds", "")

  if override3dsValue->Js.String2.length > 0 {
    {
      override_3ds: override3dsValue,
    }
  } else {
    {
      \"type": defaultSelection->getString("type", ""),
      data: defaultSelection
      ->getArrayFromDict("data", [])
      ->Js.Array2.map(ele => ele->connectorSelectionDataMapperFromJson),
    }
  }
}

let getConnectorStringFromConnectorSelectionData = connectorSelectionData => {
  open AdvancedRoutingTypes
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
  open AdvancedRoutingTypes
  switch connectorSelectionData {
  | VolumeObject(obj) => obj.split
  | _ => 0
  }
}

let ruleInfoTypeMapper: Js.Dict.t<Js.Json.t> => AdvancedRoutingTypes.algorithmData = json => {
  open LogicUtils
  let rulesArray = json->getArrayFromDict("rules", [])

  let defaultSelection = json->getDictfromDict("defaultSelection")

  let rulesModifiedArray = rulesArray->Js.Array2.map(rule => {
    let ruleDict = rule->getDictFromJsonObject
    let connectorsDict = ruleDict->getDictfromDict("connectorSelection")

    let connectorSelection = getDefaultSelection(connectorsDict)
    let ruleName = ruleDict->getString("name", "")

    let eachRule: AdvancedRoutingTypes.rule = {
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
    | "enum_variant" => "IS"
    | "enum_variant_array" => "CONTAINS"
    | "str_value" => "EQUAL_TO"
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

let getGatewaysArrayFromValueData = data => {
  data->Js.Array2.map(getConnectorStringFromConnectorSelectionData)
}

let getModalObj = (routingType, text) => {
  open AdvancedRoutingTypes
  switch routingType {
  | ADVANCED => {
      conType: "Activate current configured configuration?",
      conText: {
        React.string(
          `If you want to activate the ${text} configuration, the advanced configuration, set previously will be lost. Are you sure you want to activate it?`,
        )
      },
    }
  | VOLUME_SPLIT => {
      conType: "Activate current configured configuration?",
      conText: {
        React.string(
          `If you want to activate the ${text} configuration, the volume based configuration, set previously will be lost. Are you sure you want to activate it?`,
        )
      },
    }
  | PRIORITY => {
      conType: "Activate current configured configuration?",
      conText: {
        React.string(
          `If you want to activate the ${text} configuration, the simple configuration, set previously will be lost. Are you sure you want to activate it?`,
        )
      },
    }
  | DEFAULTFALLBACK => {
      conType: "Save the Current Changes ?",
      conText: {
        React.string(`Do you want to save the current changes ?`)
      },
    }
  | _ => {
      conType: "Activate Logic",
      conText: {React.string("Are you sure you want to ACTIVATE the logic?")},
    }
  }
}

let isStatementMandatoryFieldsPresent = (statement: AdvancedRoutingTypes.statement) => {
  let statementValue = switch statement.value.value->Js.Json.classify {
  | JSONArray(ele) => ele->Js.Array2.length > 0
  | JSONString(str) => str->Js.String2.length > 0
  | _ => false
  }

  statement.lhs->Js.String2.length > 0 &&
    (statement.value.\"type"->Js.String2.length > 0 &&
    statementValue)
}

let algorithmTypeMapper: Js.Dict.t<Js.Json.t> => AdvancedRoutingTypes.algorithm = values => {
  open LogicUtils
  {
    data: values->getDictfromDict("data")->ruleInfoTypeMapper,
    \"type": values->getString("type", ""),
  }
}

let getRoutingTypesFromJson: Js.Json.t => AdvancedRoutingTypes.advancedRouting = values => {
  open LogicUtils
  let valuesDict = values->getDictFromJsonObject

  {
    name: valuesDict->getString("name", ""),
    description: valuesDict->getString("description", ""),
    algorithm: valuesDict->getDictfromDict("algorithm")->algorithmTypeMapper,
  }
}

let validateStatements = statementsArray => {
  statementsArray->Js.Array2.every(isStatementMandatoryFieldsPresent)
}

let generateStatements = statements => {
  open LogicUtils

  let initialValueForStatement: AdvancedRoutingTypes.statementSendType = {
    condition: [],
  }

  statements->Array.reduce([initialValueForStatement], (acc, statement) => {
    let statementDict = statement->getDictFromJsonObject
    let logicalOperator = statementDict->getString("logical", "")->Js.String2.toLowerCase

    let lastItem =
      acc->Belt.Array.get(acc->Js.Array2.length - 1)->Belt.Option.getWithDefault({condition: []})

    let condition: AdvancedRoutingTypes.statement = {
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
      acc->Js.Array2.concat([
        {
          condition: [condition],
        },
      ])
    } else {
      lastItem.condition->Array.push(condition)
      let filteredArr = acc->Array.filterWithIndex((_, i) => i !== acc->Js.Array2.length - 1)
      filteredArr->Array.push(lastItem)
      filteredArr
    }

    newAcc
  })
}

let generateRule = rulesDict => {
  let modifiedRules = rulesDict->Js.Array2.map(ruleJson => {
    open LogicUtils
    let ruleDict = ruleJson->getDictFromJsonObject
    let statements = ruleDict->getArrayFromDict("statements", [])

    let modifiedStatements = statements->generateStatements

    {
      "name": ruleDict->getString("name", ""),
      "connectorSelection": ruleDict->getJsonObjectFromDict("connectorSelection"),
      "statements": modifiedStatements->Js.Array2.map(toJson)->Js.Json.array,
    }
  })
  modifiedRules
}
