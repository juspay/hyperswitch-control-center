open LogicUtils
open PixAutomaticoPushIntegrationTypes

let pixAutomaticoPushRequestToDictMapper = dict => {
  {
    client_id: dict->getString("client_id", ""),
    client_secret: dict->getString("client_secret", ""),
    account_number: dict->getString("account_number", ""),
    account_type: dict->getString("account_type", ""),
    branch_code: dict->getString("branch_code", ""),
  }
}

let pixAutomaticoPushNameMapper = (~name) => {
  `metadata.pix_automatico_push.${name}`
}

let pixAutomaticoPushFieldInput = (
  ~pixAutomaticoPushField: CommonConnectorTypes.inputField,
  ~fill,
) => {
  open CommonConnectorHelper
  let {\"type", name} = pixAutomaticoPushField
  let formName = pixAutomaticoPushNameMapper(~name)

  {
    switch \"type" {
    | Text => textInput(~field={pixAutomaticoPushField}, ~formName)
    | Select => selectInput(~field={pixAutomaticoPushField}, ~formName)
    | MultiSelect => multiSelectInput(~field={pixAutomaticoPushField}, ~formName)
    | Radio => radioInput(~field={pixAutomaticoPushField}, ~formName, ~fill, ())
    | _ => textInput(~field={pixAutomaticoPushField}, ~formName)
    }
  }
}

let validatePixAutomaticoPushFields = (json: JSON.t) => {
  let fields =
    json
    ->getDictFromJsonObject
    ->getDictFromNestedDict("metadata", "pix_automatico_push")
    ->pixAutomaticoPushRequestToDictMapper

  fields.client_id->isNonEmptyString &&
  fields.client_secret->isNonEmptyString &&
  fields.account_number->isNonEmptyString &&
  fields.branch_code->isNonEmptyString
    ? Button.Normal
    : Button.Disabled
}
