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
<<<<<<< HEAD
    Dict.set(error, "account_id", `Please select at least one currency`->JSON.Encode.string)
=======
    Dict.set(error, "account_id", `Please select at least one country`->JSON.Encode.string)
>>>>>>> 4bda21a5 (feat: capture paysafe metadata config (#3620))
  }
  error
}
