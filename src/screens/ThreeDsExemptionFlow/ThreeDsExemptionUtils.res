open RoutingTypes

let rules: rule = {
  name: "rule_1",
  connectorSelection: {
    decision: "three_ds",
  },
  statements: ThreeDSUtils.statementObject,
}

let getInitial3DSValueFor3DsExemptions = (
  ~currentDate,
  ~currentTime,
): ThreeDSUtils.threeDsRoutingType => {
  name: `3DS Rule-${currentDate}`,
  description: `This is a Three-Ds Rule created at ${currentTime}`,
  algorithm: {
    rules: [rules],
    defaultSelection: {
      decision: "",
    },
    metadata: JSON.Encode.null,
  },
}

let buildThreeDsExemptionPayloadBody = values => {
  open LogicUtils

  let valuesDict = values->getDictFromJsonObject
  let dataDict = valuesDict->getDictfromDict("algorithm")
  let rulesDict = dataDict->getArrayFromDict("rules", [])

  let modifiedRules = rulesDict->AdvancedRoutingUtils.generateRuleForThreeDsExemption

  {
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
  }->Identity.genericTypeToJson
}
