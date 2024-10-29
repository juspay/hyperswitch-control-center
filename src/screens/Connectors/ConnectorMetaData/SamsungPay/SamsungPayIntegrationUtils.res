open SamsungPayIntegrationTypes
open LogicUtils

let samsungPayRequest = dict => {
  merchant_business_country: dict->getString("merchant_business_country", ""),
  merchant_display_name: dict->getString("merchant_display_name", ""),
  service_id: dict->getString("service_id", ""),
  allowed_brands: dict->getStrArrayFromDict(
    "allowed_brands",
    ["visa", "masterCard", "amex", "discover"],
  ),
}

let samsungPayNameMapper = (~name) => {
  `connector_wallets_details.samsung_pay.merchant_credentials.${name}`
}

let samsungPayValueInput = (~samsungPayField: CommonConnectorTypes.inputField, ~fill) => {
  open CommonConnectorHelper
  let {\"type", name} = samsungPayField
  let formName = samsungPayNameMapper(~name)

  {
    switch \"type" {
    | Text => textInput(~field={samsungPayField}, ~formName)
    | Select => selectInput(~field={samsungPayField}, ~formName)
    | MultiSelect => multiSelectInput(~field={samsungPayField}, ~formName)
    | Radio => radioInput(~field={samsungPayField}, ~formName, ~fill, ())
    | _ => textInput(~field={samsungPayField}, ~formName)
    }
  }
}

let validateSamsungPay = (json: JSON.t) => {
  let {merchant_business_country, merchant_display_name, service_id, allowed_brands} =
    getDictFromJsonObject(json)
    ->getDictfromDict("connector_wallets_details")
    ->getDictfromDict("samsung_pay")
    ->getDictfromDict("merchant_credentials")
    ->samsungPayRequest
  merchant_business_country->isNonEmptyString &&
  merchant_display_name->isNonEmptyString &&
  service_id->isNonEmptyString &&
  allowed_brands->Array.length > 0
    ? Button.Normal
    : Button.Disabled
}
