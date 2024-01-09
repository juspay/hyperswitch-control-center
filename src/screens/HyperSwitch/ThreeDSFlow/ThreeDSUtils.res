type pageState = NEW | LANDING

let statementObject: array<AdvancedRoutingTypes.statement> = [
  {
    lhs: "amount",
    value: {
      \"type": "number",
      value: ""->Js.Json.string,
    },
    comparison: "EQUAL TO",
  },
  {
    logical: "AND",
    value: {
      \"type": "number",
      value: ""->Js.Json.string,
    },
    lhs: "currency",
    comparison: "IS",
  },
]

type threeDsRoutingType = {
  name: string,
  description: string,
  algorithm: AdvancedRoutingTypes.algorithmData,
}

let rules: AdvancedRoutingTypes.rule = {
  name: "rule_1",
  connectorSelection: {
    override_3ds: "three_ds",
  },
  statements: statementObject,
}

let buildInitial3DSValue: threeDsRoutingType = {
  name: `3DS Rule-${RoutingUtils.getCurrentUTCTime()}`,
  description: `This is a Three-Ds Rule created at ${RoutingUtils.currentTimeInUTC}`,
  algorithm: {
    rules: [rules],
    defaultSelection: {
      override_3ds: "",
    },
    metadata: Js.Json.null,
  },
}

let pageStateMapper = pageType => {
  switch pageType {
  | "new" => NEW
  | _ => LANDING
  }
}

let buildThreeDsPayloadBody = values => {
  open LogicUtils

  let valuesDict = values->getDictFromJsonObject
  let dataDict = valuesDict->getDictfromDict("algorithm")
  let rulesDict = dataDict->getArrayFromDict("rules", [])

  let modifiedRules = rulesDict->AdvancedRoutingUtils.generateRule

  let threeDsPayload = {
    "name": valuesDict->getString("name", ""),
    "algorithm": {
      "defaultSelection": {
        "override_3ds": null,
      },
      "rules": modifiedRules,
      "metadata": Dict.make()->Js.Json.object_,
    },
  }

  threeDsPayload
}
