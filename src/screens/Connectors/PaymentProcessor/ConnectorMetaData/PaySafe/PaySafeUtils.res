open LogicUtils
let payConnectorValidation = (~values) => {
  let error = Dict.make()
  if (
    values
    ->getDictFromJsonObject
    ->getDictfromDict("metadata")
    ->getDictfromDict("account_id")
    ->isEmptyDict
  ) {
    Dict.set(error, "account_id", `Please select at least one country`->JSON.Encode.string)
  }
  error
}
