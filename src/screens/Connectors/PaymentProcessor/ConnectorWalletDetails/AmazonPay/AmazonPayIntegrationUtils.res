open LogicUtils
open AmazonPayIntegrationTypes

let amazonPayRequest = dict => {
  {
    merchant_id: dict->getString("merchant_id", ""),
    store_id: dict->getString("store_id", ""),
  }
}

let amazonPayNameMapper = (~name) => {
  `connector_wallets_details.amazon_pay.${name}`
}

let amazonPayValueInput = (~amazonPayField: CommonConnectorTypes.inputField, ~fill) => {
  open CommonConnectorHelper
  let {\"type", name} = amazonPayField
  let formName = amazonPayNameMapper(~name)

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

let validateAmazonPay = (json: JSON.t) => {
  let {merchant_id, store_id} =
    json
    ->getDictFromJsonObject
    ->getDictfromDict("connector_wallets_details")
    ->getDictfromDict("amazon_pay")
    ->amazonPayRequest

  let isMerchantIdValid = merchant_id->String.length > 0
  let isStoreIdValid = store_id->String.length > 0

  if isMerchantIdValid && isStoreIdValid {
    Button.Normal
  } else {
    Button.Disabled
  }
}
