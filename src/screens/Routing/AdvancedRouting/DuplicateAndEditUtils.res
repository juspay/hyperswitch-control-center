let getIsDistributed = distributedType => distributedType === "volume_split"

let getConditionValue = (conditionArray, manipulatedStatementsArray, statementIndex) => {
  open LogicUtils

  let manipuatedConditionArray = conditionArray->Array.mapWithIndex((
    eachContent,
    conditionIndex,
  ) => {
    let conditionDict = eachContent->getDictFromJsonObject
    let valueType = conditionDict->getDictfromDict("value")->getString("type", "")

    let manipulatedConditionDict = conditionDict->Dict.copy

    manipulatedConditionDict->Dict.set(
      "comparison",
      conditionDict
      ->getString("comparison", "")
      ->AdvancedRoutingUtils.getOperatorFromComparisonType(valueType)
      ->JSON.Encode.string,
    )

    if statementIndex > 0 && conditionIndex == 0 {
      // If two sub-rules are joined using "OR" in the API call, they will appear as separate objects, one after another, in the 'statement' array.
      manipulatedConditionDict->Dict.set("logical", "OR"->JSON.Encode.string)
    } else if conditionIndex > 0 {
      // If two sub-rules are joined using "AND" in the API call, they will appear as separate objects, one after another, in the 'condition' array.
      manipulatedConditionDict->Dict.set("logical", "AND"->JSON.Encode.string)
    }

    manipulatedStatementsArray->Array.push(manipulatedConditionDict->JSON.Encode.object)
    manipulatedConditionDict->JSON.Encode.object
  })

  manipuatedConditionArray->JSON.Encode.array
}

let getStatementsArray = statementsArray => {
  open LogicUtils

  let manipulatedStatementsArrayCustom = []

  let _ = statementsArray->Array.mapWithIndex((eachStatement, statementIndex) => {
    let statementDict = eachStatement->getDictFromJsonObject

    let conditionValue =
      statementDict
      ->getArrayFromDict("condition", [])
      ->getConditionValue(manipulatedStatementsArrayCustom, statementIndex)

    conditionValue
  })

  manipulatedStatementsArrayCustom->JSON.Encode.array
}

let getRulesValue = rulesArray => {
  open LogicUtils
  let manipulatedRulesArray = rulesArray->Array.map(eachRule => {
    let eachRuleDict = eachRule->getDictFromJsonObject
    let rulesDict = eachRuleDict->Dict.copy

    rulesDict->Dict.set(
      "statements",
      eachRuleDict->getArrayFromDict("statements", [])->getStatementsArray,
    )

    let isDistributed =
      rulesDict
      ->getObj("connectorSelection", Dict.make())
      ->getString("type", "priority")
      ->getIsDistributed

    rulesDict->Dict.set("isDistribute", isDistributed->JSON.Encode.bool)

    rulesDict->JSON.Encode.object
  })

  manipulatedRulesArray->JSON.Encode.array
}

let dataMapper = dataDict => {
  open LogicUtils
  let manipuledDataDict = dataDict->Dict.copy
  manipuledDataDict->Dict.set("rules", dataDict->getArrayFromDict("rules", [])->getRulesValue)

  manipuledDataDict->JSON.Encode.object
}

let getAlgo = algoDict => {
  open LogicUtils

  let manipulatedAlgoDIct = algoDict->Dict.copy
  manipulatedAlgoDIct->Dict.set("data", algoDict->getObj("data", Dict.make())->dataMapper)

  manipulatedAlgoDIct->JSON.Encode.object
}

let manipulateInitialValuesForDuplicate = json => {
  open LogicUtils

  let previewDict = json->getDictFromJsonObject
  let finalJson = previewDict->Dict.copy

  finalJson->Dict.set("algorithm", previewDict->getObj("algorithm", Dict.make())->getAlgo)

  finalJson->JSON.Encode.object
}
