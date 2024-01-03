open RoutingTypes
open LogicUtils
external toWasm: Js.Dict.t<Js.Json.t> => wasmModule = "%identity"
let getObjects = (_: Js.Json.t) => {
  []
}
let defaultThreeDsObjectValue: routingOutputType = {
  override_3ds: "three_ds",
}
let currentTimeInUTC = Js.Date.fromFloat(Js.Date.now())->Js.Date.toUTCString

let getCurrentUTCTime = () => {
  let currentDate = Js.Date.now()->Js.Date.fromFloat
  let currMonth = currentDate->Js.Date.getUTCMonth->Belt.Float.toString
  let currDay = currentDate->Js.Date.getUTCDate->Belt.Float.toString
  let currYear = currentDate->Js.Date.getUTCFullYear->Belt.Float.toString

  `${currYear}-${currMonth}-${currDay}`
}

let operatorMapper = value => {
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

let variantTypeMapper = variantType => {
  switch variantType {
  | "number" => Number
  | "enum_variant" => Enum_variant
  | "metadata_value" => Metadata_value
  | "str_value" => String_value
  | _ => UnknownVariant("")
  }
}

let logicalOperatorMapper = logical => {
  switch logical {
  | "AND" => AND
  | "OR" => OR
  | _ => UnknownLogicalOperator("")
  }
}

let routingTypeMapper = routingType => {
  switch routingType {
  | "single" => SINGLE
  | "priority" => PRIORITY
  | "volume_split" => VOLUME_SPLIT
  | "advanced" => ADVANCED
  | "cost" => COST
  | "default" => DEFAULTFALLBACK
  | _ => NO_ROUTING
  }
}

let routingTypeName = routingType => {
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

let logicalOperatorTypeToStringMapper = logicalOperator => {
  switch logicalOperator {
  | AND => "AND"
  | OR => "OR"
  | UnknownLogicalOperator(str) => str
  }
}
let operatorTypeToStringMapper = operator => {
  switch operator {
  | IS => "IS"
  | CONTAINS => "CONTAINS"
  | IS_NOT => "IS_NOT"
  | NOT_CONTAINS => "NOT_CONTAINS"
  | GREATER_THAN => "GREATER THAN"
  | LESS_THAN => "LESS THAN"
  | EQUAL_TO => "EQUAL TO"
  | NOT_EQUAL_TO => "NOT EQUAL_TO"
  | UnknownOperator(str) => str
  }
}

let itemGateWayObjMapper = (
  dict,
  _connectorList: option<array<ConnectorTypes.connectorPayload>>,
) => {
  let connectorId = dict->getDictfromDict("connector")->getString("merchant_connector_id", "")
  [
    ("distribution", dict->getFloat("split", 0.00)->Js.Json.number),
    ("disableFallback", dict->getBool("disableFallback", false)->Js.Json.boolean),
    ("gateway_name", connectorId->Js.Json.string),
  ]->Js.Dict.fromArray
}

let itemBodyGateWayObjMapper = (
  dict,
  connectorList: option<array<ConnectorTypes.connectorPayload>>,
) => {
  let connectorId = dict->getString("gateway_name", "")
  let name =
    connectorList
    ->Belt.Option.getWithDefault([Js.Dict.empty()->ConnectorTableUtils.getProcessorPayloadType])
    ->ConnectorTableUtils.getConnectorNameViaId(connectorId)
  let newDict =
    [
      ("connector", name.connector_name->Js.Json.string),
      ("merchant_connector_id", dict->getString("gateway_name", "")->Js.Json.string),
    ]
    ->Js.Dict.fromArray
    ->Js.Json.object_
  [
    ("split", dict->getFloat("distribution", 0.00)->Js.Json.number),
    ("connector", newDict),
  ]->Js.Dict.fromArray
}

let connectorPayload = (routingType, arr) => {
  switch routingType->routingTypeMapper {
  | VOLUME_SPLIT => {
      let connectorData = arr->Array.reduce([], (acc, routingObj) => {
        let routingDict = routingObj->getDictFromJsonObject
        acc->Array.push(getString(routingDict, "connector", ""))
        acc
      })
      connectorData
    }

  | PRIORITY => arr->Js.Json.array->getStrArryFromJson
  | _ => []
  }
}

let getRoutingPayload = (data, routingType, name, description, profileId) => {
  let connectorsOrder =
    [("data", data->Js.Json.array), ("type", routingType->Js.Json.string)]->Js.Dict.fromArray

  [
    ("name", name->Js.Json.string),
    ("description", description->Js.Json.string),
    ("profile_id", profileId->Js.Json.string),
    ("algorithm", connectorsOrder->Js.Json.object_),
  ]->Js.Dict.fromArray
}

let getWasmKeyType = (wasm, value) => {
  try {
    switch wasm {
    | Some(res) => res.getKeyType(value)
    | None => ""
    }
  } catch {
  | _ => ""
  }
}

let getWasmVariantValues = (wasm, value) => {
  try {
    switch wasm {
    | Some(res) => res.getVariantValues(value)
    | None => []
    }
  } catch {
  | _ => []
  }
}

let getWasmGateway = wasm => {
  try {
    switch wasm {
    | Some(res) => res.getAllConnectors()
    | None => []
    }
  } catch {
  | _ => []
  }
}

let advanceRoutingConditionMapper = (dict, wasm) => {
  let variantType = wasm->getWasmKeyType(dict->getString("field", ""))
  let obj = {
    lhs: dict->getString("field", ""),
    comparison: switch dict->getString("operator", "")->operatorMapper {
    | IS => "equal"
    | IS_NOT => "not_equal"
    | CONTAINS => "equal"
    | NOT_CONTAINS => "not_equal"
    | EQUAL_TO => "equal"
    | GREATER_THAN => "greater_than"
    | LESS_THAN => "less_than"
    | NOT_EQUAL_TO => "not_equal"
    | UnknownOperator(str) => str
    },
    value: {
      "type": switch variantType->variantTypeMapper {
      | Number => "number"
      | Enum_variant =>
        switch dict->getString("operator", "")->operatorMapper {
        | IS => "enum_variant"
        | CONTAINS => "enum_variant_array"
        | IS_NOT => "enum_variant"
        | NOT_CONTAINS => "enum_variant_array"
        | _ => ""
        }
      | Metadata_value => "metadata_variant"
      | String_value => "str_value"
      | _ => ""
      }->Js.Json.string,
      "value": switch variantType->variantTypeMapper {
      | Number => (dict->getString("value", "")->float_of_string *. 100.00)->Js.Json.number
      | Enum_variant =>
        switch dict->getString("operator", "")->operatorMapper {
        | IS => dict->getString("value", "")->Js.Json.string
        | CONTAINS => dict->getArrayFromDict("value", [])->Js.Json.array
        | IS_NOT => dict->getString("value", "")->Js.Json.string
        | NOT_CONTAINS => dict->getArrayFromDict("value", [])->Js.Json.array

        | _ => ""->Js.Json.string
        }
      | Metadata_value => {
          let key =
            dict->getDictfromDict("metadata")->getString("key", "")->Js.String2.trim->Js.Json.string
          let value = dict->getString("value", "")->Js.String2.trim->Js.Json.string
          Js.Dict.fromArray([("key", key), ("value", value)])->Js.Json.object_
        }
      | String_value => dict->getString("value", "")->Js.Json.string
      | _ => ""->Js.Json.string
      },
    },
    metadata: Js.Dict.empty()->Js.Json.object_,
  }
  let value = [("value", obj.value["value"]), ("type", obj.value["type"])]->Js.Dict.fromArray
  let dict =
    [
      ("lhs", obj.lhs->Js.Json.string),
      ("comparison", obj.comparison->Js.Json.string),
      ("value", value->Js.Json.object_),
      ("metadata", obj.metadata),
    ]->Js.Dict.fromArray

  dict->Js.Json.object_
}

let getVolumeSplit = (
  dict_arr,
  objMapper,
  connectorList: option<array<ConnectorTypes.connectorPayload>>,
) => {
  dict_arr->Array.reduce([], (acc, routingObj) => {
    let value = [routingObj->getDictFromJsonObject->objMapper(connectorList)->Js.Json.object_]
    acc->Js.Array2.concat(value)->Js.Array2.map(value => value)
  })
}

let checkIfValuePresesent = valueRes => {
  // to check if the value is present only then add to the statement
  let conditionMatched = switch Js.Json.classify(valueRes) {
  | JSONArray(arr) => arr->Js.Array2.length > 0
  | JSONString(str) => str->Js.String2.length > 0
  | JSONNumber(num) => num > Belt.Int.toFloat(0)
  | _ => false
  }
  conditionMatched
}

let generateStatement = (arr, wasm) => {
  let conditionDict = Js.Dict.empty()
  let statementDict = Js.Dict.empty()
  arr->Array.forEachWithIndex((item, index) => {
    let valueRes =
      item
      ->getDictFromJsonObject
      ->Js.Dict.get("value")
      ->Belt.Option.getWithDefault([]->Js.Json.array)

    if valueRes->checkIfValuePresesent {
      let value = item->getDictFromJsonObject->advanceRoutingConditionMapper(wasm)
      let logical = item->getDictFromJsonObject->getString("logical.operator", "")

      switch logical->logicalOperatorMapper {
      | OR => {
          let copyDict = Js.Dict.map((. val) => val, conditionDict)
          Js.Dict.set(statementDict, Belt.Int.toString(index), copyDict)
          conditionDict->Js.Dict.set("condition", []->Js.Json.array)
          let val =
            conditionDict->Js.Dict.get("condition")->Belt.Option.getWithDefault([]->Js.Json.array)
          let arr = switch Js.Json.classify(val) {
          | JSONArray(arr) => {
              arr->Array.push(value)
              arr
            }
          | _ => []
          }
          conditionDict->Js.Dict.set("condition", arr->Js.Json.array)
        }

      | _ =>
        let val =
          conditionDict->Js.Dict.get("condition")->Belt.Option.getWithDefault([]->Js.Json.array)
        let arr = switch Js.Json.classify(val) {
        | JSONArray(arr) => {
            arr->Array.push(value)
            arr
          }

        | _ => []
        }
        conditionDict->Js.Dict.set("condition", arr->Js.Json.array)
      }
    }
  })

  let copyDict = Js.Dict.map((. val) => val, conditionDict)
  Js.Dict.set(statementDict, Belt.Int.toString(arr->Js.Array2.length), copyDict)
  statementDict
  ->Js.Dict.keys
  ->Js.Array2.map(val => {
    switch statementDict->Js.Dict.get(val) {
    | Some(dt) => dt->Js.Json.object_
    | _ => Js.Dict.empty()->Js.Json.object_
    }
  })
}

let getDefaultSelection = dict => {
  [
    ("data", dict->getArrayFromDict("default_gateways", [])->Js.Json.array),
    ("type", "priority"->Js.Json.string),
  ]->Js.Dict.fromArray
}
let generateRuleObject = (index, connectorSelection, statement) => {
  let ruleObj = Js.Dict.fromArray([
    ("name", `rule_${string_of_int(index + 1)}`->Js.Json.string),
    ("statements", statement->Js.Json.array),
    ("connectorSelection", connectorSelection->Js.Json.object_),
  ])
  ruleObj
}
let constuctAlgorithm = (dict, rules, metadata) => {
  let body =
    [
      ("defaultSelection", getDefaultSelection(dict)->Js.Json.object_),
      ("rules", rules->Js.Json.array),
      ("metadata", metadata->Js.Json.object_),
    ]->Js.Dict.fromArray

  let algorithm =
    [("type", "advanced"->Js.Json.string), ("data", body->Js.Json.object_)]->Js.Dict.fromArray

  algorithm
}

let advanceRoutingPayload = (dict, wasm, metadata, name, description) => {
  let advancedRoutingPayload =
    [
      ("name", name->Js.Json.string),
      ("description", description->Js.Json.string),
    ]->Js.Dict.fromArray

  // data part of algorithm

  let rules = []
  let _payload =
    dict
    ->getArrayFromDict("rules", [])
    ->Array.reduceWithIndex([], (acc, priorityLogicObj, index) => {
      switch priorityLogicObj->Js.Json.decodeObject {
      | Some(priorityLogicObj) => {
          let isDistribute = getBool(priorityLogicObj, "isDistribute", false)

          let connectorSelection = if isDistribute {
            let connectorSelection = Js.Dict.empty()
            Js.Dict.set(connectorSelection, "type", "volume_split"->Js.Json.string)
            let gateway =
              priorityLogicObj
              ->getArrayFromDict("gateways", [])
              ->getVolumeSplit(itemBodyGateWayObjMapper, None)
            Js.Dict.set(connectorSelection, "data", gateway->Js.Json.array)
            connectorSelection
          } else {
            let connectorSelection = Js.Dict.empty()
            Js.Dict.set(connectorSelection, "type", "priority"->Js.Json.string)
            let gateway =
              priorityLogicObj
              ->getArrayFromDict("gateways", [])
              ->Js.Array2.map(dict =>
                dict->getDictFromJsonObject->getString("gateway_name", "")->Js.Json.string
              )
            Js.Dict.set(connectorSelection, "data", gateway->Js.Json.array)
            connectorSelection
          }

          let statement = generateStatement(
            priorityLogicObj->getArrayFromDict("conditions", []),
            wasm,
          )
          let ruleObj = generateRuleObject(index, connectorSelection, statement)

          rules->Array.push(ruleObj->Js.Json.object_)
        }

      | None => ()
      }
      acc
    })

  let algorithm = constuctAlgorithm(dict, rules, metadata)

  advancedRoutingPayload->Js.Dict.set("algorithm", algorithm->Js.Json.object_)

  advancedRoutingPayload
}

let getModalObj = (routingType, text) => {
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

let getContent = routetype =>
  switch routetype {
  | DEFAULTFALLBACK => {
      heading: "Default fallback ",
      subHeading: "Fallback is a priority order of all the configured processors which is used to route traffic standalone or when other routing rules are not applicable. You can reorder the list with simple drag and drop",
    }
  | PRIORITY => {
      heading: "Rank Based Configuration",
      subHeading: "Fallback is activated when the above routing conditions happen to be false.",
    }
  | VOLUME_SPLIT => {
      heading: "Volume Based Configuration",
      subHeading: "Route traffic across various processors by volume distribution",
    }
  | ADVANCED => {
      heading: "Rule Based Configuration",
      subHeading: "Route traffic across processors with advanced logic rules on the basis of various payment parameters",
    }
  | COST => {
      heading: "Cost Based Configuration",
      subHeading: "Helps you optimise your overall payment costs with a single click by leveraging the differential processing fees across various processors",
    }
  | _ => {
      heading: "",
      subHeading: "",
    }
  }

// Volume
let getGatewayTypes = (arr: array<Js.Json.t>, gatewayKey: string, distributionKey: string) => {
  let tempArr = arr->Js.Array2.map(value => {
    let val = value->getDictFromJsonObject
    let tempval = {
      distribution: val->getInt(distributionKey, 0),
      disableFallback: val->getBool("disableFallback", false),
      gateway_name: val->getString(gatewayKey, ""),
    }
    tempval
  })
  tempArr
}

// Advanced
let valueTypeMapper = dict => {
  let value = switch Js.Dict.get(dict, "value")->Belt.Option.map(Js.Json.classify) {
  | Some(JSONArray(arr)) => StringArray(arr->getStrArrayFromJsonArray)
  | Some(JSONString(st)) => String(st)
  | Some(JSONNumber(num)) => Int(num->Belt.Float.toInt)
  | _ => String("")
  }
  value
}

let conditionTypeMapper = (conditionArr: array<Js.Json.t>) => {
  let conditionArray = []
  conditionArr->Js.Array2.forEach(value => {
    let val = value->getDictFromJsonObject
    let tempval = {
      field: val->getString("field", ""),
      metadata: val->getDictfromDict("metadata")->Js.Json.object_,
      operator: val->getString("operator", "")->operatorMapper,
      value: val->valueTypeMapper,
      logicalOperator: val->getString("logical.operator", "")->logicalOperatorMapper,
    }
    conditionArray->Array.push(tempval)
  })
  conditionArray
}
let threeDsTypeMapper = dict => {
  let getRoutingOutputval = dict->getString("override_3ds", "three_ds")
  let val = {
    override_3ds: getRoutingOutputval,
  }
  val
}

let ruleInfoTypeMapper = json => {
  let arr = json->getDictFromJsonObject->getArrayFromDict("rules", [])
  let defaultGateways =
    json->getDictFromJsonObject->getArrayFromDict("default_gateways", [])->getStrArrayFromJsonArray
  let rulesArray = arr->Js.Array2.map(value => {
    let eachRule = {
      gateways: getGatewayTypes(
        value->getDictFromJsonObject->getArrayFromDict("gateways", []),
        "gateway_name",
        "distribution",
      ),
      conditions: conditionTypeMapper(
        value->getDictFromJsonObject->getArrayFromDict("conditions", []),
      ),
      routingOutput: threeDsTypeMapper(
        value->getDictFromJsonObject->getObj("routingOutput", Js.Dict.empty()),
      ),
    }
    eachRule
  })
  let ruleInfo = {
    rules: rulesArray,
    default_gateways: defaultGateways,
  }
  ruleInfo
}

let constructNameDescription = routingType => {
  let routingText = routingType->routingTypeName
  Js.Dict.fromArray([
    (
      "name",
      `${routingText->LogicUtils.capitalizeString} Based Routing-${getCurrentUTCTime()}`->Js.Json.string,
    ),
    (
      "description",
      `This is a ${routingText} based routing created at ${currentTimeInUTC}`->Js.Json.string,
    ),
  ])
}

let manipulateInitialValueJson = initialValueJson => {
  let manipulatedJson = ADVANCED->constructNameDescription
  manipulatedJson->Js.Dict.set("code", initialValueJson->getString("code", "")->Js.Json.string)
  manipulatedJson->Js.Dict.set(
    "json",
    initialValueJson->getObj("json", Js.Dict.empty())->Js.Json.object_,
  )
  manipulatedJson
}
let currentTabNameRecoilAtom = Recoil.atom(. "currentTabName", "ActiveTab")

module SaveAndActivateButton = {
  @react.component
  let make = (
    ~onSubmit: (Js.Json.t, 'a) => promise<Js.Nullable.t<Js.Json.t>>,
    ~handleActivateConfiguration,
  ) => {
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Js.Nullable.return,
    )

    let handleSaveAndActivate = async _ev => {
      try {
        let onSubmitResponse = await onSubmit(formState.values, false)
        let currentActivatedFromJson =
          onSubmitResponse->Js.Nullable.toOption->Belt.Option.getWithDefault(Js.Json.null)
        let currentActivatedId =
          currentActivatedFromJson->LogicUtils.getDictFromJsonObject->LogicUtils.getString("id", "")
        let _ = await handleActivateConfiguration(Some(currentActivatedId))
      } catch {
      | Js.Exn.Error(e) =>
        let _err =
          Js.Exn.message(e)->Belt.Option.getWithDefault(
            "Failed to save and activate configuration!",
          )
      }
    }
    <Button
      text={"Save and Activate Rule"}
      buttonType={Primary}
      buttonSize=Button.Small
      onClick={_ => {
        handleSaveAndActivate()->ignore
      }}
      customButtonStyle="w-1/5 rounded-sm"
    />
  }
}
module ConfigureRuleButton = {
  @react.component
  let make = (~setShowModal, ~isConfigButtonEnabled) => {
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Js.Nullable.return,
    )

    <Button
      text={"Configure Rule"}
      buttonType=Primary
      buttonState={!formState.hasValidationErrors && isConfigButtonEnabled ? Normal : Disabled}
      onClick={_ => {
        setShowModal(_ => true)
      }}
      customButtonStyle="w-1/5"
    />
  }
}

let validateNameAndDescription = (~dict, ~errors) => {
  ["name", "description"]->Js.Array2.forEach(field => {
    if dict->LogicUtils.getString(field, "")->Js.String2.trim === "" {
      errors->Js.Dict.set(field, `Please provide ${field} field`->Js.Json.string)
    }
  })
}

let checkIfValuePresent = dict => {
  let valueFromObject = dict->getDictfromDict("value")

  valueFromObject
  ->getArrayFromDict("value", [])
  ->Js.Array2.filter(ele => {
    ele != ""->Js.Json.string
  })
  ->Js.Array2.length > 0 ||
  valueFromObject->getString("value", "")->Js.String2.length > 0 ||
  valueFromObject->getFloat("value", -1.0) !== -1.0 ||
  (valueFromObject->getDictfromDict("value")->getString("key", "")->Js.String2.length > 0 &&
    valueFromObject->getDictfromDict("value")->getString("value", "")->Js.String2.length > 0)
}

let validateConditionJson = (json, keys) => {
  switch json->Js.Json.decodeObject {
  | Some(dict) =>
    keys->Js.Array2.every(key => dict->Js.Dict.get(key)->Belt.Option.isSome) &&
      dict->checkIfValuePresent
  | None => false
  }
}

let validateConditionsFor3ds = dict => {
  let conditionsArray = dict->LogicUtils.getArrayFromDict("statements", [])

  conditionsArray->Array.every(value => {
    value->validateConditionJson(["comparison", "lhs"])
  })
}

let filterEmptyValues = (arr: array<RoutingTypes.condition>) => {
  arr->Js.Array2.filter(item => {
    switch item.value {
    | StringArray(arr) => arr->Js.Array2.length > 0
    | String(str) => str->Js.String2.length > 0
    | Int(int) => int > 0
    }
  })
}

let getRecordsObject = json => {
  switch Js.Json.classify(json) {
  | JSONObject(jsonDict) => jsonDict->getArrayFromDict("records", [])
  | JSONArray(jsonArray) => jsonArray
  | _ => []
  }
}
