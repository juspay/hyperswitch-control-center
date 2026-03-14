open LogicUtils
open PixIntegrationTypes

let pixRequestToDictMapper = dict => {
  {
    client_id: dict->getString("client_id", ""),
    client_secret: dict->getString("client_secret", ""),
    pix_key_value: dict->getString("pix_key_value", ""),
    pix_key_type: dict->getString("pix_key_type", ""),
    merchant_city: dict->getString("merchant_city", ""),
    merchant_name: dict->getString("merchant_name", ""),
  }
}

let pixNameMapper = (~name) => {
  `metadata.pix.${name}`
}

let pixFieldInput = (~pixField: CommonConnectorTypes.inputField, ~fill) => {
  open CommonConnectorHelper
  let {\"type", name} = pixField
  let formName = pixNameMapper(~name)

  {
    switch \"type" {
    | Text => textInput(~field={pixField}, ~formName)
    | Select => selectInput(~field={pixField}, ~formName)
    | MultiSelect => multiSelectInput(~field={pixField}, ~formName)
    | Radio => radioInput(~field={pixField}, ~formName, ~fill, ())
    | _ => textInput(~field={pixField}, ~formName)
    }
  }
}

let validatePixFields = (json: JSON.t) => {
  let pixFields =
    json->getDictFromJsonObject->getDictFromNestedDict("metadata", "pix")->pixRequestToDictMapper

  pixFields.client_id->isNonEmptyString &&
  pixFields.client_secret->isNonEmptyString &&
  pixFields.pix_key_value->isNonEmptyString &&
  pixFields.pix_key_type->isNonEmptyString &&
  pixFields.merchant_city->isNonEmptyString &&
  pixFields.merchant_name->isNonEmptyString
    ? Button.Normal
    : Button.Disabled
}
