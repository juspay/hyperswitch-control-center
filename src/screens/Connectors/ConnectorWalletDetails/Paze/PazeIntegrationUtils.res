open PazeIntegrationTypes
open LogicUtils

let pazePayRequest = dict => {
  client_id: dict->getString("client_id", ""),
  client_name: dict->getString("client_name", ""),
  client_profile_id: dict->getString("client_profile_id", ""),
}

let pazeNameMapper = (~name) => {
  `connector_wallets_details.paze.${name}`
}

let pazeValueInput = (~pazeField: CommonConnectorTypes.inputField) => {
  open CommonConnectorHelper
  let {\"type", name} = pazeField
  let formName = pazeNameMapper(~name)

  {
    switch \"type" {
    | Text => textInput(~field={pazeField}, ~formName)
    | Select => selectInput(~field={pazeField}, ~formName)
    | MultiSelect => multiSelectInput(~field={pazeField}, ~formName)
    | Radio => radioInput(~field={pazeField}, ~formName, ())
    | _ => textInput(~field={pazeField}, ~formName)
    }
  }
}

let validatePaze = (json: JSON.t) => {
  let {client_id, client_name, client_profile_id} =
    getDictFromJsonObject(json)
    ->getDictfromDict("connector_wallets_details")
    ->getDictfromDict("paze")
    ->pazePayRequest
  client_id->isNonEmptyString &&
  client_name->isNonEmptyString &&
  client_profile_id->isNonEmptyString
    ? Button.Normal
    : Button.Disabled
}
