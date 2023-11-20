external toJson: 'a => array<Js.Json.t> = "%identity"
type conditonType = {
  \"logical.operator"?: string,
  field: string,
  real_field: string,
  operator: string,
  value: string,
}

type pageState = NEW | LANDING
open RoutingUtils

let conditions: array<conditonType> = [
  {
    field: "amount",
    real_field: "amount",
    operator: "EQUAL TO",
    value: "",
  },
  {
    \"logical.operator": "AND",
    field: "currency",
    real_field: "currency",
    operator: "IS",
    value: "",
  },
]

let constructNameDescription =
  [
    ("name", `3DS Rule-${getCurrentUTCTime()}`->Js.Json.string),
    ("description", `This is a Three-Ds Rule created at ${currentTimeInUTC}`->Js.Json.string),
  ]->Js.Dict.fromArray

let buildInitial3DSValue = {
  let routingValueOutput = [("override_3ds", "three_ds"->Js.Json.string)]->Js.Dict.fromArray
  let defaultValue =
    [
      ("gateways", []->Js.Json.array),
      ("conditions", conditions->toJson->Js.Json.array),
      ("routingOutput", routingValueOutput->Js.Json.object_),
    ]->Js.Dict.fromArray

  let initialJson = [("rules", [defaultValue->Js.Json.object_]->Js.Json.array)]->Js.Dict.fromArray

  let initialValueJson = constructNameDescription

  initialValueJson->Js.Dict.set("json", initialJson->Js.Json.object_)
  initialValueJson->Js.Dict.set("code", ""->Js.Json.string)

  // initialValueJson->Js.Dict.set("routingOutput", routingValueOutput->Js.Json.object_)
  initialValueJson
}

let pageStateMapper = pageType => {
  switch pageType {
  | "new" => NEW
  | _ => LANDING
  }
}

let generateRule = (index, statement, ~threeDsValue, ()) => {
  let ruleObj = Js.Dict.fromArray([
    ("name", `rule_${string_of_int(index + 1)}`->Js.Json.string),
    ("statements", statement->Js.Json.array),
  ])
  ruleObj->Js.Dict.set("routingOutput", threeDsValue->Js.Json.object_)
  ruleObj
}
let constuctAlgorithmValue = (rules, metadata) => {
  let defaultSelection = [("override_3ds", Js.Json.null)]->Js.Dict.fromArray

  let algorithm =
    [
      ("defaultSelection", defaultSelection->Js.Json.object_),
      ("rules", rules->Js.Json.array),
      ("metadata", metadata->Js.Json.object_),
    ]->Js.Dict.fromArray

  algorithm
}

let buildThreeDsPayloadBody = (dict, wasm, metadata, name) => {
  open LogicUtils
  let threeDsPayload = [("name", name->Js.Json.string)]->Js.Dict.fromArray

  let rules = []

  let _payload =
    dict
    ->getArrayFromDict("rules", [])
    ->Array.reduceWithIndex([], (acc, priorityLogicObj, index) => {
      switch priorityLogicObj->Js.Json.decodeObject {
      | Some(priorityLogicObj) => {
          let statement = generateStatement(
            priorityLogicObj->getArrayFromDict("conditions", []),
            wasm,
          )
          let threeDsValue = priorityLogicObj->getObj("routingOutput", Js.Dict.empty())

          let ruleObj = generateRule(index, statement, ~threeDsValue, ())

          rules->Array.push(ruleObj->Js.Json.object_)
        }

      | None => ()
      }
      acc
    })

  let algorithm = constuctAlgorithmValue(rules, metadata)

  threeDsPayload->Js.Dict.set("algorithm", algorithm->Js.Json.object_)

  threeDsPayload
}
