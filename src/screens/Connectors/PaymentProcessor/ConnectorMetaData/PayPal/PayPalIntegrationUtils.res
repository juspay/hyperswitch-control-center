open LogicUtils
open PayPalIntegrationTypes

let paypalNameMapper = (~name) => {
  `metadata.paypal_sdk.${name}`
}

let paypalRequestToDictMapper = dict => {
  {
    client_id: dict->getString("client_id", ""),
  }
}

let paypalFieldInput = (~paypalField: CommonConnectorTypes.inputField, ~fill) => {
  open CommonConnectorHelper
  let {\"type", name} = paypalField
  let formName = paypalNameMapper(~name)

  {
    switch \"type" {
    | Text => textInput(~field={paypalField}, ~formName)
    | Select => selectInput(~field={paypalField}, ~formName)
    | MultiSelect => multiSelectInput(~field={paypalField}, ~formName)
    | Radio => radioInput(~field={paypalField}, ~formName, ~fill, ())
    | _ => textInput(~field={paypalField}, ~formName)
    }
  }
}

let validatePayPalFields = (json: JSON.t) => {
  let paypalFields =
    json
    ->getDictFromJsonObject
    ->getDictFromNestedDict("metadata", "paypal_sdk")
    ->paypalRequestToDictMapper

  paypalFields.client_id->isNonEmptyString ? Button.Normal : Button.Disabled
}
