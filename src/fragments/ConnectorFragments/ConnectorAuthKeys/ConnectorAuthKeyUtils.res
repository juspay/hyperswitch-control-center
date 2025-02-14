let validateRequiredFiled = (valuesFlattenJson, dict, fieldName, errors) => {
  open LogicUtils
  let newDict = getDictFromJsonObject(errors)
  dict
  ->Dict.keysToArray
  ->Array.forEach(_value => {
    let lastItem = fieldName->String.split(".")->Array.pop->Option.getOr("")
    let errorKey = dict->getString(lastItem, "")
    let value = valuesFlattenJson->getString(`${fieldName}`, "")
    if value->String.length === 0 {
      Dict.set(newDict, fieldName, `Please enter ${errorKey}`->JSON.Encode.string)
    }
  })
  newDict->JSON.Encode.object
}

let validate = (
  ~selectedConnector: ConnectorTypes.integrationFields,
  ~dict,
  ~fieldName,
  ~isLiveMode,
) => values => {
  let errors = Dict.make()
  let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)
  let labelArr = dict->Dict.valuesToArray
  selectedConnector.validate
  ->Option.getOr([])
  ->Array.forEachWithIndex((field, index) => {
    let key = field.name
    let value =
      valuesFlattenJson
      ->Dict.get(key)
      ->Option.getOr(""->JSON.Encode.string)
      ->LogicUtils.getStringFromJson("")
    let regexToUse = isLiveMode ? field.liveValidationRegex : field.testValidationRegex
    let validationResult = switch regexToUse {
    | Some(regex) => regex->RegExp.fromString->RegExp.test(value)
    | None => true
    }
    if field.isRequired->Option.getOr(true) && value->String.length === 0 {
      let errorLabel =
        labelArr
        ->Array.get(index)
        ->Option.getOr(""->JSON.Encode.string)
        ->LogicUtils.getStringFromJson("")
      Dict.set(errors, key, `Please enter ${errorLabel}`->JSON.Encode.string)
    } else if !validationResult && value->String.length !== 0 {
      let expectedFormat = isLiveMode ? field.liveExpectedFormat : field.testExpectedFormat
      let warningMessage = expectedFormat->Option.getOr("")
      Dict.set(errors, key, warningMessage->JSON.Encode.string)
    }
  })

  let profileId = valuesFlattenJson->LogicUtils.getString("profile_id", "")
  if profileId->String.length === 0 {
    Dict.set(errors, "Profile Id", `Please select your business profile`->JSON.Encode.string)
  }
  validateRequiredFiled(valuesFlattenJson, dict, fieldName, errors->JSON.Encode.object)
}
