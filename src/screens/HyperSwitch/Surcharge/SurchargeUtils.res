open ThreeDSUtils
open AdvancedRoutingTypes

let surchargeRules: AdvancedRoutingTypes.rule = {
  name: "rule_1",
  connectorSelection: {
    surcharge_details: {
      surcharge: {
        \"type": "rate",
        value: {
          percentage: 10.0,
        },
      },
      tax_on_surcharge: {
        percentage: 10.0,
      },
    }->Js.Nullable.return,
  },
  statements: statementObject,
}

let buildInitialSurchargeValue: threeDsRoutingType = {
  name: `Surcharge -${RoutingUtils.getCurrentUTCTime()}`,
  description: `This is a new Surcharge created at ${RoutingUtils.currentTimeInUTC}`,
  algorithm: {
    rules: [surchargeRules],
    defaultSelection: {
      surcharge_details: Js.Nullable.null,
    },
    metadata: Js.Json.null,
  },
}

let buildSurchargePayloadBody = values => {
  open LogicUtils
  let valuesDict = values->getDictFromJsonObject
  let algorithmDict = valuesDict->getDictfromDict("algorithm")
  let rulesDict = algorithmDict->getArrayFromDict("rules", [])

  let modifiedRules = rulesDict->AdvancedRoutingUtils.generateRule
  {
    "name": valuesDict->getString("name", ""),
    "algorithm": {
      "defaultSelection": algorithmDict->getJsonObjectFromDict("defaultSelection"),
      "rules": modifiedRules,
      "metadata": Js.Dict.empty()->Js.Json.object_,
    },
  }
}
