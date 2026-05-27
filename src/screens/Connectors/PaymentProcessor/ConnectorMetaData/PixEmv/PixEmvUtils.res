open LogicUtils
open PixEmvIntegrationTypes

let pixEmvRequestToDictMapper = dict => {
  {
    client_id: dict->getString("client_id", ""),
    client_secret: dict->getString("client_secret", ""),
    pix_key_value: dict->getString("pix_key_value", ""),
    pix_key_type: dict->getString("pix_key_type", ""),
    merchant_city: dict->getString("merchant_city", ""),
    merchant_name: dict->getString("merchant_name", ""),
  }
}

let pixEmvNameMapper = (~name) => {
  `metadata.pix_emv.${name}`
}

let pixEmvFieldInput = (~pixEmvField: CommonConnectorTypes.inputField, ~fill) => {
  open CommonConnectorHelper
  let {\"type", name} = pixEmvField
  let formName = pixEmvNameMapper(~name)

  {
    switch \"type" {
    | Text => textInput(~field={pixEmvField}, ~formName)
    | Select => selectInput(~field={pixEmvField}, ~formName)
    | MultiSelect => multiSelectInput(~field={pixEmvField}, ~formName)
    | Radio => radioInput(~field={pixEmvField}, ~formName, ~fill, ())
    | _ => textInput(~field={pixEmvField}, ~formName)
    }
  }
}

let validatePixEmvFields = (json: JSON.t) => {
  let pixEmvFields =
    json->getDictFromJsonObject->getDictFromNestedDict("metadata", "pix_emv")->pixEmvRequestToDictMapper

  pixEmvFields.client_id->isNonEmptyString &&
  pixEmvFields.client_secret->isNonEmptyString &&
  pixEmvFields.pix_key_value->isNonEmptyString &&
  pixEmvFields.pix_key_type->isNonEmptyString &&
  pixEmvFields.merchant_city->isNonEmptyString &&
  pixEmvFields.merchant_name->isNonEmptyString
    ? Button.Normal
    : Button.Disabled
}
