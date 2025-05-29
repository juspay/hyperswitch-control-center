type pageState = NEW | LANDING

let statementObject: array<RoutingTypes.statement> = [
  {
    lhs: "amount",
    value: {
      \"type": "number",
      value: ""->JSON.Encode.string,
    },
    comparison: "EQUAL TO",
  },
  {
    logical: "AND",
    value: {
      \"type": "number",
      value: ""->JSON.Encode.string,
    },
    lhs: "currency",
    comparison: "IS",
  },
]

type threeDsRoutingType = {
  name: string,
  description: string,
  algorithm: RoutingTypes.algorithmData,
}

let rules: RoutingTypes.rule = {
  name: "rule_1",
  connectorSelection: {
    decision: "three_ds",
  },
  statements: statementObject,
}

let buildInitial3DSValue: threeDsRoutingType = {
  name: `3DS Rule-${RoutingUtils.getCurrentUTCTime()}`,
  description: `This is a Three-Ds Rule created at ${RoutingUtils.currentTimeInUTC}`,
  algorithm: {
    rules: [rules],
    defaultSelection: {
      decision: "",
    },
    metadata: JSON.Encode.null,
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

  let modifiedRules = rulesDict->AdvancedRoutingUtils.generateRule(~isFrom3dsIntelligence=true)

  let threeDsPayload = {
    "name": valuesDict->getString("name", ""),
    "profile_id": valuesDict->getString("profile_id", ""),
    "description": valuesDict->getString("description", ""),
    "transaction_type": "three_ds_authentication",
    "algorithm": {
      "type": "three_ds_decision_rule",
      "data": {
        "defaultSelection": {
          "decision": "no_three_ds",
        },
        "rules": modifiedRules,
        "metadata": Dict.make()->JSON.Encode.object,
      },
    },
  }

  threeDsPayload
}
