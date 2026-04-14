open LogicUtils
open PixAutomaticoIntegrationTypes

let pixAutomaticoRequestToDictMapper = dict => {
  {
    client_id: dict->getString("client_id", ""),
    client_secret: dict->getString("client_secret", ""),
    pix_key_type: dict->getString("pix_key_type", ""),
    pix_key_value: dict->getString("pix_key_value", ""),
  }
}

let pixAutomaticoNameMapper = (~metadataKey, ~name) => {
  `metadata.${metadataKey}.${name}`
}

let pixAutomaticoFieldInput = (
  ~metadataKey,
  ~pixAutomaticoField: CommonConnectorTypes.inputField,
  ~fill,
) => {
  open CommonConnectorHelper
  let {\"type", name} = pixAutomaticoField
  let formName = pixAutomaticoNameMapper(~metadataKey, ~name)

  {
    switch \"type" {
    | Text => textInput(~field={pixAutomaticoField}, ~formName)
    | Select => selectInput(~field={pixAutomaticoField}, ~formName)
    | MultiSelect => multiSelectInput(~field={pixAutomaticoField}, ~formName)
    | Radio => radioInput(~field={pixAutomaticoField}, ~formName, ~fill, ())
    | _ => textInput(~field={pixAutomaticoField}, ~formName)
    }
  }
}

let validatePixAutomaticoFields = (~metadataKey, json: JSON.t) => {
  let fields =
    json
    ->getDictFromJsonObject
    ->getDictFromNestedDict("metadata", metadataKey)
    ->pixAutomaticoRequestToDictMapper

  fields.client_id->isNonEmptyString &&
  fields.client_secret->isNonEmptyString &&
  fields.pix_key_type->isNonEmptyString &&
  fields.pix_key_value->isNonEmptyString
    ? Button.Normal
    : Button.Disabled
}
