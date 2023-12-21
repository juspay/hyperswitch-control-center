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
    "merchant_surcharge_configs": {
      "show_surcharge_breakup_screen": true,
    },
  }
}

let ruleInfoTypeMapper: Js.Dict.t<Js.Json.t> => AdvancedRoutingTypes.algorithmData = json => {
  open LogicUtils
  let rulesArray = json->getArrayFromDict("rules", [])

  let defaultSelection = json->getDictfromDict("defaultSelection")

  let rulesModifiedArray = rulesArray->Js.Array2.map(rule => {
    let ruleDict = rule->getDictFromJsonObject
    let connectorsDict = ruleDict->getDictfromDict("connectorSelection")

    let connectorSelection = AdvancedRoutingUtils.getDefaultSelection(connectorsDict)
    let ruleName = ruleDict->getString("name", "")

    let eachRule: AdvancedRoutingTypes.rule = {
      name: ruleName,
      connectorSelection,
      statements: AdvancedRoutingUtils.conditionTypeMapper(
        ruleDict->getArrayFromDict("statements", []),
      ),
    }
    eachRule
  })

  {
    rules: rulesModifiedArray,
    defaultSelection: AdvancedRoutingUtils.getDefaultSelection(defaultSelection),
    metadata: json->getJsonObjectFromDict("metadata"),
  }
}

let getDefaultSurchargeType = surchargeType => {
  surchargeType
  ->Option.getWithDefault(Js.Nullable.null)
  ->Js.Nullable.toOption
  ->Option.getWithDefault({
    surcharge: {
      \"type": "rate",
      value: {
        percentage: 0.0,
      },
    },
    tax_on_surcharge: {
      percentage: 0.0,
    },
  })
}
