open ThreeDSUtils

let defaultSurcharge: RoutingTypes.surchargeDetailsType = {
  surcharge: {
    \"type": "rate",
    value: {
      percentage: 0.0,
    },
  },
  tax_on_surcharge: {
    percentage: 0.0,
  },
}

let surchargeRules: RoutingTypes.rule = {
  name: "rule_1",
  connectorSelection: {
    surcharge_details: defaultSurcharge->Nullable.make,
  },
  statements: statementObject,
}

let buildInitialSurchargeValue = (~currentDate, ~currentTime): threeDsRoutingType => {
  name: `Surcharge -${currentDate}`,
  description: `This is a new Surcharge created at ${currentTime}`,
  algorithm: {
    rules: [surchargeRules],
    defaultSelection: {
      surcharge_details: Nullable.null,
    },
    metadata: JSON.Encode.null,
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
      "metadata": Dict.make()->JSON.Encode.object,
    },
    "merchant_surcharge_configs": {
      "show_surcharge_breakup_screen": true,
    },
  }
}

let getTypedSurchargeConnectorSelection = ruleDict => {
  open LogicUtils
  let connectorsDict = ruleDict->getDictfromDict("connectorSelection")

  AdvancedRoutingUtils.getDefaultSelection(connectorsDict)
}

let ruleInfoTypeMapper: Dict.t<JSON.t> => RoutingTypes.algorithmData = json => {
  open LogicUtils
  let rulesArray = json->getArrayFromDict("rules", [])

  let defaultSelection = json->getDictfromDict("defaultSelection")

  let rulesModifiedArray = rulesArray->Array.map(rule => {
    let ruleDict = rule->getDictFromJsonObject

    let connectorSelection = getTypedSurchargeConnectorSelection(ruleDict)
    let ruleName = ruleDict->getString("name", "")

    let eachRule: RoutingTypes.rule = {
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
  surchargeType->Option.getOr(Nullable.null)->LogicUtils.getValFromNullableValue(defaultSurcharge)
}

let validateSurchargeRate = ruleDict => {
  let connectorSelection = ruleDict->getTypedSurchargeConnectorSelection

  let surchargeType = getDefaultSurchargeType(connectorSelection.surcharge_details)
  let surchargeValuePercent = surchargeType.surcharge.value.percentage->Option.getOr(0.0)
  let surchargeValueAmount = surchargeType.surcharge.value.amount->Option.getOr(0.0)
  let isSurchargeAmountValid = if surchargeType.surcharge.\"type" == "rate" {
    surchargeValuePercent == 0.0 || surchargeValuePercent > 100.0
  } else {
    surchargeValueAmount == 0.0
  }

  !isSurchargeAmountValid
}

let validateConditionsForSurcharge = dict => {
  let conditionsArray = dict->LogicUtils.getArrayFromDict("statements", [])

  conditionsArray->Array.every(value => {
    value->RoutingUtils.validateConditionJson(["comparison", "lhs"])
  }) && validateSurchargeRate(dict)
}

open AdvancedRoutingUtils
let connectorSelectionMapper = dict => {
  open RoutingTypes
  open LogicUtils

  let surchargeDetails = dict->getDictfromDict("surcharge_details")
  let surcharge = surchargeDetails->getDictfromDict("surcharge")
  let taxOnSurcharge = surchargeDetails->getDictfromDict("tax_on_surcharge")
  let connectorSelectionData = {
    surcharge_details: {
      surcharge: {
        \"type": surcharge->getString("type", ""),
        value: {
          percentage: surcharge->getDictfromDict("value")->getFloat("percentage", 0.0),
          amount: surcharge->getDictfromDict("value")->getFloat("amount", 0.0),
        },
      },
      tax_on_surcharge: {
        percentage: taxOnSurcharge->getFloat("percentage", 0.0),
      },
    }->Nullable.make,
  }
  connectorSelectionData
}

let conditionTypeMapper = (statementArr: array<JSON.t>) => {
  open LogicUtils
  let statements = statementArr->Array.reduce([], (acc, statementJson) => {
    let conditionArray = statementJson->getDictFromJsonObject->getArrayFromDict("condition", [])

    let arr = conditionArray->Array.mapWithIndex((conditionJson, index) => {
      let statementDict = conditionJson->getDictFromJsonObject

      let variantType = getStatementValue(statementDict->getDictfromDict("value")).\"type"
      let comparision =
        statementDict
        ->getString("comparison", "")
        ->getOperatorFromComparisonType(variantType)

      let returnValue: RoutingTypes.statement = {
        lhs: statementDict->getString("lhs", ""),
        comparison: comparision,
        logical: index === 0 ? "OR" : "AND",
        value: getStatementValue(statementDict->getDictfromDict("value")),
      }
      returnValue
    })
    acc->Array.concat(arr)
  })

  statements
}

let mapResponseToFormValues = response => {
  open LogicUtils
  let surchargeConfig = response
  let name = surchargeConfig->getString("name", "")
  let algorithm = surchargeConfig->getDictfromDict("algorithm")

  let rules = algorithm->getArrayFromDict("rules", [])

  let defaultSelection = algorithm->getDictfromDict("defaultSelection")

  let metadata = algorithm->getJsonObjectFromDict("metadata")

  let rulesData = rules->Array.map(rule => {
    let ruleDict = rule->getDictFromJsonObject
    let connectorSelection = ruleDict->getDictfromDict("connectorSelection")
    let ruleName = ruleDict->getString("name", "")
    let statements = ruleDict->getArrayFromDict("statements", [])

    let eachRule: RoutingTypes.rule = {
      name: ruleName,
      connectorSelection: connectorSelection->connectorSelectionMapper,
      statements: conditionTypeMapper(statements),
    }
    eachRule
  })

  let formValues: RoutingTypes.advancedRoutingType = {
    name,
    description: "",
    algorithm: {
      defaultSelection: getDefaultSelection(defaultSelection),
      rules: rulesData,
      metadata,
    },
  }
  formValues
}
