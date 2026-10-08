open LogicUtils
let payoutConnectorValidation = (~values, ~connectorMetaDataFields) => {
  let errors = Dict.make()
  let flattenedValues = values->JsonFlattenUtils.flattenObject(true)
  connectorMetaDataFields
  ->getDictfromDict("account_id")
  ->getDictfromDict("pay_safe_card")
  ->JSON.Encode.object
  ->convertMapObjectToDict
  ->Dict.keysToArray
  ->Array.forEach(currency => {
    let key = `metadata.account_id.pay_safe_card.${currency}.three_ds`
    if flattenedValues->getString(key, "")->isEmptyString {
      Dict.set(errors, key, `Please enter ${currency} Account ID`->JSON.Encode.string)
    }
  })
  errors
}

let payConnectorValidation = (~values) => {
  let error = Dict.make()
  if (
    values
    ->getDictFromJsonObject
    ->getDictfromDict("metadata")
    ->getDictfromDict("account_id")
    ->isEmptyDict
  ) {
    Dict.set(error, "account_id", `Please select at least one currency`->JSON.Encode.string)
  }
  error
}
