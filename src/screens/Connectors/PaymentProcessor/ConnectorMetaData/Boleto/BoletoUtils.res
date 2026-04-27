open LogicUtils
open BoletoIntegrationTypes

let boletorequestToDictMapper = dict => {
  {
    client_id: dict->getString("client_id", ""),
    client_secret: dict->getString("client_secret", ""),
    workspace_id: dict->getString("workspace_id", ""),
    covenant_code: dict->getString("covenant_code", ""),
  }
}

let boletoNameMapper = (~name) => {
  `metadata.boleto.${name}`
}

let boletoValueInput = (~boletoField: CommonConnectorTypes.inputField, ~fill) => {
  open CommonConnectorHelper
  let {\"type", name} = boletoField
  let formName = boletoNameMapper(~name)

  {
    switch \"type" {
    | Text => textInput(~field={boletoField}, ~formName)
    | Select => selectInput(~field={boletoField}, ~formName)
    | MultiSelect => multiSelectInput(~field={boletoField}, ~formName)
    | Radio => radioInput(~field={boletoField}, ~formName, ~fill, ())
    | _ => textInput(~field={boletoField}, ~formName)
    }
  }
}

let validateBoletoFields = (json: JSON.t) => {
  let boletoFields =
    json
    ->getDictFromJsonObject
    ->getDictFromNestedDict("metadata", "boleto")
    ->boletorequestToDictMapper

  boletoFields.client_id->isNonEmptyString &&
  boletoFields.client_secret->isNonEmptyString &&
  boletoFields.workspace_id->isNonEmptyString &&
  boletoFields.covenant_code->isNonEmptyString
    ? Button.Normal
    : Button.Disabled
}
