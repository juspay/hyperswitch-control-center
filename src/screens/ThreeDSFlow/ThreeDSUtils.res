type pageState = NEW | LANDING
open RoutingTypes

let getPageConfigs = isFrom3DsIntelligence =>
  if isFrom3DsIntelligence {
    {
      isFrom3DsIntelligence: true,
      pageTitle: "3DS Exemption Rules",
      pageSubtitle: "Optimize  3DS strategy by correctly applying 3DS exemptions to offer a seamless experience to the users while balancing fraud",
      configureTitle: "Configure 3DS Exemption Rules",
      configureDescription: "Configure advanced rules on parameters like amount, currency, and method to automatically apply 3DS exemptions, balancing regulatory compliance with seamless user experience.",
      baseUrl: "/3ds-exemption",
      newUrl: "/3ds-exemption?type=new",
      entityName: V1(THREE_DS_EXEMPTION_RULES),
      mixpanelEvent: "create_new_3ds_rule",
    }
  } else {
    {
      isFrom3DsIntelligence: false,
      pageTitle: "3DS Decision Manager",
      pageSubtitle: "Make your payments more secure by enforcing 3DS authentication through custom rules defined on payment parameters",
      configureTitle: "Configure 3DS Rule",
      configureDescription: "Create advanced rules using various payment parameters like amount, currency,payment method etc to enforce 3DS authentication for specific payments to reduce fraudulent transactions",
      baseUrl: "/3ds",
      newUrl: "/3ds?type=new",
      entityName: V1(THREE_DS),
      mixpanelEvent: "create_new_3ds_rule",
    }
  }

let statementObject: array<statement> = [
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
  algorithm: algorithmData,
}

let rules: rule = {
  name: "rule_1",
  connectorSelection: {
    override_3ds: "three_ds",
  },
  statements: statementObject,
}

let rulesForIntelligence: rule = {
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
      override_3ds: "",
    },
    metadata: JSON.Encode.null,
  },
}

let buildInitial3DSValueForIntelligence: threeDsRoutingType = {
  name: `3DS Rule-${RoutingUtils.getCurrentUTCTime()}`,
  description: `This is a Three-Ds Rule created at ${RoutingUtils.currentTimeInUTC}`,
  algorithm: {
    rules: [rulesForIntelligence],
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

let buildThreeDsPayloadBody = (~isFrom3DsIntelligence=false, values) => {
  open LogicUtils

  let valuesDict = values->getDictFromJsonObject
  let dataDict = valuesDict->getDictfromDict("algorithm")
  let rulesDict = dataDict->getArrayFromDict("rules", [])

  let modifiedRules = rulesDict->AdvancedRoutingUtils.generateRule(~isFrom3DsIntelligence)

  if isFrom3DsIntelligence {
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
  } else {
    {
      "name": valuesDict->getString("name", ""),
      "algorithm": {
        "defaultSelection": {
          "override_3ds": JSON.Encode.null,
        },
        "rules": modifiedRules,
        "metadata": Dict.make()->JSON.Encode.object,
      },
    }->Identity.genericTypeToJson
  }
}
