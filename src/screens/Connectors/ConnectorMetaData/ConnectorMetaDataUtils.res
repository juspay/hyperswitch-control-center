let metaDataInputKeysToIgnore = ["google_pay", "apple_pay", "zen_apple_pay"]
let connectorMetaDataNameMapper = name => {
  switch name {
  | _ => `metadata.${name}`
  }
}

let connectorMetaDataValueInput = (~connectorMetaDataFields: CommonMetaDataTypes.inputField) => {
  open CommonMetaDataHelper
  let {\"type", name} = connectorMetaDataFields
  let formName = connectorMetaDataNameMapper(name)

  {
    switch (\"type", name) {
    | (Select, "merchant_config_currency") => currencyField(~name=formName, ())
    | (Text, _) => textInput(~field={connectorMetaDataFields}, ~formName)
    | (Select, _) => selectInput(~field={connectorMetaDataFields}, ~formName, ())
    | (Toggle, _) => toggleInput(~field={connectorMetaDataFields}, ~formName)
    | (MultiSelect, _) => multiSelectInput(~field={connectorMetaDataFields}, ~formName)
    | _ => textInput(~field={connectorMetaDataFields}, ~formName)
    }
  }
}
