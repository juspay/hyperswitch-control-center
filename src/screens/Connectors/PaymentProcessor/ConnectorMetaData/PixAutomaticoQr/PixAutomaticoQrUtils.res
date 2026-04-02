open LogicUtils
open PixAutomaticoQrIntegrationTypes

let pixAutomaticoQrRequestToDictMapper = dict => {
  {
    client_id: dict->getString("client_id", ""),
    client_secret: dict->getString("client_secret", ""),
    pix_key_type: dict->getString("pix_key_type", ""),
    pix_key_value: dict->getString("pix_key_value", ""),
  }
}

let pixAutomaticoQrNameMapper = (~name) => {
  `metadata.pix_automatico_qr.${name}`
}

let pixAutomaticoQrFieldInput = (~pixAutomaticoQrField: CommonConnectorTypes.inputField, ~fill) => {
  open CommonConnectorHelper
  let {\"type", name} = pixAutomaticoQrField
  let formName = pixAutomaticoQrNameMapper(~name)

  {
    switch \"type" {
    | Text => textInput(~field={pixAutomaticoQrField}, ~formName)
    | Select => selectInput(~field={pixAutomaticoQrField}, ~formName)
    | MultiSelect => multiSelectInput(~field={pixAutomaticoQrField}, ~formName)
    | Radio => radioInput(~field={pixAutomaticoQrField}, ~formName, ~fill, ())
    | _ => textInput(~field={pixAutomaticoQrField}, ~formName)
    }
  }
}

let validatePixAutomaticoQrFields = (json: JSON.t) => {
  let fields =
    json
    ->getDictFromJsonObject
    ->getDictFromNestedDict("metadata", "pix_automatico_qr")
    ->pixAutomaticoQrRequestToDictMapper

  fields.client_id->isNonEmptyString &&
  fields.client_secret->isNonEmptyString &&
  fields.pix_key_type->isNonEmptyString &&
  fields.pix_key_value->isNonEmptyString
    ? Button.Normal
    : Button.Disabled
}
