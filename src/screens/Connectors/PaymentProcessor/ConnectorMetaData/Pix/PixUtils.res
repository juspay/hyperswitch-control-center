open LogicUtils
open PixIntegrationTypes

let pixrequestToDictMapper = dict => {
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

let amazonPayValueInput = (~amazonPayField: CommonConnectorTypes.inputField, ~fill) => {
  open CommonConnectorHelper
  let {\"type", name} = amazonPayField
  let formName = pixNameMapper(~name)

  {
    switch \"type" {
    | Text => textInput(~field={amazonPayField}, ~formName)
    | Select => selectInput(~field={amazonPayField}, ~formName)
    | MultiSelect => multiSelectInput(~field={amazonPayField}, ~formName)
    | Radio => radioInput(~field={amazonPayField}, ~formName, ~fill, ())
    | _ => textInput(~field={amazonPayField}, ~formName)
    }
  }
}

let validatePixFields = (json: JSON.t) => {
  let {client_id, client_secret, pix_key_value, pix_key_type, merchant_city, merchant_name} =
    json
    ->getDictFromJsonObject
    ->getDictfromDict("metadata")
    ->getDictfromDict("pix")
    ->pixrequestToDictMapper

  let isClientIdValid = client_id->isNonEmptyString
  let isClientSecretValid = client_secret->isNonEmptyString
  let isPixKeyValueValid = pix_key_value->isNonEmptyString
  let isPixKeyTypeValid = pix_key_type->isNonEmptyString
  let isMerchantCityValid = merchant_city->isNonEmptyString
  let isMerchantNameValid = merchant_name->isNonEmptyString

  isClientIdValid &&
  isClientSecretValid &&
  isPixKeyValueValid &&
  isPixKeyTypeValid &&
  isMerchantCityValid &&
  isMerchantNameValid
    ? Button.Normal
    : Button.Disabled
}
