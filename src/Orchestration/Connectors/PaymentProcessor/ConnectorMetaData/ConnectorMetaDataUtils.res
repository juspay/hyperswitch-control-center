let metaDataInputKeysToIgnore = ["google_pay", "apple_pay", "zen_apple_pay", "account_id"]
let connectorMetaDataNameMapper = name => {
  switch name {
  | _ => `metadata.${name}`
  }
}
let getField = (~inputType: CommonConnectorTypes.inputType, ~name, ~connectorMetaDataFields) => {
  open CommonConnectorHelper
  switch (inputType, name) {
  | (Select, "merchant_config_currency") => currencyField(~name)
  | (Text, _) => textInput(~field={connectorMetaDataFields}, ~formName=name)
  | (Number, _) => numberInput(~field={connectorMetaDataFields}, ~formName=name)
  | (Select, _) =>
    selectInput(~field={connectorMetaDataFields}, ~formName=name, ~fixedDropDownDirection=TopLeft)
  | (Toggle, _) => toggleInput(~field={connectorMetaDataFields}, ~formName=name)
  | (MultiSelect, _) => multiSelectInput(~field={connectorMetaDataFields}, ~formName=name)
  | _ => textInput(~field={connectorMetaDataFields}, ~formName=name)
  }
}

let connectorMetaDataValueInput = (~connectorMetaDataFields: CommonConnectorTypes.inputField) => {
  let {\"type": inputType, name} = connectorMetaDataFields
  let formName = connectorMetaDataNameMapper(name)

  getField(~inputType, ~name=formName, ~connectorMetaDataFields)
}

let validateMetadataRequiredFields = (~connector: ConnectorTypes.connectorTypes, ~values) => {
  switch connector {
  | Processors(PAYSAFE) => PaySafeUtils.payConnectorValidation(~values)
  | _ => Dict.make()
  }
}
