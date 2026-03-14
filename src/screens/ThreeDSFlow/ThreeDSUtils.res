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
    override_3ds: "three_ds",
  },
  statements: statementObject,
}

let getInitial3DSValue = (~currentDate, ~currentTime): threeDsRoutingType => {
  name: `3DS Rule-${currentDate}`,
  description: `This is a Three-Ds Rule created at ${currentTime}`,
  algorithm: {
    rules: [rules],
    defaultSelection: {
      override_3ds: "",
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

  let modifiedRules = rulesDict->AdvancedRoutingUtils.generateRule

  let threeDsPayload = {
    "name": valuesDict->getString("name", ""),
    "algorithm": {
      "defaultSelection": {
        "override_3ds": null,
      },
      "rules": modifiedRules,
      "metadata": Dict.make()->JSON.Encode.object,
    },
  }

  threeDsPayload
}
