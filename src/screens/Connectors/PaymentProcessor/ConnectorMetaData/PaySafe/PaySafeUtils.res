open LogicUtils
let payoutConnectorValidation = (~values, ~connectorMetaDataFields) => {
  let errors = Dict.make()
  let flattenedValues = values->JsonFlattenUtils.flattenObject(true)
  let currencies =
    connectorMetaDataFields
    ->getDictfromDict("account_id")
    ->getDictfromDict("pay_safe_card")
    ->JSON.Encode.object
    ->convertMapObjectToDict
    ->Dict.keysToArray
  let hasAccountId = currencies->Array.some(currency => {
    let key = `metadata.account_id.pay_safe_card.${currency}.three_ds`
    flattenedValues->getString(key, "")->String.trim->isNonEmptyString
  })
  if !hasAccountId {
    currencies->Array.sort((a, b) => String.compare(a, b))
    currencies
    ->Array.get(0)
    ->Option.forEach(currency => {
      Dict.set(
        errors,
        `metadata.account_id.pay_safe_card.${currency}.three_ds`,
        "Please enter at least one currency Account ID"->JSON.Encode.string,
      )
    })
  }
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
