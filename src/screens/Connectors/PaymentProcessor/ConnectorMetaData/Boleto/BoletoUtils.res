open LogicUtils
open BoletoIntegrationTypes

let boletorequestToDictMapper = dict => {
  {
    client_id: dict->getString("client_id", ""),
    client_secret: dict->getString("client_secret", ""),
    workspace_id: dict->getString("workspace_id", ""),
    covenant_code: dict->getString("covenant_code", ""),
    pix_key_value: dict->getString("pix_key_value", ""),
    pix_key_type: dict->getString("pix_key_type", ""),
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
  let {client_id, client_secret, workspace_id, covenant_code, _} =
    json
    ->getDictFromJsonObject
    ->getDictfromDict("metadata")
    ->getDictfromDict("boleto")
    ->boletorequestToDictMapper

  let isClientIdValid = client_id->isNonEmptyString
  let isClientSecretValid = client_secret->isNonEmptyString
  let isWorkspaceIdValid = workspace_id->isNonEmptyString
  let isCovenantCodeValid = covenant_code->isNonEmptyString

  isClientIdValid && isClientSecretValid && isWorkspaceIdValid && isCovenantCodeValid
    ? Button.Normal
    : Button.Disabled
}
