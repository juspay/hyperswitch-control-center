open LogicUtils
open PixQrIntegrationTypes

let pixQrRequestToDictMapper = dict => {
  {
    client_id: dict->getString("client_id", ""),
    client_secret: dict->getString("client_secret", ""),
    pix_key_value: dict->getString("pix_key_value", ""),
    pix_key_type: dict->getString("pix_key_type", ""),
    merchant_city: dict->getString("merchant_city", ""),
    merchant_name: dict->getString("merchant_name", ""),
  }
}

let pixQrNameMapper = (~name) => {
  `metadata.pix_qr.${name}`
}

let pixQrFieldInput = (~pixQrField: CommonConnectorTypes.inputField, ~fill) => {
  open CommonConnectorHelper
  let {\"type", name} = pixQrField
  let formName = pixQrNameMapper(~name)

  {
    switch \"type" {
    | Text => textInput(~field={pixQrField}, ~formName)
    | Select => selectInput(~field={pixQrField}, ~formName)
    | MultiSelect => multiSelectInput(~field={pixQrField}, ~formName)
    | Radio => radioInput(~field={pixQrField}, ~formName, ~fill, ())
    | _ => textInput(~field={pixQrField}, ~formName)
    }
  }
}

let validatePixQrFields = (json: JSON.t) => {
  let pixQrFields =
    json
    ->getDictFromJsonObject
    ->getDictFromNestedDict("metadata", "pix_qr")
    ->pixQrRequestToDictMapper

  pixQrFields.client_id->isNonEmptyString &&
  pixQrFields.client_secret->isNonEmptyString &&
  pixQrFields.pix_key_value->isNonEmptyString &&
  pixQrFields.pix_key_type->isNonEmptyString &&
  pixQrFields.merchant_city->isNonEmptyString &&
  pixQrFields.merchant_name->isNonEmptyString
    ? Button.Normal
    : Button.Disabled
}
